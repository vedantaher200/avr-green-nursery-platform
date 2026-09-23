import { Router } from 'express';
import { authenticate } from '../../middlewares/auth.middleware';
import { requirePermission } from '../../middlewares/rbac.middleware';
import { validate, uuidParam, paginationQuery } from '../../middlewares/validate.middleware';
import { asyncHandler, NotFoundError, ValidationError } from '../../middlewares/error.middleware';
import { successResponse, paginationMeta } from '../../shared/response';
import { pool } from '../../config/database';
import { z } from 'zod';
import { v4 as uuidv4 } from 'uuid';
import { InvoiceService } from '../invoice/invoice.service';
import { notificationService } from '../../shared/providers/notification.provider';

// ─────────────────────────────────────────────────────────────────────────────
// Order Module — Cart, Checkout, Order Lifecycle & Order Tracking
// ─────────────────────────────────────────────────────────────────────────────

const CreateOrderDto = z.object({
  locationId: z.string().uuid(),
  shippingAddress: z.object({
    street: z.string(),
    city: z.string(),
    state: z.string(),
    pincode: z.string(),
    geo_lat: z.number().optional(),
    geo_lng: z.number().optional(),
  }),
  items: z.array(z.object({
    productId: z.string().uuid(),
    quantity: z.number().int().positive(),
  })).min(1),
  notes: z.string().optional(),
});

const UpdateStatusDto = z.object({
  status: z.enum(['confirmed', 'packed', 'dispatched', 'delivered', 'cancelled']),
  notes: z.string().optional(),
});

const router = Router();
router.use(authenticate);

// ── POST / — create new order ─────────────────────────────────────────────────
router.post(
  '/',
  validate({ body: CreateOrderDto }),
  asyncHandler(async (req, res) => {
    const d = req.body;
    const client = await pool.connect();
    try {
      await client.query('BEGIN');

      // Fetch or auto-provision customer record
      let custResult = await client.query(
        `SELECT id FROM customers WHERE user_id = $1 AND tenant_id = $2`,
        [req.user!.userId, req.tenantId]
      );
      if (!custResult.rows[0]) {
        custResult = await client.query(
          `INSERT INTO customers (id, tenant_id, user_id)
           VALUES (gen_random_uuid(), $1, $2)
           RETURNING id`,
          [req.tenantId, req.user!.userId]
        );
      }
      if (!custResult.rows[0]) throw new NotFoundError('Customer profile');
      const customerId = custResult.rows[0].id;

      let subtotal = 0;
      const enrichedItems: Array<{ productId: string; quantity: number; unitPrice: number; totalPrice: number }> = [];

      // Validate products, prices, and reserve stock
      for (const item of d.items) {
        const prodResult = await client.query(
          `SELECT id, price FROM products WHERE id = $1 AND tenant_id = $2 AND deleted_at IS NULL`,
          [item.productId, req.tenantId]
        );
        if (!prodResult.rows[0]) throw new NotFoundError(`Product ${item.productId}`);

        const unitPrice = parseFloat(prodResult.rows[0].price);
        const totalPrice = unitPrice * item.quantity;
        subtotal += totalPrice;

        // Reserve stock (find first batch with enough available stock)
        const invResult = await client.query(
          `SELECT id, quantity_available FROM inventory
           WHERE product_id = $1 AND location_id = $2 AND tenant_id = $3
             AND quantity_available >= $4
           ORDER BY expiry_date ASC NULLS LAST
           LIMIT 1 FOR UPDATE`,
          [item.productId, d.locationId, req.tenantId, item.quantity]
        );
        if (!invResult.rows[0]) {
          throw new ValidationError(`Insufficient stock for product ${item.productId}`);
        }

        await client.query(
          `UPDATE inventory
           SET quantity_available = quantity_available - $1,
               quantity_reserved = quantity_reserved + $1,
               updated_at = NOW()
           WHERE id = $2`,
          [item.quantity, invResult.rows[0].id]
        );

        enrichedItems.push({ productId: item.productId, quantity: item.quantity, unitPrice, totalPrice });
      }

      const taxAmount = parseFloat((subtotal * 0.18).toFixed(2)); // 18% GST
      const totalAmount = parseFloat((subtotal + taxAmount).toFixed(2));
      const orderNumber = `ORD-${Date.now()}-${Math.floor(Math.random() * 1000)}`;

      // Create order
      const orderResult = await client.query(
        `INSERT INTO orders
           (tenant_id, order_number, customer_id, location_id, status,
            subtotal, tax_amount, discount_amount, total_amount, shipping_address, notes)
         VALUES ($1,$2,$3,$4,'pending_payment',$5,$6,0,$7,$8,$9)
         RETURNING *`,
        [
          req.tenantId, orderNumber, customerId, d.locationId,
          subtotal, taxAmount, totalAmount,
          JSON.stringify(d.shippingAddress), d.notes ?? null,
        ]
      );
      const order = orderResult.rows[0];

      // Insert order items
      for (const item of enrichedItems) {
        await client.query(
          `INSERT INTO order_items (order_id, product_id, quantity, unit_price, total_price)
           VALUES ($1,$2,$3,$4,$5)`,
          [order.id, item.productId, item.quantity, item.unitPrice, item.totalPrice]
        );
      }

      await client.query('COMMIT');

      // Async notification dispatch
      notificationService.send({
        tenantId: req.tenantId!,
        userId: req.user!.userId,
        eventType: 'order_created',
        title: 'Order Placed Successfully! 🌿',
        body: `Your order #${orderNumber} has been received for INR ${totalAmount}.`,
        metadata: { orderId: order.id, orderNumber },
      }).catch(() => {});

      res.status(201).json(successResponse({ ...order, items: enrichedItems }, 'Order created'));
    } catch (err) {
      await client.query('ROLLBACK');
      throw err;
    } finally {
      client.release();
    }
  })
);

// ── GET / — list orders (customer sees own; staff/manager see all) ─────────────
router.get(
  '/',
  validate({ query: paginationQuery }),
  asyncHandler(async (req, res) => {
    const { page, limit } = req.query as any;
    const offset = (page - 1) * limit;
    const isCustomer = req.user!.roleName === 'customer';

    let whereClause = `WHERE o.tenant_id = $1`;
    const params: unknown[] = [req.tenantId, limit, offset];

    let customerDbId: string | null = null;
    if (isCustomer) {
      const custResult = await pool.query(
        `SELECT id FROM customers WHERE user_id = $1`,
        [req.user!.userId]
      );
      customerDbId = custResult.rows[0]?.id ?? null;
      if (!customerDbId) {
        res.json(successResponse([], undefined, paginationMeta(0, page, limit)));
        return;
      }
      whereClause += ` AND o.customer_id = $4`;
      params.push(customerDbId);
    }

    const result = await pool.query(
      `SELECT o.*, u.first_name, u.last_name, l.name AS location_name
       FROM orders o
       JOIN customers c ON c.id = o.customer_id
       JOIN users u ON u.id = c.user_id
       JOIN locations l ON l.id = o.location_id
       ${whereClause}
       ORDER BY o.created_at DESC
       LIMIT $2 OFFSET $3`,
      params
    );

    const countQuery = customerDbId
      ? `SELECT COUNT(*) FROM orders o WHERE o.tenant_id = $1 AND o.customer_id = $2`
      : `SELECT COUNT(*) FROM orders o WHERE o.tenant_id = $1`;
    const countParams = customerDbId ? [req.tenantId, customerDbId] : [req.tenantId];
    const countResult = await pool.query(countQuery, countParams);

    res.json(
      successResponse(
        result.rows,
        undefined,
        paginationMeta(parseInt(countResult.rows[0].count, 10), page, limit)
      )
    );
  })
);

// ── GET /:id — order detail with items ───────────────────────────────────────
router.get(
  '/:id',
  validate({ params: uuidParam }),
  asyncHandler(async (req, res) => {
    const orderResult = await pool.query(
      `SELECT o.*, l.name AS location_name FROM orders o
       JOIN locations l ON l.id = o.location_id
       WHERE o.id = $1 AND o.tenant_id = $2`,
      [req.params.id, req.tenantId]
    );
    if (!orderResult.rows[0]) throw new NotFoundError('Order');

    const itemsResult = await pool.query(
      `SELECT oi.*, p.common_name, p.scientific_name, p.images
       FROM order_items oi
       JOIN products p ON p.id = oi.product_id
       WHERE oi.order_id = $1`,
      [req.params.id]
    );

    res.json(successResponse({ ...orderResult.rows[0], items: itemsResult.rows }));
  })
);

// ── PATCH /:id/status — update order status ───────────────────────────────────
router.patch(
  '/:id/status',
  requirePermission('orders.write'),
  validate({ params: uuidParam, body: UpdateStatusDto }),
  asyncHandler(async (req, res) => {
    const client = await pool.connect();
    try {
      await client.query('BEGIN');
      const orderRes = await client.query(
        `SELECT * FROM orders WHERE id = $1 AND tenant_id = $2 FOR UPDATE`,
        [req.params.id, req.tenantId]
      );
      if (!orderRes.rows[0]) throw new NotFoundError('Order');
      const previousStatus = orderRes.rows[0].status;
      const newStatus = req.body.status;

      // Update status
      const result = await client.query(
        `UPDATE orders SET status = $1, updated_at = NOW() WHERE id = $2 AND tenant_id = $3 RETURNING *`,
        [newStatus, req.params.id, req.tenantId]
      );

      // If cancelled from pending/confirmed, release reserved stock back to available
      if (newStatus === 'cancelled' && ['pending_payment', 'confirmed', 'packed'].includes(previousStatus)) {
        const items = await client.query(`SELECT * FROM order_items WHERE order_id = $1`, [req.params.id]);
        for (const item of items.rows) {
          await client.query(
            `UPDATE inventory
             SET quantity_available = quantity_available + $1,
                 quantity_reserved = GREATEST(0, quantity_reserved - $1),
                 updated_at = NOW()
             WHERE product_id = $2 AND location_id = $3 AND tenant_id = $4`,
            [item.quantity, item.product_id, orderRes.rows[0].location_id, req.tenantId]
          );
        }
      }

      // If status moved to confirmed or delivered, ensure invoice is generated
      if (['confirmed', 'delivered'].includes(newStatus)) {
        try {
          await InvoiceService.createInvoiceForOrder(client, req.tenantId!, req.params.id);
        } catch {
          // If invoice generation already exists or fails, keep order update intact
        }
      }

      await client.query('COMMIT');

      // Notify customer
      const custRes = await pool.query(
        `SELECT user_id FROM customers WHERE id = $1`,
        [orderRes.rows[0].customer_id]
      );
      if (custRes.rows[0]) {
        notificationService.send({
          tenantId: req.tenantId!,
          userId: custRes.rows[0].user_id,
          eventType: 'order_status_update',
          title: `Order Status: ${newStatus.toUpperCase()}`,
          body: `Your order #${orderRes.rows[0].order_number} is now ${newStatus}.`,
          metadata: { orderId: req.params.id, status: newStatus },
        }).catch(() => {});
      }

      res.json(successResponse(result.rows[0], `Order status updated to ${newStatus}`));
    } catch (err) {
      await client.query('ROLLBACK');
      throw err;
    } finally {
      client.release();
    }
  })
);

export default router;
