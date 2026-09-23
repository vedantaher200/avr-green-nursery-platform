import { Request, Response, NextFunction } from 'express';
import { ForbiddenError, UnauthorizedError } from './error.middleware';
import { pool } from '../config/database';

// ─────────────────────────────────────────────────────────────────────────────
// Role-Based Access Control (RBAC) Middleware
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Restricts access to one or more role names.
 * Usage: router.get('/admin', authenticate, requireRoles('super_admin'), handler)
 */
export function requireRoles(...roles: string[]) {
  return (req: Request, _res: Response, next: NextFunction): void => {
    if (!req.user) {
      return next(new UnauthorizedError());
    }
    if (!roles.includes(req.user.roleName)) {
      return next(new ForbiddenError(`Required role: ${roles.join(' or ')}`));
    }
    next();
  };
}

/**
 * Checks that the authenticated user's role has a specific permission code.
 * Loads permissions from DB and caches result in request context.
 * Usage: router.post('/inventory', authenticate, requirePermission('inventory.write'), handler)
 */
export function requirePermission(permissionCode: string) {
  return async (req: Request, _res: Response, next: NextFunction): Promise<void> => {
    try {
      if (!req.user) {
        return next(new UnauthorizedError());
      }

      // Tenant Owner and Super Admin inherently possess all permissions
      if (req.user.roleName === 'owner' || req.user.roleName === 'super_admin') {
        return next();
      }

      const result = await pool.query<{ code: string }>(
        `SELECT p.code
         FROM role_permissions rp
         JOIN permissions p ON p.id = rp.permission_id
         WHERE rp.role_id = $1 AND p.code = $2`,
        [req.user.roleId, permissionCode]
      );

      if (result.rowCount === 0) {
        return next(
          new ForbiddenError(`Permission required: ${permissionCode}`)
        );
      }

      next();
    } catch (err) {
      next(err);
    }
  };
}

/**
 * Ensures the requesting user belongs to the same tenant as the resource.
 * Reads tenantId from req.params.tenantId or req.body.tenantId.
 */
export function requireTenantMatch(
  req: Request,
  _res: Response,
  next: NextFunction
): void {
  if (!req.user) {
    return next(new UnauthorizedError());
  }

  // Super admin bypasses tenant checks
  if (req.user.roleName === 'super_admin') {
    return next();
  }

  const resourceTenantId = req.params.tenantId ?? req.body?.tenantId;
  if (resourceTenantId && resourceTenantId !== req.user.tenantId) {
    return next(new ForbiddenError('Cross-tenant access denied'));
  }

  next();
}
