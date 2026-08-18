import express from 'express';
import db from './startup/db.js';
import studentRoutes from './routes/studentRoutes.js';
import skillRoutes from './routes/skillRoutes.js';
import teacherRoutes from './routes/teacherRoutes.js';
import cors from 'cors';


const app = express();
app.use(cors({
  origin: '*', // allow all origins for development
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));
app.use(express.json()); 


//routes go here!
app.use('/api/students', studentRoutes);
app.use('/api/skills', skillRoutes);
app.use('/api/teachers',teacherRoutes);

const port = process.env.PORT || 3000;



const start = async () => {
    await db();
    app.listen(port, () => console.log('listening on port ' + port));
    
}

start();