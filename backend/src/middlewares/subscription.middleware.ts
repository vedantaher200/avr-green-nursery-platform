import { Request, Response, NextFunction } from 'express';
import { pool } from '../config/database';
import { ValidationError, ForbiddenError } from './error.middleware';

/**
 * Validates whether a tenant is allowed to perform operations subject to subscription limits
 * (e.g. creating new branches/locations, adding new staff users, adding new products).
 */
export function checkSubscriptionLimit(resource: 'branch' | 'user' | 'product') {
  return async (req: Request, _res: Response, next: NextFunction) => {
    const tenantId = req.tenantId;
    if (!tenantId) {
      return next(new ValidationError('Tenant context is required'));
    }

    try {
      // 1. Fetch tenant subscription plan & status
      const planRes = await pool.query(
        `SELECT t.status as tenant_status, sp.name, sp.max_branches, sp.max_users, sp.features
         FROM tenants t
         LEFT JOIN subscription_plans sp ON sp.id = t.subscription_plan_id
         WHERE t.id = $1`,
        [tenantId]
      );

      if (planRes.rows.length === 0) {
        return next(new ForbiddenError('Tenant account not found'));
      }

      const plan = planRes.rows[0];
      if (plan.tenant_status === 'suspended') {
        return next(new ForbiddenError('Tenant account is suspended. Please contact AVR Mitra support.'));
      }

      // 2. Count current usage
      if (resource === 'branch') {
        const countRes = await pool.query(
          `SELECT COUNT(*) as current_count FROM locations WHERE tenant_id = $1`,
          [tenantId]
        );
        const currentCount = parseInt(countRes.rows[0].current_count, 10);
        const maxBranches = plan.max_branches || 1;
        if (currentCount >= maxBranches) {
          return next(
            new ForbiddenError(
              `Subscription limit reached. Your plan allows a maximum of ${maxBranches} branch(es). Please upgrade to add more locations.`
            )
          );
        }
      } else if (resource === 'user') {
        const countRes = await pool.query(
          `SELECT COUNT(*) as current_count FROM users WHERE tenant_id = $1 AND deleted_at IS NULL`,
          [tenantId]
        );
        const currentCount = parseInt(countRes.rows[0].current_count, 10);
        const maxUsers = plan.max_users || 5;
        if (currentCount >= maxUsers) {
          return next(
            new ForbiddenError(
              `Subscription limit reached. Your plan allows a maximum of ${maxUsers} user(s). Please upgrade to invite more staff.`
            )
          );
        }
      }

      next();
    } catch (err) {
      next(err);
    }
  };
}
