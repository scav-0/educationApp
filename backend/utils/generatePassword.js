/**
 * Function for generating a random string of length 8
 * @returns Method to
 */
export default function generatePassword() {
    return Math.random().toString(36).slice(-8);
}