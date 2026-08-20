import express from 'express';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import { pool } from '../startup/db.js';
import { authenticateToken } from '../middleware/auth.js';
import generateUsername from '../utils/createUsername.js';

const router = express.Router();

/**
 * route for creating a student account -> used by teacher
 */
router.post('/create', authenticateToken, async (req, res) => {
    try {   
        const teacher_id = req.user;
        const {
            first_name,
            last_name,
            password,
            class_id
        } = req.body;

        //generate username 
        const client = await pool.connect();
        const username = await generateUsername(
                client,
                first_name,
                last_name
            );

        // validation...

        const hashedPassword =
            await bcrypt.hash(password, 10);
        
        const result = await pool.query(
            `
            INSERT INTO students
                (first_name, last_name, username, password, class_id, teacher_id)
            VALUES
                ($1, $2, $3, $4, $5, $6)
            RETURNING id
            `,
            [
                first_name,
                last_name,
                username,
                hashedPassword,
                class_id ?? null,
                teacher_id
            ]
        );

        res.status(201).json({
            message: 'Student created successfully',
            studentId: result.rows[0].id
        });

    } catch (error) {
        console.error('Error creating student:', error);

        res.status(500).json({
            message: 'Server error'
        });
    }
});

/**
 * Route for student sign in
 */
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

        //Check password -> if not correct return error
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

/**
 * Route for teacher to change student password
 */
router.post('/:studentId/password', authenticateToken, async (req, res) => {
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

/**Route for getting statistics needed for number of games played per day bar chart
 * 
 * */
router.get('/:studentId/stats/games-per-day', authenticateToken, async (req, res) => {
        try {

            const { studentId } = req.params;
            const result = await pool.query(
                `
               SELECT
                dates.date,
                COUNT(game_stats.id) AS games_played
                FROM generate_series(
                CURRENT_DATE - INTERVAL '6 days',
                CURRENT_DATE,
                INTERVAL '1 day'
                ) AS dates(date)

                LEFT JOIN game_stats
                ON DATE(game_stats.played_at) = dates.date
                AND game_stats.student_id = $1

                GROUP BY dates.date
                ORDER BY dates.date ASC
                `,
                [studentId]
            );

            res.status(200).json(result.rows);

        } catch (error) {

            console.error(
                'Error getting games per day:',
                error
            );

            res.status(500).json({
                message: 'Server error'
            });
        }
    }
);

/**
 * Route for changing students class
 */
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

/**
 * Route for getting the stats for the p_know graph
 */
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

/**
 * Route for getting the data needed to make the leaderboard
 */
router.get('/leaderboard', authenticateToken, async (req, res) => {
    try {

        const studentId = req.user;

        const result = await pool.query(
            `
            SELECT
                students.id,
                students.first_name,
                students.last_name,
                COUNT(game_stats.id) AS games_played

            FROM students

            LEFT JOIN game_stats
                ON students.id = game_stats.student_id

            WHERE students.class_id = (
                SELECT class_id
                FROM students
                WHERE id = $1
            )

            GROUP BY
                students.id,
                students.first_name,
                students.last_name

            ORDER BY games_played DESC,
                     students.last_name ASC
            `,
            [studentId]
        );

        res.status(200).json(result.rows);

    } catch (error) {

        console.error('Error getting leaderboard:', error);

        res.status(500).json({
            message: 'Server error'
        });
    }
});


export default router;