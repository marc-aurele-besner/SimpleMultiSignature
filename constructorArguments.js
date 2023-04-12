require('dotenv').config({ path: __dirname + '/.env' });

const { OWNER1, OWNER2, OWNER3, OWNER4, OWNER5 } = process.env;

module.exports = [[OWNER1, OWNER2, OWNER3, OWNER4, OWNER5], 1];
