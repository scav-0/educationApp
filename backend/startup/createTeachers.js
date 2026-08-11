//to be deleted

//create initial users with encrypted passwords

import { pool } from './db.js';
import bcrypt from 'bcrypt';

async function createStudent(email, firstName, lastName, password) {
    try {
        // Check if username already exists
        const { rows: existingTeachers } = await pool.query(
            'SELECT * FROM teachers WHERE email = $1', 
            [email]
        );
        if (existingTeachers.length > 0) {
            console.log("Email already taken!");
            return;
        }

        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(password, salt);

        await pool.query(
            "INSERT INTO teachers (email, first_name, last_name, password) VALUES ($1, $2, $3, $4)",
            [email, firstName, lastName, hashedPassword]
        );
        console.log("User inserted successfully");
    } catch (err) {
        console.log("Error inserting user:", err);
    }
}

createStudent("teacher@gmail.com", "John", "Johnson", "password");