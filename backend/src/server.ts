import http from 'http';
import { createApp } from './app';
import { config } from './config';
import { checkDatabaseConnection } from './config/database';
import { connectRedis } from './config/redis';
import { createSocketServer } from './config/socket';
import { logger } from './shared/logger';

// ─────────────────────────────────────────────────────────────────────────────
// AVRGREEN Server Bootstrap — Fail-fast startup with graceful shutdown
// ─────────────────────────────────────────────────────────────────────────────

async function bootstrap(): Promise<void> {
  logger.info(`🌿 Booting ${config.app.name} API Server [${config.app.env}]`);

  // ── 1. Verify infrastructure connections ─────────────────────────────────
  await checkDatabaseConnection();
  await connectRedis();

  // ── 2. Build Express app ──────────────────────────────────────────────────
  const app = createApp();
  const httpServer = http.createServer(app);

  // ── 3. Attach Socket.IO ───────────────────────────────────────────────────
  createSocketServer(httpServer);

  // ── 4. Start listening ────────────────────────────────────────────────────
  httpServer.listen(config.app.port, () => {
    logger.info(`✅ ${config.app.name} API running on port ${config.app.port}`);
    logger.info(`   REST API:    http://localhost:${config.app.port}/api/${config.app.apiVersion}`);
    logger.info(`   Health:      http://localhost:${config.app.port}/health`);
    logger.info(`   WebSockets:  ws://localhost:${config.app.port}/socket.io`);
  });

  // ── 5. Graceful shutdown ──────────────────────────────────────────────────
  const shutdown = async (signal: string) => {
    logger.info(`${signal} received — shutting down gracefully`);
    httpServer.close(async () => {
      logger.info('HTTP server closed');
      process.exit(0);
    });

    // Force exit after 10 seconds
    setTimeout(() => {
      logger.error('Forcing exit after timeout');
      process.exit(1);
    }, 10_000);
  };

  process.on('SIGTERM', () => shutdown('SIGTERM'));
  process.on('SIGINT',  () => shutdown('SIGINT'));
  process.on('uncaughtException', (err) => {
    logger.error('Uncaught exception', { error: err.message, stack: err.stack });
    process.exit(1);
  });
  process.on('unhandledRejection', (reason) => {
    logger.error('Unhandled promise rejection', { reason });
    process.exit(1);
  });
}

bootstrap().catch((err) => {
  console.error('Fatal startup error:', err);
  process.exit(1);
});
