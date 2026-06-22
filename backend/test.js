import dotenv from 'dotenv';
dotenv.config();

console.log("RAW DATABASE_URL:");
console.log(process.env.DATABASE_URL);

console.log("TYPE:");
console.log(typeof process.env.DATABASE_URL);

console.log("LENGTH:");
console.log(process.env.DATABASE_URL?.length);