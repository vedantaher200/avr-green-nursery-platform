import express, { Application, Request, Response, NextFunction } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';
import { config } from './config';
import { errorHandler } from './middlewares/error.middleware';
import { optionalAuthenticate } from './middlewares/auth.middleware';
import { logger } from './shared/logger';

// ── Module Routes ─────────────────────────────────────────────────────────────
import authRoutes from './modules/auth/auth.routes';
import catalogRoutes from './modules/catalog/catalog.routes';
import inventoryRoutes from './modules/inventory/inventory.routes';
import orderRoutes from './modules/order/order.routes';
import deliveryRoutes from './modules/delivery/delivery.routes';
import reportRoutes from './modules/report/report.routes';
import managementRoutes from './modules/management/management.routes';
import invoiceRoutes from './modules/invoice/invoice.routes';
import marketplaceRoutes from './modules/marketplace/marketplace.routes';

// ─────────────────────────────────────────────────────────────────────────────
// Express Application Bootstrap
// ─────────────────────────────────────────────────────────────────────────────

export function createApp(): Application {
  const app = express();

  // ── Security headers ────────────────────────────────────────────────────────
  app.use(
    helmet({
      contentSecurityPolicy: false, // Disabled to allow Swagger UI
      crossOriginEmbedderPolicy: false,
    })
  );

  // ── CORS ───────────────────────────────────────────────────────────────────
  app.use(
    cors({
      origin: (origin, cb) => {
        if (!origin || config.cors.origins.includes(origin) || config.app.isDev) {
          cb(null, true);
        } else {
          cb(new Error(`CORS: Origin ${origin} not allowed`));
        }
      },
      credentials: true,
      methods: ['GET', 'POST', 'PATCH', 'PUT', 'DELETE', 'OPTIONS'],
      allowedHeaders: ['Content-Type', 'Authorization', 'X-Idempotency-Key'],
    })
  );

  // ── Body parsers ───────────────────────────────────────────────────────────
  app.use(express.json({ limit: '10mb' }));
  app.use(express.urlencoded({ extended: true, limit: '10mb' }));

  // ── Request logger ─────────────────────────────────────────────────────────
  app.use((req: Request, _res: Response, next: NextFunction) => {
    logger.debug(`${req.method} ${req.path}`, {
      query: req.query,
      ip: req.ip,
    });
    next();
  });

  // ── Global rate limiter ─────────────────────────────────────────────────────
  app.use(
    rateLimit({
      windowMs: config.rateLimit.windowMs,
      max: config.rateLimit.max,
      standardHeaders: true,
      legacyHeaders: false,
    })
  );

  // ── Tenant context injection for all requests ───────────────────────────────
  app.use(optionalAuthenticate);

  // ── Health & readiness probes ──────────────────────────────────────────────
  app.get('/health', (_req, res) => {
    res.json({
      status: 'ok',
      app: config.app.name,
      version: config.app.apiVersion,
      timestamp: new Date().toISOString(),
    });
  });

  app.get('/ready', (_req, res) => {
    // Kubernetes readiness probe
    res.json({ ready: true });
  });

  // ── API Routes ─────────────────────────────────────────────────────────────
  const apiBase = `/api/${config.app.apiVersion}`;
  app.use(`${apiBase}/auth`,      authRoutes);
  app.use(`${apiBase}/products`,  catalogRoutes);
  app.use(`${apiBase}/inventory`, inventoryRoutes);
  app.use(`${apiBase}/orders`,    orderRoutes);
  app.use(`${apiBase}/deliveries`, deliveryRoutes);
  app.use(`${apiBase}/reports`,   reportRoutes);
  app.use(`${apiBase}/invoices`,  invoiceRoutes);
  app.use(`${apiBase}/marketplace`, marketplaceRoutes);
  app.use(`${apiBase}`, managementRoutes);

  // ── 404 catch-all ──────────────────────────────────────────────────────────
  app.use((req: Request, res: Response) => {
    res.status(404).json({
      success: false,
      error: `Cannot ${req.method} ${req.path}`,
    });
  });

  // ── Centralized error handler ──────────────────────────────────────────────
  app.use(errorHandler);

  return app;
}
