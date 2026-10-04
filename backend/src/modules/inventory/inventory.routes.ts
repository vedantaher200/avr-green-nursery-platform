import { Router } from 'express';
import { authenticate } from '../../middlewares/auth.middleware';
import { requirePermission } from '../../middlewares/rbac.middleware';
import { validate, uuidParam, paginationQuery } from '../../middlewares/validate.middleware';
import { asyncHandler, NotFoundError, ValidationError } from '../../middlewares/error.middleware';
import { successResponse, paginationMeta } from '../../shared/response';
import { pool } from '../../config/database';
import { z } from 'zod';

// ─────────────────────────────────────────────────────────────────────────────
// Inventory Module — Real-time stock management, movements, & transfers
// ─────────────────────────────────────────────────────────────────────────────

const AdjustmentDto = z.object({
  productId: z.string().uuid(),
  locationId: z.string().uuid(),
  batchNumber: z.string().default('DEFAULT_BATCH'),
  quantity: z.number().int(),
  type: z.enum(['adjustment', 'damaged']),
  notes: z.string().optional(),
});

const TransferDto = z.object({
  productId: z.string().uuid(),
  sourceLocationId: z.string().uuid(),
  destinationLocationId: z.string().uuid(),
  quantity: z.number().int().positive(),
  notes: z.string().optional(),
});

const router = Router();
router.use(authenticate);

// ── GET / — inventory list with low-stock flag ────────────────────────────────
router.get(
  '/',
  validate({ query: paginationQuery }),
  asyncHandler(async (req, res) => {
    const { page, limit, search } = req.query as any;
    const offset = (page - 1) * limit;

    const result = await pool.query(
      `SELECT i.*,
              p.common_name, p.sku, p.price,
              l.name AS location_name,
              l.type AS location_type,
              (i.quantity_available <= i.low_stock_threshold) AS is_low_stock
       FROM inventory i
       JOIN products p ON p.id = i.product_id
       JOIN locations l ON l.id = i.location_id
       WHERE i.tenant_id = $1
         ${search ? `AND p.common_name ILIKE $4` : ''}
       ORDER BY is_low_stock DESC, p.common_name ASC
       LIMIT $2 OFFSET $3`,
      search
        ? [req.tenantId, limit, offset, `%${search}%`]
        : [req.tenantId, limit, offset]
    );

    const countResult = await pool.query(
      `SELECT COUNT(*) FROM inventory WHERE tenant_id = $1`,
      [req.tenantId]
    );

    res.json(
      successResponse(
        result.rows,
        undefined,
        paginationMeta(parseInt(countResult.rows[0].count, 10), page, limit)
      )
    );
  })
);

// ── GET /low-stock — items below threshold ────────────────────────────────────
router.get(
  '/low-stock',
  asyncHandler(async (req, res) => {
    const result = await pool.query(
      `SELECT i.*, p.common_name, p.sku, l.name AS location_name
       FROM inventory i
       JOIN products p ON p.id = i.product_id
       JOIN locations l ON l.id = i.location_id
       WHERE i.tenant_id = $1 AND i.quantity_available <= i.low_stock_threshold
       ORDER BY i.quantity_available ASC`,
      [req.tenantId]
    );
    res.json(successResponse(result.rows));
  })
);

// ── POST /adjust — stock adjustment / damage write-off ───────────────────────
router.post(
  '/adjust',
  requirePermission('inventory.write'),
  validate({ body: AdjustmentDto }),
  asyncHandler(async (req, res) => {
    const d = req.body;
    const client = await pool.connect();
    try {
      await client.query('BEGIN');

      // Find inventory record
      const invResult = await client.query(
        `SELECT id, quantity_available, quantity_damaged
         FROM inventory
         WHERE product_id = $1 AND location_id = $2 AND batch_number = $3 AND tenant_id = $4
         FOR UPDATE`,
        [d.productId, d.locationId, d.batchNumber, req.tenantId]
      );

      if (!invResult.rows[0]) {
        throw new NotFoundError('Inventory record');
      }

      const inv = invResult.rows[0];
      const newQty = inv.quantity_available + d.quantity;

      if (newQty < 0) {
        throw new ValidationError(`Insufficient stock. Available: ${inv.quantity_available}`);
      }

      // Update inventory
      if (d.type === 'damaged') {
        await client.query(
          `UPDATE inventory
           SET quantity_damaged = quantity_damaged + $1,
               quantity_available = quantity_available - $1,
               updated_at = NOW()
           WHERE id = $2`,
          [Math.abs(d.quantity), inv.id]
        );
      } else {
        await client.query(
          `UPDATE inventory SET quantity_available = $1, updated_at = NOW() WHERE id = $2`,
          [newQty, inv.id]
        );
      }

      // Record movement
      await client.query(
        `INSERT INTO inventory_movements
           (tenant_id, inventory_id, type, quantity, notes, performed_by)
         VALUES ($1, $2, $3, $4, $5, $6)`,
        [req.tenantId, inv.id, d.type, d.quantity, d.notes ?? null, req.user!.userId]
      );

      await client.query('COMMIT');
      res.json(successResponse({ adjusted: true }, 'Stock adjusted successfully'));
    } catch (err) {
      await client.query('ROLLBACK');
      throw err;
    } finally {
      client.release();
    }
  })
);

// ── POST /transfer — inter-location stock transfer ────────────────────────────
router.post(
  '/transfer',
  requirePermission('inventory.write'),
  validate({ body: TransferDto }),
  asyncHandler(async (req, res) => {
    const d = req.body;
    const result = await pool.query(
      `INSERT INTO stock_transfers
         (tenant_id, product_id, source_location_id, destination_location_id, quantity, notes, requested_by, status)
       VALUES ($1,$2,$3,$4,$5,$6,$7,'requested')
       RETURNING *`,
      [req.tenantId, d.productId, d.sourceLocationId, d.destinationLocationId, d.quantity, d.notes ?? null, req.user!.userId]
    );
    res.status(201).json(successResponse(result.rows[0], 'Transfer request created'));
  })
);

// ── GET /movements/:productId — movement history ──────────────────────────────
router.get(
  '/movements/:productId',
  validate({ params: uuidParam.extend({ productId: z.string().uuid() }).omit({ id: true }).extend({ productId: z.string().uuid() }) }),
  asyncHandler(async (req, res) => {
    const result = await pool.query(
      `SELECT im.*, u.first_name, u.last_name, l.name AS location_name
       FROM inventory_movements im
       JOIN inventory i ON i.id = im.inventory_id
       JOIN locations l ON l.id = i.location_id
       LEFT JOIN users u ON u.id = im.performed_by
       WHERE im.tenant_id = $1 AND i.product_id = $2
       ORDER BY im.created_at DESC
       LIMIT 100`,
      [req.tenantId, req.params.productId]
    );
    res.json(successResponse(result.rows));
  })
);

// ─────────────────────────────────────────────────────────────────────────────
// NURSERY OWNER SUPPLY-SIDE ENDPOINTS (Tenant Isolated & Transactional)
// ─────────────────────────────────────────────────────────────────────────────

const OwnerStockUpdateDto = z.object({
  readyStock: z.number().int().min(0).optional(),
  futureStock: z.number().int().min(0).optional(),
  expectedReadyDate: z.string().optional(),
  plantPrice: z.number().min(0).optional(),
  trayPrice: z.number().min(0).optional(),
  bulkPrice: z.number().min(0).optional(),
  trayCapacity: z.number().int().positive().optional(),
  minOrderQty: z.number().int().positive().optional(),
  stockState: z.enum(['ready_now', 'limited_stock', 'coming_soon', 'prebook_available', 'sold_out']).optional(),
  isPrebookable: z.boolean().optional(),
  images: z.array(z.string()).optional(),
  commonName: z.string().optional(),
  variety: z.string().optional(),
});

const AnnouncementDto = z.object({
  title: z.string().min(3),
  content: z.string().min(5),
  crop: z.string().optional(),
  variety: z.string().optional(),
  readyQuantity: z.number().int().optional(),
  futureQuantity: z.number().int().optional(),
  expectedDays: z.number().int().optional(),
  unit: z.string().default('plants'),
});

// ── GET /owner/overview — Nursery Owner Dashboard Supply KPIs ─────────────────
router.get(
  '/owner/overview',
  asyncHandler(async (req, res) => {
    const tenantId = req.tenantId;

    // 1. Ready & Reserved Stock
    const stockQuery = await pool.query(
      `SELECT COALESCE(SUM(i.quantity_available), 0) AS total_ready,
              COALESCE(SUM(i.quantity_reserved), 0) AS total_reserved
       FROM inventory i
       WHERE i.tenant_id = $1`,
      [tenantId]
    );

    // 2. Pre-booked quantities & pending bookings
    const prebookQuery = await pool.query(
      `SELECT COALESCE(SUM(pb.total_plants), 0) AS prebooked_plants,
              COUNT(CASE WHEN pb.status = 'pending' THEN 1 END) AS pending_count
       FROM pre_bookings pb
       WHERE pb.tenant_id = $1 AND pb.status IN ('pending', 'confirmed')`,
      [tenantId]
    );

    // 3. Future planned production & earliest expected batch date
    const futureQuery = await pool.query(
      `SELECT COALESCE(SUM(p.future_stock), 0) AS future_production,
              MIN(p.expected_ready_date) AS earliest_ready_date
       FROM products p
       WHERE p.tenant_id = $1 AND p.deleted_at IS NULL`,
      [tenantId]
    );

    // 4. Products list with live ready & future counts
    const productsQuery = await pool.query(
      `SELECT p.id, p.tenant_id, p.sku, p.common_name, p.scientific_name, p.crop, p.variety,
              p.price, p.plant_price, p.tray_price, p.bulk_price, p.tray_capacity,
              p.future_stock, p.expected_ready_date, p.min_order_qty, p.is_prebookable,
              p.stock_state, p.images,
              COALESCE(SUM(i.quantity_available), 0)::int AS ready_stock,
              COALESCE(SUM(i.quantity_reserved), 0)::int AS reserved_stock
       FROM products p
       LEFT JOIN inventory i ON i.product_id = p.id
       WHERE p.tenant_id = $1 AND p.deleted_at IS NULL
       GROUP BY p.id
       ORDER BY p.common_name ASC`,
      [tenantId]
    );

    // 5. Recent Farmer Pre-Bookings
    const recentPrebookingsQuery = await pool.query(
      `SELECT pb.*, p.common_name, p.crop, p.variety
       FROM pre_bookings pb
       JOIN products p ON p.id = pb.product_id
       WHERE pb.tenant_id = $1
       ORDER BY pb.created_at DESC
       LIMIT 10`,
      [tenantId]
    );

    // 6. Active Nursery Announcements
    const announcementsQuery = await pool.query(
      `SELECT * FROM nursery_announcements
       WHERE tenant_id = $1 AND is_active = true
       ORDER BY created_at DESC`,
      [tenantId]
    );

    // 7. Authentic Farmer Demand Signals (aggregation of pre-bookings & notification interest)
    const demandSignalsQuery = await pool.query(
      `SELECT
         p.id AS product_id,
         p.common_name,
         p.crop,
         p.variety,
         COUNT(DISTINCT pnr.id) AS interested_farmers_count,
         COALESCE(SUM(pnr.desired_quantity), 0)::int AS notify_desired_quantity,
         COALESCE(SUM(pb.total_plants), 0)::int AS prebooked_plants_count,
         COUNT(DISTINCT pb.id) AS prebook_orders_count
       FROM products p
       LEFT JOIN product_notify_requests pnr ON pnr.product_id = p.id AND pnr.status = 'active'
       LEFT JOIN pre_bookings pb ON pb.product_id = p.id AND pb.status IN ('pending', 'confirmed')
       WHERE p.tenant_id = $1 AND p.deleted_at IS NULL
       GROUP BY p.id, p.common_name, p.crop, p.variety
       HAVING COUNT(DISTINCT pnr.id) > 0 OR COUNT(DISTINCT pb.id) > 0
       ORDER BY (COUNT(DISTINCT pnr.id) + COUNT(DISTINCT pb.id)) DESC`,
      [tenantId]
    );

    const notifyRequestsQuery = await pool.query(
      `SELECT pnr.*, p.common_name, p.crop, p.variety
       FROM product_notify_requests pnr
       JOIN products p ON p.id = pnr.product_id
       WHERE pnr.tenant_id = $1
       ORDER BY pnr.created_at DESC
       LIMIT 10`,
      [tenantId]
    );

    const totalInterestedFarmers = parseInt(
      (await pool.query(`SELECT COUNT(DISTINCT farmer_phone) AS total FROM product_notify_requests WHERE tenant_id = $1 AND status = 'active'`, [tenantId])).rows[0]?.total ?? '0',
      10
    );

    const totalReadyStock = parseInt(stockQuery.rows[0]?.total_ready ?? '0', 10);
    const totalReservedStock = parseInt(stockQuery.rows[0]?.total_reserved ?? '0', 10);
    const totalPrebookedQuantity = parseInt(prebookQuery.rows[0]?.prebooked_plants ?? '0', 10);
    const pendingPrebookingsCount = parseInt(prebookQuery.rows[0]?.pending_count ?? '0', 10);
    const totalFutureProduction = parseInt(futureQuery.rows[0]?.future_production ?? '0', 10);
    const expectedProductionDate = futureQuery.rows[0]?.earliest_ready_date ?? null;

    res.json(
      successResponse({
        totalReadyStock,
        totalReservedStock,
        totalPrebookedQuantity,
        totalFutureProduction,
        expectedProductionDate,
        pendingPrebookingsCount,
        activeAnnouncementsCount: announcementsQuery.rows.length,
        totalInterestedFarmers,
        demandSignals: demandSignalsQuery.rows,
        recentNotifyRequests: notifyRequestsQuery.rows,
        products: productsQuery.rows,
        recentPrebookings: recentPrebookingsQuery.rows,
        announcements: announcementsQuery.rows,
      }, 'Owner dashboard inventory metrics retrieved successfully')
    );
  })
);

// ── GET /owner/demand — Live farmer demand and notification list ───────────────
router.get(
  '/owner/demand',
  asyncHandler(async (req, res) => {
    const tenantId = req.tenantId;
    const { status = 'active' } = req.query as { status?: string };

    const [requestsRes, signalsRes] = await Promise.all([
      pool.query(
        `SELECT pnr.*, p.common_name, p.crop, p.variety, p.stock_state, p.future_stock
         FROM product_notify_requests pnr
         JOIN products p ON p.id = pnr.product_id
         WHERE pnr.tenant_id = $1 AND ($2 = 'all' OR pnr.status = $2)
         ORDER BY pnr.created_at DESC`,
        [tenantId, status]
      ),
      pool.query(
        `SELECT
           p.id AS product_id,
           p.common_name,
           p.crop,
           p.variety,
           p.stock_state,
           COUNT(DISTINCT pnr.id) AS interested_farmers_count,
           COALESCE(SUM(pnr.desired_quantity), 0)::int AS notify_desired_quantity,
           COALESCE(SUM(pb.total_plants), 0)::int AS prebooked_plants_count,
           COUNT(DISTINCT pb.id) AS prebook_orders_count
         FROM products p
         LEFT JOIN product_notify_requests pnr ON pnr.product_id = p.id AND pnr.status = 'active'
         LEFT JOIN pre_bookings pb ON pb.product_id = p.id AND pb.status IN ('pending', 'confirmed')
         WHERE p.tenant_id = $1 AND p.deleted_at IS NULL
         GROUP BY p.id, p.common_name, p.crop, p.variety, p.stock_state
         HAVING COUNT(DISTINCT pnr.id) > 0 OR COUNT(DISTINCT pb.id) > 0
         ORDER BY (COUNT(DISTINCT pnr.id) + COUNT(DISTINCT pb.id)) DESC`,
        [tenantId]
      ),
    ]);

    res.json(
      successResponse({
        requests: requestsRes.rows,
        summaryByProduct: signalsRes.rows,
        totalActiveRequests: requestsRes.rows.filter((r) => r.status === 'active').length,
      }, 'Farmer demand signals retrieved successfully')
    );
  })
);

// ── PUT /owner/products/:id/stock — Transactional stock & pricing management ──
router.put(
  '/owner/products/:id/stock',
  requirePermission('inventory.write'),
  validate({ params: uuidParam, body: OwnerStockUpdateDto }),
  asyncHandler(async (req, res) => {
    const { id } = req.params;
    const d = req.body;
    const client = await pool.connect();

    try {
      await client.query('BEGIN');

      // 1. Verify product ownership and tenant isolation
      const prodCheck = await client.query(
        `SELECT * FROM products WHERE id = $1 AND tenant_id = $2 AND deleted_at IS NULL`,
        [id, req.tenantId]
      );
      if (!prodCheck.rows[0]) {
        throw new NotFoundError('Product');
      }

      const isStockChanged = d.futureStock !== undefined || d.stockState !== undefined || d.readyStock !== undefined;
      const isPriceChanged = d.plantPrice !== undefined || d.trayPrice !== undefined || d.bulkPrice !== undefined;

      // 2. Update product master attributes with freshness tracking
      const updatedProductRes = await client.query(
        `UPDATE products SET
           plant_price = COALESCE($1, plant_price),
           tray_price = COALESCE($2, tray_price),
           bulk_price = COALESCE($3, bulk_price),
           tray_capacity = COALESCE($4, tray_capacity),
           future_stock = COALESCE($5, future_stock),
           expected_ready_date = COALESCE($6, expected_ready_date),
           min_order_qty = COALESCE($7, min_order_qty),
           stock_state = COALESCE($8, stock_state),
           is_prebookable = COALESCE($9, is_prebookable),
           images = COALESCE($10, images),
           common_name = COALESCE($11, common_name),
           variety = COALESCE($12, variety),
           stock_updated_at = CASE WHEN $15 = true THEN NOW() ELSE stock_updated_at END,
           price_updated_at = CASE WHEN $16 = true THEN NOW() ELSE price_updated_at END,
           updated_at = NOW()
         WHERE id = $13 AND tenant_id = $14
         RETURNING *`,
        [
          d.plantPrice ?? null,
          d.trayPrice ?? null,
          d.bulkPrice ?? null,
          d.trayCapacity ?? null,
          d.futureStock ?? null,
          d.expectedReadyDate ? new Date(d.expectedReadyDate) : null,
          d.minOrderQty ?? null,
          d.stockState ?? null,
          d.isPrebookable ?? null,
          d.images ? JSON.stringify(d.images) : null,
          d.commonName ?? null,
          d.variety ?? null,
          id,
          req.tenantId,
          isStockChanged,
          isPriceChanged,
        ]
      );

      // 3. If readyStock provided, update physical inventory in transaction
      let currentReadyStock = 0;
      if (d.readyStock !== undefined) {
        // Fetch or create default facility location
        const locRes = await client.query(
          `SELECT id FROM locations WHERE tenant_id = $1 ORDER BY created_at ASC LIMIT 1`,
          [req.tenantId]
        );
        const locId = locRes.rows[0]?.id;

        if (locId) {
          const invRes = await client.query(
            `INSERT INTO inventory
               (tenant_id, product_id, location_id, quantity_available, batch_number)
             VALUES ($1, $2, $3, $4, 'DEFAULT_BATCH')
             ON CONFLICT (product_id, location_id, batch_number)
             DO UPDATE SET
               quantity_available = EXCLUDED.quantity_available,
               updated_at = NOW()
             RETURNING *`,
            [req.tenantId, id, locId, d.readyStock]
          );

          currentReadyStock = invRes.rows[0]?.quantity_available ?? d.readyStock;

          // Audit log in inventory_movements
          await client.query(
            `INSERT INTO inventory_movements
               (tenant_id, inventory_id, type, quantity, notes, performed_by)
             VALUES ($1, $2, 'adjustment', $3, 'Nursery owner stock update', $4)`,
            [req.tenantId, invRes.rows[0].id, d.readyStock, req.user?.userId ?? null]
          );
        }
      } else {
        const sumRes = await client.query(
          `SELECT COALESCE(SUM(quantity_available), 0) AS total_ready FROM inventory WHERE product_id = $1`,
          [id]
        );
        currentReadyStock = parseInt(sumRes.rows[0]?.total_ready ?? '0', 10);
      }

      await client.query('COMMIT');

      const fullProduct = {
        ...updatedProductRes.rows[0],
        ready_stock: currentReadyStock,
      };

      res.json(successResponse(fullProduct, 'Nursery product and inventory updated successfully'));
    } catch (err) {
      await client.query('ROLLBACK');
      throw err;
    } finally {
      client.release();
    }
  })
);

// ── GET /owner/pre-bookings — Manage Farmer Pre-Bookings ───────────────────────
router.get(
  '/owner/pre-bookings',
  asyncHandler(async (req, res) => {
    const { status } = req.query as any;
    let query = `
      SELECT pb.*, p.common_name, p.crop, p.variety, p.images
      FROM pre_bookings pb
      JOIN products p ON p.id = pb.product_id
      WHERE pb.tenant_id = $1
    `;
    const params: any[] = [req.tenantId];
    if (status) {
      params.push(status);
      query += ` AND pb.status = $${params.length}`;
    }
    query += ` ORDER BY pb.created_at DESC`;

    const result = await pool.query(query, params);
    res.json(successResponse(result.rows, 'Pre-bookings retrieved successfully'));
  })
);

// ── PATCH /owner/pre-bookings/:id/status — Confirm or update pre-booking ──────
const UpdatePreBookingStatusDto = z.object({
  status: z.enum(['pending', 'confirmed', 'ready_for_pickup', 'fulfilled', 'cancelled']),
  notes: z.string().optional(),
});

router.patch(
  '/owner/pre-bookings/:id/status',
  requirePermission('inventory.write'),
  validate({ params: uuidParam, body: UpdatePreBookingStatusDto }),
  asyncHandler(async (req, res) => {
    const { id } = req.params;
    const { status, notes } = req.body;

    const result = await pool.query(
      `UPDATE pre_bookings SET
         status = $1,
         notes = COALESCE($2, notes),
         updated_at = NOW()
       WHERE id = $3 AND tenant_id = $4
       RETURNING *`,
      [status, notes ?? null, id, req.tenantId]
    );

    if (!result.rows[0]) {
      throw new NotFoundError('Pre-booking');
    }

    res.json(successResponse(result.rows[0], `Pre-booking status updated to ${status}`));
  })
);

// ── GET /owner/announcements — List owner broadcasts ──────────────────────────
router.get(
  '/owner/announcements',
  asyncHandler(async (req, res) => {
    const result = await pool.query(
      `SELECT * FROM nursery_announcements WHERE tenant_id = $1 ORDER BY created_at DESC`,
      [req.tenantId]
    );
    res.json(successResponse(result.rows, 'Announcements retrieved'));
  })
);

// ── POST /owner/announcements — Publish new production broadcast ──────────────
router.post(
  '/owner/announcements',
  requirePermission('inventory.write'),
  validate({ body: AnnouncementDto }),
  asyncHandler(async (req, res) => {
    const d = req.body;

    // Get owner nursery ID
    const nurseryRes = await pool.query(
      `SELECT id FROM nurseries WHERE tenant_id = $1 LIMIT 1`,
      [req.tenantId]
    );
    const nurseryId = nurseryRes.rows[0]?.id;

    const result = await pool.query(
      `INSERT INTO nursery_announcements
         (tenant_id, nursery_id, title, content, crop, variety, ready_quantity, future_quantity, expected_days, unit, is_active)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, true)
       RETURNING *`,
      [
        req.tenantId,
        nurseryId ?? null,
        d.title,
        d.content,
        d.crop ?? null,
        d.variety ?? null,
        d.readyQuantity ?? null,
        d.futureQuantity ?? null,
        d.expectedDays ?? null,
        d.unit ?? 'plants',
      ]
    );

    res.status(201).json(successResponse(result.rows[0], 'Announcement published to marketplace'));
  })
);

// ── DELETE /owner/announcements/:id — Deactivate announcement ─────────────────
router.delete(
  '/owner/announcements/:id',
  requirePermission('inventory.write'),
  validate({ params: uuidParam }),
  asyncHandler(async (req, res) => {
    await pool.query(
      `UPDATE nursery_announcements SET is_active = false WHERE id = $1 AND tenant_id = $2`,
      [req.params.id, req.tenantId]
    );
    res.json(successResponse(null, 'Announcement deactivated'));
  })
);

export default router;
