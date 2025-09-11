-- ================================================
-- ERP TN Group - Vector Database Initialization
-- Setup pgvector extension và example tables
-- ================================================

-- Enable pgvector extension
CREATE EXTENSION IF NOT EXISTS vector;

-- Enable other useful extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "btree_gin";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- ================================================
-- VECTOR DATABASE SCHEMA
-- ================================================

-- Create schema for vector operations
CREATE SCHEMA IF NOT EXISTS vector_db;

-- ================================================
-- EXAMPLE: DOCUMENT EMBEDDINGS TABLE
-- ================================================

-- Table để lưu trữ document embeddings (OpenAI, Cohere, etc.)
CREATE TABLE IF NOT EXISTS vector_db.document_embeddings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    document_id VARCHAR(255) NOT NULL,
    title TEXT,
    content TEXT,
    content_hash VARCHAR(64),
    -- Vector embedding (1536 dimensions for OpenAI Ada-002)
    embedding vector(1536),
    metadata JSONB DEFAULT '{}',
    source VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Index cho similarity search
CREATE INDEX IF NOT EXISTS idx_document_embeddings_vector 
ON vector_db.document_embeddings 
USING ivfflat (embedding vector_cosine_ops) 
WITH (lists = 100);

-- Index cho metadata search
CREATE INDEX IF NOT EXISTS idx_document_embeddings_metadata 
ON vector_db.document_embeddings 
USING gin (metadata);

-- Index cho full-text search
CREATE INDEX IF NOT EXISTS idx_document_embeddings_content 
ON vector_db.document_embeddings 
USING gin (to_tsvector('english', content));

-- ================================================
-- EXAMPLE: PRODUCT EMBEDDINGS TABLE
-- ================================================

-- Table cho product recommendations
CREATE TABLE IF NOT EXISTS vector_db.product_embeddings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id VARCHAR(255) NOT NULL UNIQUE,
    product_name TEXT NOT NULL,
    description TEXT,
    category VARCHAR(255),
    price DECIMAL(10,2),
    -- Vector embedding (384 dimensions for sentence-transformers)
    embedding vector(384),
    features JSONB DEFAULT '{}',
    tags TEXT[],
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Index cho product similarity
CREATE INDEX IF NOT EXISTS idx_product_embeddings_vector 
ON vector_db.product_embeddings 
USING ivfflat (embedding vector_cosine_ops) 
WITH (lists = 50);

-- ================================================
-- EXAMPLE: USER BEHAVIOR EMBEDDINGS
-- ================================================

-- Table cho user behavior analysis
CREATE TABLE IF NOT EXISTS vector_db.user_behavior_embeddings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id VARCHAR(255) NOT NULL,
    session_id VARCHAR(255),
    behavior_type VARCHAR(100), -- 'purchase', 'view', 'search', etc.
    -- Vector embedding cho user behavior pattern
    embedding vector(256),
    context_data JSONB DEFAULT '{}',
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Index cho user similarity
CREATE INDEX IF NOT EXISTS idx_user_behavior_vector 
ON vector_db.user_behavior_embeddings 
USING ivfflat (embedding vector_cosine_ops) 
WITH (lists = 30);

-- ================================================
-- VECTOR SEARCH FUNCTIONS
-- ================================================

-- Function: Similarity search cho documents
CREATE OR REPLACE FUNCTION vector_db.search_similar_documents(
    query_embedding vector(1536),
    similarity_threshold float DEFAULT 0.8,
    max_results int DEFAULT 10
)
RETURNS TABLE (
    document_id VARCHAR(255),
    title TEXT,
    similarity FLOAT,
    content TEXT,
    metadata JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        de.document_id,
        de.title,
        1 - (de.embedding <=> query_embedding) AS similarity,
        de.content,
        de.metadata
    FROM vector_db.document_embeddings de
    WHERE 1 - (de.embedding <=> query_embedding) > similarity_threshold
    ORDER BY de.embedding <=> query_embedding
    LIMIT max_results;
END;
$$ LANGUAGE plpgsql;

-- Function: Product recommendations
CREATE OR REPLACE FUNCTION vector_db.get_product_recommendations(
    input_product_id VARCHAR(255),
    max_results int DEFAULT 5
)
RETURNS TABLE (
    product_id VARCHAR(255),
    product_name TEXT,
    similarity FLOAT,
    category VARCHAR(255),
    price DECIMAL(10,2)
) AS $$
DECLARE
    input_embedding vector(384);
BEGIN
    -- Get embedding của sản phẩm input
    SELECT embedding INTO input_embedding
    FROM vector_db.product_embeddings
    WHERE product_embeddings.product_id = input_product_id;
    
    IF input_embedding IS NULL THEN
        RAISE EXCEPTION 'Product not found: %', input_product_id;
    END IF;
    
    RETURN QUERY
    SELECT 
        pe.product_id,
        pe.product_name,
        1 - (pe.embedding <=> input_embedding) AS similarity,
        pe.category,
        pe.price
    FROM vector_db.product_embeddings pe
    WHERE pe.product_id != input_product_id
      AND pe.is_active = true
    ORDER BY pe.embedding <=> input_embedding
    LIMIT max_results;
END;
$$ LANGUAGE plpgsql;

-- Function: Hybrid search (vector + text)
CREATE OR REPLACE FUNCTION vector_db.hybrid_document_search(
    query_text TEXT,
    query_embedding vector(1536),
    text_weight FLOAT DEFAULT 0.3,
    vector_weight FLOAT DEFAULT 0.7,
    max_results int DEFAULT 10
)
RETURNS TABLE (
    document_id VARCHAR(255),
    title TEXT,
    combined_score FLOAT,
    text_score FLOAT,
    vector_score FLOAT,
    content TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        de.document_id,
        de.title,
        (text_weight * ts_rank_cd(to_tsvector('english', de.content), plainto_tsquery('english', query_text)) + 
         vector_weight * (1 - (de.embedding <=> query_embedding))) AS combined_score,
        ts_rank_cd(to_tsvector('english', de.content), plainto_tsquery('english', query_text)) AS text_score,
        1 - (de.embedding <=> query_embedding) AS vector_score,
        de.content
    FROM vector_db.document_embeddings de
    WHERE de.content IS NOT NULL
    ORDER BY combined_score DESC
    LIMIT max_results;
END;
$$ LANGUAGE plpgsql;

-- ================================================
-- VECTOR ANALYTICS VIEWS
-- ================================================

-- View: Document statistics
CREATE OR REPLACE VIEW vector_db.document_stats AS
SELECT 
    COUNT(*) as total_documents,
    COUNT(DISTINCT source) as unique_sources,
    AVG(vector_dims(embedding)) as avg_embedding_dims,
    MIN(created_at) as first_document,
    MAX(created_at) as latest_document
FROM vector_db.document_embeddings;

-- View: Product statistics
CREATE OR REPLACE VIEW vector_db.product_stats AS
SELECT 
    COUNT(*) as total_products,
    COUNT(DISTINCT category) as unique_categories,
    AVG(price) as avg_price,
    COUNT(*) FILTER (WHERE is_active = true) as active_products
FROM vector_db.product_embeddings;

-- ================================================
-- SAMPLE DATA (Optional)
-- ================================================

-- Insert sample document embeddings (với random vectors for demo)
INSERT INTO vector_db.document_embeddings (document_id, title, content, source, embedding)
VALUES 
(
    'doc_001',
    'Introduction to Vector Databases',
    'Vector databases are specialized databases designed to store and query high-dimensional vectors efficiently.',
    'documentation',
    -- Random vector for demo (thực tế sẽ được tạo bởi AI model)
    (SELECT ARRAY(SELECT random() FROM generate_series(1, 1536))::vector)
),
(
    'doc_002', 
    'PostgreSQL pgvector Extension',
    'The pgvector extension adds vector similarity search to PostgreSQL, enabling AI and machine learning applications.',
    'documentation',
    (SELECT ARRAY(SELECT random() FROM generate_series(1, 1536))::vector)
);

-- Insert sample products
INSERT INTO vector_db.product_embeddings (product_id, product_name, description, category, price, embedding)
VALUES
(
    'prod_001',
    'Laptop Gaming ROG',
    'High-performance gaming laptop with RTX graphics',
    'Electronics',
    1299.99,
    (SELECT ARRAY(SELECT random() FROM generate_series(1, 384))::vector)
),
(
    'prod_002',
    'iPhone 15 Pro',
    'Latest smartphone with advanced camera system',
    'Electronics', 
    999.99,
    (SELECT ARRAY(SELECT random() FROM generate_series(1, 384))::vector)
);

-- ================================================
-- PERMISSIONS
-- ================================================

-- Grant permissions cho vector operations
GRANT USAGE ON SCHEMA vector_db TO PUBLIC;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA vector_db TO PUBLIC;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA vector_db TO PUBLIC;

-- Log vector database initialization
INSERT INTO backup_history (backup_name, backup_type, notes) 
VALUES ('vector_db_init', 'system', 'Vector database initialized with pgvector extension')
ON CONFLICT DO NOTHING;

-- Display success message
DO $$
BEGIN
    RAISE NOTICE '🧠 Vector Database initialized successfully!';
    RAISE NOTICE '📊 Extensions: pgvector, uuid-ossp, btree_gin, pg_trgm';
    RAISE NOTICE '🗃️  Schema: vector_db with sample tables';
    RAISE NOTICE '🔍 Functions: similarity search, recommendations, hybrid search';
    RAISE NOTICE '📈 Views: document_stats, product_stats';
END $$;
