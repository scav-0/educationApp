/**
 * Function for generating a random string of length 8
 * @returns Random string of length 8
 */
export default function generatePassword() {
    return Math.random().toString(36).slice(-8);
}