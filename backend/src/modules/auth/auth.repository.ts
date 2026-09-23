import { pool } from '../../config/database';
import { ConflictError, NotFoundError } from '../../middlewares/error.middleware';

// ─────────────────────────────────────────────────────────────────────────────
// Auth Repository — all DB operations for the auth module
// ─────────────────────────────────────────────────────────────────────────────

export interface UserRow {
  id: string;
  tenant_id: string | null;
  role_id: string;
  role_name: string;
  email: string;
  phone: string;
  password_hash: string;
  first_name: string;
  last_name: string;
  avatar_url: string | null;
  mfa_enabled: boolean;
  mfa_secret: string | null;
  status: string;
}

export const authRepository = {
  async findByEmail(email: string): Promise<UserRow | null> {
    const result = await pool.query<UserRow>(
      `SELECT u.*, r.name AS role_name
       FROM users u
       JOIN roles r ON r.id = u.role_id
       WHERE u.email = $1 AND u.deleted_at IS NULL
       LIMIT 1`,
      [email]
    );
    return result.rows[0] ?? null;
  },

  async findByPhoneOrEmail(identifier: string): Promise<UserRow | null> {
    const cleanDigits = identifier.replace(/[^0-9]/g, '');
    const last10 = cleanDigits.length >= 10 ? cleanDigits.slice(-10) : cleanDigits;

    const result = await pool.query<UserRow>(
      `SELECT u.*, r.name AS role_name
       FROM users u
       JOIN roles r ON r.id = u.role_id
       WHERE (u.email = $1 OR u.phone = $1 OR ($2 != '' AND u.phone LIKE '%' || $2))
         AND u.deleted_at IS NULL
       LIMIT 1`,
      [identifier, last10]
    );
    return result.rows[0] ?? null;
  },

  async phoneExists(phone: string): Promise<boolean> {
    const cleanDigits = phone.replace(/[^0-9]/g, '');
    const last10 = cleanDigits.length >= 10 ? cleanDigits.slice(-10) : cleanDigits;
    const result = await pool.query<{ count: string }>(
      `SELECT COUNT(*) as count FROM users WHERE (phone = $1 OR ($2 != '' AND phone LIKE '%' || $2)) AND deleted_at IS NULL`,
      [phone, last10]
    );
    return parseInt(result.rows[0].count, 10) > 0;
  },

  async findById(userId: string): Promise<UserRow | null> {
    const result = await pool.query<UserRow>(
      `SELECT u.*, r.name AS role_name
       FROM users u
       JOIN roles r ON r.id = u.role_id
       WHERE u.id = $1 AND u.deleted_at IS NULL
       LIMIT 1`,
      [userId]
    );
    return result.rows[0] ?? null;
  },

  async findRoleByName(roleName: string): Promise<{ id: string } | null> {
    const result = await pool.query<{ id: string }>(
      `SELECT id FROM roles WHERE name = $1 LIMIT 1`,
      [roleName]
    );
    return result.rows[0] ?? null;
  },

  async emailExists(email: string): Promise<boolean> {
    const result = await pool.query<{ count: string }>(
      `SELECT COUNT(*) as count FROM users WHERE email = $1`,
      [email]
    );
    return parseInt(result.rows[0].count, 10) > 0;
  },

  async createUser(data: {
    tenantId: string | null;
    roleId: string;
    email: string;
    phone: string;
    passwordHash: string;
    firstName: string;
    lastName: string;
  }): Promise<UserRow> {
    const result = await pool.query<UserRow>(
      `INSERT INTO users (tenant_id, role_id, email, phone, password_hash, first_name, last_name)
       VALUES ($1, $2, $3, $4, $5, $6, $7)
       RETURNING *`,
      [
        data.tenantId,
        data.roleId,
        data.email,
        data.phone,
        data.passwordHash,
        data.firstName,
        data.lastName,
      ]
    );
    return result.rows[0];
  },

  async createTenant(name: string, slug: string, planId: string): Promise<{ id: string }> {
    // Check slug uniqueness
    const existing = await pool.query(
      `SELECT id FROM tenants WHERE slug = $1`,
      [slug]
    );
    if (existing.rowCount! > 0) {
      throw new ConflictError(`Nursery URL "${slug}" is already taken`);
    }

    const result = await pool.query<{ id: string }>(
      `INSERT INTO tenants (name, slug, subscription_plan_id, status)
       VALUES ($1, $2, $3, 'trial')
       RETURNING id`,
      [name, slug, planId]
    );
    return result.rows[0];
  },

  async createSession(data: {
    userId: string;
    refreshTokenHash: string;
    deviceInfo: object;
    expiresAt: Date;
  }): Promise<{ id: string }> {
    const result = await pool.query<{ id: string }>(
      `INSERT INTO sessions (user_id, refresh_token_hash, device_info, expires_at)
       VALUES ($1, $2, $3, $4)
       RETURNING id`,
      [data.userId, data.refreshTokenHash, JSON.stringify(data.deviceInfo), data.expiresAt]
    );
    return result.rows[0];
  },

  async findValidSession(
    userId: string,
    refreshTokenHash: string
  ): Promise<{ id: string; expires_at: Date } | null> {
    const result = await pool.query<{ id: string; expires_at: Date }>(
      `SELECT id, expires_at FROM sessions
       WHERE user_id = $1 AND refresh_token_hash = $2
         AND revoked = FALSE AND expires_at > NOW()
       LIMIT 1`,
      [userId, refreshTokenHash]
    );
    return result.rows[0] ?? null;
  },

  async revokeSession(sessionId: string): Promise<void> {
    await pool.query(
      `UPDATE sessions SET revoked = TRUE WHERE id = $1`,
      [sessionId]
    );
  },

  async revokeAllUserSessions(userId: string): Promise<void> {
    await pool.query(
      `UPDATE sessions SET revoked = TRUE WHERE user_id = $1`,
      [userId]
    );
  },

  async updatePassword(userId: string, passwordHash: string): Promise<void> {
    await pool.query(
      `UPDATE users SET password_hash = $1, updated_at = NOW() WHERE id = $2`,
      [passwordHash, userId]
    );
  },
};
