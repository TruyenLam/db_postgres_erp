@echo off
REM ================================================
REM ERP TN Group - Vector Database Management
REM Quản lý Vector Database và AI operations
REM ================================================

:menu
cls
echo ================================================
echo     🧠 ERP TN Group - Vector Database Manager
echo ================================================
echo.
echo 1. Vector Database Status
echo 2. Create Vector Indexes
echo 3. Test Similarity Search
echo 4. Insert Sample Embeddings
echo 5. Vector Database Statistics
echo 6. Backup Vector Data
echo 7. Vector Search Performance Test
echo 8. AI/ML Integration Test
echo 9. Exit
echo.
set /p choice=Choose option (1-9): 

if "%choice%"=="1" goto vector_status
if "%choice%"=="2" goto create_indexes
if "%choice%"=="3" goto test_search
if "%choice%"=="4" goto insert_samples
if "%choice%"=="5" goto vector_stats
if "%choice%"=="6" goto backup_vector
if "%choice%"=="7" goto performance_test
if "%choice%"=="8" goto ai_integration
if "%choice%"=="9" goto exit

echo Invalid option!
pause
goto menu

:vector_status
echo.
echo ================================================
echo           🔍 Vector Database Status
echo ================================================

echo 📊 Checking pgvector extension...
docker-compose exec postgres_secure psql -U %POSTGRES_USER% -d %POSTGRES_DB% -c "SELECT extname, extversion FROM pg_extension WHERE extname = 'vector';"

echo.
echo 📊 Vector tables:
docker-compose exec postgres_secure psql -U %POSTGRES_USER% -d %POSTGRES_DB% -c "SELECT schemaname, tablename FROM pg_tables WHERE schemaname = 'vector_db';"

echo.
echo 📊 Vector indexes:
docker-compose exec postgres_secure psql -U %POSTGRES_USER% -d %POSTGRES_DB% -c "SELECT indexname, tablename FROM pg_indexes WHERE indexname LIKE '%%vector%%';"

pause
goto menu

:create_indexes
echo.
echo 🔧 Creating vector indexes...

docker-compose exec postgres_secure psql -U %POSTGRES_USER% -d %POSTGRES_DB% -c "
-- Recreate indexes with optimal settings
DROP INDEX IF EXISTS vector_db.idx_document_embeddings_vector;
DROP INDEX IF EXISTS vector_db.idx_product_embeddings_vector;
DROP INDEX IF EXISTS vector_db.idx_user_behavior_vector;

-- Create optimized IVFFLAT indexes
CREATE INDEX idx_document_embeddings_vector 
ON vector_db.document_embeddings 
USING ivfflat (embedding vector_cosine_ops) 
WITH (lists = 100);

CREATE INDEX idx_product_embeddings_vector 
ON vector_db.product_embeddings 
USING ivfflat (embedding vector_cosine_ops) 
WITH (lists = 50);

CREATE INDEX idx_user_behavior_vector 
ON vector_db.user_behavior_embeddings 
USING ivfflat (embedding vector_cosine_ops) 
WITH (lists = 30);

SELECT 'Vector indexes created successfully!' as result;
"

echo ✅ Vector indexes created!
pause
goto menu

:test_search
echo.
echo 🔍 Testing similarity search...

docker-compose exec postgres_secure psql -U %POSTGRES_USER% -d %POSTGRES_DB% -c "
-- Test document similarity search
SELECT 'Testing document similarity search...' as test;

WITH random_query AS (
    SELECT (SELECT ARRAY(SELECT random() FROM generate_series(1, 1536)))::vector as query_vector
)
SELECT 
    document_id,
    title,
    similarity,
    LEFT(content, 100) || '...' as content_preview
FROM vector_db.search_similar_documents(
    (SELECT query_vector FROM random_query),
    0.0,  -- Low threshold for demo
    3     -- Max results
);
"

echo.
echo 🛍️ Testing product recommendations...

docker-compose exec postgres_secure psql -U %POSTGRES_USER% -d %POSTGRES_DB% -c "
-- Test product recommendations
SELECT 'Testing product recommendations...' as test;

SELECT * FROM vector_db.get_product_recommendations('prod_001', 5);
"

pause
goto menu

:insert_samples
echo.
echo 📥 Inserting sample embeddings...

docker-compose exec postgres_secure psql -U %POSTGRES_USER% -d %POSTGRES_DB% -c "
-- Insert more sample documents
INSERT INTO vector_db.document_embeddings (document_id, title, content, source, embedding)
VALUES 
('doc_' || generate_random_uuid()::text, 
 'Sample Document ' || floor(random() * 1000)::text,
 'This is sample content for testing vector similarity search with various topics and keywords.',
 'generated',
 (SELECT ARRAY(SELECT random() FROM generate_series(1, 1536)))::vector)
FROM generate_series(1, 10);

-- Insert more sample products  
INSERT INTO vector_db.product_embeddings (product_id, product_name, description, category, price, embedding)
VALUES 
('prod_' || generate_random_uuid()::text,
 'Product ' || floor(random() * 1000)::text,
 'Sample product description with various features and specifications.',
 (ARRAY['Electronics', 'Fashion', 'Books', 'Sports'])[floor(random() * 4 + 1)],
 round((random() * 1000 + 10)::numeric, 2),
 (SELECT ARRAY(SELECT random() FROM generate_series(1, 384)))::vector)
FROM generate_series(1, 20);

SELECT 'Sample embeddings inserted successfully!' as result;
"

echo ✅ Sample data inserted!
pause
goto menu

:vector_stats
echo.
echo ================================================
echo         📊 Vector Database Statistics
echo ================================================

docker-compose exec postgres_secure psql -U %POSTGRES_USER% -d %POSTGRES_DB% -c "
-- Document statistics
SELECT 'DOCUMENT STATISTICS' as category, * FROM vector_db.document_stats;

-- Product statistics  
SELECT 'PRODUCT STATISTICS' as category, * FROM vector_db.product_stats;

-- Index usage statistics
SELECT 
    'INDEX USAGE' as category,
    schemaname,
    tablename,
    indexname,
    idx_tup_read,
    idx_tup_fetch
FROM pg_stat_user_indexes 
WHERE indexname LIKE '%%vector%%';

-- Table sizes
SELECT 
    'TABLE SIZES' as category,
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size
FROM pg_tables 
WHERE schemaname = 'vector_db';
"

pause
goto menu

:backup_vector
echo.
echo 💾 Backing up vector database...

docker-compose exec postgres_secure pg_dump -U %POSTGRES_USER% -d %POSTGRES_DB% --schema=vector_db --format=custom > volumes/backups/vector_db_backup_%date:~-4,4%%date:~-10,2%%date:~-7,2%.dump

echo ✅ Vector database backed up!
pause
goto menu

:performance_test
echo.
echo ⚡ Running vector search performance test...

docker-compose exec postgres_secure psql -U %POSTGRES_USER% -d %POSTGRES_DB% -c "
-- Performance test
EXPLAIN (ANALYZE, BUFFERS) 
SELECT document_id, title, 1 - (embedding <=> (SELECT ARRAY(SELECT random() FROM generate_series(1, 1536)))::vector) as similarity
FROM vector_db.document_embeddings
ORDER BY embedding <=> (SELECT ARRAY(SELECT random() FROM generate_series(1, 1536)))::vector
LIMIT 10;
"

pause
goto menu

:ai_integration
echo.
echo 🤖 AI/ML Integration Test...

echo 📝 Example: How to integrate with AI models:
echo.
echo 1. OpenAI Integration:
echo    curl -X POST https://api.openai.com/v1/embeddings \
echo         -H "Authorization: Bearer YOUR_API_KEY" \
echo         -d '{"input": "Your text here", "model": "text-embedding-ada-002"}'
echo.
echo 2. Insert embedding vào database:
echo    INSERT INTO vector_db.document_embeddings (document_id, title, content, embedding)
echo    VALUES ('doc_id', 'title', 'content', '[embedding_array]'::vector);
echo.
echo 3. Search similar documents:
echo    SELECT * FROM vector_db.search_similar_documents('[query_embedding]'::vector, 0.8, 10);
echo.

echo 🔧 Vector database functions available:
docker-compose exec postgres_secure psql -U %POSTGRES_USER% -d %POSTGRES_DB% -c "
SELECT routine_name, routine_type 
FROM information_schema.routines 
WHERE routine_schema = 'vector_db'
ORDER BY routine_name;
"

pause
goto menu

:exit
echo.
echo 🧠 Vector Database management completed!
echo.
echo 📋 Available Features:
echo ✅ pgvector extension enabled
echo ✅ Document embeddings with similarity search
echo ✅ Product recommendations system
echo ✅ User behavior analysis
echo ✅ Hybrid search (text + vector)
echo ✅ Vector analytics and monitoring
echo.
echo 🤖 Ready for AI/ML integration!
echo.
exit
