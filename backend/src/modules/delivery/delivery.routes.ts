import { Router } from 'express';
import { authenticate } from '../../middlewares/auth.middleware';
import { requirePermission } from '../../middlewares/rbac.middleware';
import { validate, uuidParam, paginationQuery } from '../../middlewares/validate.middleware';
import { asyncHandler, NotFoundError } from '../../middlewares/error.middleware';
import { successResponse } from '../../shared/response';
import { pool } from '../../config/database';
import { z } from 'zod';

// ─────────────────────────────────────────────────────────────────────────────
// Delivery Module — Assignment, GPS Tracking, Proof of Delivery
// ─────────────────────────────────────────────────────────────────────────────

const AssignDeliveryDto = z.object({
  orderId: z.string().uuid(),
  deliveryAgentId: z.string().uuid(),
});

const UpdateLocationDto = z.object({
  lat: z.number().min(-90).max(90),
  lng: z.number().min(-180).max(180),
});

const ProofOfDeliveryDto = z.object({
  photoKey: z.string().optional(),
  signatureKey: z.string().optional(),
  notes: z.string().optional(),
});

const FailDeliveryDto = z.object({
  reason: z.string().min(5),
});

const router = Router();
router.use(authenticate);

// ── GET / — list tenant deliveries ────────────────────────────────────────────
router.get(
  '/',
  asyncHandler(async (req, res) => {
    const result = await pool.query(
      `SELECT d.*, o.order_number, o.total_amount, o.status AS order_status,
              u.first_name AS agent_first, u.last_name AS agent_last, u.phone AS agent_phone
       FROM deliveries d
       JOIN orders o ON o.id = d.order_id
       LEFT JOIN users u ON u.id = d.delivery_agent_id
       WHERE d.tenant_id = $1
       ORDER BY d.created_at DESC LIMIT 50`,
      [req.tenantId]
    );
    res.json(successResponse(result.rows));
  })
);

// ── POST /assign — assign order to delivery agent ─────────────────────────────
router.post(
  '/assign',
  requirePermission('orders.write'),
  validate({ body: AssignDeliveryDto }),
  asyncHandler(async (req, res) => {
    const d = req.body;
    const client = await pool.connect();
    try {
      await client.query('BEGIN');

      // Verify order belongs to tenant and is in correct state
      const orderResult = await client.query(
        `SELECT id, status FROM orders WHERE id = $1 AND tenant_id = $2`,
        [d.orderId, req.tenantId]
      );
      if (!orderResult.rows[0]) throw new NotFoundError('Order');
      if (!['confirmed', 'packed'].includes(orderResult.rows[0].status)) {
        throw new Error('Order must be confirmed or packed before delivery assignment');
      }

      // Create or update delivery record
      const deliveryResult = await client.query(
        `INSERT INTO deliveries (tenant_id, order_id, delivery_agent_id, status)
         VALUES ($1, $2, $3, 'assigned')
         ON CONFLICT (order_id) DO UPDATE
           SET delivery_agent_id = EXCLUDED.delivery_agent_id,
               status = 'assigned',
               updated_at = NOW()
         RETURNING *`,
        [req.tenantId, d.orderId, d.deliveryAgentId]
      );

      // Update order status
      await client.query(
        `UPDATE orders SET status = 'dispatched', updated_at = NOW() WHERE id = $1`,
        [d.orderId]
      );

      await client.query('COMMIT');
      res.status(201).json(successResponse(deliveryResult.rows[0], 'Delivery assigned'));
    } catch (err) {
      await client.query('ROLLBACK');
      throw err;
    } finally {
      client.release();
    }
  })
);

// ── PATCH /:id/location — update live GPS position (delivery agent) ───────────
router.patch(
  '/:id/location',
  validate({ params: uuidParam, body: UpdateLocationDto }),
  asyncHandler(async (req, res) => {
    const { lat, lng } = req.body;
    await pool.query(
      `UPDATE deliveries SET current_lat = $1, current_lng = $2, updated_at = NOW()
       WHERE id = $3 AND delivery_agent_id = $4`,
      [lat, lng, req.params.id, req.user!.userId]
    );
    res.json(successResponse({ lat, lng }, 'Location updated'));
  })
);

// ── POST /:id/delivered — mark as delivered with proof ───────────────────────
router.post(
  '/:id/delivered',
  validate({ params: uuidParam, body: ProofOfDeliveryDto }),
  asyncHandler(async (req, res) => {
    const client = await pool.connect();
    try {
      await client.query('BEGIN');

      const result = await client.query(
        `UPDATE deliveries
         SET status = 'delivered',
             proof_of_delivery = $1,
             updated_at = NOW()
         WHERE id = $2 AND delivery_agent_id = $3
         RETURNING order_id`,
        [JSON.stringify(req.body), req.params.id, req.user!.userId]
      );

      if (!result.rows[0]) throw new NotFoundError('Delivery');

      await client.query(
        `UPDATE orders SET status = 'delivered', updated_at = NOW() WHERE id = $1`,
        [result.rows[0].order_id]
      );

      await client.query('COMMIT');
      res.json(successResponse(null, 'Delivery marked as completed'));
    } catch (err) {
      await client.query('ROLLBACK');
      throw err;
    } finally {
      client.release();
    }
  })
);

// ── POST /:id/failed — mark delivery as failed ────────────────────────────────
router.post(
  '/:id/failed',
  validate({ params: uuidParam, body: FailDeliveryDto }),
  asyncHandler(async (req, res) => {
    await pool.query(
      `UPDATE deliveries SET status = 'failed', failure_reason = $1, updated_at = NOW()
       WHERE id = $2 AND delivery_agent_id = $3`,
      [req.body.reason, req.params.id, req.user!.userId]
    );
    res.json(successResponse(null, 'Delivery marked as failed'));
  })
);

// ── GET /agent/me — delivery agent's active deliveries ───────────────────────
router.get(
  '/agent/me',
  asyncHandler(async (req, res) => {
    const result = await pool.query(
      `SELECT d.*, o.order_number, o.total_amount, o.shipping_address,
              u.first_name AS customer_first, u.last_name AS customer_last
       FROM deliveries d
       JOIN orders o ON o.id = d.order_id
       JOIN customers c ON c.id = o.customer_id
       JOIN users u ON u.id = c.user_id
       WHERE d.delivery_agent_id = $1 AND d.status IN ('assigned', 'picked_up', 'in_transit')
       ORDER BY d.created_at ASC`,
      [req.user!.userId]
    );
    res.json(successResponse(result.rows));
  })
);

// ── GET /track/:orderId — customer tracking view ──────────────────────────────
router.get(
  '/track/:orderId',
  validate({ params: z.object({ orderId: z.string().uuid() }) }),
  asyncHandler(async (req, res) => {
    const result = await pool.query(
      `SELECT d.status, d.current_lat, d.current_lng, d.proof_of_delivery,
              u.first_name AS agent_first, u.last_name AS agent_last, u.phone AS agent_phone
       FROM deliveries d
       JOIN users u ON u.id = d.delivery_agent_id
       WHERE d.order_id = $1 AND d.tenant_id = $2`,
      [req.params.orderId, req.tenantId]
    );
    if (!result.rows[0]) throw new NotFoundError('Delivery');
    res.json(successResponse(result.rows[0]));
  })
);

export default router;
