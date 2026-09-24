import { pool } from '../config/database';

async function migrateMarketplace() {
  console.log('--- Applying Multi-Nursery Marketplace DB Migration ---');

  // 1. Column additions with IF NOT EXISTS
  await pool.query(`
    ALTER TABLE products ADD COLUMN IF NOT EXISTS crop VARCHAR(100);
    ALTER TABLE products ADD COLUMN IF NOT EXISTS variety VARCHAR(100);
    ALTER TABLE products ADD COLUMN IF NOT EXISTS selling_unit VARCHAR(50) DEFAULT 'seedling';
    ALTER TABLE products ADD COLUMN IF NOT EXISTS tray_size INT DEFAULT 104;
    ALTER TABLE products ADD COLUMN IF NOT EXISTS min_order_qty INT DEFAULT 1;

    ALTER TABLE nurseries ADD COLUMN IF NOT EXISTS is_verified BOOLEAN DEFAULT TRUE;
    ALTER TABLE nurseries ADD COLUMN IF NOT EXISTS delivery_available BOOLEAN DEFAULT TRUE;
    ALTER TABLE nurseries ADD COLUMN IF NOT EXISTS pickup_available BOOLEAN DEFAULT TRUE;
    ALTER TABLE nurseries ADD COLUMN IF NOT EXISTS rating NUMERIC(3, 2) DEFAULT 4.8;
    ALTER TABLE nurseries ADD COLUMN IF NOT EXISTS review_count INT DEFAULT 142;
    ALTER TABLE nurseries ADD COLUMN IF NOT EXISTS image_url TEXT DEFAULT 'assets/images/nursery_hero_banner.jpg';
    ALTER TABLE nurseries ADD COLUMN IF NOT EXISTS opening_time VARCHAR(20) DEFAULT '07:00 AM';
    ALTER TABLE nurseries ADD COLUMN IF NOT EXISTS closing_time VARCHAR(20) DEFAULT '07:00 PM';
    ALTER TABLE nurseries ADD COLUMN IF NOT EXISTS is_open BOOLEAN DEFAULT TRUE;
  `);

  console.log('Columns verified.');

  // 2. Insert / Update Tenants & Nurseries
  await pool.query(`
    INSERT INTO tenants (id, name, slug, subscription_plan_id, status) VALUES
    ('33333333-3333-3333-3333-333333333333', 'AVR Green Nursery - Yeola Central', 'avrgreen-yeola', '00000000-0000-0000-0000-000000000002', 'active'),
    ('33333333-3333-3333-3333-333333333334', 'Sai Krupa Krishi Nursery', 'saikrupa-angangaon', '00000000-0000-0000-0000-000000000002', 'active'),
    ('33333333-3333-3333-3333-333333333335', 'Godavari Hi-Tech Agro Nursery', 'godavari-nashik', '00000000-0000-0000-0000-000000000002', 'active'),
    ('33333333-3333-3333-3333-333333333336', 'Chandwad Farmers Nursery & Seedlings', 'chandwad-farmers', '00000000-0000-0000-0000-000000000002', 'active'),
    ('33333333-3333-3333-3333-333333333337', 'Shree Samarth Agro Seedling Center', 'samarth-chandwad', '00000000-0000-0000-0000-000000000002', 'active')
    ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, status = EXCLUDED.status;

    INSERT INTO nurseries (id, tenant_id, name, code, is_verified, delivery_available, pickup_available, rating, review_count, image_url, opening_time, closing_time, is_open) VALUES
    ('44444444-4444-4444-4444-444444444444', '33333333-3333-3333-3333-333333333333', 'AVR Green Yeola Central Facility', 'AVR-YLA-01', true, true, true, 4.9, 184, 'assets/images/nursery_hero_banner.jpg', '06:30 AM', '07:30 PM', true),
    ('44444444-4444-4444-4444-444444444445', '33333333-3333-3333-3333-333333333334', 'Sai Krupa Seedling Farm', 'SKK-ANG-01', true, true, true, 4.8, 128, 'assets/images/nursery_hero_banner.jpg', '07:00 AM', '07:00 PM', true),
    ('44444444-4444-4444-4444-444444444446', '33333333-3333-3333-3333-333333333335', 'Godavari Polyhouse Center', 'GDV-NSK-01', true, true, false, 4.7, 95, 'assets/images/nursery_hero_banner.jpg', '07:30 AM', '06:30 PM', true),
    ('44444444-4444-4444-4444-444444444447', '33333333-3333-3333-3333-333333333336', 'Chandwad Agro Nursery Hub', 'CHD-NSK-01', true, true, true, 4.8, 156, 'assets/images/nursery_hero_banner.jpg', '07:00 AM', '07:00 PM', true),
    ('44444444-4444-4444-4444-444444444448', '33333333-3333-3333-3333-333333333337', 'Shree Samarth Agro Seedlings', 'SAM-CHD-02', true, true, true, 4.6, 72, 'assets/images/nursery_hero_banner.jpg', '07:00 AM', '06:30 PM', true)
    ON CONFLICT (id) DO UPDATE SET
      name = EXCLUDED.name,
      is_verified = EXCLUDED.is_verified,
      rating = EXCLUDED.rating,
      review_count = EXCLUDED.review_count,
      delivery_available = EXCLUDED.delivery_available,
      pickup_available = EXCLUDED.pickup_available;

    INSERT INTO locations (id, tenant_id, nursery_id, type, name, address, geo_lat, geo_lng, contact_phone) VALUES
    ('55555555-5555-5555-5555-555555555501', '33333333-3333-3333-3333-333333333333', '44444444-4444-4444-4444-444444444444', 'branch', 'Yeola Central Highway Branch', '{"street": "Manmad-Yeola Highway, Near Market Yard", "city": "Yeola", "state": "Maharashtra", "pincode": "423401"}', 20.042100, 74.489200, '+91 9900000002'),
    ('55555555-5555-5555-5555-555555555502', '33333333-3333-3333-3333-333333333334', '44444444-4444-4444-4444-444444444445', 'branch', 'Angangaon Farm Center', '{"street": "Angangaon Road, Taluka Yeola", "city": "Angangaon", "state": "Maharashtra", "pincode": "423401"}', 20.015400, 74.521000, '+91 9900000021'),
    ('55555555-5555-5555-5555-555555555503', '33333333-3333-3333-3333-333333333335', '44444444-4444-4444-4444-444444444446', 'branch', 'Panchavati Hi-Tech Nursery', '{"street": "Dindori Road, Panchavati", "city": "Nashik", "state": "Maharashtra", "pincode": "422003"}', 20.011000, 73.790000, '+91 9900000031'),
    ('55555555-5555-5555-5555-555555555504', '33333333-3333-3333-3333-333333333336', '44444444-4444-4444-4444-444444444447', 'branch', 'Chandwad Kisan Center', '{"street": "Lasalgaon Road, Chandwad", "city": "Chandwad", "state": "Maharashtra", "pincode": "423101"}', 20.327500, 74.241900, '+91 9900000041'),
    ('55555555-5555-5555-5555-555555555505', '33333333-3333-3333-3333-333333333337', '44444444-4444-4444-4444-444444444448', 'branch', 'Samarth Seedling Facility', '{"street": "Lasalgaon-Chandwad Link Highway", "city": "Chandwad", "state": "Maharashtra", "pincode": "423101"}', 20.312000, 74.251000, '+91 9900000051')
    ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, address = EXCLUDED.address, nursery_id = EXCLUDED.nursery_id;
  `);

  console.log('Regional nurseries and locations initialized.');

  // 3. Populate Agricultural Categories for Tenants B, C, D, E
  const tenants = [
    '33333333-3333-3333-3333-333333333333',
    '33333333-3333-3333-3333-333333333334',
    '33333333-3333-3333-3333-333333333335',
    '33333333-3333-3333-3333-333333333336',
    '33333333-3333-3333-3333-333333333337'
  ];

  for (const t of tenants) {
    await pool.query(`
      INSERT INTO categories (tenant_id, name, slug) VALUES
      ($1, 'Vegetable Seedlings', 'vegetables'),
      ($1, 'Fruit Plants', 'fruits'),
      ($1, 'Flowering Crops', 'flowering'),
      ($1, 'Commercial Agro Crops', 'commercial')
      ON CONFLICT (tenant_id, slug) DO NOTHING;
    `, [t]);
  }

  // 4. Update existing products with crop/variety metadata
  await pool.query(`
    UPDATE products SET crop = 'Chilli', variety = 'Balram F1', selling_unit = 'tray', tray_size = 104, min_order_qty = 1 WHERE sku LIKE '%CHI%' OR common_name ILIKE '%chilli%';
    UPDATE products SET crop = 'Tomato', variety = 'Abhinav Hybrid', selling_unit = 'tray', tray_size = 104, min_order_qty = 1 WHERE sku LIKE '%TOM%' OR common_name ILIKE '%tomato%';
    UPDATE products SET crop = 'Capsicum', variety = 'Indra Green', selling_unit = 'tray', tray_size = 104, min_order_qty = 1 WHERE sku LIKE '%CAP%' OR common_name ILIKE '%capsicum%';
    UPDATE products SET crop = 'Brinjal', variety = 'Manjri Gota', selling_unit = 'tray', tray_size = 104, min_order_qty = 1 WHERE sku LIKE '%BRIN%' OR common_name ILIKE '%brinjal%';
    UPDATE products SET crop = 'Marigold', variety = 'Calcutta Orange', selling_unit = 'pack_100', tray_size = 70, min_order_qty = 1 WHERE common_name ILIKE '%marigold%' OR common_name ILIKE '%genda%';
    UPDATE products SET crop = 'Sugarcane', variety = 'Co 86032', selling_unit = 'bulk', tray_size = 104, min_order_qty = 500 WHERE common_name ILIKE '%sugar%' OR common_name ILIKE '%cane%';
    UPDATE products SET crop = 'Lemon', variety = 'Kagzi Baramasi', selling_unit = 'seedling', min_order_qty = 5 WHERE common_name ILIKE '%lemon%' OR common_name ILIKE '%nimbu%';
    UPDATE products SET crop = 'Mango', variety = 'Kesar Grafted', selling_unit = 'seedling', min_order_qty = 2 WHERE common_name ILIKE '%mango%' OR common_name ILIKE '%aam%';
  `);

  // 5. Insert rich Crop -> Variety Catalog for Tenant B (Sai Krupa Krishi Nursery - Angangaon)
  const tenantB = '33333333-3333-3333-3333-333333333334';
  const locB = '55555555-5555-5555-5555-555555555502';
  const catVegB = (await pool.query(`SELECT id FROM categories WHERE tenant_id = $1 AND slug = 'vegetables'`, [tenantB])).rows[0]?.id;
  const catFlowerB = (await pool.query(`SELECT id FROM categories WHERE tenant_id = $1 AND slug = 'flowering'`, [tenantB])).rows[0]?.id;
  const catCropB = (await pool.query(`SELECT id FROM categories WHERE tenant_id = $1 AND slug = 'commercial'`, [tenantB])).rows[0]?.id;

  const varietiesB = [
    { sku: 'ANG-CHI-BAL', name: 'Balram Chilli Seedlings (104 Tray)', crop: 'Chilli', variety: 'Balram', price: 220, cat: catVegB, unit: 'tray', tray: 104, stock: 450 },
    { sku: 'ANG-CHI-BUL', name: 'Bullet Teja Mirchi Seedlings (104 Tray)', crop: 'Chilli', variety: 'Bullet', price: 230, cat: catVegB, unit: 'tray', tray: 104, stock: 380 },
    { sku: 'ANG-CHI-NAN', name: 'Nandita F1 Chilli Seedlings (104 Tray)', crop: 'Chilli', variety: 'Nandita', price: 240, cat: catVegB, unit: 'tray', tray: 104, stock: 290 },
    { sku: 'ANG-TOM-HYB', name: 'Abhinav Hybrid Tomato Seedlings', crop: 'Tomato', variety: 'Hybrid Tomato', price: 180, cat: catVegB, unit: 'tray', tray: 104, stock: 600 },
    { sku: 'ANG-TOM-DES', name: 'Desi Red Tomato Seedlings', crop: 'Tomato', variety: 'Desi Tomato', price: 160, cat: catVegB, unit: 'tray', tray: 104, stock: 500 },
    { sku: 'ANG-CAP-GRN', name: 'Green Bell Capsicum Polyhouse Seedlings', crop: 'Capsicum', variety: 'Green Capsicum', price: 280, cat: catVegB, unit: 'tray', tray: 104, stock: 310 },
    { sku: 'ANG-MAR-YEL', name: 'Yellow African Marigold (Genda) Seedlings', crop: 'Marigold', variety: 'Yellow Marigold', price: 150, cat: catFlowerB, unit: 'tray', tray: 70, stock: 400 },
    { sku: 'ANG-MAR-ORG', name: 'Calcutta Orange Marigold Seedlings', crop: 'Marigold', variety: 'Orange Marigold', price: 150, cat: catFlowerB, unit: 'tray', tray: 70, stock: 420 },
    { sku: 'ANG-SUG-860', name: 'Sugarcane Seedlings Co 86032 (Single Eye Bud)', crop: 'Sugarcane', variety: 'Co 86032', price: 2.20, cat: catCropB, unit: 'seedling', tray: 104, stock: 15000 },
  ];

  for (const v of varietiesB) {
    const prodRes = await pool.query(`
      INSERT INTO products (tenant_id, sku, category_id, common_name, crop, variety, price, cost_price, selling_unit, tray_size)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
      ON CONFLICT (tenant_id, sku) DO UPDATE SET price = EXCLUDED.price, crop = EXCLUDED.crop, variety = EXCLUDED.variety
      RETURNING id;
    `, [tenantB, v.sku, v.cat, v.name, v.crop, v.variety, v.price, v.price * 0.6, v.unit, v.tray]);

    const prodId = prodRes.rows[0].id;
    await pool.query(`
      INSERT INTO inventory (tenant_id, product_id, location_id, quantity_available, batch_number)
      VALUES ($1, $2, $3, $4, 'BATCH-ANG-2026')
      ON CONFLICT (product_id, location_id, batch_number) DO UPDATE SET quantity_available = EXCLUDED.quantity_available;
    `, [tenantB, prodId, locB, v.stock]);
  }

  // 6. Insert rich Crop -> Variety Catalog for Tenant C (Godavari Hi-Tech Agro Nursery - Nashik)
  const tenantC = '33333333-3333-3333-3333-333333333335';
  const locC = '55555555-5555-5555-5555-555555555503';
  const catVegC = (await pool.query(`SELECT id FROM categories WHERE tenant_id = $1 AND slug = 'vegetables'`, [tenantC])).rows[0]?.id;
  const catFlowerC = (await pool.query(`SELECT id FROM categories WHERE tenant_id = $1 AND slug = 'flowering'`, [tenantC])).rows[0]?.id;

  const varietiesC = [
    { sku: 'GDV-CHI-NND', name: 'Nandini Heavy Girth Chilli Seedlings', crop: 'Chilli', variety: 'Nandini', price: 250, cat: catVegC, unit: 'tray', tray: 104, stock: 320 },
    { sku: 'GDV-TOM-CHE', name: 'Sugar Ruby Cherry Tomato Seedlings', crop: 'Tomato', variety: 'Cherry Tomato', price: 320, cat: catVegC, unit: 'tray', tray: 104, stock: 200 },
    { sku: 'GDV-CAP-COL', name: 'Red & Yellow Colored Capsicum Seedlings', crop: 'Capsicum', variety: 'Hybrid Capsicum', price: 350, cat: catVegC, unit: 'tray', tray: 104, stock: 180 },
    { sku: 'GDV-BRN-RND', name: 'Ravaiya Round Purple Brinjal Seedlings', crop: 'Brinjal', variety: 'Round Brinjal', price: 170, cat: catVegC, unit: 'tray', tray: 104, stock: 410 },
    { sku: 'GDV-CHR-WHT', name: 'White Chrysanthemum (Shevanti) Plantlets', crop: 'Chrysanthemum', variety: 'White Shevanti', price: 190, cat: catFlowerC, unit: 'tray', tray: 70, stock: 250 },
  ];

  for (const v of varietiesC) {
    const prodRes = await pool.query(`
      INSERT INTO products (tenant_id, sku, category_id, common_name, crop, variety, price, cost_price, selling_unit, tray_size)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
      ON CONFLICT (tenant_id, sku) DO UPDATE SET price = EXCLUDED.price, crop = EXCLUDED.crop, variety = EXCLUDED.variety
      RETURNING id;
    `, [tenantC, v.sku, v.cat, v.name, v.crop, v.variety, v.price, v.price * 0.6, v.unit, v.tray]);

    const prodId = prodRes.rows[0].id;
    await pool.query(`
      INSERT INTO inventory (tenant_id, product_id, location_id, quantity_available, batch_number)
      VALUES ($1, $2, $3, $4, 'BATCH-GDV-2026')
      ON CONFLICT (product_id, location_id, batch_number) DO UPDATE SET quantity_available = EXCLUDED.quantity_available;
    `, [tenantC, prodId, locC, v.stock]);
  }

  // 6.b Insert rich Crop -> Variety Catalog for Tenant D (Chandwad Farmers Nursery & Seedlings)
  const tenantD = '33333333-3333-3333-3333-333333333336';
  const locD = '55555555-5555-5555-5555-555555555504';
  const catVegD = (await pool.query(`SELECT id FROM categories WHERE tenant_id = $1 AND slug = 'vegetables'`, [tenantD])).rows[0]?.id;
  const catFlowerD = (await pool.query(`SELECT id FROM categories WHERE tenant_id = $1 AND slug = 'flowering'`, [tenantD])).rows[0]?.id;
  const catFruitD = (await pool.query(`SELECT id FROM categories WHERE tenant_id = $1 AND slug = 'fruits'`, [tenantD])).rows[0]?.id;

  const varietiesD = [
    { sku: 'CHD-TOM-ABH', name: 'Abhinav Hybrid Tomato Seedlings (104 Tray)', crop: 'Tomato', variety: 'Abhinav Hybrid', price: 180, cat: catVegD, unit: 'tray', tray: 104, stock: 550 },
    { sku: 'CHD-CHI-BAL', name: 'Balram F1 Green Chilli Seedlings (104 Tray)', crop: 'Chilli', variety: 'Balram F1', price: 220, cat: catVegD, unit: 'tray', tray: 104, stock: 480 },
    { sku: 'CHD-CAP-IND', name: 'Indra Green Bell Capsicum Polyhouse Seedlings', crop: 'Capsicum', variety: 'Indra Green', price: 290, cat: catVegD, unit: 'tray', tray: 104, stock: 320 },
    { sku: 'CHD-BRN-MNJ', name: 'Manjri Gota Purple Brinjal Seedlings', crop: 'Brinjal', variety: 'Manjri Gota', price: 160, cat: catVegD, unit: 'tray', tray: 104, stock: 400 },
    { sku: 'CHD-CAB-GLD', name: 'Golden Acre Cabbage Seedlings', crop: 'Cabbage', variety: 'Golden Acre', price: 150, cat: catVegD, unit: 'tray', tray: 104, stock: 350 },
    { sku: 'CHD-CLF-SNW', name: 'Snowball 16 Cauliflower Seedlings', crop: 'Cauliflower', variety: 'Snowball 16', price: 160, cat: catVegD, unit: 'tray', tray: 104, stock: 300 },
    { sku: 'CHD-MRG-CAL', name: 'Calcutta Orange Marigold Seedlings (70 Tray)', crop: 'Marigold', variety: 'Calcutta Orange', price: 140, cat: catFlowerD, unit: 'tray', tray: 70, stock: 600 },
    { sku: 'CHD-LEM-KGZ', name: 'Kagzi Baramasi Seedless Lemon Saplings', crop: 'Lemon', variety: 'Kagzi Baramasi', price: 45, cat: catFruitD, unit: 'seedling', tray: 104, stock: 1200 },
  ];

  for (const v of varietiesD) {
    const prodRes = await pool.query(`
      INSERT INTO products (tenant_id, sku, category_id, common_name, crop, variety, price, cost_price, selling_unit, tray_size)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
      ON CONFLICT (tenant_id, sku) DO UPDATE SET price = EXCLUDED.price, crop = EXCLUDED.crop, variety = EXCLUDED.variety
      RETURNING id;
    `, [tenantD, v.sku, v.cat, v.name, v.crop, v.variety, v.price, v.price * 0.6, v.unit, v.tray]);

    const prodId = prodRes.rows[0].id;
    await pool.query(`
      INSERT INTO inventory (tenant_id, product_id, location_id, quantity_available, batch_number)
      VALUES ($1, $2, $3, $4, 'BATCH-CHD-2026')
      ON CONFLICT (product_id, location_id, batch_number) DO UPDATE SET quantity_available = EXCLUDED.quantity_available;
    `, [tenantD, prodId, locD, v.stock]);
  }

  // 7. Create Bulk Quotes Table for Marketplace
  await pool.query(`
    CREATE TABLE IF NOT EXISTS marketplace_bulk_quotes (
      id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
      tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
      product_id UUID REFERENCES products(id) ON DELETE SET NULL,
      farmer_phone VARCHAR(20) NOT NULL,
      farmer_name VARCHAR(100),
      crop VARCHAR(100) NOT NULL,
      variety VARCHAR(100),
      requested_quantity INT NOT NULL,
      expected_delivery_date DATE,
      notes TEXT,
      status VARCHAR(50) DEFAULT 'submitted',
      created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
    );
  `);

  console.log('Marketplace bulk quotes table ready.');
  console.log('✅ Multi-Nursery Marketplace Migration Completed Successfully.');
  await pool.end();
}

migrateMarketplace().catch(err => {
  console.error('Migration failed:', err);
  pool.end();
  process.exit(1);
});
