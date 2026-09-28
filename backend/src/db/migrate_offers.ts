import { pool } from '../config/database';

export async function migrateOffers() {
  console.log('--- Applying Nursery Offers & Campaigns Migration ---');

  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    // 1. Create nursery_offers table
    await client.query(`
      CREATE TABLE IF NOT EXISTS nursery_offers (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
        nursery_id UUID REFERENCES nurseries(id) ON DELETE CASCADE,
        title VARCHAR(255) NOT NULL,
        short_description TEXT,
        banner_image_url TEXT,
        offer_type VARCHAR(50) NOT NULL DEFAULT 'percentage_discount',
        discount_type VARCHAR(30) NOT NULL DEFAULT 'percentage',
        discount_value NUMERIC(10, 2) NOT NULL,
        applicable_crop VARCHAR(100),
        applicable_variety VARCHAR(100),
        min_quantity INT DEFAULT 1,
        min_order_value NUMERIC(10, 2) DEFAULT 0.00,
        start_date TIMESTAMPTZ NOT NULL,
        end_date TIMESTAMPTZ NOT NULL,
        is_prebooking_offer BOOLEAN DEFAULT FALSE,
        max_redemptions INT,
        current_redemptions INT DEFAULT 0,
        status VARCHAR(30) NOT NULL DEFAULT 'active',
        terms_conditions TEXT,
        event_label VARCHAR(100),
        created_at TIMESTAMPTZ DEFAULT NOW(),
        updated_at TIMESTAMPTZ DEFAULT NOW()
      );

      CREATE INDEX IF NOT EXISTS idx_nursery_offers_tenant ON nursery_offers(tenant_id, status);
      CREATE INDEX IF NOT EXISTS idx_nursery_offers_dates ON nursery_offers(start_date, end_date, status);
      CREATE INDEX IF NOT EXISTS idx_nursery_offers_crop ON nursery_offers(applicable_crop);
    `);

    // 2. Create offer_products table for explicit product bindings
    await client.query(`
      CREATE TABLE IF NOT EXISTS offer_products (
        offer_id UUID NOT NULL REFERENCES nursery_offers(id) ON DELETE CASCADE,
        product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
        created_at TIMESTAMPTZ DEFAULT NOW(),
        PRIMARY KEY (offer_id, product_id)
      );

      CREATE INDEX IF NOT EXISTS idx_offer_products_offer ON offer_products(offer_id);
      CREATE INDEX IF NOT EXISTS idx_offer_products_product ON offer_products(product_id);
    `);

    // 3. Extend orders table to track applied offer and discount
    await client.query(`
      ALTER TABLE orders ADD COLUMN IF NOT EXISTS offer_id UUID REFERENCES nursery_offers(id) ON DELETE SET NULL;
    `);

    // 4. Seed initial authentic multi-nursery campaigns
    const tenantA = '33333333-3333-3333-3333-333333333333'; // AVR Green Yeola
    const nurseryA = '44444444-4444-4444-4444-444444444444';
    const tenantB = '33333333-3333-3333-3333-333333333334'; // Sai Krupa
    const nurseryB = '44444444-4444-4444-4444-444444444445';
    const tenantC = '33333333-3333-3333-3333-333333333335'; // Godavari Hi-Tech
    const nurseryC = '44444444-4444-4444-4444-444444444446';
    const tenantD = '33333333-3333-3333-3333-333333333336'; // Chandwad Farmers
    const nurseryD = '44444444-4444-4444-4444-444444444447';

    // Insert sample seasonal campaign offers for each participating nursery
    const now = new Date();
    const tenDaysFromNow = new Date(Date.now() + 10 * 86400000);
    const twentyDaysFromNow = new Date(Date.now() + 20 * 86400000);
    const fiveDaysAgo = new Date(Date.now() - 5 * 86400000);

    const offers = [
      {
        id: '77777777-1111-1111-1111-111111111101',
        tenant_id: tenantA,
        nursery_id: nurseryA,
        title: 'Ganesh Chaturthi Farmer Offer',
        short_description: 'Special 10% OFF on all Tomato & Chilli hybrid seedling trays for festival plantation.',
        offer_type: 'percentage_discount',
        discount_type: 'percentage',
        discount_value: 10,
        applicable_crop: 'Tomato',
        applicable_variety: 'Abhinav Hybrid',
        min_quantity: 2,
        min_order_value: 300,
        start_date: fiveDaysAgo,
        end_date: tenDaysFromNow,
        is_prebooking_offer: false,
        max_redemptions: 100,
        current_redemptions: 14,
        status: 'active',
        terms_conditions: 'Valid on orders of 2 or more seedling trays. Cannot be combined with other nursery bulk discounts.',
        event_label: '🌿 Farmer Festival Offer',
      },
      {
        id: '77777777-1111-1111-1111-111111111102',
        tenant_id: tenantB,
        nursery_id: nurseryB,
        title: 'Rabi Season Pre-Booking Special',
        short_description: 'Book Balram & Bullet Teja Chilli Trays in advance with flat ₹50 OFF per 5 trays.',
        offer_type: 'bulk_purchase',
        discount_type: 'flat_amount',
        discount_value: 50,
        applicable_crop: 'Chilli',
        applicable_variety: 'Balram',
        min_quantity: 5,
        min_order_value: 1000,
        start_date: fiveDaysAgo,
        end_date: twentyDaysFromNow,
        is_prebooking_offer: true,
        max_redemptions: 50,
        current_redemptions: 9,
        status: 'active',
        terms_conditions: 'Applicable on advance pre-bookings for October Rabi dispatch batches. Advance 20% required.',
        event_label: '🔥 Early Booking Offer',
      },
      {
        id: '77777777-1111-1111-1111-111111111103',
        tenant_id: tenantC,
        nursery_id: nurseryC,
        title: 'Polyhouse Colored Capsicum & Cherry Tomato Launch',
        short_description: 'Special introductory tray pricing on high-yield exotic vegetable seedlings.',
        offer_type: 'special_price',
        discount_type: 'percentage',
        discount_value: 15,
        applicable_crop: 'Capsicum',
        applicable_variety: 'Hybrid Capsicum',
        min_quantity: 1,
        min_order_value: 250,
        start_date: fiveDaysAgo,
        end_date: tenDaysFromNow,
        is_prebooking_offer: false,
        max_redemptions: 75,
        current_redemptions: 6,
        status: 'active',
        terms_conditions: 'Valid for farm pickup and local dispatch in Nashik region while stock lasts.',
        event_label: '⭐ High-Tech Special',
      },
      {
        id: '77777777-1111-1111-1111-111111111104',
        tenant_id: tenantD,
        nursery_id: nurseryD,
        title: 'Chandwad Kisan Monsoon Plantation Offer',
        short_description: 'Flat ₹40 OFF on Calcutta Orange Marigold and Kagzi Lemon saplings.',
        offer_type: 'flat_discount',
        discount_type: 'flat_amount',
        discount_value: 40,
        applicable_crop: 'Marigold',
        applicable_variety: 'Calcutta Orange',
        min_quantity: 3,
        min_order_value: 400,
        start_date: fiveDaysAgo,
        end_date: fifteenDaysFromNow(15),
        is_prebooking_offer: false,
        max_redemptions: 60,
        current_redemptions: 11,
        status: 'active',
        terms_conditions: 'Minimum 3 trays/units of Marigold or Lemon required for discount application.',
        event_label: '🌱 Local Farmer Discount',
      },
      {
        id: '77777777-1111-1111-1111-111111111105',
        tenant_id: tenantA,
        nursery_id: nurseryA,
        title: 'Upcoming Diwali Flower & Fruit Sapling Gala',
        short_description: 'Exclusive 20% savings on decorative flower varieties scheduled for next month.',
        offer_type: 'percentage_discount',
        discount_type: 'percentage',
        discount_value: 20,
        applicable_crop: 'Marigold',
        applicable_variety: null,
        min_quantity: 4,
        min_order_value: 500,
        start_date: new Date(Date.now() + 5 * 86400000), // In future -> scheduled
        end_date: new Date(Date.now() + 25 * 86400000),
        is_prebooking_offer: true,
        max_redemptions: 40,
        current_redemptions: 0,
        status: 'scheduled',
        terms_conditions: 'Scheduled festival campaign. Activates automatically on start date.',
        event_label: '🪔 Festival Upcoming',
      },
    ];

    function fifteenDaysFromNow(days: number) {
      return new Date(Date.now() + days * 86400000);
    }

    for (const o of offers) {
      await client.query(`
        INSERT INTO nursery_offers
          (id, tenant_id, nursery_id, title, short_description, offer_type, discount_type, discount_value,
           applicable_crop, applicable_variety, min_quantity, min_order_value, start_date, end_date,
           is_prebooking_offer, max_redemptions, current_redemptions, status, terms_conditions, event_label)
        VALUES
          ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20)
        ON CONFLICT (id) DO UPDATE SET
          title = EXCLUDED.title,
          short_description = EXCLUDED.short_description,
          discount_value = EXCLUDED.discount_value,
          applicable_crop = EXCLUDED.applicable_crop,
          status = EXCLUDED.status,
          start_date = EXCLUDED.start_date,
          end_date = EXCLUDED.end_date,
          event_label = EXCLUDED.event_label;
      `, [
        o.id, o.tenant_id, o.nursery_id, o.title, o.short_description, o.offer_type, o.discount_type, o.discount_value,
        o.applicable_crop, o.applicable_variety, o.min_quantity, o.min_order_value, o.start_date, o.end_date,
        o.is_prebooking_offer, o.max_redemptions, o.current_redemptions, o.status, o.terms_conditions, o.event_label
      ]);
    }

    await client.query('COMMIT');
    console.log('✅ Nursery Offers & Campaigns migration completed successfully.');
  } catch (err) {
    await client.query('ROLLBACK');
    console.error('❌ Offers migration failed:', err);
    throw err;
  } finally {
    client.release();
  }
}

if (require.main === module) {
  migrateOffers().then(() => pool.end()).catch(() => pool.end());
}
