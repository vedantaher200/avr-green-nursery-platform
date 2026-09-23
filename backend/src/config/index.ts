import dotenv from 'dotenv';
dotenv.config();

// ─────────────────────────────────────────────────────────────────────────────
// Central validated config — fails fast at startup if a required key is missing
// ─────────────────────────────────────────────────────────────────────────────

function required(key: string): string {
  const value = process.env[key];
  if (!value) throw new Error(`[Config] Missing required environment variable: ${key}`);
  return value;
}

function optional(key: string, fallback: string): string {
  return process.env[key] ?? fallback;
}

export const config = {
  app: {
    name: optional('APP_NAME', 'AVRGREEN'),
    env: optional('NODE_ENV', 'development'),
    port: parseInt(optional('PORT', '5000'), 10),
    apiVersion: optional('API_VERSION', 'v1'),
    isDev: optional('NODE_ENV', 'development') === 'development',
  },
  db: {
    host: optional('DB_HOST', 'localhost'),
    port: parseInt(optional('DB_PORT', '5432'), 10),
    user: optional('DB_USER', 'avrgreen_user'),
    password: optional('DB_PASSWORD', 'password'),
    name: optional('DB_NAME', 'avrgreen_db'),
    poolMax: parseInt(optional('DB_POOL_MAX', '20'), 10),
  },
  redis: {
    url: optional('REDIS_URL', 'redis://localhost:6379'),
  },
  jwt: {
    accessSecret: optional('JWT_ACCESS_SECRET', 'avrgreen_access_secret_dev_key_change_in_production'),
    refreshSecret: optional('JWT_REFRESH_SECRET', 'avrgreen_refresh_secret_dev_key_change_in_production'),
    accessExpiresIn: optional('JWT_ACCESS_EXPIRES_IN', '15m'),
    refreshExpiresIn: optional('JWT_REFRESH_EXPIRES_IN', '30d'),
  },
  r2: {
    accountId: optional('R2_ACCOUNT_ID', ''),
    accessKeyId: optional('R2_ACCESS_KEY_ID', ''),
    secretAccessKey: optional('R2_SECRET_ACCESS_KEY', ''),
    bucketName: optional('R2_BUCKET_NAME', 'avrgreen-assets'),
    publicUrl: optional('R2_PUBLIC_URL', 'http://localhost:9000/avrgreen-assets'),
  },
  razorpay: {
    keyId: optional('RAZORPAY_KEY_ID', ''),
    keySecret: optional('RAZORPAY_KEY_SECRET', ''),
    webhookSecret: optional('RAZORPAY_WEBHOOK_SECRET', ''),
  },
  smtp: {
    host: optional('SMTP_HOST', 'smtp.ethereal.email'),
    port: parseInt(optional('SMTP_PORT', '587'), 10),
    user: optional('SMTP_USER', ''),
    pass: optional('SMTP_PASS', ''),
    from: optional('SMTP_FROM', 'AVRGREEN <no-reply@avrgreen.com>'),
  },
  rateLimit: {
    windowMs: parseInt(optional('RATE_LIMIT_WINDOW_MS', '60000'), 10),
    max: parseInt(optional('RATE_LIMIT_MAX_REQUESTS', '100'), 10),
    authMax: parseInt(optional('RATE_LIMIT_AUTH_MAX', process.env.NODE_ENV === 'production' ? '10' : '100'), 10),
  },
  cors: {
    origins: optional('CORS_ORIGINS', 'http://localhost:3000').split(','),
  },
};

export type AppConfig = typeof config;
