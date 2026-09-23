import { createClient, RedisClientType } from 'redis';
import { config } from './index';
import { logger } from '../shared/logger';

// ─────────────────────────────────────────────────────────────────────────────
// Shared Redis client for caching, session tokens, OTP, BullMQ backing store
// ─────────────────────────────────────────────────────────────────────────────

let redisClient: RedisClientType | null = null;
let isRedisConnected = false;
const devMemoryStore = new Map<string, { value: string; expiresAt?: number }>();

export function getRedisClient(): RedisClientType | null {
  if (!redisClient) {
    try {
      redisClient = createClient({
        url: config.redis.url,
        socket: {
          connectTimeout: 1000,
          reconnectStrategy: false,
        },
      }) as RedisClientType;

      redisClient.on('connect', () => {
        isRedisConnected = true;
        logger.info('Redis: client connected');
      });
      redisClient.on('error', (err) => {
        isRedisConnected = false;
      });
    } catch {
      redisClient = null;
    }
  }
  return redisClient;
}

export async function connectRedis(): Promise<void> {
  const client = getRedisClient();
  if (!client) {
    logger.warn('Redis client not created — using in-memory store for local development');
    return;
  }
  try {
    await client.connect();
    await client.ping();
    isRedisConnected = true;
    logger.info('Redis: PING OK');
  } catch (err: any) {
    isRedisConnected = false;
    logger.warn(`Redis not available (${err.message}) — using in-memory fallback store for dev session/tokens`);
  }
}

// ── Typed helpers ─────────────────────────────────────────────────────────────

export const redis = {
  /** Store a value with optional TTL in seconds */
  set: async (key: string, value: string, ttlSec?: number): Promise<void> => {
    if (isRedisConnected && redisClient) {
      try {
        if (ttlSec) {
          await redisClient.setEx(key, ttlSec, value);
        } else {
          await redisClient.set(key, value);
        }
        return;
      } catch {
        // Fallback to memory
      }
    }
    const expiresAt = ttlSec ? Date.now() + ttlSec * 1000 : undefined;
    devMemoryStore.set(key, { value, expiresAt });
  },

  get: async (key: string): Promise<string | null> => {
    if (isRedisConnected && redisClient) {
      try {
        return await redisClient.get(key);
      } catch {
        // Fallback to memory
      }
    }
    const item = devMemoryStore.get(key);
    if (!item) return null;
    if (item.expiresAt && Date.now() > item.expiresAt) {
      devMemoryStore.delete(key);
      return null;
    }
    return item.value;
  },

  del: async (...keys: string[]): Promise<void> => {
    if (isRedisConnected && redisClient) {
      try {
        await redisClient.del(keys);
        return;
      } catch {
        // Fallback to memory
      }
    }
    for (const key of keys) {
      devMemoryStore.delete(key);
    }
  },

  exists: async (key: string): Promise<boolean> => {
    if (isRedisConnected && redisClient) {
      try {
        const count = await redisClient.exists(key);
        return count > 0;
      } catch {
        // Fallback to memory
      }
    }
    const item = devMemoryStore.get(key);
    if (!item) return false;
    if (item.expiresAt && Date.now() > item.expiresAt) {
      devMemoryStore.delete(key);
      return false;
    }
    return true;
  },

  /** Increment an integer counter and return the new value */
  incr: async (key: string): Promise<number> => {
    if (isRedisConnected && redisClient) {
      try {
        return await redisClient.incr(key);
      } catch {
        // Fallback to memory
      }
    }
    const item = devMemoryStore.get(key);
    let val = 0;
    if (item && (!item.expiresAt || Date.now() <= item.expiresAt)) {
      val = parseInt(item.value, 10) || 0;
    }
    val += 1;
    devMemoryStore.set(key, { value: String(val) });
    return val;
  },

  expire: async (key: string, ttlSec: number): Promise<void> => {
    if (isRedisConnected && redisClient) {
      try {
        await redisClient.expire(key, ttlSec);
        return;
      } catch {
        // Fallback to memory
      }
    }
    const item = devMemoryStore.get(key);
    if (item) {
      item.expiresAt = Date.now() + ttlSec * 1000;
    }
  },
};

// ── Redis key namespaces ──────────────────────────────────────────────────────
export const REDIS_KEYS = {
  otpCode: (phone: string) => `otp:${phone}`,
  refreshToken: (userId: string, tokenId: string) => `rt:${userId}:${tokenId}`,
  revokedToken: (jti: string) => `revoked:${jti}`,
  catalogCache: (tenantId: string, page: number) => `catalog:${tenantId}:p${page}`,
  rateLimitAuth: (ip: string) => `rl:auth:${ip}`,
};
