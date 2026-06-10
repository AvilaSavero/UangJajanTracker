const mysql = require('mysql2/promise');
require('dotenv').config();

const pool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 3306,
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'money_tracker',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0, 
  timezone: '+07:00',
  connectTimeout: 10000, // 10 seconds timeout for Railway stability
});

// Tambahkan log untuk mengecek koneksi saat startup
pool.getConnection()
  .then(connection => {
    console.log(`✅ Database connected successfully: ${process.env.DB_NAME} at ${process.env.DB_HOST}:${process.env.DB_PORT}`);
    connection.release(); // Release the connection after the test
  })
  .catch(err => {
    console.error('❌ Database connection failed! Check your Railway Environment Variables.');
    console.error('Error Code:', err.code);
    console.error('Fatal:', err.fatal);
  });

module.exports = pool;