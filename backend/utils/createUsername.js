/**
 * Function for generating a unique username for a student account
 * @param {database client} client 
 * @param {String first name of student} firstName 
 * @param {String last name of student} lastName 
 * @returns firstName.lastName + integer if username is taken
 */
export default async function generateUsername(client, firstName, lastName) {
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

