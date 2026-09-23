import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { config } from '../config';
import { UnauthorizedError } from './error.middleware';
import { redis, REDIS_KEYS } from '../config/redis';
import { pool } from '../config/database';

// ─────────────────────────────────────────────────────────────────────────────
// Extend Express Request with authenticated context
// ─────────────────────────────────────────────────────────────────────────────

export interface JwtPayload {
  userId: string;
  tenantId: string | null;
  roleId: string;
  roleName: string;
  jti: string;           // JWT ID for revocation
}

declare global {
  namespace Express {
    interface Request {
      user?: JwtPayload;
      tenantId?: string;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Auth Middleware — verifies JWT and populates req.user & req.tenantId
// ─────────────────────────────────────────────────────────────────────────────

export async function authenticate(
  req: Request,
  _res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader?.startsWith('Bearer ')) {
      throw new UnauthorizedError('No bearer token provided');
    }

    const token = authHeader.split(' ')[1];
    const payload = jwt.verify(token, config.jwt.accessSecret) as JwtPayload;

    // Check revocation list in Redis
    const isRevoked = await redis.exists(REDIS_KEYS.revokedToken(payload.jti));
    if (isRevoked) {
      throw new UnauthorizedError('Token has been revoked');
    }

    req.user = payload;
    req.tenantId = payload.tenantId ?? undefined;

    // Inject tenant context for RLS if tenant-scoped
    if (payload.tenantId) {
      await pool.query(`SET LOCAL app.current_tenant_id = '${payload.tenantId}'`);
    }

    next();
  } catch (err) {
    if (err instanceof jwt.JsonWebTokenError) {
      next(new UnauthorizedError('Invalid or expired token'));
    } else {
      next(err);
    }
  }
}

/** Convenience middleware — authentication is optional (for public + private mixed routes) */
export async function optionalAuthenticate(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  const authHeader = req.headers.authorization;
  if (!authHeader?.startsWith('Bearer ')) {
    return next();
  }
  return authenticate(req, res, next);
}
