

import { pool } from '../config/db.js';

const studentIds = [4,5,6,11,16,10,3,15];;

const games = [
    'bracelet',
    'symbol',
    'honeycomb'
];

async function populateGameStats() {

    try {

        for (const studentId of studentIds) {

            // 2-5 games per day
            for (let day = 0; day < 7; day++) {

                const gamesToday =
                    Math.floor(Math.random() * 4) + 2;

                for (let i = 0; i < gamesToday; i++) {

                    const game =
                        games[
                            Math.floor(
                                Math.random() * games.length
                            )
                        ];

                    const correct =
                        Math.random() < 0.7;

                    const attempts =
                        Math.floor(Math.random() * 3) + 1;

                    const timeTaken =
                        Math.floor(
                            Math.random() * 120
                        ) + 20;

                    const pKnow =
                        (Math.random() * 0.5 + 0.5)
                            .toFixed(2);

                    // Random time within this particular day
                    const playedAt = new Date();

                    playedAt.setDate(
                        playedAt.getDate() - day
                    );

                    playedAt.setHours(
                        Math.floor(Math.random() * 24)
                    );

                    playedAt.setMinutes(
                        Math.floor(Math.random() * 60)
                    );

                    playedAt.setSeconds(
                        Math.floor(Math.random() * 60)
                    );

                    await pool.query(
                        `
                        INSERT INTO game_stats (
                            student_id,
                            game,
                            correct,
                            attempts,
                            time_taken,
                            p_know,
                            played_at
                        )
                        VALUES ($1, $2, $3, $4, $5, $6, $7)
                        `,
                        [
                            studentId,
                            game,
                            correct,
                            attempts,
                            timeTaken,
                            pKnow,
                            playedAt
                        ]
                    );
                }
            }
        }

        console.log('Fake game stats created!');

    } catch (error) {

        console.error(
            'Error creating fake stats:',
            error
        );

    } finally {

        await pool.end();

    }
}

// populateGameStats();

async function resetStudentSkills(studentIds) {
    const games = ['bracelet', 'symbol', 'honeycomb'];
    
    for (const studentId of studentIds) {
        await pool.query(
            `DELETE FROM student_skills WHERE student_id = $1`,
            [studentId]
        );

        for (const game of games) {
             const pKnow = Math.random() * 0.5 + 0.5;
            await pool.query(
                `
                INSERT INTO student_skills
                    (student_id, game, p_know)
                VALUES ($1, $2, $3)
                `,
                [studentId, game, pKnow]
            );
        }
    }

    console.log('Student skills reset!');
}

await resetStudentSkills(studentIds);