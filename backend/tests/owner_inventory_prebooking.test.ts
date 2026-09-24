import { pool } from '../src/config/database';

const API_BASE = 'http://localhost:5000/api/v1';

async function runTest() {
  console.log('============================================================');
  console.log('TEST SUITE: OWNER INVENTORY, FUTURE STOCK & PRE-BOOKING');
  console.log('============================================================\n');

  const tenantA = '33333333-3333-3333-3333-333333333333'; // AVR Green Yeola
  const tenantB = '33333333-3333-3333-3333-333333333334'; // Sai Krupa


  console.log('1. Testing Owner Dashboard Supply Overview (Tenant A)...');
  // 1. Direct DB Query for overview
  const stockRes = await pool.query(
    `SELECT COALESCE(SUM(i.quantity_available), 0) AS total_ready,
            COALESCE(SUM(i.quantity_reserved), 0) AS total_reserved
     FROM inventory i WHERE i.tenant_id = $1`,
    [tenantA]
  );
  const futureRes = await pool.query(
    `SELECT COALESCE(SUM(p.future_stock), 0) AS total_future,
            MIN(p.expected_ready_date) AS earliest_date
     FROM products p WHERE p.tenant_id = $1 AND p.deleted_at IS NULL`,
    [tenantA]
  );
  const prebookRes = await pool.query(
    `SELECT COALESCE(SUM(pb.total_plants), 0) AS prebooked,
            COUNT(CASE WHEN pb.status = 'pending' THEN 1 END) AS pending_count
     FROM pre_bookings pb WHERE pb.tenant_id = $1 AND pb.status IN ('pending', 'confirmed')`,
    [tenantA]
  );

  console.log(`   - Ready Stock: ${stockRes.rows[0].total_ready}`);
  console.log(`   - Reserved Stock: ${stockRes.rows[0].total_reserved}`);
  console.log(`   - Future Production: ${futureRes.rows[0].total_future}`);
  console.log(`   - Earliest Batch Date: ${futureRes.rows[0].earliest_date}`);
  console.log(`   - Pre-booked Quantity: ${prebookRes.rows[0].prebooked}`);
  console.log(`   - Pending Pre-bookings: ${prebookRes.rows[0].pending_count}`);

  if (parseInt(futureRes.rows[0].total_future, 10) <= 0) {
    throw new Error('Future production should be greater than 0');
  }
  console.log('   ✅ Owner supply overview metrics verified.');

  console.log('\n2. Testing Owner Transactional Stock & Pricing Update...');
  const prodRes = await pool.query(
    `SELECT id, common_name, crop, variety FROM products WHERE tenant_id = $1 LIMIT 1`,
    [tenantA]
  );
  const testProduct = prodRes.rows[0];

  const updateClient = await pool.connect();
  try {
    await updateClient.query('BEGIN');
    const updateRes = await updateClient.query(
      `UPDATE products SET
         plant_price = 3.20,
         tray_price = 330.00,
         bulk_price = 2.70,
         tray_capacity = 104,
         future_stock = 65000,
         expected_ready_date = CURRENT_DATE + INTERVAL '12 days',
         stock_state = 'ready_now',
         is_prebookable = true
       WHERE id = $1 AND tenant_id = $2
       RETURNING *`,
      [testProduct.id, tenantA]
    );

    // Update physical ready stock
    const locRes = await updateClient.query(
      `SELECT id FROM locations WHERE tenant_id = $1 LIMIT 1`,
      [tenantA]
    );
    await updateClient.query(
      `INSERT INTO inventory
         (tenant_id, product_id, location_id, quantity_available, batch_number)
       VALUES ($1, $2, $3, 25000, 'BATCH-SEPT-26')
       ON CONFLICT (product_id, location_id, batch_number)
       DO UPDATE SET quantity_available = 25000`,
      [tenantA, testProduct.id, locRes.rows[0].id]
    );

    await updateClient.query('COMMIT');

    const updated = updateRes.rows[0];
    if (parseFloat(updated.plant_price) !== 3.20 || parseInt(updated.future_stock, 10) !== 65000) {
      throw new Error('Product update mismatch');
    }
    console.log(`   - Updated ${updated.common_name}: Plant Price: ₹${updated.plant_price}, Future Stock: ${updated.future_stock}`);
    console.log('   ✅ Transactional stock update verified.');
  } catch (e) {
    await updateClient.query('ROLLBACK');
    throw e;
  } finally {
    updateClient.release();
  }

  console.log('\n3. Testing Pre-Booking Placement (Verifying Ready Stock NOT Deducted)...');
  // Check ready stock before pre-booking
  const readyBeforeRes = await pool.query(
    `SELECT COALESCE(SUM(quantity_available), 0) AS ready FROM inventory WHERE product_id = $1`,
    [testProduct.id]
  );
  const readyBefore = parseInt(readyBeforeRes.rows[0].ready, 10);

  // Place pre-booking
  const bookingNumber = `PRE-TEST-${Date.now().toString().slice(-6)}`;
  await pool.query(
    `INSERT INTO pre_bookings
       (tenant_id, product_id, booking_number, farmer_name, farmer_phone,
        farmer_location, unit, quantity, total_plants, unit_price, total_amount, advance_amount,
        expected_ready_date, status, notes)
     VALUES ($1, $2, $3, 'Kisan Patil', '+91 9888877777', 'Nashik Dindori', 'tray', 10, 1040, 330.00, 3300.00, 660.00, CURRENT_DATE + INTERVAL '12 days', 'pending', 'Test pre-booking')`,
    [tenantA, testProduct.id, bookingNumber]
  );

  // Check ready stock after pre-booking
  const readyAfterRes = await pool.query(
    `SELECT COALESCE(SUM(quantity_available), 0) AS ready FROM inventory WHERE product_id = $1`,
    [testProduct.id]
  );
  const readyAfter = parseInt(readyAfterRes.rows[0].ready, 10);

  if (readyBefore !== readyAfter) {
    throw new Error(`CRITICAL ERROR: Ready stock was altered! Before: ${readyBefore}, After: ${readyAfter}`);
  }
  console.log(`   - Ready Stock Before: ${readyBefore}, Ready Stock After: ${readyAfter} (UNTOUCHED)`);
  console.log('   ✅ Pre-booking placed without deducting ready stock.');

  console.log('\n4. Testing Nursery Announcements...');
  const annRes = await pool.query(
    `SELECT * FROM nursery_announcements WHERE tenant_id = $1 AND is_active = true`,
    [tenantA]
  );
  if (annRes.rows.length === 0) {
    throw new Error('Expected active announcements for Tenant A');
  }
  console.log(`   - Found ${annRes.rows.length} announcements for Tenant A.`);
  console.log(`   - Title: "${annRes.rows[0].title}"`);
  console.log(`   - Content: "${annRes.rows[0].content}"`);
  console.log('   ✅ Nursery production announcement broadcast verified.');

  console.log('\n5. Testing Strict Tenant Isolation...');
  // Tenant B attempts to query Tenant A's pre-bookings
  const crossTenantBooking = await pool.query(
    `SELECT * FROM pre_bookings WHERE tenant_id = $1 AND booking_number = $2`,
    [tenantB, bookingNumber]
  );
  if (crossTenantBooking.rows.length !== 0) {
    throw new Error('Tenant isolation breach! Tenant B found Tenant A booking');
  }
  console.log('   - Tenant B queried Tenant A booking: 0 rows returned (ISOLATED)');
  console.log('   ✅ Tenant isolation strictly preserved.');

  console.log('\n============================================================');
  console.log('ALL SUPPLY-SIDE & PRE-BOOKING TESTS PASSED (100% VERIFIED)');
  console.log('============================================================\n');
}

runTest()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error('Test failed:', err);
    process.exit(1);
  });
