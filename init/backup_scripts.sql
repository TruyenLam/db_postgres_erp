-- ================================================
-- ERP TN Group - Database Backup Information
-- ================================================

-- Tạo bảng để track backup history (optional)
CREATE TABLE IF NOT EXISTS backup_history (
    id SERIAL PRIMARY KEY,
    backup_name VARCHAR(255) NOT NULL,
    backup_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    backup_size BIGINT,
    backup_type VARCHAR(50) DEFAULT 'auto',
    notes TEXT
);

-- Insert sample record
INSERT INTO backup_history (backup_name, backup_type, notes) 
VALUES ('initial_backup_' || TO_CHAR(NOW(), 'YYYYMMDD_HH24MISS') || '.sql', 'manual', 'Database initialized with backup tracking');

-- Tạo function để log backup
CREATE OR REPLACE FUNCTION log_backup(backup_file TEXT, backup_type TEXT DEFAULT 'auto', notes TEXT DEFAULT NULL)
RETURNS VOID AS $$
BEGIN
    INSERT INTO backup_history (backup_name, backup_type, notes)
    VALUES (backup_file, backup_type, notes);
END;
$$ LANGUAGE plpgsql;

-- Hiển thị thông tin backup
COMMENT ON TABLE backup_history IS 'Bảng lưu trữ lịch sử backup database ERP TN Group';
