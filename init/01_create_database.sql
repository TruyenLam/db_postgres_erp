-- ================================================
-- ERP TN Group - Database Initialization
-- Creates database if not exists
-- ================================================

-- Create database
SELECT 'CREATE DATABASE erp_tngroup' 
WHERE NOT EXISTS (
    SELECT FROM pg_database WHERE datname = 'erp_tngroup'
)\gexec

-- Connect to the database
\c erp_tngroup;

-- Create admin user if not exists
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_user WHERE usename = 'erp_admin') THEN
        CREATE USER erp_admin WITH PASSWORD 'TnGroup@2024!Secure#db$2025';
    END IF;
END $$;

-- Grant permissions
GRANT ALL PRIVILEGES ON DATABASE erp_tngroup TO erp_admin;
GRANT ALL ON SCHEMA public TO erp_admin;

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

\echo 'Database initialization completed successfully!'
