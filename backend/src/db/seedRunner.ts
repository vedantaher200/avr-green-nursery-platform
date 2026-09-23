import fs from 'fs';
import path from 'path';
import { pool } from '../config/database';

async function main() {
  const sql = fs.readFileSync(path.join(__dirname, 'schema.sql'), 'utf8') + '\n' + fs.readFileSync(path.join(__dirname, 'seeds.sql'), 'utf8');
  await pool.query(sql);
  await pool.end();
  console.log('AVRGREEN schema and demo data loaded.');
}
main().catch(async (error) => { console.error(error); await pool.end(); process.exit(1); });
