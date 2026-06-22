import express from 'express';
// import dotenv from 'dotenv';
import db from './startup/db.js';
import studentRoutes from './routes/studentRoutes.js';
import cors from 'cors';


// dotenv.config();
const app = express();
app.use(cors({
  origin: '*', // allow all origins for development
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));
app.use(express.json()); 

app.use('/api/users', studentRoutes);

const port = process.env.PORT || 3000;



const start = async () => {
    await db();
    app.listen(port, () => console.log('listening on port ' + port));
    
}

start();