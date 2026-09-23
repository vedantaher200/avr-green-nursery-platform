import { Router } from 'express';
import { authenticate } from '../../middlewares/auth.middleware';
import { asyncHandler, NotFoundError, ValidationError } from '../../middlewares/error.middleware';
import { successResponse } from '../../shared/response';
import { pool } from '../../config/database';
import { InvoiceService } from './invoice.service';

const router = Router();
router.use(authenticate);

// ── GET /invoices — List tenant or customer invoices ───────────────────────────
router.get(
  '/',
  asyncHandler(async (req, res) => {
    const tenantId = req.tenantId;
    if (!tenantId) throw new ValidationError('Tenant context is required');

    let query = `
      SELECT i.*, o.order_number, o.total_amount, o.status as order_status,
             u.first_name, u.last_name
      FROM invoices i
      JOIN orders o ON o.id = i.order_id
      JOIN customers c ON c.id = o.customer_id
      JOIN users u ON u.id = c.user_id
      WHERE i.tenant_id = $1
    `;
    const params: any[] = [tenantId];

    // If customer, only show their own invoices
    if (req.user?.roleName === 'customer') {
      query += ` AND c.user_id = $2`;
      params.push(req.user.userId);
    }

    query += ` ORDER BY i.created_at DESC LIMIT 50`;
    const result = await pool.query(query, params);
    res.json(successResponse(result.rows, 'Invoices retrieved'));
  })
);

// ── GET /invoices/:orderId — Get invoice details ──────────────────────────────
router.get(
  '/:orderId',
  asyncHandler(async (req, res) => {
    const tenantId = req.tenantId;
    if (!tenantId) throw new ValidationError('Tenant context is required');

    const result = await pool.query(
      `SELECT i.*, o.order_number, o.subtotal, o.tax_amount, o.total_amount, o.status as order_status
       FROM invoices i
       JOIN orders o ON o.id = i.order_id
       WHERE i.tenant_id = $1 AND (i.order_id = $2 OR i.id = $2)`,
      [tenantId, req.params.orderId]
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
    const tenantId = req.tenantId;
    if (!tenantId) throw new ValidationError('Tenant context is required');

    try {
      const { buffer, fileName } = await InvoiceService.getInvoicePdf(tenantId, req.params.orderId);

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
    const tenantId = req.tenantId;
    if (!tenantId) throw new ValidationError('Tenant context is required');

    const invoiceId = await InvoiceService.createInvoiceForOrder(pool, tenantId, req.params.orderId);
    res.status(201).json(successResponse({ invoiceId }, 'Invoice generated successfully'));
  })
);

export default router;
