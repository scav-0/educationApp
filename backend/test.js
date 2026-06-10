import pg from 'pg';

const { Pool } = pg;

const pool = new Pool({
  host: 'localhost',
  port: 5432,
  database: 'education_app',
  user: 'postgres',
  password: '123Tibby',
});

pool.connect()
  .then(client => {
    console.log('connected!');
    client.release();
  })
  .catch(err => console.log('error:', err.message));