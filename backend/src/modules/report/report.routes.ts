import { Router } from 'express';
import { authenticate } from '../../middlewares/auth.middleware';
import { requirePermission } from '../../middlewares/rbac.middleware';
import { asyncHandler } from '../../middlewares/error.middleware';
import { successResponse } from '../../shared/response';
import { pool } from '../../config/database';
import { z } from 'zod';
import { validate } from '../../middlewares/validate.middleware';

// ─────────────────────────────────────────────────────────────────────────────
// Reports Module — Business Intelligence & Analytics
// ─────────────────────────────────────────────────────────────────────────────

const DateRangeQuery = z.object({
  from: z.string().regex(/^\d{4}-\d{2}-\d{2}$/).optional(),
  to: z.string().regex(/^\d{4}-\d{2}-\d{2}$/).optional(),
  locationId: z.string().uuid().optional(),
});

const router = Router();
router.use(authenticate, requirePermission('reports.view'));

// ── GET /dashboard — owner KPI dashboard snapshot ─────────────────────────────
router.get(
  '/dashboard',
  asyncHandler(async (req, res) => {
    const tenantId = req.tenantId;
    const today = new Date().toISOString().split('T')[0];

    const [
      todayOrders,
      totalRevenue,
      activeCustomers,
      lowStockItems,
      recentOrders,
      topProducts,
    ] = await Promise.all([
      // Today's orders
      pool.query(
        `SELECT COUNT(*) AS count, COALESCE(SUM(total_amount), 0) AS revenue
         FROM orders WHERE tenant_id = $1 AND DATE(created_at) = $2
         AND status NOT IN ('cancelled', 'failed')`,
        [tenantId, today]
      ),
      // Total revenue this month
      pool.query(
        `SELECT COALESCE(SUM(total_amount), 0) AS revenue,
                COALESCE(SUM(tax_amount), 0) AS total_tax
         FROM orders WHERE tenant_id = $1
           AND DATE_TRUNC('month', created_at) = DATE_TRUNC('month', NOW())
           AND status NOT IN ('cancelled', 'failed')`,
        [tenantId]
      ),
      // Active customers
      pool.query(
        `SELECT COUNT(DISTINCT customer_id) AS count FROM orders
         WHERE tenant_id = $1 AND status = 'delivered'`,
        [tenantId]
      ),
      // Low stock alerts
      pool.query(
        `SELECT COUNT(*) AS count FROM inventory
         WHERE tenant_id = $1 AND quantity_available <= low_stock_threshold`,
        [tenantId]
      ),
      // Recent 5 orders
      pool.query(
        `SELECT o.id, o.order_number, o.status, o.total_amount, o.created_at,
                u.first_name, u.last_name
         FROM orders o
         JOIN customers c ON c.id = o.customer_id
         JOIN users u ON u.id = c.user_id
         WHERE o.tenant_id = $1
         ORDER BY o.created_at DESC LIMIT 5`,
        [tenantId]
      ),
      // Top 5 selling products this month
      pool.query(
        `SELECT p.common_name, p.sku, SUM(oi.quantity) AS units_sold,
                SUM(oi.total_price) AS revenue
         FROM order_items oi
         JOIN orders o ON o.id = oi.order_id
         JOIN products p ON p.id = oi.product_id
         WHERE o.tenant_id = $1
           AND DATE_TRUNC('month', o.created_at) = DATE_TRUNC('month', NOW())
           AND o.status NOT IN ('cancelled', 'failed')
         GROUP BY p.id, p.common_name, p.sku
         ORDER BY units_sold DESC LIMIT 5`,
        [tenantId]
      ),
    ]);

    res.json(
      successResponse({
        today: {
          orderCount: parseInt(todayOrders.rows[0].count),
          revenue: parseFloat(todayOrders.rows[0].revenue),
        },
        thisMonth: {
          revenue: parseFloat(totalRevenue.rows[0].revenue),
          totalTax: parseFloat(totalRevenue.rows[0].total_tax),
        },
        activeCustomers: parseInt(activeCustomers.rows[0].count),
        lowStockAlerts: parseInt(lowStockItems.rows[0].count),
        recentOrders: recentOrders.rows,
        topProducts: topProducts.rows,
      })
    );
  })
);

// ── GET /sales — daily/monthly sales breakdown ────────────────────────────────
router.get(
  '/sales',
  validate({ query: DateRangeQuery }),
  asyncHandler(async (req, res) => {
    const { from, to } = req.query as any;
    const fromDate = from ?? new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString().split('T')[0];
    const toDate = to ?? new Date().toISOString().split('T')[0];

    const result = await pool.query(
      `SELECT DATE(created_at) AS date,
              COUNT(*) AS order_count,
              SUM(subtotal) AS subtotal,
              SUM(tax_amount) AS tax,
              SUM(total_amount) AS total
       FROM orders
       WHERE tenant_id = $1
         AND DATE(created_at) BETWEEN $2 AND $3
         AND status NOT IN ('cancelled', 'failed')
       GROUP BY DATE(created_at)
       ORDER BY date ASC`,
      [req.tenantId, fromDate, toDate]
    );

    res.json(successResponse(result.rows));
  })
);

// ── GET /inventory-valuation — total inventory value ─────────────────────────
router.get(
  '/inventory-valuation',
  asyncHandler(async (req, res) => {
    const result = await pool.query(
      `SELECT l.name AS location_name, l.type AS location_type,
              SUM(i.quantity_available * p.cost_price) AS cost_value,
              SUM(i.quantity_available * p.price) AS retail_value,
              SUM(i.quantity_available) AS total_units
       FROM inventory i
       JOIN products p ON p.id = i.product_id
       JOIN locations l ON l.id = i.location_id
       WHERE i.tenant_id = $1
       GROUP BY l.id, l.name, l.type
       ORDER BY retail_value DESC`,
      [req.tenantId]
    );
    res.json(successResponse(result.rows));
  })
);

// ── GET /top-customers — highest spending customers ───────────────────────────
router.get(
  '/top-customers',
  asyncHandler(async (req, res) => {
    const result = await pool.query(
      `SELECT u.first_name, u.last_name, u.email, u.phone,
              COUNT(o.id) AS order_count,
              SUM(o.total_amount) AS total_spent,
              c.loyalty_points
       FROM orders o
       JOIN customers c ON c.id = o.customer_id
       JOIN users u ON u.id = c.user_id
       WHERE o.tenant_id = $1 AND o.status = 'delivered'
       GROUP BY u.id, u.first_name, u.last_name, u.email, u.phone, c.loyalty_points
       ORDER BY total_spent DESC LIMIT 10`,
      [req.tenantId]
    );
    res.json(successResponse(result.rows));
  })
);

export default router;
