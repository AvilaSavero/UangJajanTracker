require('dotenv').config();
const express = require('express');
const cors = require('cors');
const routes = require('./routes');
const migrate = require('./config/migrate');

try {
  require('express-async-errors');
} catch (e) {
  console.warn('⚠️ express-async-errors is missing. Please run: npm install express-async-errors');
}

const app = express();

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Health check
app.get('/', (_, res) => res.json({ success: true, message: 'Money Tracker API v1.0' }));

// API routes
app.use('/api/v1', routes);

// 404 handler
app.use((req, res) => res.status(404).json({ success: false, message: `Route ${req.path} tidak ditemukan` }));

// Error handler
app.use((err, req, res, next) => {
  console.error('🔥 Global Error Handler:', err.stack);
  const statusCode = err.statusCode || 500;
  res.status(statusCode).json({ 
    success: false, 
    message: err.message || 'Internal server error' 
  });
});

const PORT = process.env.PORT || 3000;

// Run migrations before starting the server
migrate()
  .then(() => {
    const server = app.listen(PORT, '0.0.0.0', () => {
      console.log(`🚀 Server ready on port ${PORT}`);
      console.log(`📡 Base URL: /api/v1`);
    });

    // Handle graceful shutdown
    process.on('SIGTERM', () => server.close());
  })
  .catch((err) => {
    console.error('Failed to run migrations, server will not start:', err);
    process.exit(1);
  });

// Tangkap error yang tidak terduga agar server tidak crash (502)
process.on('unhandledRejection', (reason) => {
  console.error('🛑 Unhandled Rejection:', reason);
});

process.on('uncaughtException', (err) => {
  console.error('🛑 Uncaught Exception:', err);
  process.exit(1); // Exit with failure to allow Railway to restart the services
});
