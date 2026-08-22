import express from 'express';
import { pool } from '../config/db.js';
import { authenticateToken } from '../middleware/auth.js';
import bcrypt from 'bcrypt';

import generateUsername from '../utils/createUsername.js';
import generatePassword from '../utils/generatePassword.js';


const router = express.Router();
/**
 * Route for getting classes assigned to current teacher
 */
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

/**
 * Route for creating a new class (and student accounts for the class)
 */
router.post('/create-classes', authenticateToken, async (req, res) => {
    const client = await pool.connect();
    try {
        const teacherId = req.user;
        const { name, students } = req.body;

        // Validate class name
        if (!name || name.trim() === '') {
            return res.status(400).json({
                message: 'Class name is required'
            });
        }

        //  check if students is an array also
        if (!Array.isArray(students)) {
            return res.status(400).json({
                message: 'Error with student entry'
            });
        }

        //Special case - if there are 0 students
        if (students.length === 0) {
            //START
            await client.query('BEGIN');

            const classResult = await client.query(
                `INSERT INTO classes (name, teacher_id)
             VALUES ($1, $2)
             RETURNING id, name`,
                [name.trim(), teacherId]
            );
            await client.query('COMMIT');

            const newClass = classResult.rows[0];
            res.status(201).json({
                message: 'Class created successfully',

                class: {
                    id: newClass.id,
                    name: newClass.name
                },

                students: []
            });

        } else {
            //Otherwise continue with adding students

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
        }
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

/**
 * Route for getting students in a certain class (with id classID)
 */
router.get('/:classId/students', authenticateToken, async (req, res) => {

    try {

        const teacherId = req.user;
        const { classId } = req.params;

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

/**
 * Route for deleting a class and removing the students from the class
 */
router.delete('/:classId', authenticateToken, async (req, res) => {

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

export default router;