import express from 'express';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import { pool } from '../startup/db.js';
import { authenticateToken } from '../middleware/auth.js';

const router = express.Router();

router.post('/sign-in', async (req, res) => {
    try {

        const { email, password } = req.body;
        // console.log(email);
        //Find teacher with that username
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

router.get('/get-classes', authenticateToken, async (req, res) => {
    try {
        const teacherId = req.user;

        const result = await pool.query(
            `SELECT id, name
       FROM classes
       WHERE teacher_id = $1
       ORDER BY name`,
            [teacherId]
        );

        res.status(200).json(result.rows);

    } catch (error) {
        console.error(error);
        res.status(500).json({
            message: 'Server error'
        });
    }
});

router.post('/create-classes', authenticateToken, async (req, res) => {
    const client = await pool.connect();
    try {
        const teacherId = req.user;
        const { name, students } = req.body;

        // console.log('Teacher ID:', teacherId);
        // console.log('Class name:', name);
        // console.log('Students:', students);

        //VALIDATION
        // Validate class name
        if (!name || name.trim() === '') {
            return res.status(400).json({
                message: 'Class name is required'
            });
        }

        // Validate students
        if (!Array.isArray(students) || students.length === 0) {
            return res.status(400).json({
                message: 'At least one student is required'
            });
        }

        // Make sure every student has a name
        for (const student of students) {
            if (
                !student.first_name ||
                !student.last_name
            ) {
                return res.status(400).json({
                    message: 'Every student must have a first and last name'
                });
            }
        }

        //START 
        await client.query('BEGIN');

        //create class first

        const classResult = await client.query(
            `INSERT INTO classes (name, teacher_id)
             VALUES ($1, $2)
             RETURNING id, name`,
            [name.trim(), teacherId]
        );

        const newClass = classResult.rows[0];

        //create students next

        const createdStudents = [];

        for (const student of students) {

            const firstName = student.first_name.trim();
            const lastName = student.last_name.trim();

            // Generate username
            const username = await generateUsername(
                client,
                firstName,
                lastName
            );

            // Generate temporary password
            const password = generatePassword();

            // Hash password before storing it
            const hashedPassword = await bcrypt.hash(
                password,
                10
            );

            const studentResult = await client.query(
                `INSERT INTO students
                    (first_name, last_name, username, password, class_id, teacher_id)
                 VALUES
                    ($1, $2, $3, $4, $5, $6)
                 RETURNING id, first_name, last_name, username`,
                [
                    firstName,
                    lastName,
                    username,
                    hashedPassword,
                    newClass.id,
                    teacherId
                ]
            );

            createdStudents.push({
                id: studentResult.rows[0].id,
                first_name: firstName,
                last_name: lastName,
                username: username,
                password: password
            });

        }

        await client.query('COMMIT');

        res.status(201).json({
            message: 'Class created successfully',

            class: {
                id: newClass.id,
                name: newClass.name
            },

            students: createdStudents
        });

    } catch (error) {

        // Something went wrong -> undo everything
        await client.query('ROLLBACK');

        console.error('Create class error:', error);

        res.status(500).json({
            message: 'Server error'
        });

    } finally {
        client.release();
    }
});

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



router.get(
    '/:classId/students',
    authenticateToken,
    async (req, res) => {

        try {

            const teacherId = req.user;
            const { classId } = req.params;

            // console.log(
            //     `Getting students from class ${classId} `
            //     + `for teacher ${teacherId}`
            // );

            const result = await pool.query(
                `SELECT
                    students.id,
                    students.first_name,
                    students.last_name,
                    students.username,
                    classes.id AS class_id,
                    classes.name AS class_name
                 FROM students
                 JOIN classes
                    ON students.class_id = classes.id
                 WHERE students.class_id = $1
                 AND classes.teacher_id = $2
                 ORDER BY students.last_name, students.first_name`,
                [classId, teacherId]
            );

            // console.log(
            //     'Students found:',
            //     result.rows.length
            // );

            res.status(200).json(result.rows);

        } catch (error) {

            console.error(
                'Error getting class students:',
                error
            );

            res.status(500).json({
                message: 'Server error'
            });
        }
    }
);

router.delete(
    '/:classId',
    authenticateToken,
    async (req, res) => {

        const client = await pool.connect();

        try {

            const teacherId = req.user;
            const { classId } = req.params;

            await client.query('BEGIN');

            // First make sure this class belongs
            // to the teacher
            const classResult = await client.query(
                `SELECT id
                 FROM classes
                 WHERE id = $1
                 AND teacher_id = $2`,
                [classId, teacherId]
            );

            if (classResult.rows.length === 0) {

                await client.query('ROLLBACK');

                return res.status(404).json({
                    message: 'Class not found'
                });
            }


            // Remove the class assignment from students.
            
            await client.query(
                `UPDATE students
                 SET class_id = NULL
                 WHERE class_id = $1`,
                [classId]
            );


            // Now delete the class itself
            await client.query(
                `DELETE FROM classes
                 WHERE id = $1`,
                [classId]
            );


            await client.query('COMMIT');

            res.status(200).json({
                message: 'Class deleted successfully'
            });

        } catch (error) {

            await client.query('ROLLBACK');

            console.error(
                'Error deleting class:',
                error
            );

            res.status(500).json({
                message: 'Server error'
            });

        } finally {

            client.release();
        }
    }
);

function generatePassword() {
    return Math.random()
        .toString(36)
        .slice(-8);
}

async function generateUsername(client, firstName, lastName) {
    const baseUsername =
        `${firstName}.${lastName}`
            .toLowerCase()
            .replace(/[^a-z0-9.]/g, '');

    let username = baseUsername;
    let number = 1;

    do {
        const result = await client.query(
            `SELECT 1
             FROM students
             WHERE username = $1`,
            [username]
        );

        if (result.rows.length === 0) {
            return username;
        }

        number++;
        username = `${baseUsername}${number}`;

    } while (true);
}

//Don't need a sign out post

export default router;