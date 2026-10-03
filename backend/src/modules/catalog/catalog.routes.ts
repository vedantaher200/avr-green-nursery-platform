import { Router } from 'express';
import { authenticate } from '../../middlewares/auth.middleware';
import { requirePermission } from '../../middlewares/rbac.middleware';
import { validate, uuidParam, paginationQuery } from '../../middlewares/validate.middleware';
import { asyncHandler } from '../../middlewares/error.middleware';
import { successResponse, paginationMeta } from '../../shared/response';
import { pool } from '../../config/database';
import { NotFoundError } from '../../middlewares/error.middleware';
import { z } from 'zod';

// ─────────────────────────────────────────────────────────────────────────────
// Catalog Module — Products & Categories (inline for brevity)
// ─────────────────────────────────────────────────────────────────────────────

const CreateProductDto = z.object({
  sku: z.string().min(2).max(50),
  categoryId: z.string().uuid().optional(),
  supplierId: z.string().uuid().optional(),
  commonName: z.string().min(2).max(255),
  scientificName: z.string().optional(),
  crop: z.string().optional(),
  variety: z.string().optional(),
  sellingUnit: z.string().optional(),
  traySize: z.number().int().optional(),
  minOrderQty: z.number().int().optional(),
  description: z.string().optional(),
  careInstructions: z.record(z.string()).optional(),
  price: z.number().positive(),
  costPrice: z.number().positive(),
  barcode: z.string().optional(),
});

const router = Router();

// ── GET /products — paginated product list ────────────────────────────────────
router.get(
  '/',
  validate({ query: paginationQuery }),
  asyncHandler(async (req, res) => {
    const { page, limit, search, sortBy, sortOrder, crop, variety, category, categoryId, tenantId: queryTenantId } = req.query as any;
    const isOwnerOrStaff = req.user && req.user.roleName !== 'customer' && req.user.tenantId;
    const tenantId = isOwnerOrStaff
      ? req.user?.tenantId
      : ((queryTenantId as string) || (req.headers['x-tenant-id'] as string) || req.tenantId || '33333333-3333-3333-3333-333333333333');
    const offset = (page - 1) * limit;

    let extraFilters = '';
    const params: unknown[] = [];

    // If owner/staff, force their tenant. If customer, use provided tenant or allow all (multi-nursery marketplace).
    let targetTenantId = isOwnerOrStaff ? req.user?.tenantId : (queryTenantId as string);

    if (targetTenantId) {
      params.push(targetTenantId);
      extraFilters += ` AND p.tenant_id = $${params.length}`;
    }

    if (search) {
      params.push(`%${search}%`);
      extraFilters += ` AND (p.common_name ILIKE $${params.length} OR p.scientific_name ILIKE $${params.length} OR p.sku ILIKE $${params.length} OR p.crop ILIKE $${params.length} OR p.variety ILIKE $${params.length})`;
    }

    if (crop && crop !== 'all') {
      params.push(crop);
      extraFilters += ` AND p.crop = $${params.length}`;
    }

    if (variety && variety !== 'all') {
      params.push(variety);
      extraFilters += ` AND p.variety = $${params.length}`;
    }

    if (categoryId) {
      params.push(categoryId);
      extraFilters += ` AND p.category_id = $${params.length}`;
    } else if (category && category !== 'all') {
      params.push(category);
      extraFilters += ` AND (c.slug = $${params.length} OR c.name ILIKE $${params.length})`;
    }

    const validSortCols: Record<string, string> = {
      name: 'p.common_name',
      price: 'p.price',
      created_at: 'p.created_at',
      sku: 'p.sku',
    };
    const orderCol = validSortCols[sortBy] ?? 'p.created_at';
    const orderDir = sortOrder === 'asc' ? 'ASC' : 'DESC';

    const countParams = [...params];
    const countQuery = `
      SELECT COUNT(DISTINCT p.id) FROM products p
      LEFT JOIN categories c ON c.id = p.category_id
      WHERE p.deleted_at IS NULL AND p.status = 'active'
      ${extraFilters}
    `;

    params.push(limit);
    const limitIdx = params.length;
    params.push(offset);
    const offsetIdx = params.length;

    const query = `
      SELECT p.*, c.name AS category_name, s.name AS supplier_name,
             n.name AS nursery_name,
             COALESCE(n.rating, 4.8) AS nursery_rating,
             COALESCE(n.review_count, 128) AS review_count,
             COALESCE(SUM(i.quantity_available), 0)::INT AS total_stock
      FROM products p
      LEFT JOIN categories c ON c.id = p.category_id
      LEFT JOIN suppliers s ON s.id = p.supplier_id
      LEFT JOIN nurseries n ON n.tenant_id = p.tenant_id
      LEFT JOIN inventory i ON i.product_id = p.id
      WHERE p.deleted_at IS NULL AND p.status = 'active'
      ${extraFilters}
      GROUP BY p.id, c.name, s.name, n.name, n.rating, n.review_count
      ORDER BY ${orderCol} ${orderDir}
      LIMIT $${limitIdx} OFFSET $${offsetIdx}
    `;

    const [rows, countResult] = await Promise.all([
      pool.query(query, params),
      pool.query(countQuery, countParams),
    ]);

    const total = parseInt(countResult.rows[0].count, 10);
    res.json(successResponse(rows.rows, undefined, paginationMeta(total, page, limit)));
  })
);

// Static paths must be registered before /:id so they are not treated as IDs.
router.get(
  '/categories/all',
  asyncHandler(async (req, res) => {
    const result = await pool.query(
      `SELECT id, name, slug, parent_id, icon_url
       FROM categories WHERE tenant_id = $1
       ORDER BY name ASC`,
      [req.tenantId]
    );
    res.json(successResponse(result.rows));
  })
);

// ── GET /products/:id — single product ───────────────────────────────────────
router.get(
  '/:id',
  validate({ params: uuidParam }),
  asyncHandler(async (req, res) => {
    const result = await pool.query(
      `SELECT p.*, c.name AS category_name, s.name AS supplier_name
       FROM products p
       LEFT JOIN categories c ON c.id = p.category_id
       LEFT JOIN suppliers s ON s.id = p.supplier_id
       WHERE p.id = $1 AND p.tenant_id = $2 AND p.deleted_at IS NULL`,
      [req.params.id, req.tenantId]
    );
    if (!result.rows[0]) throw new NotFoundError('Product');
    res.json(successResponse(result.rows[0]));
  })
);

// ── POST /products — create product ──────────────────────────────────────────
router.post(
  '/',
  authenticate,
  requirePermission('catalog.write'),
  validate({ body: CreateProductDto }),
  asyncHandler(async (req, res) => {
    const d = req.body;
    const result = await pool.query(
      `INSERT INTO products
         (tenant_id, sku, category_id, supplier_id, common_name, scientific_name,
          crop, variety, selling_unit, tray_size, min_order_qty,
          description, care_instructions, price, cost_price, barcode)
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16)
       RETURNING *`,
      [
        req.tenantId, d.sku, d.categoryId ?? null, d.supplierId ?? null,
        d.commonName, d.scientificName ?? null,
        d.crop ?? null, d.variety ?? null, d.sellingUnit ?? 'seedling', d.traySize ?? 104, d.minOrderQty ?? 1,
        d.description ?? null,
        JSON.stringify(d.careInstructions ?? {}), d.price, d.costPrice,
        d.barcode ?? null,
      ]
    );
    res.status(201).json(successResponse(result.rows[0], 'Product created'));
  })
);

// ── PATCH /products/:id — update product ─────────────────────────────────────
router.patch(
  '/:id',
  authenticate,
  requirePermission('catalog.write'),
  validate({ params: uuidParam }),
  asyncHandler(async (req, res) => {
    const { id } = req.params;
    const d = req.body;
    const result = await pool.query(
      `UPDATE products SET
         common_name = COALESCE($1, common_name),
         price = COALESCE($2, price),
         description = COALESCE($3, description),
         status = COALESCE($4, status),
         updated_at = NOW()
       WHERE id = $5 AND tenant_id = $6 AND deleted_at IS NULL
       RETURNING *`,
      [d.commonName ?? null, d.price ?? null, d.description ?? null, d.status ?? null, id, req.tenantId]
    );
    if (!result.rows[0]) throw new NotFoundError('Product');
    res.json(successResponse(result.rows[0], 'Product updated'));
  })
);

// ── DELETE /products/:id — soft delete ───────────────────────────────────────
router.delete(
  '/:id',
  authenticate,
  requirePermission('catalog.write'),
  validate({ params: uuidParam }),
  asyncHandler(async (req, res) => {
    await pool.query(
      `UPDATE products SET deleted_at = NOW() WHERE id = $1 AND tenant_id = $2`,
      [req.params.id, req.tenantId]
    );
    res.json(successResponse(null, 'Product deleted'));
  })
);

// ── GET /categories ───────────────────────────────────────────────────────────
export default router;
