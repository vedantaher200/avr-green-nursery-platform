import { Pool, PoolClient } from 'pg';
import { config } from './index';
import { logger } from '../shared/logger';

// ─────────────────────────────────────────────────────────────────────────────
// PostgreSQL connection pool with RLS tenant context injection
// ─────────────────────────────────────────────────────────────────────────────

export const pool = new Pool({
  host: config.db.host,
  port: config.db.port,
  user: config.db.user,
  password: config.db.password,
  database: config.db.name,
  max: config.db.poolMax,
  idleTimeoutMillis: 30_000,
  connectionTimeoutMillis: 10_000,
});

pool.on('connect', () => {
  logger.debug('PostgreSQL: new client connected to pool');
});

pool.on('error', (err) => {
  logger.error('PostgreSQL pool error', { error: err.message });
});

/**
 * Returns a pool client with tenant isolation applied via PostgreSQL's
 * `SET LOCAL app.current_tenant_id` (used by Row-Level Security policies).
 * Always call `client.release()` when done — use the `withTenantClient` helper below.
 */
export async function getTenantClient(tenantId: string): Promise<PoolClient> {
  const client = await pool.connect();
  await client.query(`SET LOCAL app.current_tenant_id = '${tenantId}'`);
  return client;
}

/**
 * Convenience helper: acquires a tenant-scoped client, runs the callback,
 * and guarantees release even on errors.
 */
export async function withTenantClient<T>(
  tenantId: string,
  fn: (client: PoolClient) => Promise<T>
): Promise<T> {
  const client = await getTenantClient(tenantId);
  try {
    return await fn(client);
  } finally {
    client.release();
  }
}

export async function checkDatabaseConnection(): Promise<void> {
  try {
    const result = await pool.query('SELECT NOW() as time, current_database() as db');
    logger.info(`PostgreSQL connected: ${result.rows[0].db} @ ${result.rows[0].time}`);
  } catch (err) {
    logger.error('PostgreSQL connection failed', { error: err });
    throw err;
  }
}
