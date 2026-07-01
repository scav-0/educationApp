import express from 'express';
import jwt from 'jsonwebtoken';
import { pool } from '../startup/db.js';
import { authenticateToken } from '../middleware/auth.js';
import PKnownNext from '../utils/bayesian.js';

const router = express.Router();

const games = ['bracelet', 'symbol'];//UPDATE AS MORE GAMES ARE ADDED
const defaultPknow = 0.3;


router.get('/:studentId', authenticateToken, async (req, res) => {
    try {
        const { studentId } = req.params;

        
        //so that students can only fetch their own skills
        if (Number(studentId) !== Number(req.user)) {
            return res.status(403).json({ message: 'Not authorized' })
        }



        const result = await pool.query(
            'SELECT game, p_know FROM student_skills WHERE student_id =$1', [studentId]
        );

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

        // Convert rows into a flat object { bracelet: 0.3, symbol: 0.3 }
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

router.post('/update', authenticateToken, async (req, res) => {
    try {

        const student_id = req.user;
        const {  game, correct } = req.body;
        
        console.log("studentID : " + student_id);
        console.log("game : " + game);
        console.log("correct : " + correct);
        

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
        console.log("Pknow before.. : "+pKnow);
        switch(game){
            case 'bracelet':
                pKnow = PKnownNext(pKnow, 0.01, 0.25, 0.1, correct);
                break;
            case 'symbol':
                pKnow = PKnownNext(pKnow, 0.01, 0.25, 0.1, correct);
                break;
            //add more when more games are added (IS IT POSSIBLE TO CREATE OBJECTS INSTEAD OF HAVING TO UPDATE IN DIFFERENT PLACES)
        }

        console.log("Pknow after.. : "+pKnow);
        console.log("\n")


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




}
);

export default router;