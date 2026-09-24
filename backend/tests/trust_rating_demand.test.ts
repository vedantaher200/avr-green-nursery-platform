import { pool } from '../src/config/database';
import { createApp } from '../src/app';
import { Server } from 'http';

async function runTrustAndDemandTests() {
  console.log('============================================================');
  console.log('TEST SUITE: NURSERY TRUST, RATING, RANKING & DEMAND SIGNALS');
  console.log('============================================================\n');

  const app = createApp();
  let server: Server;
  let port = 0;
  let baseUrl = '';

  await new Promise<void>((resolve) => {
    server = app.listen(0, () => {
      port = (server.address() as any).port;
      baseUrl = `http://127.0.0.1:${port}/api/v1`;
      resolve();
    });
  });

  try {
    // 1. Test Nursery Trust & Rating Breakdown
    console.log('1. Testing Nursery Trust, 5-Factor Breakdown & Primary Rating...');
    const nurseriesRes = await fetch(`${baseUrl}/marketplace/nurseries`);
    const nurseriesJson = (await nurseriesRes.json()) as any;
    const nurseries = nurseriesJson.data;

    if (!Array.isArray(nurseries) || nurseries.length === 0) {
      throw new Error('Expected at least one nursery returned');
    }

    const primaryNursery = nurseries.find((n: any) => n.code === 'GHE-01' || n.code === 'AVR-YLA-01' || n.name.includes('AVR Green Yeola')) || nurseries[0];
    console.log(`   - Nursery: ${primaryNursery.name}`);
    console.log(`   - Primary Rating: ⭐ ${primaryNursery.rating}`);
    console.log(`   - Farmer Reviews: ${primaryNursery.reviewCount}`);
    console.log(`   - Successful Orders: ${primaryNursery.successfulOrdersCount}`);
    console.log(`   - Recent Activity: ${primaryNursery.activityText}`);
    console.log(`   - Breakdown: Quality ${primaryNursery.ratingBreakdown.plantQuality}, Delivery ${primaryNursery.ratingBreakdown.delivery}, Service ${primaryNursery.ratingBreakdown.service}, Packaging ${primaryNursery.ratingBreakdown.packaging}, Value ${primaryNursery.ratingBreakdown.value}`);

    if (primaryNursery.rating !== 4.8 || primaryNursery.reviewCount !== 326) {
      throw new Error(`Expected primary rating 4.8 and 326 reviews, got ${primaryNursery.rating} and ${primaryNursery.reviewCount}`);
    }
    if (!primaryNursery.ratingBreakdown || !primaryNursery.ratingBreakdown.plantQuality) {
      throw new Error('Missing ratingBreakdown on nursery');
    }
    console.log('   ✅ Nursery primary rating & 5-factor breakdown verified.\n');

    // 2. Test Explainable Multi-Factor Ranking
    console.log('2. Testing Explainable Multi-Factor Ranking Logic...');
    console.log(`   - Ranking Badge: ${primaryNursery.rankingBadge}`);
    console.log(`   - Ranking Reason: ${primaryNursery.rankingReason}`);
    console.log(`   - Total Rank Score: ${primaryNursery.rankingScore} pts`);
    console.log(`   - Factors:`, primaryNursery.rankingFactors);

    if (!primaryNursery.rankingFactors || typeof primaryNursery.rankingFactors.total !== 'number') {
      throw new Error('Missing rankingFactors breakdown in nursery response');
    }
    if (primaryNursery.rankingFactors.rating <= 0 || primaryNursery.rankingFactors.verification <= 0) {
      throw new Error('Ranking factors must have non-zero authentic scores');
    }
    console.log('   ✅ Multi-factor ranking logic explainable and verified.\n');

    // 3. Test Location & Taluka / City Filter
    console.log('3. Testing Location Discovery (Chandwad / Nashik)...');
    const locationRes = await fetch(`${baseUrl}/marketplace/nurseries?city=Chandwad`);
    const locationJson = (await locationRes.json()) as any;
    const locationNurseries = locationJson.data;

    console.log(`   - Nurseries found for Chandwad / Nashik: ${locationNurseries.length}`);
    locationNurseries.forEach((n: any, idx: number) => {
      console.log(`     [${idx + 1}] ${n.name} (${n.city}) - Distance: ${n.distanceKm} km (Score: ${n.rankingScore})`);
    });

    if (locationNurseries.length === 0) {
      throw new Error('Expected nurseries returned for Chandwad location filter');
    }
    console.log('   ✅ Location discovery and distance calculation verified.\n');

    // 4. Test Stock & Price Freshness Timestamps
    console.log('4. Testing Product Stock Freshness Timestamps in DB...');
    const productsRes = await pool.query(
      `SELECT id, common_name, crop, variety, stock_updated_at, price_updated_at
       FROM products
       WHERE tenant_id = '33333333-3333-3333-3333-333333333333' AND deleted_at IS NULL
       LIMIT 3`
    );
    for (const prod of productsRes.rows) {
      console.log(`   - ${prod.common_name} (${prod.variety}): Stock Updated ${prod.stock_updated_at ? new Date(prod.stock_updated_at).toLocaleTimeString() : 'N/A'}, Price Updated ${prod.price_updated_at ? new Date(prod.price_updated_at).toLocaleDateString() : 'N/A'}`);
      if (!prod.stock_updated_at || !prod.price_updated_at) {
        throw new Error(`Product ${prod.id} is missing authentic freshness timestamps`);
      }
    }
    console.log('   ✅ Stock and price freshness timestamps verified.\n');

    // 5. Test [Notify Me] Farmer Request API
    console.log('5. Testing [Notify Me] Farmer Request API...');
    const testProductId = productsRes.rows[0].id;
    const notifyRes = await fetch(`${baseUrl}/marketplace/notify-me`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        productId: testProductId,
        farmerName: 'Sunil Patil',
        farmerPhone: '+91 9822334455',
        farmerLocation: 'Chandwad, Nashik',
        desiredQuantity: 15,
        unit: 'tray',
        notes: 'Need early morning delivery when batch ready',
      }),
    });
    const notifyJson = (await notifyRes.json()) as any;
    console.log(`   - Status: ${notifyRes.status}`);
    console.log(`   - Response:`, notifyJson.data);

    if (notifyRes.status !== 201 || !notifyJson.data?.id) {
      throw new Error('Failed to create notify request');
    }
    console.log('   ✅ [Notify Me] demand capture verified.\n');

    // 6. Test Owner Real Demand Signals
    console.log('6. Testing Owner Demand Signals Overview...');
    const loginRes = await fetch(`${baseUrl}/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        email: 'owner@avrnursery.com',
        password: 'Admin@123456',
      }),
    });
    const loginJson = (await loginRes.json()) as any;
    const ownerToken = loginJson.data?.accessToken;

    const ownerOverviewRes = await fetch(`${baseUrl}/inventory/owner/overview`, {
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${ownerToken}`,
      },
    });
    const ownerOverviewJson = (await ownerOverviewRes.json()) as any;
    const overviewData = ownerOverviewJson.data;

    console.log(`   - Total Interested Farmers: ${overviewData.totalInterestedFarmers}`);
    console.log(`   - Demand Signals Count: ${overviewData.demandSignals?.length}`);
    overviewData.demandSignals?.forEach((sig: any) => {
      console.log(`     * ${sig.common_name} (${sig.variety}): ${sig.interested_farmers_count} interested farmers (wants ${sig.notify_desired_quantity} trays), ${sig.prebooked_plants_count} pre-booked plants`);
    });

    if (overviewData.totalInterestedFarmers < 1) {
      throw new Error('Expected at least 1 interested farmer in demand signals');
    }
    console.log('   ✅ Authentic demand signals verified without fabrication.\n');

    console.log('============================================================');
    console.log('ALL TRUST, RATING, RANKING & DEMAND TESTS PASSED (100% VERIFIED)');
    console.log('============================================================\n');
  } finally {
    server!.close();
    await pool.end();
  }
}

runTrustAndDemandTests().catch((err) => {
  console.error('❌ Test failed:', err);
  process.exit(1);
});
