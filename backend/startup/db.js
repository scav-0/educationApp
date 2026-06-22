import pg from 'pg';
import dotenv from 'dotenv';

dotenv.config();

const { Pool } = pg;
const pool = new Pool({
    connectionString: process.env.DATABASE_URL_OFFLINE,
    
});
//ONLINE DATABASE DOESNT WORK ON QUB WIFI
//process.env.DATABASE_URL
//process.env.DATABASE_URL_OFFLINE
export default async function connectToDb() {
    try {
        console.log('attempting to connect...');
        const client = await pool.connect();
        console.log('connected to db');
        client.release();
        return pool;
    } catch (error) {
        console.log('connection error:', error);
        throw error;
    }
}

pool.on('error', (err) => {
  console.log('pool error:', err.message);
});

export { pool };