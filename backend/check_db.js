const { Pool } = require('pg');
const pool = new Pool({ user: 'avrgreen_user', password: 'password', host: 'localhost', port: 5432, database: 'avrgreen_db' });
pool.query("SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'locations'").then(r => {
  console.table(r.rows);
  process.exit();
});
