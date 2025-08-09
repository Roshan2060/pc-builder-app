-- Sample Data for PC Builder Database

-- VENDORS
INSERT INTO vendors (name) VALUES
('Intel'),('AMD'),('NVIDIA'),('ASUS'),('MSI'),('Gigabyte'),('Corsair'),('Samsung'),('Western Digital'),('Seagate'),('EVGA'),('Noctua'),('be quiet!'),('Fractal Design'),('NZXT'),('Crucial'),('G.Skill'),('Kingston'),('Cooler Master'),('Phanteks');

-- CPUs
INSERT INTO cpus (name, model, vendor_id, price, description, socket_type, tdp) VALUES
('Intel Core i9-13900K','13900K',1,589.99,'24-core processor','LGA1700',253),
('Intel Core i7-13700K','13700K',1,409.99,'16-core processor','LGA1700',253),
('Intel Core i5-13600K','13600K',1,319.99,'14-core processor','LGA1700',181),
('Intel Core i9-14900K','14900K',1,599.99,'24-core processor refresh','LGA1700',253),
('AMD Ryzen 9 7950X','7950X',2,699.99,'16-core processor','AM5',170),
('AMD Ryzen 7 7700X','7700X',2,399.99,'8-core processor','AM5',105),
('AMD Ryzen 5 7600X','7600X',2,299.99,'6-core processor','AM5',105),
('AMD Ryzen 9 7900X3D','7900X3D',2,599.99,'12-core processor 3D V-Cache','AM5',120);

-- MOTHERBOARDS
INSERT INTO motherboards (name, model, vendor_id, price, description, socket_type, form_factor, ram_type, ram_slots, max_ram_speed, sata_ports, m2_slots, m2_pcie_slots) VALUES
('ASUS ROG Maximus Z790 Hero','Z790 Hero',4,449.99,'High-end Intel Z790 motherboard','LGA1700','ATX','DDR5',4,7800,4,4,3),
('MSI MPG Z790 Gaming Edge WiFi','Z790 Gaming Edge',5,399.99,'Gaming-focused Z790 motherboard','LGA1700','ATX','DDR5',4,7200,4,4,3),
('Gigabyte Z790 Aorus Elite AX','Z790 Aorus Elite',6,349.99,'Value Z790 motherboard','LGA1700','ATX','DDR5',4,7600,4,4,3),
('ASUS ROG Crosshair X670E Hero','X670E Hero',4,499.99,'Premium X670E motherboard','AM5','ATX','DDR5',4,6400,4,4,3),
('MSI MPG X670E Carbon WiFi','X670E Carbon',5,449.99,'High-performance X670E','AM5','ATX','DDR5',4,6600,4,4,3),
('Gigabyte X670E Aorus Master','X670E Aorus Master',6,479.99,'Feature-packed X670E','AM5','ATX','DDR5',4,6400,4,4,3);

-- RAM
INSERT INTO ram_modules (name, model, vendor_id, price, description, modules_in_kit, ram_type, speed) VALUES
('Corsair Dominator Platinum RGB','CMT32GX5M2X6000C36',7,199.99,'Premium DDR5 memory',2,'DDR5',6000),
('G.Skill Trident Z5 RGB','F5-6000J3636F16GX2-TZ5RK',17,189.99,'High-performance DDR5 memory',2,'DDR5',6000),
('Crucial Ballistix Max RGB','BLM2K16G56C36U4B',16,179.99,'Fast DDR5 memory',2,'DDR5',5600),
('Corsair Vengeance RGB Pro','CMW32GX4M2D3600C18',7,149.99,'Popular DDR4 memory',2,'DDR4',3600),
('G.Skill Ripjaws V','F4-3600C18D-32GVK',17,129.99,'Reliable DDR4 memory',2,'DDR4',3600),
('Kingston Fury Beast RGB','KF436C18BBK2/32',18,139.99,'DDR4 memory with good value',2,'DDR4',3600);

-- GPUs
INSERT INTO gpus (name, model, vendor_id, price, description, length_mm, tdp, recommended_psu_watts) VALUES
('NVIDIA GeForce RTX 4090','RTX 4090',3,1599.99,'Flagship graphics card',304,450,850),
('NVIDIA GeForce RTX 4080','RTX 4080',3,1199.99,'High-end graphics card',304,320,750),
('NVIDIA GeForce RTX 4070 Ti','RTX 4070 Ti',3,799.99,'Mid-high graphics card',285,285,700),
('AMD Radeon RX 7900 XTX','RX 7900 XTX',2,999.99,'AMD flagship',287,355,800),
('AMD Radeon RX 7900 XT','RX 7900 XT',2,899.99,'High-end AMD graphics',287,315,750),
('AMD Radeon RX 7800 XT','RX 7800 XT',2,499.99,'Mid-high AMD graphics',267,263,700);

-- Storage
INSERT INTO storage_devices (name, model, vendor_id, price, description, storage_type, interface, form_factor) VALUES
('Samsung 990 Pro','MZ-V9P2T0BW',8,199.99,'High-performance PCIe 4.0 NVMe SSD','SSD','PCIe','M.2'),
('WD Black SN850X','WDS2000X2G00E',9,189.99,'Gaming-focused PCIe 4.0 NVMe SSD','SSD','PCIe','M.2'),
('Crucial P5 Plus','CT2000P5PSSD8',16,179.99,'Reliable PCIe 4.0 NVMe SSD','SSD','PCIe','M.2'),
('Samsung 870 EVO','MZ-77E2T0BW',8,149.99,'Reliable SATA SSD','SSD','SATA','2.5"'),
('Crucial MX500','CT2000MX500SSD1',16,129.99,'Great value SATA SSD','SSD','SATA','2.5"'),
('Seagate Barracuda','ST2000DM008',10,49.99,'Reliable 2TB hard drive','HDD','SATA','3.5"'),
('WD Blue','WD20EZBX',9,54.99,'Dependable 2TB hard drive','HDD','SATA','3.5"');

-- PSUs
INSERT INTO power_supplies (name, model, vendor_id, price, description, wattage) VALUES
('Corsair HX1500i','CP-9020210-NA',7,399.99,'1500W fully modular 80+ Platinum PSU',1500),
('EVGA SuperNOVA 1300 GT','220-GT-1300-X1',11,299.99,'1300W fully modular 80+ Gold PSU',1300),
('Seasonic PRIME TX-1000','SSR-1000TR',20,349.99,'1000W fully modular 80+ Titanium PSU',1000),
('Corsair RM850x','CP-9020200-NA',7,149.99,'850W fully modular 80+ Gold PSU',850),
('EVGA SuperNOVA 750 GT','220-GT-0750-X1',11,99.99,'750W fully modular 80+ Gold PSU',750),
('be quiet! Straight Power 11 650W','BN297',13,119.99,'650W fully modular 80+ Gold PSU',650);

-- Cases
INSERT INTO cases (name, model, vendor_id, price, description, motherboard_form_factors, max_gpu_length_mm, max_cooler_height_mm) VALUES
('Phanteks Enthoo 719','PH-ES719LTG_DAG01',20,299.99,'Massive full tower case',ARRAY['E-ATX','ATX','Micro-ATX','Mini-ITX'],500,190),
('Fractal Design Torrent','FD-C-TOR1A-01',14,199.99,'Airflow-focused case',ARRAY['E-ATX','ATX','Micro-ATX','Mini-ITX'],467,188),
('NZXT H7 Flow','CA-H7FW-B1',15,129.99,'Clean mid tower',ARRAY['ATX','Micro-ATX','Mini-ITX'],400,167),
('Corsair 4000D Airflow','CC-9011200-WW',7,94.99,'Popular mid tower',ARRAY['ATX','Micro-ATX','Mini-ITX'],360,170),
('be quiet! Pure Base 500DX','BGW37',13,109.99,'Silent case with RGB accents',ARRAY['ATX','Micro-ATX','Mini-ITX'],369,190);

-- CPU Coolers
INSERT INTO cpu_coolers (name, model, vendor_id, price, description, socket_support, height_mm) VALUES
('Noctua NH-D15','NH-D15',12,99.99,'Premium air cooler',ARRAY['LGA1700','LGA1200','LGA1151','AM5','AM4'],165),
('be quiet! Dark Rock Pro 4','BK022',13,89.99,'Silent air cooler',ARRAY['LGA1700','LGA1200','LGA1151','AM5','AM4'],163),
('Cooler Master Hyper 212 EVO V2','RR-2V2E-18PK-R1',19,44.99,'Popular budget air cooler',ARRAY['LGA1700','LGA1200','LGA1151','AM5','AM4'],159);


