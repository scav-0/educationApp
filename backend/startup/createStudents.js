//to be deleted

//create initial users with encrypted passwords

import { pool } from './db.js';
import bcrypt from 'bcrypt';

async function createStudent(username, firstName, lastName, password) {
    try {
        // Check if username already exists
        const { rows: existingStudents } = await pool.query(
            'SELECT * FROM students WHERE username = $1', 
            [username]
        );
        if (existingStudents.length > 0) {
            console.log("Username already taken!");
            return;
        }

        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(password, salt);

        await pool.query(
            "INSERT INTO students (username, first_name, last_name, password) VALUES ($1, $2, $3, $4)",
            [username, firstName, lastName, hashedPassword]
        );
        console.log("User inserted successfully");
    } catch (err) {
        console.log("Error inserting user:", err);
    }
}

createStudent("scav0", "Sean", "Cavanagh", "password");


