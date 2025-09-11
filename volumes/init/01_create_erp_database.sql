-- ================================================
-- Comprehensive ERP Database System for Warehouse Management
-- PostgreSQL 15+ Database Schema
-- 
-- Based on the extensive research and requirements provided
-- This script creates a production-ready, scalable ERP system
-- ================================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "btree_gin";
CREATE EXTENSION IF NOT EXISTS "pg_stat_statements";

-- Set timezone
SET timezone = 'Asia/Ho_Chi_Minh';

-- ================================================
-- 1. LANGUAGE SUPPORT SYSTEM
-- ================================================

-- Central language registry
CREATE TABLE languages (
    code CHAR(2) PRIMARY KEY,
    name TEXT NOT NULL,
    locale TEXT,
    date_format TEXT,
    number_format TEXT,
    currency_symbol TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Insert default languages
INSERT INTO languages (code, name, locale, date_format, number_format, currency_symbol) VALUES
('en', 'English', 'en_US', 'MM/DD/YYYY', '1,234.56', '$'),
('vi', 'Vietnamese', 'vi_VN', 'DD/MM/YYYY', '1.234,56', '₫'),
('es', 'Spanish', 'es_ES', 'DD/MM/YYYY', '1.234,56', '€'),
('fr', 'French', 'fr_FR', 'DD/MM/YYYY', '1 234,56', '€'),
('de', 'German', 'de_DE', 'DD.MM.YYYY', '1.234,56', '€'),
('zh', 'Chinese', 'zh_CN', 'YYYY/MM/DD', '1,234.56', '¥');

-- ================================================
-- 2. USER MANAGEMENT & SECURITY
-- ================================================

-- Role-based access control with JSONB permissions
CREATE TABLE user_roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    role_name VARCHAR(50) UNIQUE NOT NULL,
    permissions JSONB DEFAULT '{}',
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Insert default roles
INSERT INTO user_roles (role_name, permissions, description) VALUES
('super_admin', '{"all": "*"}', 'Super Administrator with full access'),
('warehouse_manager', '{"warehouse": ["read", "write", "manage"], "inventory": ["read", "write"], "reports": ["read"]}', 'Warehouse Manager'),
('warehouse_operator', '{"inventory": ["read", "write"], "orders": ["read", "write"]}', 'Warehouse Operator'),
('inventory_analyst', '{"inventory": ["read"], "reports": ["read"], "analytics": ["read"]}', 'Inventory Analyst'),
('readonly_user', '{"all": ["read"]}', 'Read-only access to all data');

-- Comprehensive user profiles with audit fields
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username VARCHAR(100) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    role_id UUID REFERENCES user_roles(id),
    last_login TIMESTAMP,
    failed_login_attempts INTEGER DEFAULT 0,
    account_locked BOOLEAN DEFAULT FALSE,
    preferences JSONB DEFAULT '{}',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Session tracking for security
CREATE TABLE user_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    session_token TEXT UNIQUE NOT NULL,
    ip_address INET,
    user_agent TEXT,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Create admin user
INSERT INTO users (username, email, password_hash, first_name, last_name, role_id) 
SELECT 'admin', 'admin@tngroup.com', crypt('TnGroup@2024!Admin', gen_salt('bf')), 'Admin', 'User', id 
FROM user_roles WHERE role_name = 'super_admin';

-- ================================================
-- 3. LOCATION & WAREHOUSE MANAGEMENT
-- ================================================

-- Geographic locations with coordinates
CREATE TABLE locations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    address TEXT,
    city VARCHAR(100),
    state_province VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(100),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    timezone VARCHAR(50),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Insert sample locations
INSERT INTO locations (name, address, city, state_province, country, timezone) VALUES
('Ho Chi Minh Warehouse', '123 Nguyen Van Linh, District 7', 'Ho Chi Minh City', 'Ho Chi Minh', 'Vietnam', 'Asia/Ho_Chi_Minh'),
('Hanoi Distribution Center', '456 Pham Hung, Cau Giay', 'Hanoi', 'Hanoi', 'Vietnam', 'Asia/Ho_Chi_Minh'),
('Da Nang Regional Hub', '789 Bach Dang, Hai Chau', 'Da Nang', 'Da Nang', 'Vietnam', 'Asia/Ho_Chi_Minh');

-- Storage facilities with capacity tracking
CREATE TABLE warehouses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    warehouse_code VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    location_id UUID REFERENCES locations(id),
    warehouse_type VARCHAR(50), -- 'distribution', 'fulfillment', 'cold_storage'
    total_capacity_sqft DECIMAL(12, 2),
    operational_capacity_sqft DECIMAL(12, 2),
    manager_user_id UUID REFERENCES users(id),
    operating_hours JSONB,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Insert sample warehouses
INSERT INTO warehouses (warehouse_code, name, location_id, warehouse_type, total_capacity_sqft, operational_capacity_sqft, operating_hours) 
SELECT 'WH-HCM-01', 'Ho Chi Minh Main Warehouse', id, 'distribution', 50000.00, 45000.00, '{"monday": {"open": "08:00", "close": "18:00"}, "tuesday": {"open": "08:00", "close": "18:00"}}'
FROM locations WHERE name = 'Ho Chi Minh Warehouse';

-- Granular location tracking (aisle/shelf/bin)
CREATE TABLE warehouse_zones (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    warehouse_id UUID REFERENCES warehouses(id),
    zone_code VARCHAR(20) NOT NULL,
    zone_type VARCHAR(50), -- 'receiving', 'picking', 'shipping', 'bulk'
    aisle VARCHAR(10),
    shelf VARCHAR(10),
    bin VARCHAR(10),
    capacity_units INTEGER,
    environmental_controls JSONB, -- temperature, humidity requirements
    access_restrictions JSONB,
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(warehouse_id, zone_code)
);

-- ================================================
-- 4. PRODUCT MANAGEMENT SYSTEM
-- ================================================

-- Hierarchical category structure
CREATE TABLE product_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    parent_id UUID REFERENCES product_categories(id),
    category_path TEXT, -- materialized path for hierarchy
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    display_order INTEGER,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Insert sample categories
INSERT INTO product_categories (name, description, display_order) VALUES
('Electronics', 'Electronic devices and components', 1),
('Office Supplies', 'Office and business supplies', 2),
('Industrial Equipment', 'Heavy machinery and industrial tools', 3),
('Raw Materials', 'Basic materials and components', 4);

-- Vendor management with ratings and terms
CREATE TABLE suppliers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    supplier_code VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    contact_person VARCHAR(255),
    email VARCHAR(255),
    phone VARCHAR(50),
    address TEXT,
    payment_terms JSONB,
    lead_time_days INTEGER,
    quality_rating DECIMAL(3, 2),
    is_preferred BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Insert sample suppliers
INSERT INTO suppliers (supplier_code, name, contact_person, email, payment_terms, lead_time_days, quality_rating) VALUES
('SUP-001', 'TechCorp Vietnam', 'Nguyen Van A', 'contact@techcorp.vn', '{"terms": "NET30", "discount": "2/10"}', 14, 4.5),
('SUP-002', 'Global Electronics Ltd', 'John Smith', 'sales@globalelectronics.com', '{"terms": "NET45", "discount": "1/15"}', 21, 4.2);

-- Master product catalog with extensive attributes
CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sku VARCHAR(50) UNIQUE NOT NULL,
    upc VARCHAR(20),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    category_id UUID REFERENCES product_categories(id),
    unit_of_measure VARCHAR(20),
    weight_kg DECIMAL(8, 3),
    dimensions JSONB, -- length, width, height
    hazmat_classification VARCHAR(50),
    storage_requirements JSONB,
    shelf_life_days INTEGER,
    minimum_stock_level INTEGER DEFAULT 0,
    maximum_stock_level INTEGER,
    reorder_point INTEGER,
    reorder_quantity INTEGER,
    standard_cost DECIMAL(10, 4),
    list_price DECIMAL(10, 2),
    is_serialized BOOLEAN DEFAULT FALSE,
    is_lot_tracked BOOLEAN DEFAULT FALSE,
    custom_attributes JSONB DEFAULT '{}',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Product translations for multi-language support
CREATE TABLE product_translations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID REFERENCES products(id) ON DELETE CASCADE,
    language_code CHAR(2) REFERENCES languages(code),
    name TEXT NOT NULL,
    description TEXT,
    UNIQUE(product_id, language_code)
);

-- Insert sample products
INSERT INTO products (sku, name, description, unit_of_measure, weight_kg, standard_cost, list_price) VALUES
('LAPTOP-001', 'Business Laptop Pro', 'High-performance business laptop with SSD', 'EA', 2.5, 800.00, 1200.00),
('MOUSE-001', 'Wireless Mouse', 'Ergonomic wireless mouse', 'EA', 0.1, 15.00, 25.00),
('KEYBOARD-001', 'Mechanical Keyboard', 'RGB mechanical gaming keyboard', 'EA', 1.2, 80.00, 120.00);

-- ================================================
-- 5. INVENTORY MANAGEMENT
-- ================================================

-- Real-time stock levels by location
CREATE TABLE inventory (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID REFERENCES products(id),
    warehouse_id UUID REFERENCES warehouses(id),
    zone_id UUID REFERENCES warehouse_zones(id),
    quantity_on_hand INTEGER NOT NULL DEFAULT 0,
    quantity_allocated INTEGER DEFAULT 0,
    quantity_available INTEGER GENERATED ALWAYS AS (quantity_on_hand - quantity_allocated) STORED,
    quantity_on_order INTEGER DEFAULT 0,
    last_count_date TIMESTAMP,
    last_count_quantity INTEGER,
    variance_quantity INTEGER DEFAULT 0,
    average_cost DECIMAL(10, 4),
    total_value DECIMAL(15, 2) GENERATED ALWAYS AS (quantity_on_hand * average_cost) STORED,
    last_movement_date TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(product_id, warehouse_id, zone_id),
    CONSTRAINT chk_inventory_quantities 
        CHECK (quantity_on_hand >= 0 AND quantity_allocated >= 0)
);

-- Batch/lot tracking with expiry dates
CREATE TABLE inventory_lots (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    inventory_id UUID REFERENCES inventory(id),
    lot_number VARCHAR(100) NOT NULL,
    expiration_date DATE,
    manufacture_date DATE,
    supplier_lot_number VARCHAR(100),
    quantity INTEGER NOT NULL,
    status VARCHAR(20) DEFAULT 'available', -- 'available', 'hold', 'expired'
    quality_status VARCHAR(20) DEFAULT 'pass', -- 'pass', 'fail', 'quarantine'
    received_date TIMESTAMP DEFAULT NOW(),
    UNIQUE(inventory_id, lot_number)
);

-- Complete transaction history (will be partitioned by date)
CREATE TABLE stock_movements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    movement_type VARCHAR(50) NOT NULL, -- 'receipt', 'shipment', 'transfer', 'adjustment'
    product_id UUID REFERENCES products(id),
    warehouse_id UUID REFERENCES warehouses(id),
    zone_id UUID REFERENCES warehouse_zones(id),
    lot_id UUID REFERENCES inventory_lots(id),
    quantity INTEGER NOT NULL,
    unit_cost DECIMAL(10, 4),
    reference_type VARCHAR(50), -- 'purchase_order', 'sales_order', 'transfer'
    reference_id UUID,
    movement_date TIMESTAMP DEFAULT NOW(),
    user_id UUID REFERENCES users(id),
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Individual item tracking
CREATE TABLE serial_numbers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID REFERENCES products(id),
    serial_number VARCHAR(255) UNIQUE NOT NULL,
    inventory_id UUID REFERENCES inventory(id),
    status VARCHAR(20) DEFAULT 'in_stock', -- 'in_stock', 'sold', 'rma'
    purchase_date DATE,
    warranty_expires_date DATE,
    created_at TIMESTAMP DEFAULT NOW()
);

-- ================================================
-- 6. ORDER MANAGEMENT
-- ================================================

-- Customer management
CREATE TABLE customers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_code VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    phone VARCHAR(50),
    address TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    credit_limit DECIMAL(12, 2),
    payment_terms VARCHAR(50),
    custom_fields JSONB DEFAULT '{}',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Orders
CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_number VARCHAR(50) UNIQUE NOT NULL,
    customer_id UUID REFERENCES customers(id),
    order_date TIMESTAMP DEFAULT NOW(),
    required_date TIMESTAMP,
    ship_date TIMESTAMP,
    status VARCHAR(20) DEFAULT 'pending', -- 'pending', 'processing', 'shipped', 'delivered', 'cancelled'
    total_amount DECIMAL(12, 2),
    shipping_address TEXT,
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Order line items
CREATE TABLE order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id),
    quantity INTEGER NOT NULL,
    unit_price DECIMAL(10, 2),
    total_price DECIMAL(12, 2) GENERATED ALWAYS AS (quantity * unit_price) STORED,
    created_at TIMESTAMP DEFAULT NOW()
);

-- ================================================
-- 7. CUSTOM FIELDS SYSTEM (Dynamic Columns)
-- ================================================

-- Custom field definitions management
CREATE TABLE custom_field_definitions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entity_type TEXT NOT NULL, -- 'products', 'customers', 'orders'
    field_name TEXT NOT NULL,
    field_type TEXT NOT NULL CHECK (field_type IN ('text', 'number', 'boolean', 'date', 'select', 'multi_select')),
    is_required BOOLEAN DEFAULT FALSE,
    validation_rules JSONB DEFAULT '{}',
    field_options JSONB DEFAULT '{}', -- For select fields
    display_order INTEGER,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(entity_type, field_name)
);

-- ================================================
-- 8. AUDIT SYSTEM
-- ================================================

-- Enhanced audit log table
CREATE TABLE audit_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    table_name TEXT NOT NULL,
    record_id UUID NOT NULL,
    operation VARCHAR(10) NOT NULL, -- INSERT, UPDATE, DELETE
    old_values JSONB,
    new_values JSONB,
    changed_fields TEXT[],
    user_id UUID REFERENCES users(id),
    user_ip INET,
    application_name TEXT,
    transaction_id TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- ================================================
-- 9. INDEXES FOR PERFORMANCE
-- ================================================

-- Composite indexes for common query patterns
CREATE INDEX idx_inventory_product_warehouse ON inventory (product_id, warehouse_id);
CREATE INDEX idx_stock_movements_product_date ON stock_movements (product_id, movement_date);
CREATE INDEX idx_orders_customer_date ON orders (customer_id, order_date);
CREATE INDEX idx_products_sku ON products (sku) WHERE is_active = TRUE;

-- GIN indexes for JSONB attributes
CREATE INDEX idx_products_custom_attributes ON products USING GIN (custom_attributes);
CREATE INDEX idx_users_preferences ON users USING GIN (preferences);
CREATE INDEX idx_audit_log_new_values ON audit_log USING GIN (new_values);

-- Text search indexes
CREATE INDEX idx_products_name_search ON products USING GIN (to_tsvector('english', name || ' ' || COALESCE(description, '')));
CREATE INDEX idx_customers_name_search ON customers USING GIN (to_tsvector('english', name));

-- ================================================
-- 10. VIEWS FOR COMMON QUERIES
-- ================================================

-- Localized product view with fallback logic
CREATE VIEW products_localized AS
SELECT 
    p.id,
    p.sku,
    p.standard_cost,
    p.list_price,
    COALESCE(pt_req.name, pt_def.name, p.name) as name,
    COALESCE(pt_req.description, pt_def.description, p.description) as description,
    p.is_active,
    p.created_at
FROM products p
LEFT JOIN product_translations pt_def ON p.id = pt_def.product_id AND pt_def.language_code = 'en'
LEFT JOIN product_translations pt_req ON p.id = pt_req.product_id 
    AND pt_req.language_code = COALESCE(current_setting('app.language', true), 'en');

-- Inventory summary view
CREATE VIEW inventory_summary AS
SELECT 
    i.id,
    p.sku,
    p.name AS product_name,
    w.warehouse_code,
    w.name AS warehouse_name,
    i.quantity_on_hand,
    i.quantity_allocated,
    i.quantity_available,
    i.average_cost,
    i.total_value,
    CASE 
        WHEN i.quantity_available <= p.minimum_stock_level THEN 'LOW_STOCK'
        WHEN i.quantity_available <= p.reorder_point THEN 'REORDER'
        ELSE 'NORMAL'
    END AS stock_status
FROM inventory i
JOIN products p ON i.product_id = p.id
JOIN warehouses w ON i.warehouse_id = w.id
WHERE p.is_active = TRUE AND w.is_active = TRUE;

-- ================================================
-- 11. FUNCTIONS AND PROCEDURES
-- ================================================

-- Function to get current user ID (to be set by application)
CREATE OR REPLACE FUNCTION current_user_id() 
RETURNS UUID AS $$
BEGIN
    RETURN COALESCE(current_setting('app.current_user_id', true)::UUID, '00000000-0000-0000-0000-000000000000'::UUID);
END;
$$ LANGUAGE plpgsql;

-- Function to validate and set custom field values
CREATE OR REPLACE FUNCTION set_custom_field(
    p_table_name TEXT,
    p_record_id UUID,
    p_field_name TEXT,
    p_field_value JSONB
) RETURNS BOOLEAN AS $$
DECLARE
    field_def RECORD;
    update_sql TEXT;
BEGIN
    -- Get field definition
    SELECT * INTO field_def
    FROM custom_field_definitions
    WHERE entity_type = p_table_name AND field_name = p_field_name;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Custom field % not defined for entity type %', p_field_name, p_table_name;
    END IF;
    
    -- Update the record (simplified - add validation as needed)
    update_sql := format('UPDATE %I SET custom_fields = custom_fields || %L WHERE id = %L',
                        p_table_name, 
                        jsonb_build_object(p_field_name, p_field_value), 
                        p_record_id);
    EXECUTE update_sql;
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- Generic audit trigger function
CREATE OR REPLACE FUNCTION generic_audit_trigger()
RETURNS TRIGGER AS $$
DECLARE
    old_record JSONB := NULL;
    new_record JSONB := NULL;
    changed_fields TEXT[] := '{}';
    field_name TEXT;
BEGIN
    -- Capture old and new values
    IF TG_OP = 'DELETE' THEN
        old_record := to_jsonb(OLD);
    ELSIF TG_OP = 'UPDATE' THEN
        old_record := to_jsonb(OLD);
        new_record := to_jsonb(NEW);
        
        -- Identify changed fields
        FOR field_name IN SELECT jsonb_object_keys(new_record)
        LOOP
            IF old_record->field_name IS DISTINCT FROM new_record->field_name THEN
                changed_fields := array_append(changed_fields, field_name);
            END IF;
        END LOOP;
    ELSE
        new_record := to_jsonb(NEW);
    END IF;
    
    -- Insert audit record
    INSERT INTO audit_log (
        table_name, record_id, operation, old_values, new_values, 
        changed_fields, user_id, user_ip, application_name, transaction_id
    ) VALUES (
        TG_TABLE_NAME,
        COALESCE(NEW.id, OLD.id),
        TG_OP,
        old_record,
        new_record,
        changed_fields,
        current_user_id(),
        inet_client_addr(),
        current_setting('application_name', true),
        txid_current()::TEXT
    );
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Apply audit triggers to key tables
CREATE TRIGGER products_audit_trigger
    AFTER INSERT OR UPDATE OR DELETE ON products
    FOR EACH ROW EXECUTE FUNCTION generic_audit_trigger();

CREATE TRIGGER inventory_audit_trigger
    AFTER INSERT OR UPDATE OR DELETE ON inventory
    FOR EACH ROW EXECUTE FUNCTION generic_audit_trigger();

CREATE TRIGGER orders_audit_trigger
    AFTER INSERT OR UPDATE OR DELETE ON orders
    FOR EACH ROW EXECUTE FUNCTION generic_audit_trigger();

-- ================================================
-- 12. SAMPLE DATA
-- ================================================

-- Insert sample data for testing
INSERT INTO customers (customer_code, name, email, credit_limit) VALUES
('CUST-001', 'ABC Company Ltd', 'contact@abc.com', 100000.00),
('CUST-002', 'XYZ Corporation', 'info@xyz.com', 50000.00);

INSERT INTO orders (order_number, customer_id, total_amount, status) 
SELECT 'ORD-2024-001', id, 1500.00, 'pending'
FROM customers WHERE customer_code = 'CUST-001';

-- ================================================
-- FINAL SETUP
-- ================================================

-- Update table statistics
ANALYZE;

-- Log completion
INSERT INTO audit_log (table_name, record_id, operation, new_values, user_id) 
VALUES ('system', gen_random_uuid(), 'SETUP', '{"message": "ERP database schema created successfully", "version": "1.0"}', current_user_id());

COMMIT;
