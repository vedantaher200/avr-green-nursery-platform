import { Router } from 'express';
import { authenticate } from '../../middlewares/auth.middleware';
import { asyncHandler, NotFoundError, ValidationError, ForbiddenError } from '../../middlewares/error.middleware';
import { successResponse } from '../../shared/response';
import { pool } from '../../config/database';
import { InvoiceService } from './invoice.service';

const router = Router();
router.use(authenticate);

// ── GET /invoices — List tenant or customer invoices ───────────────────────────
router.get(
  '/',
  asyncHandler(async (req, res) => {
    let query = `
      SELECT i.*, o.order_number, o.total_amount, o.status as order_status,
             u.first_name, u.last_name, t.name as nursery_name
      FROM invoices i
      JOIN orders o ON o.id = i.order_id
      JOIN tenants t ON t.id = i.tenant_id
      JOIN customers c ON c.id = o.customer_id
      JOIN users u ON u.id = c.user_id
      WHERE 1=1
    `;
    const params: any[] = [];

    // If customer, show only their own invoices
    if (req.user?.roleName === 'customer') {
      params.push(req.user.userId);
      query += ` AND c.user_id = $${params.length}`;
    } else {
      // Nursery Owner / Staff — strictly tenant isolated
      const tenantId = req.tenantId;
      if (!tenantId) throw new ValidationError('Tenant context is required');
      params.push(tenantId);
      query += ` AND i.tenant_id = $${params.length}`;
    }

    query += ` ORDER BY i.created_at DESC LIMIT 50`;
    const result = await pool.query(query, params);
    res.json(successResponse(result.rows, 'Invoices retrieved'));
  })
);

// Helper function to resolve and authorize an order
async function resolveAndAuthorizeOrder(req: any, orderOrInvoiceId: string) {
  const orderRes = await pool.query(
    `SELECT o.*, c.user_id as customer_user_id
     FROM orders o
     JOIN customers c ON c.id = o.customer_id
     WHERE o.id = $1 OR o.order_number = $1
        OR EXISTS (SELECT 1 FROM invoices inv WHERE (inv.id = $1 OR inv.invoice_number = $1) AND inv.order_id = o.id)
     LIMIT 1`,
    [orderOrInvoiceId]
  );

  if (!orderRes.rows[0]) {
    throw new NotFoundError('Order or Invoice');
  }

  const order = orderRes.rows[0];

  // RBAC & Tenant Isolation Authorization:
  if (req.user?.roleName === 'customer') {
    if (order.customer_user_id !== req.user.userId) {
      throw new ForbiddenError('You are not authorized to view another customer\'s invoice');
    }
  } else if (['owner', 'manager', 'staff'].includes(req.user?.roleName || '')) {
    if (order.tenant_id !== req.tenantId) {
      throw new ForbiddenError('Unauthorized cross-tenant invoice access');
    }
  } else if (req.user?.roleName !== 'super_admin') {
    throw new ForbiddenError('Access denied');
  }

  return order;
}

// ── GET /invoices/:orderId — Get invoice details ──────────────────────────────
router.get(
  '/:orderId',
  asyncHandler(async (req, res) => {
    const order = await resolveAndAuthorizeOrder(req, req.params.orderId);

    // Auto-generate invoice record if missing
    await InvoiceService.createInvoiceForOrder(pool, order.tenant_id, order.id).catch(() => {});

    const result = await pool.query(
      `SELECT i.*, o.order_number, o.subtotal, o.tax_amount, o.discount_amount, o.total_amount,
              o.status as order_status, t.name as nursery_name
       FROM invoices i
       JOIN orders o ON o.id = i.order_id
       JOIN tenants t ON t.id = i.tenant_id
       WHERE i.tenant_id = $1 AND i.order_id = $2`,
      [order.tenant_id, order.id]
    );

    if (result.rows.length === 0) {
      throw new NotFoundError('Invoice');
    }

    res.json(successResponse(result.rows[0], 'Invoice details retrieved'));
  })
);

// ── GET /invoices/:orderId/pdf — Download professional PDF invoice ───────────
router.get(
  '/:orderId/pdf',
  asyncHandler(async (req, res) => {
    const order = await resolveAndAuthorizeOrder(req, req.params.orderId);

    // Auto-generate invoice record if missing
    await InvoiceService.createInvoiceForOrder(pool, order.tenant_id, order.id).catch(() => {});

    try {
      const { buffer, fileName } = await InvoiceService.getInvoicePdf(order.tenant_id, order.id);

      res.setHeader('Content-Type', 'application/pdf');
      res.setHeader('Content-Disposition', `attachment; filename="${fileName}"`);
      res.setHeader('Content-Length', buffer.length);
      res.send(buffer);
    } catch (err: any) {
      throw new NotFoundError('Invoice PDF');
    }
  })
);

// ── POST /invoices/:orderId/generate — Generate invoice for an order ──────────
router.post(
  '/:orderId/generate',
  asyncHandler(async (req, res) => {
    const order = await resolveAndAuthorizeOrder(req, req.params.orderId);
    const invoiceId = await InvoiceService.createInvoiceForOrder(pool, order.tenant_id, order.id);
    res.status(201).json(successResponse({ invoiceId }, 'Invoice generated successfully'));
  })
);

export default router;
