import { pool } from '../config/database';

async function migrateLocationDiscovery() {
  console.log('--- Applying Location Discovery Migration ---');

  try {
    // 1. Add specific discovery columns to locations
    await pool.query(`
      ALTER TABLE locations ADD COLUMN IF NOT EXISTS state VARCHAR(100);
      ALTER TABLE locations ADD COLUMN IF NOT EXISTS district VARCHAR(100);
      ALTER TABLE locations ADD COLUMN IF NOT EXISTS taluka VARCHAR(100);
      ALTER TABLE locations ADD COLUMN IF NOT EXISTS city VARCHAR(100);
      ALTER TABLE locations ADD COLUMN IF NOT EXISTS area VARCHAR(100);
      ALTER TABLE locations ADD COLUMN IF NOT EXISTS pincode VARCHAR(20);
      ALTER TABLE locations ADD COLUMN IF NOT EXISTS address_line TEXT;
      ALTER TABLE locations ADD COLUMN IF NOT EXISTS is_published BOOLEAN DEFAULT FALSE;
    `);
    console.log('Columns added/verified.');

    // 2. Backfill explicit columns from the existing JSONB address
    await pool.query(`
      UPDATE locations SET
        state = address->>'state',
        city = address->>'city',
        pincode = address->>'pincode',
        address_line = address->>'street'
      WHERE state IS NULL;
    `);
    console.log('Existing location data backfilled.');

    // 3. Create high-performance indexes for marketplace discovery
    await pool.query(`
      CREATE INDEX IF NOT EXISTS idx_locations_geo ON locations(geo_lat, geo_lng);
      CREATE INDEX IF NOT EXISTS idx_locations_hierarchy ON locations(state, district, taluka, city);
      CREATE INDEX IF NOT EXISTS idx_locations_published ON locations(is_published) WHERE is_published = TRUE;
    `);
    console.log('Indexes created.');

    console.log('✅ Location Discovery Migration Completed Successfully.');
  } catch (error) {
    console.error('Migration failed:', error);
    process.exit(1);
  } finally {
    await pool.end();
  }
}

migrateLocationDiscovery();
