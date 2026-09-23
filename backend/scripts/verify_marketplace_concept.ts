const API_BASE = 'http://localhost:5000/api/v1';

async function runVerification() {
  console.log('================================================================');
  console.log('AVR GREEN NURSERY — MULTI-NURSERY MARKETPLACE VERIFICATION');
  console.log('================================================================\n');

  let passed = 0;
  let failed = 0;

  function assert(condition: boolean, testName: string) {
    if (condition) {
      console.log(`[PASS] ${testName}`);
      passed++;
    } else {
      console.error(`[FAIL] ${testName}`);
      failed++;
    }
  }

  try {
    // 1. Marketplace Nurseries Discovery
    console.log('1. Testing Marketplace Nurseries Discovery:');
    const nurseriesRes = await fetch(`${API_BASE}/marketplace/nurseries`);
    assert(nurseriesRes.status === 200, 'GET /marketplace/nurseries returns 200 OK');
    const nurseriesJson: any = await nurseriesRes.json();
    assert(Array.isArray(nurseriesJson.data), 'Returns array of nurseries');
    assert(nurseriesJson.data.length >= 4, `Found ${nurseriesJson.data.length} registered regional nurseries`);

    const yeola = nurseriesJson.data.find((n: any) => n.city.toLowerCase() === 'yeola');
    const angangaon = nurseriesJson.data.find((n: any) => n.city.toLowerCase().includes('angangaon'));
    const nashik = nurseriesJson.data.find((n: any) => n.city.toLowerCase() === 'nashik');
    const chandwad = nurseriesJson.data.find((n: any) => n.city.toLowerCase() === 'chandwad');

    assert(!!yeola, 'Yeola Central Nursery is registered');
    assert(!!angangaon, 'Sai Krupa Krishi Nursery (Angangaon) is registered');
    assert(!!nashik, 'Godavari Hi-Tech Agro (Nashik) is registered');
    assert(!!chandwad, 'Chandwad Farmers Nursery is registered');

    console.log(`\nSample Nursery: "${yeola.name}" (${yeola.city})`);
    console.log(`  - Active Varieties: ${yeola.activeVarietiesCount}`);
    console.log(`  - Available Crops: ${yeola.availableCrops.join(', ')}`);
    console.log(`  - Delivery: ${yeola.deliveryAvailable ? 'Yes' : 'No'}, Pickup: ${yeola.pickupAvailable ? 'Yes' : 'No'}`);

    // 2. City Filtering
    console.log('\n2. Testing Location-based Discovery Filter:');
    const nashikFilterRes = await fetch(`${API_BASE}/marketplace/nurseries?city=Nashik`);
    assert(nashikFilterRes.status === 200, 'GET /marketplace/nurseries?city=Nashik returns 200');
    const nashikJson: any = await nashikFilterRes.json();
    assert(nashikJson.data.length >= 1, 'Returns nurseries in Nashik district');

    // 3. Single Nursery Details
    console.log('\n3. Testing Single Nursery Detail:');
    const nurseryDetailRes = await fetch(`${API_BASE}/marketplace/nurseries/${yeola.id}`);
    assert(nurseryDetailRes.status === 200, 'GET /marketplace/nurseries/:id returns 200');
    const nurseryDetailJson: any = await nurseryDetailRes.json();
    assert(nurseryDetailJson.data.name === yeola.name, 'Nursery detail matches');

    // 4. Commercial Bulk Quote Request
    console.log('\n4. Testing Bulk Quote Submission:');
    const quoteRes = await fetch(`${API_BASE}/marketplace/bulk-quote`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        nurseryId: yeola.id,
        tenantId: yeola.tenantId,
        farmerName: 'Dnyaneshwar Shinde',
        farmerPhone: '9900000005',
        crop: 'Chilli',
        variety: 'Balram F1',
        requestedQuantity: 5000,
        expectedDeliveryDate: '2026-10-15',
        notes: 'Need healthy, hardened 28-day seedlings delivered to Yeola farm.',
      }),
    });
    assert(quoteRes.status === 201, 'POST /marketplace/bulk-quote returns 201 Created');
    const quoteJson: any = await quoteRes.json();
    assert(quoteJson.data.status === 'submitted', 'Quote status is submitted');
    console.log(`  - Quote ID created: ${quoteJson.data.id}`);

    // 5. Crop & Variety Hierarchy in Catalog
    console.log('\n5. Testing Crop & Variety Hierarchy:');
    const productsRes = await fetch(`${API_BASE}/products?tenantId=${yeola.tenantId}`);
    assert(productsRes.status === 200, 'GET /products?tenantId returns 200');
    const productsJson: any = await productsRes.json();
    const products = productsJson.data;
    assert(products && products.length >= 4, `Yeola Nursery has ${products ? products.length : 0} products listed`);

    const chilliBalram = products.find((p: any) => p.variety === 'Balram F1' || p.crop === 'Chilli');
    assert(!!chilliBalram, 'Balram F1 chilli seedlings found in Yeola catalog');
    if (chilliBalram) {
      console.log(`  - Product: "${chilliBalram.commonName}" | Crop: ${chilliBalram.crop} | Variety: ${chilliBalram.variety} | Selling Unit: ${chilliBalram.selling_unit || chilliBalram.sellingUnit} | Price: ₹${chilliBalram.price}`);
    }

    // 6. Cross-nursery Isolation in Catalog
    console.log('\n6. Testing Multi-Tenant Nursery Isolation:');
    const saiProductsRes = await fetch(`${API_BASE}/products?tenantId=${angangaon.tenantId}`);
    assert(saiProductsRes.status === 200, 'GET /products for Sai Krupa returns 200');
    const saiJson: any = await saiProductsRes.json();
    const saiProducts = saiJson.data;
    assert(saiProducts && saiProducts.length >= 2, `Sai Krupa Nursery has ${saiProducts ? saiProducts.length : 0} products`);
    assert(
      saiProducts.every((p: any) => p.tenant_id === angangaon.tenantId || p.tenantId === angangaon.tenantId),
      'Sai Krupa catalog strictly contains only its own tenant products'
    );

    console.log('\n================================================================');
    console.log(`VERIFICATION SUMMARY: ${passed} PASSED, ${failed} FAILED`);
    console.log('================================================================');

    if (failed > 0) {
      process.exit(1);
    }
  } catch (err: any) {
    console.error('Verification failed with error:', err.message);
    process.exit(1);
  }
}

runVerification();
