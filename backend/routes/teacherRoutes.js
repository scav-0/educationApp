import express from 'express';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import { pool } from '../config/db.js';
import { authenticateToken } from '../middleware/auth.js';


const router = express.Router();

/**
 * Route for creating a teacher account
 */
router.post('/register', async (req, res) => {
    try {
        const {
            firstName,
            lastName,
            email,
            password
        } = req.body;

        if (!firstName || !lastName || !email || !password) {
            return res.status(400).json({
                message: 'All fields are required'
            });
        }

        // Check if email already exists
        const existingTeacher = await pool.query(
            'SELECT id FROM teachers WHERE email = $1',
            [email]
        );

        if (existingTeacher.rows.length > 0) {
            return res.status(409).json({
                message: 'An account with this email already exists'
            });
        }

        // Hash password
        const hashedPassword = await bcrypt.hash(password, 10);

        const result = await pool.query(
            `
            INSERT INTO teachers
                (first_name, last_name, email, password)
            VALUES
                ($1, $2, $3, $4)
            RETURNING id
            `,
            [
                firstName,
                lastName,
                email,
                hashedPassword
            ]
        );

        res.status(201).json({
            message: 'Teacher account created successfully',
            teacherId: result.rows[0].id
        });

    } catch (error) {
        console.error(
            'Error creating teacher account:',
            error
        );

        res.status(500).json({
            message: 'Server error'
        });
    }
});

/**
 * Route for teacher sign in
 */
router.post('/sign-in', async (req, res) => {
    try {

        const { email, password } = req.body;
        
        //Find teacher with that email
        const result = await pool.query(
            'SELECT * FROM teachers where email = $1',
            [email]
        );
        const teacher = result.rows[0];

        //If no such teacher return error message
        if (!teacher) {
            return res.status(401).json({ message: 'Invalid credentials' });
        }

        //Check password -> if not return error
        const isMatch = await bcrypt.compare(password, teacher.password);
        if (!isMatch) {
            return res.status(401).json({ message: 'Incorrect Username or Password' });
        }

        //create token
        const token = jwt.sign(
            { id: teacher.id, email: teacher.email },
            process.env.JWT_SECRET,
        );

        //Send back the token and the username and first and last name
        res.json({ token, id: teacher.id, email: teacher.email, first_name: teacher.first_name, last_name: teacher.last_name });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }

});



/**
 * Route for getting students assigned to current teacher
 */
router.get('/students', authenticateToken, async (req, res) => {

    try {

        const teacherId = req.user;

        const result = await pool.query(
            `SELECT
                students.id,
                students.first_name,
                students.last_name,
                students.username,
                students.class_id,
                classes.name AS class_name
             FROM students
             LEFT JOIN classes
                ON students.class_id = classes.id
             WHERE students.teacher_id = $1
             ORDER BY students.last_name, students.first_name`,
            [teacherId]
        );

        res.status(200).json(result.rows);

    } catch (error) {

        console.error('Error getting students:', error);

        res.status(500).json({
            message: 'Server error'
        });
    }
});




export default router;