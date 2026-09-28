import { pool } from '../../config/database';
import { NotFoundError, ValidationError, ForbiddenError } from '../../middlewares/error.middleware';

export interface CreateOfferInput {
  title: string;
  shortDescription?: string;
  bannerImageUrl?: string;
  offerType: 'percentage_discount' | 'flat_discount' | 'special_price' | 'bulk_purchase' | 'prebook_offer' | 'early_bird' | 'limited_stock';
  discountType: 'percentage' | 'flat_amount' | 'special_unit_price';
  discountValue: number;
  applicableCrop?: string;
  applicableVariety?: string;
  minQuantity?: number;
  minOrderValue?: number;
  startDate: string | Date;
  endDate: string | Date;
  isPrebookingOffer?: boolean;
  maxRedemptions?: number;
  termsConditions?: string;
  eventLabel?: string;
  productIds?: string[];
}

export class OffersService {
  /**
   * Helper to compute effective offer status based on dates
   */
  static computeDynamicStatus(offer: any): string {
    if (offer.status === 'draft' || offer.status === 'paused' || offer.status === 'cancelled') {
      return offer.status;
    }
    const now = new Date();
    const start = new Date(offer.start_date);
    const end = new Date(offer.end_date);

    if (now > end) {
      return 'expired';
    }
    if (now < start) {
      return 'scheduled';
    }
    return 'active';
  }

  /**
   * List active offers for the farmer marketplace across all participating nurseries
   */
  static async getMarketplaceOffers(filters: { crop?: string; nurseryId?: string; city?: string }) {
    let query = `
      SELECT
        o.*,
        n.name AS nursery_name,
        n.code AS nursery_code,
        n.is_verified AS nursery_is_verified,
        COALESCE(n.rating, 4.8) AS nursery_rating,
        COALESCE(n.review_count, 120) AS nursery_reviews,
        COALESCE(n.image_url, 'assets/images/nursery_hero_banner.jpg') AS nursery_image_url,
        l.name AS location_name,
        l.address AS location_address,
        l.address->>'city' AS nursery_city,
        l.contact_phone AS nursery_phone,
        ARRAY_REMOVE(ARRAY_AGG(DISTINCT p.common_name), NULL) AS sample_products
      FROM nursery_offers o
      JOIN nurseries n ON n.tenant_id = o.tenant_id
      LEFT JOIN locations l ON l.nursery_id = n.id
      LEFT JOIN offer_products op ON op.offer_id = o.id
      LEFT JOIN products p ON (p.id = op.product_id OR (o.applicable_crop IS NOT NULL AND p.crop = o.applicable_crop AND p.tenant_id = o.tenant_id))
      WHERE o.status = 'active'
        AND o.start_date <= NOW()
        AND o.end_date >= NOW()
    `;

    const params: any[] = [];
    if (filters.crop && filters.crop.trim() !== '') {
      params.push(`%${filters.crop.trim()}%`);
      query += ` AND (o.applicable_crop ILIKE $${params.length} OR o.applicable_variety ILIKE $${params.length} OR o.title ILIKE $${params.length})`;
    }
    if (filters.nurseryId) {
      params.push(filters.nurseryId);
      query += ` AND (n.id = $${params.length} OR o.tenant_id = $${params.length})`;
    }
    if (filters.city && filters.city.trim() !== '') {
      params.push(`%${filters.city.trim()}%`);
      query += ` AND (l.address->>'city' ILIKE $${params.length} OR n.name ILIKE $${params.length})`;
    }

    query += `
      GROUP BY o.id, n.name, n.code, n.is_verified, n.rating, n.review_count, n.image_url,
               l.name, l.address, l.contact_phone
      ORDER BY o.created_at DESC
    `;

    const result = await pool.query(query, params);

    return result.rows.map((row) => {
      const now = new Date();
      const end = new Date(row.end_date);
      const remainingMs = Math.max(0, end.getTime() - now.getTime());
      const remainingHours = Math.floor(remainingMs / (1000 * 60 * 60));
      const remainingDays = Math.floor(remainingHours / 24);

      let validityText = '';
      if (remainingDays > 1) {
        validityText = `${remainingDays} days remaining`;
      } else if (remainingHours > 0) {
        validityText = `${remainingHours} hrs remaining`;
      } else {
        validityText = 'Ending soon';
      }

      const discountLabel =
        row.discount_type === 'percentage'
          ? `${Math.round(row.discount_value)}% OFF`
          : `₹${parseFloat(row.discount_value).toFixed(0)} OFF`;

      return {
        id: row.id,
        tenantId: row.tenant_id,
        nurseryId: row.nursery_id,
        title: row.title,
        shortDescription: row.short_description,
        bannerImageUrl: row.banner_image_url,
        offerType: row.offer_type,
        discountType: row.discount_type,
        discountValue: parseFloat(row.discount_value),
        discountLabel,
        applicableCrop: row.applicable_crop,
        applicableVariety: row.applicable_variety,
        minQuantity: row.min_quantity,
        minOrderValue: parseFloat(row.min_order_value || 0),
        startDate: row.start_date,
        endDate: row.end_date,
        isPrebookingOffer: row.is_prebooking_offer,
        maxRedemptions: row.max_redemptions,
        currentRedemptions: row.current_redemptions,
        status: 'active',
        termsConditions: row.terms_conditions,
        eventLabel: row.event_label ?? '🌿 Special Farmer Offer',
        validityText,
        remainingHours,
        nurseryName: row.nursery_name,
        nurseryCode: row.nursery_code,
        nurseryIsVerified: row.nursery_is_verified ?? true,
        nurseryRating: parseFloat(row.nursery_rating ?? 4.8),
        nurseryReviews: parseInt(row.nursery_reviews ?? 100, 10),
        nurseryImageUrl: row.nursery_image_url,
        nurseryCity: row.nursery_city ?? 'Maharashtra',
        nurseryPhone: row.nursery_phone,
        sampleProducts: row.sample_products ?? [],
      };
    });
  }

  /**
   * Get single offer details with eligible products
   */
  static async getOfferDetails(offerId: string) {
    const res = await pool.query(
      `SELECT o.*, n.name AS nursery_name, n.code AS nursery_code, n.is_verified,
              n.rating, n.review_count, n.image_url,
              l.name AS location_name, l.address, l.contact_phone
       FROM nursery_offers o
       JOIN nurseries n ON n.tenant_id = o.tenant_id
       LEFT JOIN locations l ON l.nursery_id = n.id
       WHERE o.id = $1`,
      [offerId]
    );

    if (!res.rows[0]) {
      throw new NotFoundError('Offer');
    }

    const o = res.rows[0];
    const dynamicStatus = this.computeDynamicStatus(o);

    // Fetch applicable products
    let prodQuery = `
      SELECT p.id, p.common_name, p.crop, p.variety, p.price, p.plant_price, p.tray_price,
             p.tray_size, p.images, p.status, p.stock_state,
             COALESCE(SUM(inv.quantity_available), 0) AS ready_stock
      FROM products p
      LEFT JOIN inventory inv ON inv.product_id = p.id
      WHERE p.tenant_id = $1 AND p.deleted_at IS NULL AND p.status = 'active'
    `;
    const prodParams: any[] = [o.tenant_id];

    if (o.applicable_crop) {
      prodParams.push(o.applicable_crop);
      prodQuery += ` AND p.crop = $${prodParams.length}`;
    }
    if (o.applicable_variety) {
      prodParams.push(o.applicable_variety);
      prodQuery += ` AND p.variety ILIKE $${prodParams.length}`;
    }

    prodQuery += ` GROUP BY p.id ORDER BY p.common_name ASC LIMIT 20`;
    const prodRes = await pool.query(prodQuery, prodParams);

    const discountLabel =
      o.discount_type === 'percentage'
        ? `${Math.round(o.discount_value)}% OFF`
        : `₹${parseFloat(o.discount_value).toFixed(0)} OFF`;

    return {
      id: o.id,
      tenantId: o.tenant_id,
      nurseryId: o.nursery_id,
      title: o.title,
      shortDescription: o.short_description,
      bannerImageUrl: o.banner_image_url,
      offerType: o.offer_type,
      discountType: o.discount_type,
      discountValue: parseFloat(o.discount_value),
      discountLabel,
      applicableCrop: o.applicable_crop,
      applicableVariety: o.applicable_variety,
      minQuantity: o.min_quantity,
      minOrderValue: parseFloat(o.min_order_value || 0),
      startDate: o.start_date,
      endDate: o.end_date,
      isPrebookingOffer: o.is_prebooking_offer,
      maxRedemptions: o.max_redemptions,
      currentRedemptions: o.current_redemptions,
      status: dynamicStatus,
      rawStatus: o.status,
      termsConditions: o.terms_conditions,
      eventLabel: o.event_label,
      nursery: {
        id: o.nursery_id,
        name: o.nursery_name,
        code: o.nursery_code,
        isVerified: o.is_verified ?? true,
        rating: parseFloat(o.rating ?? 4.8),
        reviewCount: parseInt(o.review_count ?? 100, 10),
        imageUrl: o.image_url,
        city: o.address?.city ?? 'Maharashtra',
        phone: o.contact_phone,
      },
      applicableProducts: prodRes.rows.map((p) => {
        const basePrice = parseFloat(p.tray_price ?? p.price ?? 200);
        let discountedPrice = basePrice;
        if (o.discount_type === 'percentage') {
          discountedPrice = Math.max(0, Math.round(basePrice * (1 - o.discount_value / 100) * 100) / 100);
        } else if (o.discount_type === 'flat_amount') {
          discountedPrice = Math.max(0, Math.round((basePrice - o.discount_value) * 100) / 100);
        }
        return {
          id: p.id,
          name: p.common_name,
          crop: p.crop,
          variety: p.variety,
          originalPrice: basePrice,
          offerPrice: discountedPrice,
          traySize: p.tray_size ?? 104,
          readyStock: parseInt(p.ready_stock ?? 0, 10),
          stockState: p.stock_state ?? 'ready_now',
        };
      }),
    };
  }

  /**
   * Authoritative backend discount calculator for cart and checkout
   */
  static async calculateDiscount(
    tenantId: string,
    offerId: string,
    items: Array<{ productId: string; quantity: number }>
  ): Promise<{
    isValid: boolean;
    discountAmount: number;
    subtotal: number;
    finalTotal: number;
    reason?: string;
  }> {
    const offerRes = await pool.query(
      `SELECT * FROM nursery_offers WHERE id = $1 AND tenant_id = $2`,
      [offerId, tenantId]
    );

    if (!offerRes.rows[0]) {
      return { isValid: false, discountAmount: 0, subtotal: 0, finalTotal: 0, reason: 'Offer not found for this nursery' };
    }

    const offer = offerRes.rows[0];
    const dynStatus = this.computeDynamicStatus(offer);
    if (dynStatus !== 'active') {
      return { isValid: false, discountAmount: 0, subtotal: 0, finalTotal: 0, reason: `Offer is currently ${dynStatus}` };
    }

    if (offer.max_redemptions && offer.current_redemptions >= offer.max_redemptions) {
      return { isValid: false, discountAmount: 0, subtotal: 0, finalTotal: 0, reason: 'Offer redemption limit reached' };
    }

    // Fetch product details
    const productIds = items.map((i) => i.productId);
    const prodRes = await pool.query(
      `SELECT id, price, crop, variety FROM products WHERE id = ANY($1) AND tenant_id = $2 AND deleted_at IS NULL`,
      [productIds, tenantId]
    );

    const prodMap = new Map<string, any>();
    for (const p of prodRes.rows) {
      prodMap.set(p.id, p);
    }

    let subtotal = 0;
    let eligibleSubtotal = 0;
    let eligibleQuantity = 0;

    for (const item of items) {
      const prod = prodMap.get(item.productId);
      if (!prod) continue;

      const unitPrice = parseFloat(prod.price);
      const lineTotal = unitPrice * item.quantity;
      subtotal += lineTotal;

      let isEligible = true;
      if (offer.applicable_crop && prod.crop && prod.crop.toLowerCase() !== offer.applicable_crop.toLowerCase()) {
        isEligible = false;
      }
      if (offer.applicable_variety && prod.variety) {
        const pv = prod.variety.toLowerCase();
        const ov = offer.applicable_variety.toLowerCase();
        if (!pv.includes(ov) && !ov.includes(pv)) {
          isEligible = false;
        }
      }

      if (isEligible) {
        eligibleSubtotal += lineTotal;
        eligibleQuantity += item.quantity;
      }
    }

    if (eligibleQuantity === 0) {
      return { isValid: false, discountAmount: 0, subtotal, finalTotal: subtotal, reason: 'No items in cart match the offer terms' };
    }

    if (offer.min_quantity && eligibleQuantity < offer.min_quantity) {
      return {
        isValid: false,
        discountAmount: 0,
        subtotal,
        finalTotal: subtotal,
        reason: `Minimum ${offer.min_quantity} items required for this offer (current: ${eligibleQuantity})`,
      };
    }

    if (offer.min_order_value && eligibleSubtotal < parseFloat(offer.min_order_value)) {
      return {
        isValid: false,
        discountAmount: 0,
        subtotal,
        finalTotal: subtotal,
        reason: `Minimum order value ₹${offer.min_order_value} required for this offer`,
      };
    }

    let discountAmount = 0;
    const discountVal = parseFloat(offer.discount_value);

    if (offer.discount_type === 'percentage') {
      discountAmount = Math.round((eligibleSubtotal * (discountVal / 100)) * 100) / 100;
    } else if (offer.discount_type === 'flat_amount') {
      discountAmount = Math.min(eligibleSubtotal, discountVal);
    } else if (offer.discount_type === 'special_unit_price') {
      discountAmount = Math.max(0, eligibleSubtotal - discountVal * eligibleQuantity);
    }

    discountAmount = Math.round(discountAmount * 100) / 100;
    const finalTotal = Math.max(0, Math.round((subtotal - discountAmount) * 100) / 100);

    return {
      isValid: true,
      discountAmount,
      subtotal,
      finalTotal,
    };
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // NURSERY OWNER OFFER MANAGEMENT (Strictly Tenant Scoped)
  // ─────────────────────────────────────────────────────────────────────────────

  /**
   * List offers belonging to the authenticated owner's tenant
   */
  static async getOwnerOffers(tenantId: string, statusFilter?: string) {
    let query = `
      SELECT o.*,
             COUNT(DISTINCT op.product_id) AS custom_products_count
      FROM nursery_offers o
      LEFT JOIN offer_products op ON op.offer_id = o.id
      WHERE o.tenant_id = $1
    `;
    const params: any[] = [tenantId];

    if (statusFilter && statusFilter !== 'all') {
      params.push(statusFilter);
      query += ` AND o.status = $${params.length}`;
    }

    query += ` GROUP BY o.id ORDER BY o.created_at DESC`;

    const res = await pool.query(query, params);

    return res.rows.map((row) => ({
      ...row,
      discount_value: parseFloat(row.discount_value),
      min_order_value: parseFloat(row.min_order_value || 0),
      dynamic_status: this.computeDynamicStatus(row),
    }));
  }

  /**
   * Create new offer for owner's tenant
   */
  static async createOffer(tenantId: string, input: CreateOfferInput) {
    if (input.discountValue <= 0) {
      throw new ValidationError('Discount value must be greater than zero');
    }

    const start = new Date(input.startDate);
    const end = new Date(input.endDate);
    if (isNaN(start.getTime()) || isNaN(end.getTime())) {
      throw new ValidationError('Valid start date and end date are required');
    }
    if (end <= start) {
      throw new ValidationError('End date must be after start date');
    }

    // Fetch nursery id for tenant
    const nurseryRes = await pool.query(`SELECT id FROM nurseries WHERE tenant_id = $1 LIMIT 1`, [tenantId]);
    const nurseryId = nurseryRes.rows[0]?.id || null;

    const client = await pool.connect();
    try {
      await client.query('BEGIN');

      const now = new Date();
      let initialStatus = 'active';
      if (start > now) {
        initialStatus = 'scheduled';
      }

      const insertRes = await client.query(
        `INSERT INTO nursery_offers
          (tenant_id, nursery_id, title, short_description, banner_image_url, offer_type,
           discount_type, discount_value, applicable_crop, applicable_variety, min_quantity,
           min_order_value, start_date, end_date, is_prebooking_offer, max_redemptions,
           status, terms_conditions, event_label)
         VALUES
          ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19)
         RETURNING *`,
        [
          tenantId,
          nurseryId,
          input.title,
          input.shortDescription ?? null,
          input.bannerImageUrl ?? null,
          input.offerType,
          input.discountType,
          input.discountValue,
          input.applicableCrop ?? null,
          input.applicableVariety ?? null,
          input.minQuantity ?? 1,
          input.minOrderValue ?? 0,
          start,
          end,
          input.isPrebookingOffer ?? false,
          input.maxRedemptions ?? null,
          initialStatus,
          input.termsConditions ?? null,
          input.eventLabel ?? '🌿 Farmer Offer',
        ]
      );

      const offer = insertRes.rows[0];

      // Bind individual products if provided
      if (input.productIds && input.productIds.length > 0) {
        for (const pid of input.productIds) {
          await client.query(
            `INSERT INTO offer_products (offer_id, product_id)
             SELECT $1, id FROM products WHERE id = $2 AND tenant_id = $3
             ON CONFLICT DO NOTHING`,
            [offer.id, pid, tenantId]
          );
        }
      }

      await client.query('COMMIT');
      return offer;
    } catch (err) {
      await client.query('ROLLBACK');
      throw err;
    } finally {
      client.release();
    }
  }

  /**
   * Update offer (tenant scoped)
   */
  static async updateOffer(tenantId: string, offerId: string, input: Partial<CreateOfferInput>) {
    const existing = await pool.query(
      `SELECT * FROM nursery_offers WHERE id = $1 AND tenant_id = $2`,
      [offerId, tenantId]
    );

    if (!existing.rows[0]) {
      throw new NotFoundError('Offer');
    }

    const cur = existing.rows[0];
    const title = input.title ?? cur.title;
    const shortDesc = input.shortDescription !== undefined ? input.shortDescription : cur.short_description;
    const bannerUrl = input.bannerImageUrl !== undefined ? input.bannerImageUrl : cur.banner_image_url;
    const offerType = input.offerType ?? cur.offer_type;
    const discountType = input.discountType ?? cur.discount_type;
    const discountValue = input.discountValue ?? parseFloat(cur.discount_value);
    const applicableCrop = input.applicableCrop !== undefined ? input.applicableCrop : cur.applicable_crop;
    const applicableVariety = input.applicableVariety !== undefined ? input.applicableVariety : cur.applicable_variety;
    const minQty = input.minQuantity ?? cur.min_quantity;
    const minOrderVal = input.minOrderValue ?? parseFloat(cur.min_order_value);
    const start = input.startDate ? new Date(input.startDate) : cur.start_date;
    const end = input.endDate ? new Date(input.endDate) : cur.end_date;
    const isPrebook = input.isPrebookingOffer ?? cur.is_prebooking_offer;
    const maxRedemptions = input.maxRedemptions !== undefined ? input.maxRedemptions : cur.max_redemptions;
    const terms = input.termsConditions !== undefined ? input.termsConditions : cur.terms_conditions;
    const eventLabel = input.eventLabel !== undefined ? input.eventLabel : cur.event_label;

    if (discountValue <= 0) throw new ValidationError('Discount value must be greater than zero');
    if (end <= start) throw new ValidationError('End date must be after start date');

    const updateRes = await pool.query(
      `UPDATE nursery_offers SET
         title = $1, short_description = $2, banner_image_url = $3, offer_type = $4,
         discount_type = $5, discount_value = $6, applicable_crop = $7, applicable_variety = $8,
         min_quantity = $9, min_order_value = $10, start_date = $11, end_date = $12,
         is_prebooking_offer = $13, max_redemptions = $14, terms_conditions = $15,
         event_label = $16, updated_at = NOW()
       WHERE id = $17 AND tenant_id = $18
       RETURNING *`,
      [
        title, shortDesc, bannerUrl, offerType, discountType, discountValue,
        applicableCrop, applicableVariety, minQty, minOrderVal, start, end,
        isPrebook, maxRedemptions, terms, eventLabel, offerId, tenantId
      ]
    );

    return updateRes.rows[0];
  }

  /**
   * Change offer status (pause, resume, cancel, publish)
   */
  static async updateOfferStatus(tenantId: string, offerId: string, newStatus: string) {
    const validStatuses = ['draft', 'scheduled', 'active', 'paused', 'expired', 'cancelled'];
    if (!validStatuses.includes(newStatus)) {
      throw new ValidationError(`Invalid status: ${newStatus}`);
    }

    const res = await pool.query(
      `UPDATE nursery_offers
       SET status = $1, updated_at = NOW()
       WHERE id = $2 AND tenant_id = $3
       RETURNING *`,
      [newStatus, offerId, tenantId]
    );

    if (!res.rows[0]) {
      throw new NotFoundError('Offer');
    }

    return res.rows[0];
  }

  /**
   * Delete or cancel offer
   */
  static async deleteOffer(tenantId: string, offerId: string) {
    const res = await pool.query(
      `DELETE FROM nursery_offers WHERE id = $1 AND tenant_id = $2 RETURNING id`,
      [offerId, tenantId]
    );

    if (!res.rows[0]) {
      throw new NotFoundError('Offer');
    }

    return { deleted: true, id: offerId };
  }
}
