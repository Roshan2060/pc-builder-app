-- PC Builder Database Schema (compatibility-focused)

-- Inline lean schema to be executable from Django cursor
-- (copy of previous database_schema_lean.sql)

-- Users (separate from Django auth; minimal for builds linkage)
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(150) UNIQUE NOT NULL,
    email VARCHAR(254) UNIQUE NOT NULL,
    password_hash VARCHAR(128) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE
);

-- Vendors
CREATE TABLE IF NOT EXISTS vendors (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL
);

-- CPUs
CREATE TABLE IF NOT EXISTS cpus (
    id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    model VARCHAR(100),
    vendor_id INTEGER REFERENCES vendors(id),
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    description TEXT,
    socket_type VARCHAR(50) NOT NULL,
    tdp INTEGER NOT NULL,
    is_active BOOLEAN DEFAULT TRUE
);

-- Motherboards
CREATE TABLE IF NOT EXISTS motherboards (
    id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    model VARCHAR(100),
    vendor_id INTEGER REFERENCES vendors(id),
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    description TEXT,
    socket_type VARCHAR(50) NOT NULL,
    form_factor VARCHAR(20) NOT NULL,
    ram_type VARCHAR(20) NOT NULL,
    ram_slots INTEGER NOT NULL,
    max_ram_speed INTEGER NOT NULL,
    sata_ports INTEGER DEFAULT 0,
    m2_slots INTEGER DEFAULT 0,
    m2_pcie_slots INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE
);

-- RAM
CREATE TABLE IF NOT EXISTS ram_modules (
    id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    model VARCHAR(100),
    vendor_id INTEGER REFERENCES vendors(id),
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    description TEXT,
    ram_type VARCHAR(20) NOT NULL,
    modules_in_kit INTEGER NOT NULL,
    speed INTEGER NOT NULL,
    is_active BOOLEAN DEFAULT TRUE
);

-- GPUs
CREATE TABLE IF NOT EXISTS gpus (
    id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    model VARCHAR(100),
    vendor_id INTEGER REFERENCES vendors(id),
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    description TEXT,
    length_mm INTEGER NOT NULL,
    tdp INTEGER NOT NULL,
    recommended_psu_watts INTEGER NOT NULL,
    is_active BOOLEAN DEFAULT TRUE
);

-- Storage
CREATE TABLE IF NOT EXISTS storage_devices (
    id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    model VARCHAR(100),
    vendor_id INTEGER REFERENCES vendors(id),
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    description TEXT,
    storage_type VARCHAR(20) NOT NULL,
    interface VARCHAR(20) NOT NULL,
    form_factor VARCHAR(20) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE
);

-- Power supplies
CREATE TABLE IF NOT EXISTS power_supplies (
    id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    model VARCHAR(100),
    vendor_id INTEGER REFERENCES vendors(id),
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    description TEXT,
    wattage INTEGER NOT NULL,
    is_active BOOLEAN DEFAULT TRUE
);

-- Cases
CREATE TABLE IF NOT EXISTS cases (
    id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    model VARCHAR(100),
    vendor_id INTEGER REFERENCES vendors(id),
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    description TEXT,
    motherboard_form_factors TEXT[] NOT NULL,
    max_gpu_length_mm INTEGER NOT NULL,
    max_cooler_height_mm INTEGER NOT NULL,
    is_active BOOLEAN DEFAULT TRUE
);

-- CPU coolers
CREATE TABLE IF NOT EXISTS cpu_coolers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    model VARCHAR(100),
    vendor_id INTEGER REFERENCES vendors(id),
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    description TEXT,
    socket_support TEXT[] NOT NULL,
    height_mm INTEGER NOT NULL,
    is_active BOOLEAN DEFAULT TRUE
);

-- Builds
CREATE TABLE IF NOT EXISTS builds (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    total_price DECIMAL(12,2) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Build parts
CREATE TABLE IF NOT EXISTS build_parts (
    id SERIAL PRIMARY KEY,
    build_id INTEGER REFERENCES builds(id) ON DELETE CASCADE,
    part_type VARCHAR(20) NOT NULL,
    part_id INTEGER NOT NULL,
    quantity INTEGER DEFAULT 1 CHECK (quantity > 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Compatibility rules (optional)
CREATE TABLE IF NOT EXISTS compatibility_rules (
    id SERIAL PRIMARY KEY,
    rule_name VARCHAR(100) NOT NULL,
    rule_type VARCHAR(50) NOT NULL,
    source_component VARCHAR(20) NOT NULL,
    target_component VARCHAR(20) NOT NULL,
    rule_condition JSONB NOT NULL,
    error_message TEXT NOT NULL,
    severity VARCHAR(20) DEFAULT 'error'
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_cpus_socket_type ON cpus(socket_type);
CREATE INDEX IF NOT EXISTS idx_motherboards_socket_type ON motherboards(socket_type);
CREATE INDEX IF NOT EXISTS idx_motherboards_form_factor ON motherboards(form_factor);
CREATE INDEX IF NOT EXISTS idx_ram_modules_ram_type ON ram_modules(ram_type);
CREATE INDEX IF NOT EXISTS idx_gpus_length ON gpus(length_mm);
CREATE INDEX IF NOT EXISTS idx_cases_max_gpu_length ON cases(max_gpu_length_mm);
CREATE INDEX IF NOT EXISTS idx_cases_max_cooler_height ON cases(max_cooler_height_mm);
CREATE INDEX IF NOT EXISTS idx_cpu_coolers_height ON cpu_coolers(height_mm);
CREATE INDEX IF NOT EXISTS idx_power_supplies_wattage ON power_supplies(wattage);
CREATE INDEX IF NOT EXISTS idx_builds_user_id ON builds(user_id);
CREATE INDEX IF NOT EXISTS idx_build_parts_build_id ON build_parts(build_id);
CREATE INDEX IF NOT EXISTS idx_build_parts_part_type ON build_parts(part_type);

-- Build total price
CREATE OR REPLACE FUNCTION calculate_build_total_price(build_id_param INTEGER)
RETURNS DECIMAL(12,2) AS $$
DECLARE
    total DECIMAL(12,2) := 0;
BEGIN
    SELECT COALESCE(SUM(
        CASE 
            WHEN bp.part_type = 'cpu' THEN c.price * bp.quantity
            WHEN bp.part_type = 'motherboard' THEN m.price * bp.quantity
            WHEN bp.part_type = 'ram' THEN r.price * bp.quantity
            WHEN bp.part_type = 'gpu' THEN g.price * bp.quantity
            WHEN bp.part_type = 'storage' THEN s.price * bp.quantity
            WHEN bp.part_type = 'psu' THEN p.price * bp.quantity
            WHEN bp.part_type = 'case' THEN cs.price * bp.quantity
            WHEN bp.part_type = 'cooler' THEN cc.price * bp.quantity
            ELSE 0
        END
    ), 0) INTO total
    FROM build_parts bp
    LEFT JOIN cpus c ON bp.part_type = 'cpu' AND bp.part_id = c.id
    LEFT JOIN motherboards m ON bp.part_type = 'motherboard' AND bp.part_id = m.id
    LEFT JOIN ram_modules r ON bp.part_type = 'ram' AND bp.part_id = r.id
    LEFT JOIN gpus g ON bp.part_type = 'gpu' AND bp.part_id = g.id
    LEFT JOIN storage_devices s ON bp.part_type = 'storage' AND bp.part_id = s.id
    LEFT JOIN power_supplies p ON bp.part_type = 'psu' AND bp.part_id = p.id
    LEFT JOIN cases cs ON bp.part_type = 'case' AND bp.part_id = cs.id
    LEFT JOIN cpu_coolers cc ON bp.part_type = 'cooler' AND bp.part_id = cc.id
    WHERE bp.build_id = build_id_param;

    RETURN total;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_build_total_price()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE builds 
    SET total_price = calculate_build_total_price(COALESCE(NEW.build_id, OLD.build_id))
    WHERE id = COALESCE(NEW.build_id, OLD.build_id);
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_build_total_price
    AFTER INSERT OR UPDATE OR DELETE ON build_parts
    FOR EACH ROW EXECUTE FUNCTION update_build_total_price();


