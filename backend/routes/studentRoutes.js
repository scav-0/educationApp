import express from 'express';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import { pool } from '../startup/db.js';
import { authenticateToken } from '../middleware/auth.js';

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
        res.json({ token, id: student.id, username: student.username, first_name: student.first_name, last_name: student.last_name });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }

});

router.post(
    '/:studentId/password',
    authenticateToken,
    async (req, res) => {

        try {

            const teacherId = req.user;
            const { studentId } = req.params;
            const { password } = req.body;

            if (!password || password.trim() === '') {
                return res.status(400).json({
                    message: 'Password cannot be empty'
                });
            }

            // Make sure this student belongs
            // to the logged-in teacher
            const studentResult = await pool.query(
                `SELECT id
                 FROM students
                 WHERE id = $1
                 AND teacher_id = $2`,
                [studentId, teacherId]
            );

            if (studentResult.rows.length === 0) {
                return res.status(404).json({
                    message: 'Student not found'
                });
            }

            // Hash the new password
            const hashedPassword =
                await bcrypt.hash(password, 10);

            // Update password
            await pool.query(
                `UPDATE students
                 SET password = $1
                 WHERE id = $2`,
                [hashedPassword, studentId]
            );

            res.status(200).json({
                message: 'Password changed successfully'
            });

        } catch (error) {

            console.error(
                'Error changing password:',
                error
            );

            res.status(500).json({
                message: 'Server error'
            });
        }
    }
);

router.post(
    '/:studentId/class',
    authenticateToken,
    async (req, res) => {

        try {

            const teacherId = req.user;
            const { studentId } = req.params;
            const { classId } = req.body;

            // Make sure the class belongs
            // to this teacher
            const classResult = await pool.query(
                `SELECT id
                 FROM classes
                 WHERE id = $1
                 AND teacher_id = $2`,
                [classId, teacherId]
            );

            if (classResult.rows.length === 0) {
                return res.status(404).json({
                    message: 'Class not found'
                });
            }

            // Make sure the student belongs
            // to this teacher
            const studentResult = await pool.query(
                `SELECT id
                 FROM students
                 WHERE id = $1
                 AND teacher_id = $2`,
                [studentId, teacherId]
            );

            if (studentResult.rows.length === 0) {
                return res.status(404).json({
                    message: 'Student not found'
                });
            }

            // Change class
            await pool.query(
                `UPDATE students
                 SET class_id = $1
                 WHERE id = $2`,
                [classId, studentId]
            );

            res.status(200).json({
                message: 'Class changed successfully'
            });

        } catch (error) {

            console.error(
                'Error changing student class:',
                error
            );

            res.status(500).json({
                message: 'Server error'
            });
        }
    }
);

router.post(
    '/:studentId/delete',
    authenticateToken,
    async (req, res) => {

        try {
            // POST GRE HAS CASCADE TO DELETE ASSOCIATED FILES SUCH AS GAME STATS
            const teacherId = req.user;
            const { studentId } = req.params;

            // Make absolutely sure this student
            // belongs to the logged-in teacher
            const studentResult = await pool.query(
                `SELECT id
                 FROM students
                 WHERE id = $1
                 AND teacher_id = $2`,
                [studentId, teacherId]
            );

            if (studentResult.rows.length === 0) {
                return res.status(404).json({
                    message: 'Student not found'
                });
            }

            // Delete student
            await pool.query(
                `DELETE FROM students
                 WHERE id = $1
                 AND teacher_id = $2`,
                [studentId, teacherId]
            );

            res.status(200).json({
                message: 'Student deleted successfully'
            });

        } catch (error) {

            console.error(
                'Error deleting student:',
                error
            );

            res.status(500).json({
                message: 'Server error'
            });
        }
    }
);

router.get(
    '/:studentId/stats/:game',
    authenticateToken,
    async (req, res) => {

        try {

            const teacherId = req.user;
            const { studentId, game } = req.params;

            // First check that this student belongs
            // to the logged-in teacher
            const studentResult = await pool.query(
                `SELECT id
                 FROM students
                 WHERE id = $1
                 AND teacher_id = $2`,
                [studentId, teacherId]
            );

            if (studentResult.rows.length === 0) {
                return res.status(404).json({
                    message: 'Student not found'
                });
            }

            const result = await pool.query(
                `SELECT
                    p_know,
                    played_at
                 FROM game_stats
                 WHERE student_id = $1
                 AND game = $2
                 ORDER BY played_at ASC`,
                [studentId, game]
            );

            res.status(200).json(result.rows);

        } catch (error) {

            console.error(
                'Error getting student stats:',
                error
            );

            res.status(500).json({
                message: 'Server error'
            });
        }
    }
);





//Don't need a sign out post

export default router;