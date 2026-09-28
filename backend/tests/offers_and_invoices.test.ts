import jwt from 'jsonwebtoken';
import { v4 as uuidv4 } from 'uuid';
import { pool } from '../src/config/database';
import { config } from '../src/config';
import { OffersService } from '../src/modules/offers/offers.service';
import { InvoiceService } from '../src/modules/invoice/invoice.service';

function generateTestToken(user: { userId: string; tenantId: string | null; roleId: string; roleName: string }) {
  return jwt.sign(
    { ...user, jti: uuidv4() },
    config.jwt.accessSecret,
    { expiresIn: '1h' }
  );
}

async function runTests() {
  console.log('============================================================');
  console.log('TEST SUITE: OFFERS, CAMPAIGNS, TENANT ISOLATION & INVOICE PDF');
  console.log('============================================================\n');

  let passedCount = 0;
  function assert(condition: boolean, message: string) {
    if (condition) {
      console.log(`  ✓ PASS - ${message}`);
      passedCount++;
    } else {
      console.error(`  ✗ FAIL - ${message}`);
      throw new Error(`Assertion failed: ${message}`);
    }
  }

  const tenantA = '33333333-3333-3333-3333-333333333333'; // AVR Green Yeola
  const tenantB = '33333333-3333-3333-3333-333333333334'; // Sai Krupa
  const farmerUserId = '66666666-6666-6666-6666-666666666605';

  // ─────────────────────────────────────────────────────────────
  // 1. PUBLIC MARKETPLACE MULTI-NURSERY OFFERS
  // ─────────────────────────────────────────────────────────────
  console.log('1. Public Marketplace Multi-Nursery Offers Discovery...');
  const publicOffers = await OffersService.getMarketplaceOffers({});
  assert(publicOffers.length >= 3, `Discovered ${publicOffers.length} active marketplace offers`);

  const uniqueTenants = new Set(publicOffers.map((o) => o.tenantId));
  assert(uniqueTenants.size >= 2, `Multiple participating nurseries published offers (found ${uniqueTenants.size} distinct tenants)`);

  for (const o of publicOffers) {
    assert(o.status === 'active', `Offer "${o.title}" has active status`);
    assert(new Date(o.startDate) <= new Date(), `Offer "${o.title}" start date is past/current`);
    assert(new Date(o.endDate) >= new Date(), `Offer "${o.title}" end date is in the future`);
    assert(Boolean(o.nurseryName && o.nurseryName.length > 0), `Offer includes nursery metadata (${o.nurseryName})`);
    assert(Boolean(o.discountLabel && o.discountLabel.includes('OFF')), `Offer formatted clean discount label (${o.discountLabel})`);
  }

  // ─────────────────────────────────────────────────────────────
  // 2. OWNER OFFER CREATION & STRICT TENANT SCOPING
  // ─────────────────────────────────────────────────────────────
  console.log('\n2. Owner Offer Creation & Strict Tenant Scoping...');
  const newOffer = await OffersService.createOffer(tenantA, {
    title: 'Automated Test Farmer Discount',
    shortDescription: '15% savings on early field plantation',
    offerType: 'percentage_discount',
    discountType: 'percentage',
    discountValue: 15,
    applicableCrop: 'Tomato',
    minQuantity: 2,
    minOrderValue: 200,
    startDate: new Date(Date.now() - 3600000).toISOString(),
    endDate: new Date(Date.now() + 86400000 * 7).toISOString(),
    termsConditions: 'Test terms apply',
    eventLabel: '🧪 Test Campaign',
  });

  assert(newOffer.id && newOffer.tenant_id === tenantA, 'Offer created and scoped strictly to Tenant A');

  // Verify Owner A can see it
  const ownerAOffers = await OffersService.getOwnerOffers(tenantA);
  const foundInA = ownerAOffers.some((o: any) => o.id === newOffer.id);
  assert(foundInA, 'Owner A retrieved own newly created offer');

  // Verify Owner B CANNOT see it (Tenant Isolation!)
  const ownerBOffers = await OffersService.getOwnerOffers(tenantB);
  const foundInB = ownerBOffers.some((o: any) => o.id === newOffer.id);
  assert(!foundInB, 'Owner B CANNOT see Owner A\'s offer (Strict Tenant Isolation)');

  // Verify Owner B CANNOT modify Owner A's offer
  let tenantViolationCaught = false;
  try {
    await OffersService.updateOffer(tenantB, newOffer.id, { title: 'Hacked Title' });
  } catch (err: any) {
    tenantViolationCaught = true;
  }
  assert(tenantViolationCaught, 'Owner B cross-tenant update attempt atomically rejected');

  // Verify Owner B CANNOT delete Owner A's offer
  let deleteViolationCaught = false;
  try {
    await OffersService.deleteOffer(tenantB, newOffer.id);
  } catch (err: any) {
    deleteViolationCaught = true;
  }
  assert(deleteViolationCaught, 'Owner B cross-tenant deletion attempt atomically rejected');

  // Clean up created test offer
  await OffersService.deleteOffer(tenantA, newOffer.id);
  assert(true, 'Owner A cleanly deleted own test offer');

  // ─────────────────────────────────────────────────────────────
  // 3. AUTHORITATIVE BACKEND DISCOUNT CALCULATION
  // ─────────────────────────────────────────────────────────────
  console.log('\n3. Authoritative Backend Discount Calculation...');
  // Find product for Tenant A Tomato
  const prodRes = await pool.query(
    `SELECT id, price, crop FROM products WHERE tenant_id = $1 AND crop = 'Tomato' AND deleted_at IS NULL LIMIT 1`,
    [tenantA]
  );
  if (prodRes.rows[0]) {
    const prod = prodRes.rows[0];
    const unitPrice = parseFloat(prod.price);
    // Find active offer for Tenant A
    const offerRes = await pool.query(
      `SELECT id, discount_value, discount_type, min_quantity, min_order_value
       FROM nursery_offers
       WHERE tenant_id = $1 AND status = 'active' AND applicable_crop = 'Tomato'
       LIMIT 1`,
      [tenantA]
    );

    if (offerRes.rows[0]) {
      const off = offerRes.rows[0];
      const minVal = parseFloat(off.min_order_value || '0');
      const testQty = Math.max(
        off.min_quantity || 1,
        Math.ceil((minVal + 100) / (unitPrice > 0 ? unitPrice : 100))
      );
      const calcValid = await OffersService.calculateDiscount(tenantA, off.id, [
        { productId: prod.id, quantity: testQty },
      ]);
      assert(calcValid.isValid, `Backend approved eligible discount calculation (reason: ${calcValid.reason ?? 'none'})`);
      assert(calcValid.discountAmount > 0, `Computed positive discount of ₹${calcValid.discountAmount}`);
      assert(calcValid.finalTotal < calcValid.subtotal, 'Final total correctly reduced by discount');

      // Test below min_quantity
      const calcInvalid = await OffersService.calculateDiscount(tenantA, off.id, [
        { productId: prod.id, quantity: 1 },
      ]);
      if (off.min_quantity > 1) {
        assert(!calcInvalid.isValid, 'Backend rejected discount when below minimum quantity requirement');
      }
    }
  }

  // ─────────────────────────────────────────────────────────────
  // 4. INVOICE PDF GENERATION & AUTHORIZATION
  // ─────────────────────────────────────────────────────────────
  console.log('\n4. Invoice PDF Generation & Role/Tenant Authorization...');
  // Find or create test order for Tenant A
  const existingOrder = await pool.query(
    `SELECT o.id, o.order_number, o.tenant_id, c.user_id as customer_user_id
     FROM orders o
     JOIN customers c ON c.id = o.customer_id
     WHERE o.tenant_id = $1 LIMIT 1`,
    [tenantA]
  );

  let testOrderId = '';
  let orderOwnerUserId = '';
  if (existingOrder.rows[0]) {
    testOrderId = existingOrder.rows[0].id;
    orderOwnerUserId = existingOrder.rows[0].customer_user_id;
  } else {
    // Insert a confirmed sample order
    const cust = await pool.query(`SELECT id, user_id FROM customers WHERE tenant_id = $1 LIMIT 1`, [tenantA]);
    const custId = cust.rows[0]?.id;
    orderOwnerUserId = cust.rows[0]?.user_id || farmerUserId;
    const orderIns = await pool.query(
      `INSERT INTO orders
        (tenant_id, order_number, customer_id, status, subtotal, tax_amount, total_amount, shipping_address)
       VALUES ($1, 'ORD-TEST-999', $2, 'confirmed', 500, 90, 590, '{"city": "Yeola"}')
       RETURNING id`,
      [tenantA, custId]
    );
    testOrderId = orderIns.rows[0].id;
  }

  // Generate / Retrieve PDF via service
  const pdfResult = await InvoiceService.getInvoicePdf(tenantA, testOrderId);
  assert(Buffer.isBuffer(pdfResult.buffer), 'InvoiceService returned valid binary PDF buffer');
  assert(pdfResult.buffer.length > 1000, `PDF size is valid (${pdfResult.buffer.length} bytes)`);
  assert(pdfResult.fileName.endsWith('.pdf'), `PDF filename is formatted properly (${pdfResult.fileName})`);

  // Verify PDF binary signature (%PDF-1.)
  const pdfHeader = pdfResult.buffer.slice(0, 5).toString('ascii');
  assert(pdfHeader === '%PDF-', 'PDF contains valid %PDF- header magic bytes');

  console.log('\n============================================================');
  console.log(`ALL OFFERS & INVOICE TESTS PASSED: ${passedCount} assertions verified`);
  console.log('============================================================\n');

  await pool.end();
}

runTests().catch((err) => {
  console.error('Test suite failed:', err);
  pool.end();
  process.exit(1);
});
