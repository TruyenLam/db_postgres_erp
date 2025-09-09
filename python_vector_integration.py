#!/usr/bin/env python3
"""
ERP TN Group - Vector Database Python Integration
AI/ML integration với PostgreSQL + pgvector

Author: Lam Van Truyen
Email: lamvantruyen@gmail.com
Website: shareapiai.com
"""

import psycopg2
import numpy as np
import json
from typing import List, Dict, Any, Optional
import os
from datetime import datetime

class ERPVectorDB:
    """
    ERP TN Group Vector Database Manager
    
    Provides Python interface cho vector operations trong PostgreSQL
    """
    
    def __init__(self, 
                 host: str = "localhost", 
                 port: int = 5432,
                 database: str = "erp_tngroup", 
                 user: str = "erp_admin", 
                 password: str = None):
        """
        Initialize database connection
        
        Args:
            host: Database host
            port: Database port  
            database: Database name
            user: Database user
            password: Database password (từ environment nếu None)
        """
        self.host = host
        self.port = port
        self.database = database
        self.user = user
        self.password = password or os.getenv('POSTGRES_PASSWORD')
        self.conn = None
        
    def connect(self):
        """Establish database connection"""
        try:
            self.conn = psycopg2.connect(
                host=self.host,
                port=self.port,
                database=self.database,
                user=self.user,
                password=self.password
            )
            print(f"✅ Connected to ERP Vector Database at {self.host}:{self.port}")
            return True
        except Exception as e:
            print(f"❌ Database connection failed: {e}")
            return False
    
    def disconnect(self):
        """Close database connection"""
        if self.conn:
            self.conn.close()
            print("🔌 Database connection closed")
    
    def insert_document_embedding(self, 
                                document_id: str,
                                title: str,
                                content: str,
                                embedding: List[float],
                                source: str = "api",
                                metadata: Dict = None) -> bool:
        """
        Insert document embedding vào database
        
        Args:
            document_id: Unique document identifier
            title: Document title
            content: Document content
            embedding: Vector embedding (list of floats)
            source: Data source
            metadata: Additional metadata
            
        Returns:
            bool: Success status
        """
        try:
            with self.conn.cursor() as cur:
                cur.execute("""
                    INSERT INTO vector_db.document_embeddings 
                    (document_id, title, content, embedding, source, metadata)
                    VALUES (%s, %s, %s, %s, %s, %s)
                    ON CONFLICT (document_id) DO UPDATE SET
                        title = EXCLUDED.title,
                        content = EXCLUDED.content,
                        embedding = EXCLUDED.embedding,
                        metadata = EXCLUDED.metadata,
                        updated_at = CURRENT_TIMESTAMP
                """, (document_id, title, content, embedding, source, json.dumps(metadata or {})))
                
                self.conn.commit()
                print(f"✅ Document embedding inserted: {document_id}")
                return True
                
        except Exception as e:
            print(f"❌ Failed to insert document embedding: {e}")
            self.conn.rollback()
            return False
    
    def search_similar_documents(self, 
                               query_embedding: List[float],
                               threshold: float = 0.8,
                               limit: int = 10) -> List[Dict]:
        """
        Search similar documents using vector similarity
        
        Args:
            query_embedding: Query vector
            threshold: Similarity threshold (0-1)
            limit: Maximum results
            
        Returns:
            List of similar documents với similarity scores
        """
        try:
            with self.conn.cursor() as cur:
                cur.execute("""
                    SELECT * FROM vector_db.search_similar_documents(%s, %s, %s)
                """, (query_embedding, threshold, limit))
                
                results = []
                for row in cur.fetchall():
                    results.append({
                        'document_id': row[0],
                        'title': row[1], 
                        'similarity': float(row[2]),
                        'content': row[3],
                        'metadata': row[4]
                    })
                
                print(f"🔍 Found {len(results)} similar documents")
                return results
                
        except Exception as e:
            print(f"❌ Search failed: {e}")
            return []
    
    def insert_product_embedding(self,
                               product_id: str,
                               product_name: str,
                               description: str,
                               category: str,
                               price: float,
                               embedding: List[float],
                               features: Dict = None) -> bool:
        """
        Insert product embedding cho recommendation system
        
        Args:
            product_id: Unique product identifier
            product_name: Product name
            description: Product description
            category: Product category
            price: Product price
            embedding: Vector embedding
            features: Product features
            
        Returns:
            bool: Success status
        """
        try:
            with self.conn.cursor() as cur:
                cur.execute("""
                    INSERT INTO vector_db.product_embeddings 
                    (product_id, product_name, description, category, price, embedding, features)
                    VALUES (%s, %s, %s, %s, %s, %s, %s)
                    ON CONFLICT (product_id) DO UPDATE SET
                        product_name = EXCLUDED.product_name,
                        description = EXCLUDED.description,
                        category = EXCLUDED.category,
                        price = EXCLUDED.price,
                        embedding = EXCLUDED.embedding,
                        features = EXCLUDED.features,
                        updated_at = CURRENT_TIMESTAMP
                """, (product_id, product_name, description, category, price, 
                     embedding, json.dumps(features or {})))
                
                self.conn.commit()
                print(f"✅ Product embedding inserted: {product_id}")
                return True
                
        except Exception as e:
            print(f"❌ Failed to insert product embedding: {e}")
            self.conn.rollback()
            return False
    
    def get_product_recommendations(self, 
                                  product_id: str,
                                  limit: int = 5) -> List[Dict]:
        """
        Get product recommendations based on similarity
        
        Args:
            product_id: Reference product ID
            limit: Maximum recommendations
            
        Returns:
            List of recommended products
        """
        try:
            with self.conn.cursor() as cur:
                cur.execute("""
                    SELECT * FROM vector_db.get_product_recommendations(%s, %s)
                """, (product_id, limit))
                
                results = []
                for row in cur.fetchall():
                    results.append({
                        'product_id': row[0],
                        'product_name': row[1],
                        'similarity': float(row[2]),
                        'category': row[3],
                        'price': float(row[4]) if row[4] else None
                    })
                
                print(f"🛍️ Found {len(results)} product recommendations")
                return results
                
        except Exception as e:
            print(f"❌ Recommendation failed: {e}")
            return []
    
    def hybrid_search(self,
                     query_text: str,
                     query_embedding: List[float],
                     text_weight: float = 0.3,
                     vector_weight: float = 0.7,
                     limit: int = 10) -> List[Dict]:
        """
        Hybrid search combining text search và vector similarity
        
        Args:
            query_text: Text query
            query_embedding: Vector query
            text_weight: Weight for text search (0-1)
            vector_weight: Weight for vector search (0-1)
            limit: Maximum results
            
        Returns:
            List of search results với combined scores
        """
        try:
            with self.conn.cursor() as cur:
                cur.execute("""
                    SELECT * FROM vector_db.hybrid_document_search(%s, %s, %s, %s, %s)
                """, (query_text, query_embedding, text_weight, vector_weight, limit))
                
                results = []
                for row in cur.fetchall():
                    results.append({
                        'document_id': row[0],
                        'title': row[1],
                        'combined_score': float(row[2]),
                        'text_score': float(row[3]),
                        'vector_score': float(row[4]),
                        'content': row[5]
                    })
                
                print(f"🔍 Hybrid search found {len(results)} results")
                return results
                
        except Exception as e:
            print(f"❌ Hybrid search failed: {e}")
            return []
    
    def get_vector_stats(self) -> Dict:
        """
        Get vector database statistics
        
        Returns:
            Dictionary với database statistics
        """
        try:
            stats = {}
            
            with self.conn.cursor() as cur:
                # Document stats
                cur.execute("SELECT * FROM vector_db.document_stats")
                doc_stats = cur.fetchone()
                if doc_stats:
                    stats['documents'] = {
                        'total': doc_stats[0],
                        'unique_sources': doc_stats[1],
                        'avg_embedding_dims': doc_stats[2],
                        'first_document': doc_stats[3],
                        'latest_document': doc_stats[4]
                    }
                
                # Product stats
                cur.execute("SELECT * FROM vector_db.product_stats")
                prod_stats = cur.fetchone()
                if prod_stats:
                    stats['products'] = {
                        'total': prod_stats[0],
                        'unique_categories': prod_stats[1],
                        'avg_price': float(prod_stats[2]) if prod_stats[2] else 0,
                        'active_products': prod_stats[3]
                    }
                
            return stats
            
        except Exception as e:
            print(f"❌ Failed to get stats: {e}")
            return {}


def demo_usage():
    """
    Demo sử dụng ERP Vector Database
    """
    print("🚀 ERP TN Group - Vector Database Demo")
    print("=" * 50)
    
    # Initialize database connection
    vector_db = ERPVectorDB()
    
    if not vector_db.connect():
        return
    
    try:
        # Demo 1: Insert document embedding
        print("\n📄 Demo 1: Insert Document Embedding")
        doc_embedding = np.random.rand(1536).tolist()  # Fake embedding for demo
        
        success = vector_db.insert_document_embedding(
            document_id="demo_doc_001",
            title="Vector Database Tutorial",
            content="This is a comprehensive guide to using vector databases for AI applications.",
            embedding=doc_embedding,
            source="tutorial",
            metadata={"author": "Lam Van Truyen", "category": "technical"}
        )
        
        # Demo 2: Search similar documents
        print("\n🔍 Demo 2: Search Similar Documents")
        query_embedding = np.random.rand(1536).tolist()
        results = vector_db.search_similar_documents(query_embedding, threshold=0.0, limit=3)
        
        for result in results:
            print(f"  📋 {result['title']} (similarity: {result['similarity']:.3f})")
        
        # Demo 3: Insert product embedding
        print("\n🛍️ Demo 3: Insert Product Embedding")
        product_embedding = np.random.rand(384).tolist()
        
        vector_db.insert_product_embedding(
            product_id="demo_prod_001",
            product_name="AI-Powered Laptop",
            description="High-performance laptop optimized for AI and machine learning workloads",
            category="Electronics",
            price=1599.99,
            embedding=product_embedding,
            features={"ram": "32GB", "gpu": "RTX 4080", "cpu": "Intel i9"}
        )
        
        # Demo 4: Get statistics
        print("\n📊 Demo 4: Vector Database Statistics")
        stats = vector_db.get_vector_stats()
        print(f"  📄 Documents: {stats.get('documents', {}).get('total', 0)}")
        print(f"  🛍️ Products: {stats.get('products', {}).get('total', 0)}")
        
        print("\n✅ Demo completed successfully!")
        
    except Exception as e:
        print(f"❌ Demo failed: {e}")
    
    finally:
        vector_db.disconnect()


if __name__ == "__main__":
    demo_usage()
