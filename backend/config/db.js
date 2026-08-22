import pg from 'pg';
import dotenv from 'dotenv';

dotenv.config();

const { Pool } = pg;
const pool = new Pool({
    connectionString: process.env.DATABASE_URL_OFFLINE,
    
});
/**
 * Function for connecting to the database, prints connected to db once connections, and connection error otherwise
 * @returns pool for future queries
 */
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

/**
 * Method for printing pool errors to console
 */
pool.on('error', (err) => {
  console.log('pool error:', err.message);
});

export { pool };