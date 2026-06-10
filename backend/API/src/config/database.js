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
});

// Tambahkan log untuk mengecek koneksi saat startup
pool.getConnection()
  .then(connection => {
    console.log(`✅ Database connected successfully to: ${process.env.DB_NAME} on ${process.env.DB_HOST}`);
    connection.release();
  })
  .catch(err => {
    console.error('❌ Database connection failed!');
    console.error('Details:', err);
  });

module.exports = pool;