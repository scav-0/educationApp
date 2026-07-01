import express from 'express';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import { pool } from '../startup/db.js';

const router = express.Router();

router.post('/sign-in', async (req, res) => {
    try {
        //Take username and password from front end
        const { username, password } = req.body;

        //Find student with that username
        const result = await pool.query(
            'SELECT * FROM students where username = $1',
            [username]
        );
        const student = result.rows[0];

        //If no such student return error message
        if (!student) {
            return res.status(401).json({ message: 'Invalid credentials' });
        }

        //Check password -> if not return error
        const isMatch = await bcrypt.compare(password, student.password);
        if (!isMatch) {
            return res.status(401).json({ message: 'Incorrect Username or Password' });
        }

        //create token
        const token = jwt.sign(
            { id: student.id, username: student.username },
            process.env.JWT_SECRET,
            { expiresIn: '1d' }//JIC students share tablets 1 day expiration
        );

        //Send back the token and the username and first and last name
        res.json({ token, id: student.id, username: student.username,first_name: student.first_name, last_name: student.last_name });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }

});



//Don't need a sign out post

export default router;