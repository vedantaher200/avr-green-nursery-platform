import { Router } from 'express';
import { z } from 'zod';
import { authenticate } from '../../middlewares/auth.middleware';
import { requireRoles } from '../../middlewares/rbac.middleware';
import { asyncHandler, NotFoundError, ValidationError } from '../../middlewares/error.middleware';
import { validate, paginationQuery, uuidParam } from '../../middlewares/validate.middleware';
import { pool } from '../../config/database';
import { paginationMeta, successResponse } from '../../shared/response';
import { InvoiceService } from '../invoice/invoice.service';

/** Operational resources that were absent from the original API. */
const router = Router();
router.use(authenticate);
const tenant = (id: string | undefined) => { if (!id) throw new ValidationError('A tenant account is required'); return id; };
const page = (query: any) => ({ limit: Number(query.limit ?? 20), offset: (Number(query.page ?? 1) - 1) * Number(query.limit ?? 20) });
const supplierDto = z.object({ name: z.string().min(2), contactName: z.string().optional(), email: z.string().email().optional(), phone: z.string().optional(), address: z.record(z.unknown()).optional(), rating: z.number().min(0).max(5).optional() });
const purchaseDto = z.object({ supplierId: z.string().uuid(), locationId: z.string().uuid(), items: z.array(z.object({ productId: z.string().uuid(), quantity: z.number().int().positive(), unitPrice: z.number().positive() })).min(1) });
const paymentDto = z.object({ orderId: z.string().uuid(), method: z.enum(['upi', 'card', 'net_banking', 'cash']), amount: z.number().positive(), status: z.enum(['initiated', 'success', 'failed', 'refunded']).default('initiated'), idempotencyKey: z.string().min(8) });

router.get('/dashboard', requireRoles('owner', 'manager', 'staff'), asyncHandler(async (req, res) => {
  const t = tenant(req.tenantId);
  const result = await pool.query(`SELECT
    (SELECT COUNT(*) FROM orders WHERE tenant_id=$1 AND created_at::date=CURRENT_DATE) AS orders_today,
    (SELECT COALESCE(SUM(total_amount),0) FROM orders WHERE tenant_id=$1 AND status NOT IN ('cancelled','failed') AND created_at::date=CURRENT_DATE) AS sales_today,
    (SELECT COUNT(*) FROM products WHERE tenant_id=$1 AND deleted_at IS NULL) AS products,
    (SELECT COUNT(*) FROM inventory WHERE tenant_id=$1 AND quantity_available <= low_stock_threshold) AS low_stock,
    (SELECT COUNT(*) FROM deliveries WHERE tenant_id=$1 AND status IN ('assigned','picked_up','in_transit')) AS active_deliveries`, [t]);
  res.json(successResponse(result.rows[0]));
}));

router.get('/customers', requireRoles('owner', 'manager', 'staff'), validate({ query: paginationQuery }), asyncHandler(async (req, res) => {
  const { limit, offset } = page(req.query); const t = tenant(req.tenantId);
  const result = await pool.query(`SELECT c.*, u.first_name, u.last_name, u.email, u.phone, COUNT(*) OVER() AS total
    FROM customers c JOIN users u ON u.id=c.user_id WHERE c.tenant_id=$1 ORDER BY c.created_at DESC LIMIT $2 OFFSET $3`, [t, limit, offset]);
  res.json(successResponse(result.rows, 'Customers retrieved', paginationMeta(Number(result.rows[0]?.total ?? 0), Number(req.query.page ?? 1), limit)));
}));

router.get('/suppliers', requireRoles('owner', 'manager', 'staff'), validate({ query: paginationQuery }), asyncHandler(async (req, res) => {
  const { limit, offset } = page(req.query); const t = tenant(req.tenantId);
  const result = await pool.query('SELECT *, COUNT(*) OVER() AS total FROM suppliers WHERE tenant_id=$1 ORDER BY name LIMIT $2 OFFSET $3', [t, limit, offset]);
  res.json(successResponse(result.rows, 'Suppliers retrieved', paginationMeta(Number(result.rows[0]?.total ?? 0), Number(req.query.page ?? 1), limit)));
}));
router.post('/suppliers', requireRoles('owner', 'manager'), validate({ body: supplierDto }), asyncHandler(async (req, res) => {
  const b = req.body; const result = await pool.query(`INSERT INTO suppliers (tenant_id,name,contact_name,email,phone,address,rating) VALUES ($1,$2,$3,$4,$5,$6,$7) RETURNING *`, [tenant(req.tenantId), b.name, b.contactName ?? null, b.email ?? null, b.phone ?? null, JSON.stringify(b.address ?? {}), b.rating ?? 5]);
  res.status(201).json(successResponse(result.rows[0], 'Supplier created'));
}));

router.get('/purchases', requireRoles('owner', 'manager', 'staff'), asyncHandler(async (req, res) => {
  const result = await pool.query(`SELECT po.*, s.name AS supplier_name, l.name AS location_name FROM purchase_orders po JOIN suppliers s ON s.id=po.supplier_id JOIN locations l ON l.id=po.location_id WHERE po.tenant_id=$1 ORDER BY po.created_at DESC`, [tenant(req.tenantId)]);
  res.json(successResponse(result.rows));
}));
router.post('/purchases', requireRoles('owner', 'manager'), validate({ body: purchaseDto }), asyncHandler(async (req, res) => {
  const client = await pool.connect(); const b = req.body; const t = tenant(req.tenantId);
  try { await client.query('BEGIN'); const total = b.items.reduce((n: number, i: any) => n + i.quantity * i.unitPrice, 0);
    const po = await client.query(`INSERT INTO purchase_orders(tenant_id,supplier_id,location_id,po_number,total_amount,created_by) VALUES($1,$2,$3,$4,$5,$6) RETURNING *`, [t,b.supplierId,b.locationId,`PO-${Date.now()}`,total,req.user!.userId]);
    for (const i of b.items) await client.query('INSERT INTO purchase_order_items(purchase_order_id,product_id,quantity,unit_price,total_price) VALUES($1,$2,$3,$4,$5)', [po.rows[0].id,i.productId,i.quantity,i.unitPrice,i.quantity*i.unitPrice]);
    await client.query('COMMIT'); res.status(201).json(successResponse(po.rows[0], 'Purchase order created'));
  } catch (e) { await client.query('ROLLBACK'); throw e; } finally { client.release(); }
}));
router.post('/purchases/:id/receive', requireRoles('owner', 'manager', 'staff'), validate({ params: uuidParam }), asyncHandler(async (req, res) => {
  const client = await pool.connect(); const t = tenant(req.tenantId);
  try { await client.query('BEGIN'); const po = await client.query('SELECT * FROM purchase_orders WHERE id=$1 AND tenant_id=$2 FOR UPDATE', [req.params.id,t]); if (!po.rows[0]) throw new NotFoundError('Purchase order');
    const items = await client.query('SELECT * FROM purchase_order_items WHERE purchase_order_id=$1', [req.params.id]);
    for (const i of items.rows) { const inv = await client.query(`INSERT INTO inventory(tenant_id,product_id,location_id,quantity_available,batch_number) VALUES($1,$2,$3,$4,'DEFAULT_BATCH') ON CONFLICT(product_id,location_id,batch_number) DO UPDATE SET quantity_available=inventory.quantity_available+EXCLUDED.quantity_available,updated_at=NOW() RETURNING id`, [t,i.product_id,po.rows[0].location_id,i.quantity]); await client.query(`INSERT INTO inventory_movements(tenant_id,inventory_id,type,quantity,reference_id,performed_by,notes) VALUES($1,$2,'purchase_in',$3,$4,$5,'Purchase received')`, [t,inv.rows[0].id,i.quantity,req.params.id,req.user!.userId]); }
    await client.query("UPDATE purchase_orders SET status='goods_received',updated_at=NOW() WHERE id=$1", [req.params.id]); await client.query('COMMIT'); res.json(successResponse(null, 'Inventory received'));
  } catch (e) { await client.query('ROLLBACK'); throw e; } finally { client.release(); }
}));

router.get('/payments', requireRoles('owner', 'manager', 'staff'), asyncHandler(async (req, res) => { const result=await pool.query('SELECT p.*,o.order_number FROM payments p JOIN orders o ON o.id=p.order_id WHERE p.tenant_id=$1 ORDER BY p.created_at DESC',[tenant(req.tenantId)]); res.json(successResponse(result.rows)); }));
router.post('/payments', requireRoles('owner', 'manager', 'staff', 'customer'), validate({ body: paymentDto }), asyncHandler(async (req,res) => { const b=req.body; const t=tenant(req.tenantId); const result=await pool.query(`INSERT INTO payments(tenant_id,order_id,method,status,amount,idempotency_key) SELECT $1,$2,$3,$4,$5,$6 WHERE EXISTS(SELECT 1 FROM orders WHERE id=$2 AND tenant_id=$1) ON CONFLICT(idempotency_key) DO UPDATE SET status=EXCLUDED.status,updated_at=NOW() RETURNING *`,[t,b.orderId,b.method,b.status,b.amount,b.idempotencyKey]); if(!result.rows[0]) throw new NotFoundError('Order'); if(b.status==='success') { await pool.query("UPDATE orders SET status='confirmed',updated_at=NOW() WHERE id=$1 AND tenant_id=$2",[b.orderId,t]); await InvoiceService.createInvoiceForOrder(pool, t, b.orderId).catch(() => {}); } res.status(201).json(successResponse(result.rows[0],'Payment recorded')); }));

router.get('/staff', requireRoles('owner', 'manager'), asyncHandler(async (req,res) => { const r=await pool.query(`SELECT u.id,u.first_name,u.last_name,u.email,u.phone,u.status,r.name AS role FROM users u JOIN roles r ON r.id=u.role_id WHERE u.tenant_id=$1 AND r.name IN ('manager','staff','delivery_agent') ORDER BY u.first_name`,[tenant(req.tenantId)]); res.json(successResponse(r.rows)); }));
router.get('/notifications', asyncHandler(async (req,res) => { const r=await pool.query('SELECT * FROM notifications WHERE user_id=$1 ORDER BY created_at DESC LIMIT 100',[req.user!.userId]); res.json(successResponse(r.rows)); }));
router.patch('/notifications/:id/read', validate({ params: uuidParam }), asyncHandler(async(req,res)=>{ const r=await pool.query("UPDATE notifications SET status='sent' WHERE id=$1 AND user_id=$2 RETURNING *",[req.params.id,req.user!.userId]); if(!r.rows[0]) throw new NotFoundError('Notification'); res.json(successResponse(r.rows[0])); }));

router.get('/admin/tenants', requireRoles('super_admin'), asyncHandler(async (_req,res)=>{const r=await pool.query(`SELECT t.*,sp.name AS plan_name,COUNT(u.id) AS user_count FROM tenants t LEFT JOIN subscription_plans sp ON sp.id=t.subscription_plan_id LEFT JOIN users u ON u.tenant_id=t.id GROUP BY t.id,sp.name ORDER BY t.created_at DESC`);res.json(successResponse(r.rows));}));
router.patch('/admin/tenants/:id/status', requireRoles('super_admin'), validate({ params: uuidParam, body: z.object({ status:z.enum(['active','suspended','trial']) }) }), asyncHandler(async(req,res)=>{const r=await pool.query('UPDATE tenants SET status=$1,updated_at=NOW() WHERE id=$2 RETURNING *',[req.body.status,req.params.id]);if(!r.rows[0])throw new NotFoundError('Tenant');res.json(successResponse(r.rows[0]));}));
router.get('/admin/audit-logs', requireRoles('super_admin'), asyncHandler(async(_req,res)=>{const r=await pool.query('SELECT a.*,u.email,t.name AS tenant_name FROM audit_logs a LEFT JOIN users u ON u.id=a.user_id LEFT JOIN tenants t ON t.id=a.tenant_id ORDER BY a.created_at DESC LIMIT 200');res.json(successResponse(r.rows));}));

const locationDto = z.object({
  name: z.string().min(2),
  address_line: z.string().optional(),
  area: z.string().optional(),
  taluka: z.string().optional(),
  city: z.string().optional(),
  district: z.string().optional(),
  state: z.string().optional(),
  pincode: z.string().optional(),
  geo_lat: z.number().optional().nullable(),
  geo_lng: z.number().optional().nullable(),
  contact_phone: z.string().optional(),
  is_published: z.boolean().default(false)
});

router.get('/locations', requireRoles('owner', 'manager'), asyncHandler(async (req, res) => {
  const result = await pool.query('SELECT * FROM locations WHERE tenant_id = $1 ORDER BY created_at ASC', [tenant(req.tenantId)]);
  res.json(successResponse(result.rows));
}));

router.put('/locations/:id', requireRoles('owner', 'manager'), validate({ params: uuidParam, body: locationDto }), asyncHandler(async (req, res) => {
  const b = req.body;
  const result = await pool.query(`
    UPDATE locations SET
      name = COALESCE($1, name),
      address_line = $2,
      area = $3,
      taluka = $4,
      city = $5,
      district = $6,
      state = $7,
      pincode = $8,
      geo_lat = $9,
      geo_lng = $10,
      contact_phone = COALESCE($11, contact_phone),
      is_published = $12,
      updated_at = NOW()
    WHERE id = $13 AND tenant_id = $14
    RETURNING *
  `, [b.name, b.address_line, b.area, b.taluka, b.city, b.district, b.state, b.pincode, b.geo_lat, b.geo_lng, b.contact_phone, b.is_published, req.params.id, tenant(req.tenantId)]);
  
  if (!result.rows[0]) throw new NotFoundError('Location not found or unauthorized');
  res.json(successResponse(result.rows[0], 'Location updated successfully'));
}));

export default router;
