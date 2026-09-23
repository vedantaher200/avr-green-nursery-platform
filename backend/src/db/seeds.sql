-- =============================================================================
-- AVRGREEN Seed Data
-- Default Subscription Plans, Roles, Permissions, Demo Tenant & Core Master Data
-- =============================================================================

-- 1. SUBSCRIPTION PLANS
INSERT INTO subscription_plans (id, name, price_monthly, max_branches, max_users, features) VALUES
('00000000-0000-0000-0000-000000000001', 'Starter Nursery', 1499.00, 1, 3, '{"multi_branch": false, "live_tracking": false, "analytics": "basic"}'),
('00000000-0000-0000-0000-000000000002', 'Growth Enterprise', 3999.00, 5, 15, '{"multi_branch": true, "live_tracking": true, "analytics": "advanced"}'),
('00000000-0000-0000-0000-000000000003', 'Pro Multi-Branch SaaS', 9999.00, 20, 100, '{"multi_branch": true, "live_tracking": true, "analytics": "custom", "api_access": true}');

-- 2. ROLES
INSERT INTO roles (id, name, description) VALUES
('11111111-1111-1111-1111-111111111111', 'super_admin', 'SaaS Platform Owner with cross-tenant administrative control'),
('11111111-1111-1111-1111-111111111112', 'owner', 'Nursery Business Owner with full operational authority'),
('11111111-1111-1111-1111-111111111113', 'manager', 'Branch/Warehouse Manager overseeing stock and order dispatch'),
('11111111-1111-1111-1111-111111111114', 'staff', 'Nursery floor staff processing stock and packing orders'),
('11111111-1111-1111-1111-111111111115', 'customer', 'End customer browsing plant catalog and ordering online'),
('11111111-1111-1111-1111-111111111116', 'delivery_agent', 'Logistics agent delivering orders with live GPS tracking'),
('11111111-1111-1111-1111-111111111117', 'supplier', 'Plant & fertilizer wholesale vendor supplying nursery inventory');

-- 3. PERMISSIONS
INSERT INTO permissions (id, code, description) VALUES
('22222222-2222-2222-2222-222222222201', 'tenants.manage', 'Create and modify platform tenants'),
('22222222-2222-2222-2222-222222222202', 'nursery.read', 'View nursery and location details'),
('22222222-2222-2222-2222-222222222203', 'nursery.write', 'Create and modify nurseries and branches'),
('22222222-2222-2222-2222-222222222204', 'catalog.read', 'View product catalog'),
('22222222-2222-2222-2222-222222222205', 'catalog.write', 'Manage plants, seeds, prices, and categories'),
('22222222-2222-2222-2222-222222222206', 'inventory.read', 'View stock levels and batch numbers'),
('22222222-2222-2222-2222-222222222207', 'inventory.write', 'Adjust stock, perform transfers, and record damage'),
('22222222-2222-2222-2222-222222222208', 'orders.read', 'View customer orders'),
('22222222-2222-2222-2222-222222222209', 'orders.write', 'Process orders, dispatch, and initiate refunds'),
('22222222-2222-2222-2222-222222222210', 'delivery.execute', 'Update delivery status and push live GPS coordinates'),
('22222222-2222-2222-2222-222222222211', 'reports.view', 'Generate and view financial & inventory valuation analytics');

-- 4. DEMO TENANTS & REGIONAL NURSERY LOCATIONS (Maharashtra Nursery Cluster)
INSERT INTO tenants (id, name, slug, subscription_plan_id, status) VALUES
('33333333-3333-3333-3333-333333333333', 'AVR Green Nursery - Yeola Central', 'avrgreen-yeola', '00000000-0000-0000-0000-000000000002', 'active'),
('33333333-3333-3333-3333-333333333334', 'Sai Krupa Krishi Nursery', 'saikrupa-angangaon', '00000000-0000-0000-0000-000000000002', 'active'),
('33333333-3333-3333-3333-333333333335', 'Godavari Hi-Tech Agro Nursery', 'godavari-nashik', '00000000-0000-0000-0000-000000000002', 'active'),
('33333333-3333-3333-3333-333333333336', 'Chandwad Farmers Nursery & Seedlings', 'chandwad-farmers', '00000000-0000-0000-0000-000000000002', 'active');

INSERT INTO nurseries (id, tenant_id, name, code) VALUES
('44444444-4444-4444-4444-444444444444', '33333333-3333-3333-3333-333333333333', 'AVR Green Yeola Central Facility', 'AVR-YLA-01'),
('44444444-4444-4444-4444-444444444445', '33333333-3333-3333-3333-333333333334', 'Sai Krupa Seedling Farm', 'SKK-ANG-01'),
('44444444-4444-4444-4444-444444444446', '33333333-3333-3333-3333-333333333335', 'Godavari Polyhouse Center', 'GDV-NSK-01'),
('44444444-4444-4444-4444-444444444447', '33333333-3333-3333-3333-333333333336', 'Chandwad Agro Nursery Hub', 'CHD-NSK-01');

INSERT INTO locations (id, tenant_id, nursery_id, type, name, address, geo_lat, geo_lng, contact_phone) VALUES
('55555555-5555-5555-5555-555555555501', '33333333-3333-3333-3333-333333333333', '44444444-4444-4444-4444-444444444444', 'branch', 'Yeola Central Highway Branch', '{"street": "Manmad-Yeola Highway, Near Market Yard", "city": "Yeola", "state": "Maharashtra", "pincode": "423401"}', 20.042100, 74.489200, '+91 9900000002'),
('55555555-5555-5555-5555-555555555502', '33333333-3333-3333-3333-333333333334', '44444444-4444-4444-4444-444444444445', 'branch', 'Angangaon Farm Center', '{"street": "Angangaon Road, Taluka Yeola", "city": "Angangaon", "state": "Maharashtra", "pincode": "423401"}', 20.015400, 74.521000, '+91 9900000021'),
('55555555-5555-5555-5555-555555555503', '33333333-3333-3333-3333-333333333335', '44444444-4444-4444-4444-444444444446', 'branch', 'Panchavati Hi-Tech Nursery', '{"street": "Dindori Road, Panchavati", "city": "Nashik", "state": "Maharashtra", "pincode": "422003"}', 20.011000, 73.790000, '+91 9900000031'),
('55555555-5555-5555-5555-555555555504', '33333333-3333-3333-3333-333333333336', '44444444-4444-4444-4444-444444444447', 'branch', 'Chandwad Kisan Center', '{"street": "Lasalgaon Road, Chandwad", "city": "Chandwad", "state": "Maharashtra", "pincode": "423101"}', 20.327500, 74.241900, '+91 9900000041');

-- 5. DEMO USERS FOR ALL 7 ROLES (Password: 'Password123!')
-- Hash generated using bcrypt for 'Password123!'
INSERT INTO users (id, tenant_id, role_id, email, phone, password_hash, first_name, last_name, status) VALUES
('66666666-6666-6666-6666-666666666601', NULL, '11111111-1111-1111-1111-111111111111', 'admin@avrgreen.com', '+91 9900000001', '$2a$12$kdRfEs4XoziCJ4oCGhNlZOE05ldLu8VW7CdvIFmyzzuW167deysje', 'Global', 'SuperAdmin', 'active'),
('66666666-6666-6666-6666-666666666602', '33333333-3333-3333-3333-333333333333', '11111111-1111-1111-1111-111111111112', 'owner@avrnursery.com', '+91 9900000002', '$2a$12$kdRfEs4XoziCJ4oCGhNlZOE05ldLu8VW7CdvIFmyzzuW167deysje', 'Vaibhav', 'NurseryOwner', 'active'),
('66666666-6666-6666-6666-666666666603', '33333333-3333-3333-3333-333333333333', '11111111-1111-1111-1111-111111111113', 'manager@avrnursery.com', '+91 9900000003', '$2a$12$kdRfEs4XoziCJ4oCGhNlZOE05ldLu8VW7CdvIFmyzzuW167deysje', 'Ramesh', 'Manager', 'active'),
('66666666-6666-6666-6666-666666666604', '33333333-3333-3333-3333-333333333333', '11111111-1111-1111-1111-111111111114', 'staff@avrnursery.com', '+91 9900000004', '$2a$12$kdRfEs4XoziCJ4oCGhNlZOE05ldLu8VW7CdvIFmyzzuW167deysje', 'Suresh', 'StaffMember', 'active'),
('66666666-6666-6666-6666-666666666605', '33333333-3333-3333-3333-333333333333', '11111111-1111-1111-1111-111111111115', 'customer@gmail.com', '+91 9900000005', '$2a$12$kdRfEs4XoziCJ4oCGhNlZOE05ldLu8VW7CdvIFmyzzuW167deysje', 'Ananya', 'Customer', 'active'),
('66666666-6666-6666-6666-666666666606', '33333333-3333-3333-3333-333333333333', '11111111-1111-1111-1111-111111111116', 'driver@avrlogistics.com', '+91 9900000006', '$2a$12$kdRfEs4XoziCJ4oCGhNlZOE05ldLu8VW7CdvIFmyzzuW167deysje', 'Rajesh', 'DeliveryRider', 'active'),
('66666666-6666-6666-6666-666666666607', '33333333-3333-3333-3333-333333333333', '11111111-1111-1111-1111-111111111117', 'vendor@greenagro.com', '+91 9900000007', '$2a$12$kdRfEs4XoziCJ4oCGhNlZOE05ldLu8VW7CdvIFmyzzuW167deysje', 'GreenAgro', 'WholesaleSupplier', 'active');

-- 6. CATEGORIES & PRODUCTS
INSERT INTO categories (id, tenant_id, name, slug) VALUES
('77777777-7777-7777-7777-777777777701', '33333333-3333-3333-3333-333333333333', 'Indoor Air-Purifying Plants', 'indoor-plants'),
('77777777-7777-7777-7777-777777777702', '33333333-3333-3333-3333-333333333333', 'Exotic Flowering Plants', 'flowering-plants'),
('77777777-7777-7777-7777-777777777703', '33333333-3333-3333-3333-333333333333', 'Organic Fertilizers & Soil', 'fertilizers'),
('77777777-7777-7777-7777-777777777704', '33333333-3333-3333-3333-333333333333', 'Ceramic & Terracotta Pots', 'pots-planters');

INSERT INTO products (id, tenant_id, sku, category_id, common_name, scientific_name, description, price, cost_price, barcode, qr_code) VALUES
('88888888-8888-8888-8888-888888888801', '33333333-3333-3333-3333-333333333333', 'PLANT-MON-01', '77777777-7777-7777-7777-777777777701', 'Monstera Deliciosa (Swiss Cheese Plant)', 'Monstera deliciosa Liebm.', 'Vibrant tropical indoor plant with iconic natural leaf holes.', 899.00, 450.00, '8901234567890', 'QR-MON-01'),
('88888888-8888-8888-8888-888888888802', '33333333-3333-3333-3333-333333333333', 'PLANT-SNK-02', '77777777-7777-7777-7777-777777777701', 'Snake Plant Golden Hahnii', 'Dracaena trifasciata', 'Hardy air purifier thriving in low-light indoor environments.', 449.00, 200.00, '8901234567891', 'QR-SNK-02'),
('88888888-8888-8888-8888-888888888803', '33333333-3333-3333-3333-333333333333', 'FERT-VERM-03', '77777777-7777-7777-7777-777777777703', 'Premium Organic Vermicompost 5kg', 'Lumbricus rubellus bio-compost', '100% pure organic compost enriched with essential NPK bio-nutrients.', 299.00, 120.00, '8901234567892', 'QR-VERM-03');

-- 7. INVENTORY LEVELS
INSERT INTO inventory (id, tenant_id, product_id, location_id, quantity_available, quantity_reserved, batch_number) VALUES
('99999999-9999-9999-9999-999999999901', '33333333-3333-3333-3333-333333333333', '88888888-8888-8888-8888-888888888801', '55555555-5555-5555-5555-555555555501', 45, 2, 'BATCH-2026-A'),
('99999999-9999-9999-9999-999999999902', '33333333-3333-3333-3333-333333333333', '88888888-8888-8888-8888-888888888802', '55555555-5555-5555-5555-555555555501', 120, 5, 'BATCH-2026-B'),
('99999999-9999-9999-9999-999999999903', '33333333-3333-3333-3333-333333333333', '88888888-8888-8888-8888-888888888803', '55555555-5555-5555-5555-555555555502', 300, 0, 'BATCH-2026-C');

-- Additional realistic catalogue and supplier data for a usable first run.
INSERT INTO suppliers (tenant_id, name, contact_name, email, phone, rating) VALUES
('33333333-3333-3333-3333-333333333333','Leaf & Loom Farms','Maya Rao','maya@leafloom.example','+91 9901000001',4.8),
('33333333-3333-3333-3333-333333333333','Verdant Wholesale','Kiran Shah','orders@verdant.example','+91 9901000002',4.6),
('33333333-3333-3333-3333-333333333333','Bloom Source','Nisha Jain','hello@bloomsource.example','+91 9901000003',4.7),
('33333333-3333-3333-3333-333333333333','Terra Pottery','Dev Patel','sales@terrapottery.example','+91 9901000004',4.5),
('33333333-3333-3333-3333-333333333333','Rooted Organics','Arun Das','team@rooted.example','+91 9901000005',4.9);
INSERT INTO products (tenant_id, sku, category_id, common_name, scientific_name, description, price, cost_price) VALUES
('33333333-3333-3333-3333-333333333333','PLANT-PEA-04','77777777-7777-7777-7777-777777777701','Areca Palm','Dypsis lutescens','Graceful low-maintenance indoor palm.',699,340),
('33333333-3333-3333-3333-333333333333','PLANT-POT-05','77777777-7777-7777-7777-777777777701','Golden Pothos','Epipremnum aureum','Trailing foliage plant for bright rooms.',349,150),
('33333333-3333-3333-3333-333333333333','PLANT-FIC-06','77777777-7777-7777-7777-777777777701','Fiddle Leaf Fig','Ficus lyrata','Statement foliage plant.',1299,700),
('33333333-3333-3333-3333-333333333333','PLANT-ALO-07','77777777-7777-7777-7777-777777777701','Aloe Vera','Aloe barbadensis','Medicinal succulent for sunny windows.',249,95),
('33333333-3333-3333-3333-333333333333','PLANT-ROS-08','77777777-7777-7777-7777-777777777702','Desi Rose','Rosa indica','Fragrant flowering rose.',399,170),
('33333333-3333-3333-3333-333333333333','PLANT-HIB-09','77777777-7777-7777-7777-777777777702','Hibiscus Red','Hibiscus rosa-sinensis','Tropical flowering shrub.',349,140),
('33333333-3333-3333-3333-333333333333','PLANT-JAS-10','77777777-7777-7777-7777-777777777702','Jasmine','Jasminum sambac','Aromatic white flowers.',299,115),
('33333333-3333-3333-3333-333333333333','PLANT-TUL-11','77777777-7777-7777-7777-777777777702','Holy Basil Tulsi','Ocimum tenuiflorum','Sacred herb for home gardens.',149,55),
('33333333-3333-3333-3333-333333333333','FERT-NEEM-12','77777777-7777-7777-7777-777777777703','Neem Cake 1kg','Azadirachta indica','Organic soil amendment.',199,70),
('33333333-3333-3333-3333-333333333333','FERT-SEA-13','77777777-7777-7777-7777-777777777703','Seaweed Tonic 500ml','Ascophyllum nodosum','Natural growth tonic.',249,100),
('33333333-3333-3333-3333-333333333333','POT-CER-14','77777777-7777-7777-7777-777777777704','Ceramic Planter Medium','Ceramic','Hand-finished indoor planter.',599,260),
('33333333-3333-3333-3333-333333333333','POT-TERR-15','77777777-7777-7777-7777-777777777704','Terracotta Pot Large','Terracotta','Classic breathable clay pot.',399,150);
