import { z, ZodSchema } from 'zod';
import { Request, Response, NextFunction } from 'express';
import { ValidationError } from './error.middleware';

// ─────────────────────────────────────────────────────────────────────────────
// Zod Request Validation Middleware Factory
// ─────────────────────────────────────────────────────────────────────────────

type ValidateParts = {
  body?: ZodSchema;
  query?: ZodSchema;
  params?: ZodSchema;
};

export function validate(schemas: ValidateParts) {
  return (req: Request, _res: Response, next: NextFunction): void => {
    try {
      if (schemas.body) {
        req.body = schemas.body.parse(req.body);
      }
      if (schemas.query) {
        req.query = schemas.query.parse(req.query) as typeof req.query;
      }
      if (schemas.params) {
        req.params = schemas.params.parse(req.params) as typeof req.params;
      }
      next();
    } catch (err) {
      if (err instanceof z.ZodError) {
        const messages = err.errors
          .map((e) => `${e.path.join('.')}: ${e.message}`)
          .join('; ');
        next(new ValidationError(messages));
      } else {
        next(err);
      }
    }
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// Common Reusable Schemas
// ─────────────────────────────────────────────────────────────────────────────

export const uuidParam = z.object({
  id: z.string().uuid('Invalid UUID format'),
});

export const paginationQuery = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
  search: z.string().optional(),
  sortBy: z.string().optional(),
  sortOrder: z.enum(['asc', 'desc']).default('desc'),
}).passthrough();

export type PaginationQuery = z.infer<typeof paginationQuery>;
