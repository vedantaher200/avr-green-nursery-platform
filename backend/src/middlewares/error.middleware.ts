import { Request, Response, NextFunction } from 'express';
import { logger } from '../shared/logger';
import { errorResponse } from '../shared/response';

// ─────────────────────────────────────────────────────────────────────────────
// Typed Application Errors
// ─────────────────────────────────────────────────────────────────────────────

export class AppError extends Error {
  public readonly statusCode: number;
  public readonly isOperational: boolean;

  constructor(message: string, statusCode = 500, isOperational = true) {
    super(message);
    this.statusCode = statusCode;
    this.isOperational = isOperational;
    Object.setPrototypeOf(this, new.target.prototype);
    Error.captureStackTrace(this);
  }
}

export class ValidationError extends AppError {
  constructor(message: string) { super(message, 400); }
}

export class UnauthorizedError extends AppError {
  constructor(message = 'Unauthorized') { super(message, 401); }
}

export class ForbiddenError extends AppError {
  constructor(message = 'Forbidden') { super(message, 403); }
}

export class NotFoundError extends AppError {
  constructor(resource = 'Resource') { super(`${resource} not found`, 404); }
}

export class ConflictError extends AppError {
  constructor(message: string) { super(message, 409); }
}

// ─────────────────────────────────────────────────────────────────────────────
// Global Error Handler Middleware
// ─────────────────────────────────────────────────────────────────────────────

// eslint-disable-next-line @typescript-eslint/no-unused-vars
export function errorHandler(
  err: Error,
  req: Request,
  res: Response,
  _next: NextFunction
): void {
  if (err instanceof AppError) {
    if (err.statusCode >= 500) {
      logger.error('Operational error', {
        message: err.message,
        statusCode: err.statusCode,
        path: req.path,
        stack: err.stack,
      });
    }
    res.status(err.statusCode).json(errorResponse(err.message));
    return;
  }

  // Unhandled / unexpected error
  logger.error('Unhandled error', {
    message: err.message,
    path: req.path,
    stack: err.stack,
  });

  res.status(500).json(errorResponse('An unexpected error occurred'));
}

/** Async route wrapper — forwards thrown errors to errorHandler */
export function asyncHandler<T>(
  fn: (req: Request, res: Response, next: NextFunction) => Promise<T>
) {
  return (req: Request, res: Response, next: NextFunction): void => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
}
