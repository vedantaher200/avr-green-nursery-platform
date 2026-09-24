import { pool } from '../config/database';

export async function migrateOwnerInventoryAndPrebooking() {
  console.log('--- Applying Owner Inventory, Future Stock & Pre-Booking Migration ---');

  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    // 1. Extend products table with pricing tiers, future stock, tray capacity, and stock states
    await client.query(`
      ALTER TABLE products ADD COLUMN IF NOT EXISTS plant_price NUMERIC(10, 2);
      ALTER TABLE products ADD COLUMN IF NOT EXISTS tray_price NUMERIC(10, 2);
      ALTER TABLE products ADD COLUMN IF NOT EXISTS bulk_price NUMERIC(10, 2);
      ALTER TABLE products ADD COLUMN IF NOT EXISTS tray_capacity INT DEFAULT 104;
      ALTER TABLE products ADD COLUMN IF NOT EXISTS future_stock INT DEFAULT 0;
      ALTER TABLE products ADD COLUMN IF NOT EXISTS expected_ready_date DATE;
      ALTER TABLE products ADD COLUMN IF NOT EXISTS is_prebookable BOOLEAN DEFAULT TRUE;
      ALTER TABLE products ADD COLUMN IF NOT EXISTS stock_state VARCHAR(30) DEFAULT 'ready_now';
    `);

    // 2. Create Pre-Bookings table
    await client.query(`
      CREATE TABLE IF NOT EXISTS pre_bookings (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
        product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
        customer_id UUID REFERENCES customers(id) ON DELETE SET NULL,
        booking_number VARCHAR(50) NOT NULL UNIQUE,
        farmer_name VARCHAR(150) NOT NULL,
        farmer_phone VARCHAR(20) NOT NULL,
        farmer_location VARCHAR(255),
        unit VARCHAR(50) NOT NULL DEFAULT 'tray',
        quantity INT NOT NULL,
        total_plants INT NOT NULL,
        unit_price NUMERIC(10, 2) NOT NULL,
        total_amount NUMERIC(12, 2) NOT NULL,
        advance_amount NUMERIC(12, 2) DEFAULT 0.00,
        expected_ready_date DATE NOT NULL,
        status VARCHAR(30) NOT NULL DEFAULT 'pending',
        notes TEXT,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      );

      CREATE INDEX IF NOT EXISTS idx_pre_bookings_tenant_status ON pre_bookings (tenant_id, status);
      CREATE INDEX IF NOT EXISTS idx_pre_bookings_product ON pre_bookings (product_id);
      CREATE INDEX IF NOT EXISTS idx_pre_bookings_farmer_phone ON pre_bookings (farmer_phone);
    `);

    // 3. Create Nursery Announcements table
    await client.query(`
      CREATE TABLE IF NOT EXISTS nursery_announcements (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
        nursery_id UUID REFERENCES nurseries(id) ON DELETE CASCADE,
        title VARCHAR(255) NOT NULL,
        content TEXT NOT NULL,
        crop VARCHAR(100),
        variety VARCHAR(100),
        ready_quantity INT,
        future_quantity INT,
        expected_days INT,
        unit VARCHAR(50) DEFAULT 'plants',
        is_active BOOLEAN DEFAULT TRUE,
        published_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      );

      CREATE INDEX IF NOT EXISTS idx_announcements_tenant ON nursery_announcements (tenant_id, is_active);
    `);

    // 4. Update initial products with realistic prices, future production, and stock states
    await client.query(`
      UPDATE products SET
        plant_price = COALESCE(plant_price, ROUND(price / NULLIF(tray_size, 0), 2), 2.50),
        tray_price = COALESCE(tray_price, price, 260.00),
        bulk_price = COALESCE(bulk_price, ROUND((price / NULLIF(tray_size, 0)) * 0.85, 2), 2.10),
        tray_capacity = COALESCE(tray_size, 104),
        future_stock = CASE
          WHEN future_stock IS NULL OR future_stock = 0 THEN 50000
          ELSE future_stock
        END,
        expected_ready_date = CASE
          WHEN expected_ready_date IS NULL THEN CURRENT_DATE + INTERVAL '10 days'
          ELSE expected_ready_date
        END,
        is_prebookable = true,
        stock_state = 'ready_now'
      WHERE deleted_at IS NULL;
    `);

    // 5. Seed initial owner announcements for Tenant A and Tenant B
    const tenantA = '33333333-3333-3333-3333-333333333333';
    const nurseryA = '44444444-4444-4444-4444-444444444444';
    const tenantB = '33333333-3333-3333-3333-333333333334';
    const nurseryB = '44444444-4444-4444-4444-444444444445';

    await client.query(`
      INSERT INTO nursery_announcements
        (id, tenant_id, nursery_id, title, content, crop, variety, ready_quantity, future_quantity, expected_days, unit, is_active)
      VALUES
        ('77777777-7777-7777-7777-777777777701', '${tenantA}', '${nurseryA}',
         'Tomato Hybrid Production Batch Announcement',
         'Tomato Hybrid — 20,000 plants ready for immediate field dispatch. Next production batch of 50,000 plants expected in 10 days.',
         'Tomato', 'Abhinav Hybrid', 20000, 50000, 10, 'plants', true),
        ('77777777-7777-7777-7777-777777777702', '${tenantA}', '${nurseryA}',
         'Marigold Diwali Flowering Batch Ready',
         'Marigold — 1,000 trays ready now. Next production batch: 5,000 trays in 20 days.',
         'Marigold', 'Calcutta Orange', 1000, 5000, 20, 'trays', true),
        ('77777777-7777-7777-7777-777777777703', '${tenantB}', '${nurseryB}',
         'Green Chilli Balram F1 Hardened Seedlings',
         'Balram F1 Green Chilli — 15,000 hardened seedlings ready. Advance booking open for October planting.',
         'Chilli', 'Balram F1', 15000, 30000, 14, 'plants', true)
      ON CONFLICT (id) DO UPDATE SET
        title = EXCLUDED.title,
        content = EXCLUDED.content,
        ready_quantity = EXCLUDED.ready_quantity,
        future_quantity = EXCLUDED.future_quantity,
        expected_days = EXCLUDED.expected_days,
        is_active = EXCLUDED.is_active;
    `);

    // 6. Seed sample initial pre-booking for verification
    const sampleProductRes = await client.query(`
      SELECT id FROM products WHERE tenant_id = '${tenantA}' AND crop = 'Tomato' LIMIT 1
    `);
    if (sampleProductRes.rows[0]) {
      const prodId = sampleProductRes.rows[0].id;
      await client.query(`
        INSERT INTO pre_bookings
          (id, tenant_id, product_id, booking_number, farmer_name, farmer_phone, farmer_location,
           unit, quantity, total_plants, unit_price, total_amount, advance_amount, expected_ready_date, status, notes)
        VALUES
          ('88888888-8888-8888-8888-888888888891', '${tenantA}', '${prodId}', 'PRE-AVR-2026-001',
           'Ramesh Patil', '+91 9822012345', 'Yeola Taluka, Nashik',
           'tray', 50, 5200, 260.00, 13000.00, 2600.00, CURRENT_DATE + INTERVAL '10 days', 'pending',
           'Transplanting planned for 15 Oct. Please deliver with polyhouse hardening cert.')
        ON CONFLICT (id) DO NOTHING;
      `);
    }

    await client.query('COMMIT');
    console.log('✅ Owner Inventory, Future Stock & Pre-Booking Migration completed successfully.');
  } catch (err) {
    await client.query('ROLLBACK');
    console.error('❌ Migration failed:', err);
    throw err;
  } finally {
    client.release();
  }
}

if (require.main === module) {
  migrateOwnerInventoryAndPrebooking()
    .then(() => process.exit(0))
    .catch((err) => {
      console.error(err);
      process.exit(1);
    });
}
