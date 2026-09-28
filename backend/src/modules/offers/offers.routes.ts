import { Router } from 'express';
import { z } from 'zod';
import { authenticate } from '../../middlewares/auth.middleware';
import { requireRoles } from '../../middlewares/rbac.middleware';
import { asyncHandler, ValidationError } from '../../middlewares/error.middleware';
import { validate } from '../../middlewares/validate.middleware';
import { successResponse } from '../../shared/response';
import { OffersService } from './offers.service';

const router = Router();

// ─────────────────────────────────────────────────────────────────────────────
// Public Farmer Marketplace Endpoints
// ─────────────────────────────────────────────────────────────────────────────

router.get(
  '/marketplace/offers',
  asyncHandler(async (req, res) => {
    const { crop, nurseryId, city } = req.query as any;
    const offers = await OffersService.getMarketplaceOffers({
      crop: crop ? String(crop) : undefined,
      nurseryId: nurseryId ? String(nurseryId) : undefined,
      city: city ? String(city) : undefined,
    });
    res.json(successResponse(offers, 'Active marketplace offers retrieved successfully'));
  })
);

router.get(
  '/marketplace/offers/:id',
  asyncHandler(async (req, res) => {
    const offer = await OffersService.getOfferDetails(req.params.id);
    res.json(successResponse(offer, 'Offer details retrieved successfully'));
  })
);

const CalculateDiscountDto = z.object({
  tenantId: z.string().uuid(),
  offerId: z.string().uuid(),
  items: z.array(
    z.object({
      productId: z.string().uuid(),
      quantity: z.number().int().positive(),
    })
  ).min(1),
});

router.post(
  '/marketplace/offers/calculate-discount',
  validate({ body: CalculateDiscountDto }),
  asyncHandler(async (req, res) => {
    const { tenantId, offerId, items } = req.body;
    const result = await OffersService.calculateDiscount(tenantId, offerId, items);
    res.json(successResponse(result, 'Discount calculation completed'));
  })
);

// ─────────────────────────────────────────────────────────────────────────────
// Nursery Owner / Manager Endpoints (Tenant Scoped & Authorized)
// ─────────────────────────────────────────────────────────────────────────────

const CreateOfferDto = z.object({
  title: z.string().min(3).max(255),
  shortDescription: z.string().optional(),
  bannerImageUrl: z.string().optional(),
  offerType: z.enum([
    'percentage_discount',
    'flat_discount',
    'special_price',
    'bulk_purchase',
    'prebook_offer',
    'early_bird',
    'limited_stock',
  ]),
  discountType: z.enum(['percentage', 'flat_amount', 'special_unit_price']),
  discountValue: z.number().positive(),
  applicableCrop: z.string().optional(),
  applicableVariety: z.string().optional(),
  minQuantity: z.number().int().min(1).default(1),
  minOrderValue: z.number().min(0).default(0),
  startDate: z.string(),
  endDate: z.string(),
  isPrebookingOffer: z.boolean().default(false),
  maxRedemptions: z.number().int().positive().optional(),
  termsConditions: z.string().optional(),
  eventLabel: z.string().optional(),
  productIds: z.array(z.string().uuid()).optional(),
});

const UpdateStatusDto = z.object({
  status: z.enum(['draft', 'scheduled', 'active', 'paused', 'expired', 'cancelled']),
});

// GET /owner/offers — List owner's tenant offers
router.get(
  '/owner/offers',
  authenticate,
  requireRoles('owner', 'manager', 'staff'),
  asyncHandler(async (req, res) => {
    const tenantId = req.tenantId;
    if (!tenantId) throw new ValidationError('Tenant context is required');

    const { status } = req.query as any;
    const offers = await OffersService.getOwnerOffers(tenantId, status);
    res.json(successResponse(offers, 'Owner offers retrieved successfully'));
  })
);

// POST /owner/offers — Create new offer
router.post(
  '/owner/offers',
  authenticate,
  requireRoles('owner', 'manager'),
  validate({ body: CreateOfferDto }),
  asyncHandler(async (req, res) => {
    const tenantId = req.tenantId;
    if (!tenantId) throw new ValidationError('Tenant context is required');

    const offer = await OffersService.createOffer(tenantId, req.body);
    res.status(201).json(successResponse(offer, 'Offer created successfully'));
  })
);

// GET /owner/offers/:id — Get single offer
router.get(
  '/owner/offers/:id',
  authenticate,
  requireRoles('owner', 'manager', 'staff'),
  asyncHandler(async (req, res) => {
    const tenantId = req.tenantId;
    if (!tenantId) throw new ValidationError('Tenant context is required');

    const offer = await OffersService.getOfferDetails(req.params.id);
    if (offer.tenantId !== tenantId) {
      return res.status(403).json({ success: false, error: 'Unauthorized cross-tenant access' });
    }
    res.json(successResponse(offer, 'Offer retrieved successfully'));
  })
);

// PUT /owner/offers/:id — Update offer
router.put(
  '/owner/offers/:id',
  authenticate,
  requireRoles('owner', 'manager'),
  validate({ body: CreateOfferDto.partial() }),
  asyncHandler(async (req, res) => {
    const tenantId = req.tenantId;
    if (!tenantId) throw new ValidationError('Tenant context is required');

    const updated = await OffersService.updateOffer(tenantId, req.params.id, req.body);
    res.json(successResponse(updated, 'Offer updated successfully'));
  })
);

// PATCH /owner/offers/:id/status — Change status
router.patch(
  '/owner/offers/:id/status',
  authenticate,
  requireRoles('owner', 'manager'),
  validate({ body: UpdateStatusDto }),
  asyncHandler(async (req, res) => {
    const tenantId = req.tenantId;
    if (!tenantId) throw new ValidationError('Tenant context is required');

    const updated = await OffersService.updateOfferStatus(tenantId, req.params.id, req.body.status);
    res.json(successResponse(updated, `Offer status updated to ${req.body.status}`));
  })
);

// DELETE /owner/offers/:id — Delete offer
router.delete(
  '/owner/offers/:id',
  authenticate,
  requireRoles('owner', 'manager'),
  asyncHandler(async (req, res) => {
    const tenantId = req.tenantId;
    if (!tenantId) throw new ValidationError('Tenant context is required');

    const result = await OffersService.deleteOffer(tenantId, req.params.id);
    res.json(successResponse(result, 'Offer deleted successfully'));
  })
);

export default router;
