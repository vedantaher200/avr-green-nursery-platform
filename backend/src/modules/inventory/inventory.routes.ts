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

export default router;
