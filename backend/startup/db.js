import pg from 'pg';
import dotenv from 'dotenv';

dotenv.config();

const { Pool } = pg;
const pool = new Pool({
    connectionString: process.env.DATABASE_URL
});

export default async function connectToDb() {
    try {
        const client = await pool.connect();
        console.log('connected to db');
        client.release();
        return pool;
    } catch (error) {
        console.log(error);
        throw error;
    }
}

pool.on('error', (err) => {
  console.log('pool error:', err.message);
});

export { pool };