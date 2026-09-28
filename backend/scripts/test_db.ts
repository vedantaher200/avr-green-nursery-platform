import { pool } from '../src/config/database';

async function check() {
  try {
    const res = await pool.query('SELECT current_database(), current_user, NOW()');
    console.log('✅ DB Connected successfully:', res.rows[0]);
    process.exit(0);
  } catch (err: any) {
    console.error('❌ DB connection failed:', err.message);
    process.exit(1);
  }
}

check();
