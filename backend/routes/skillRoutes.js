import express from 'express';
import jwt from 'jsonwebtoken';
import { pool } from '../startup/db.js';
import { authenticateToken } from '../middleware/auth.js';
import PKnownNext from '../utils/bayesian.js';

const router = express.Router();

const games = ['bracelet', 'symbol', 'honeycomb'];//UPDATE AS MORE GAMES ARE ADDED
const defaultPknow = 0.3;//sets default value for pKnow for later

/**
 * Route for skills/fetch, to fetch skills for game difficulty
 */
router.get('/fetch', authenticateToken, async (req, res) => {
    try {
        
        const { studentId } = req.user;

              
        let result = await pool.query(
            'SELECT game, p_know FROM student_skills WHERE student_id =$1', [studentId]
        );

        //If not all games have a p_know value, insert default values into gaps
        if (result.rows.length < games.length) {
            for (const game of games) {
                const insert = await pool.query(
                    'INSERT INTO student_skills(student_id, game, p_know) VALUES ($1, $2, $3) ON CONFLICT (student_id, game) DO NOTHING',
                    [studentId, game, defaultPknow]
                );
            };
            

            result = await pool.query(
                'SELECT game, p_know FROM student_skills WHERE student_id =$1', [studentId]
            );
        }

        // Convert rows into a flat object for api
        const skills = {};
        result.rows.forEach(row => {
            skills[row.game] = parseFloat(row.p_know);
        });

        res.status(200).json(skills);

    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
});

/**
 * Route for updating skills 
 */
router.post('/update', authenticateToken, async (req, res) => {
    try {
        const student_id = req.user;
        const {  game, correct } = req.body;

        
        const skillResult = await pool.query(
            `SELECT p_know
             FROM student_skills
             WHERE student_id = $1
             AND game = $2`,
            [student_id, game]
        );

        if (skillResult.rows.length === 0) {
            return res.status(404).json({
                message: 'Skill not found'
            });
        }

        let pKnow = parseFloat(skillResult.rows[0].p_know);
        
        //update pKnow differently depending on game
        switch(game){
            case 'bracelet':
                pKnow = PKnownNext(pKnow, 0.01, 0.25, 0.1, correct);
                break;
            case 'symbol':
                pKnow = PKnownNext(pKnow, 0.01, 0.25, 0.1, correct);
                break;
            case 'honeycomb':
                pKnow = PKnownNext(pKnow, 0.01,0.15,0.2, correct);
            
        }

        await pool.query(
            `UPDATE student_skills
             SET p_know = $1
             WHERE student_id = $2
             AND game = $3`,
            [pKnow, student_id, game]
        );

        res.status(200).json({
            p_know: pKnow
        });

    } catch (error) {
        console.error(error);
        res.status(500).json({
            message: 'Server error'
        });
    }
});

/**
 * Route for saving game stats
 */
router.post('/stats', authenticateToken, async (req, res) => {
  try {
    const { game, correct, attempts, time_taken, p_know } = req.body;
    await pool.query(
      `INSERT INTO game_stats (student_id, game, correct, attempts, time_taken, p_know)
       VALUES ($1, $2, $3, $4, $5, $6)`,
      [req.user, game, correct, attempts, time_taken, p_know]
    );
    res.status(200).json({ message: 'Stats saved' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

/**
 * Route for getting stast summary for stats page
 */
router.get(
    '/:studentId/summary',
    authenticateToken,
    async (req, res) => {
        try {
            const studentId = req.params.studentId;
            const game = req.query.game;
            //needs to work for game or no game
            const result = await pool.query(
                `
                SELECT
                    (
                        SELECT COUNT(*)
                        FROM game_stats
                        WHERE student_id = $1
                        ${game ? 'AND game = $2' : ''}
                    ) AS games_played,

                    (
                        SELECT COALESCE(AVG(attempts), 0)
                        FROM game_stats
                        WHERE student_id = $1
                        ${game ? 'AND game = $2' : ''}
                    ) AS average_attempts,

                    (
                        SELECT COALESCE(AVG(time_taken), 0)
                        FROM game_stats
                        WHERE student_id = $1
                        ${game ? 'AND game = $2' : ''}
                    ) AS average_time,

                    (
                        SELECT COALESCE(AVG(p_know), 0)
                        FROM student_skills
                        WHERE student_id = $1
                        ${game ? 'AND game = $2' : ''}
                    ) AS p_know
                `,
                game ? [studentId, game] : [studentId]
            );

            res.status(200).json(result.rows[0]);

        } catch (error) {

            console.error(
                'Error getting student summary:',
                error
            );

            res.status(500).json({
                message: 'Server error'
            });
        }
    }
);

export default router;