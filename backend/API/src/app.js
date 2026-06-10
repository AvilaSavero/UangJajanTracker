require('dotenv').config();
const express = require('express');
const cors = require('cors');
const routes = require('./routes');

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
  console.error(err);
  res.status(500).json({ success: false, message: 'Internal server error' });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, '0.0.0.0', () => console.log(`✅ Server is listening on port ${PORT}`));
