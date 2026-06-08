const express = require('express');
const app = express();
const db = require('./startup/db');

require('dotenv').config();

const port = process.env.PORT || 3000;

const start = async () => {
    await db();
    app.listen(port, () => console.log('listening on port ' + port));
}

start();