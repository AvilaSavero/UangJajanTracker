const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { validationResult } = require('express-validator');
const pool = require('../config/database');

const makeToken = (id) =>
  jwt.sign({ id }, process.env.JWT_SECRET, { expiresIn: process.env.JWT_EXPIRES_IN || '7d' });

// POST /auth/register
exports.register = async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty())
    return res.status(422).json({
      success: false,
      message: errors.array()[0].msg,
      errors: errors.array(),
    });

  const { name, email, password } = req.body;
  try {
    const [exists] = await pool.query('SELECT id FROM users WHERE email = ?', [email]);
    if (exists.length)
      return res.status(409).json({ success: false, message: 'Email sudah terdaftar' });

    const hash = await bcrypt.hash(password, 12);
    const [result] = await pool.query(
      'INSERT INTO users (name, email, password) VALUES (?, ?, ?)',
      [name, email, hash]
    );

    // Buat spending_limit default
    const [user] = await pool.query('SELECT * FROM users WHERE email = ?', [email]);
    try {
      await pool.query('INSERT INTO spending_limits (user_id) VALUES (?)', [user[0].id]);
    } catch (limitErr) {
      console.log('Warning: Could not create spending limit:', limitErr.message);
      // Continue anyway, spending_limit is optional
    }

    const token = makeToken(user[0].id);
    res.status(201).json({
      success: true,
      message: 'Registrasi berhasil',
      data: { token, user: sanitize(user[0]) },
    });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

// POST /auth/login
exports.login = async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty())
    return res.status(422).json({
      success: false,
      message: errors.array()[0].msg,
      errors: errors.array(),
    });

  const { email, password } = req.body;
  try {
    const [rows] = await pool.query('SELECT * FROM users WHERE email = ?', [email]);
    if (!rows.length)
      return res.status(401).json({ success: false, message: 'Email atau password salah' });

    const ok = await bcrypt.compare(password, rows[0].password);
    if (!ok)
      return res.status(401).json({ success: false, message: 'Email atau password salah' });

    const token = makeToken(rows[0].id);
    res.json({ success: true, message: 'Login berhasil', data: { token, user: sanitize(rows[0]) } });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

// GET /auth/me
exports.me = async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT * FROM users WHERE id = ?', [req.user.id]);
    if (!rows.length) return res.status(404).json({ success: false, message: 'User tidak ditemukan' });
    res.json({ success: true, data: sanitize(rows[0]) });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

// PUT /auth/profile
exports.updateProfile = async (req, res) => {
  const { name, avatar_url, currency, language } = req.body;
  try {
    await pool.query(
      'UPDATE users SET name=?, avatar_url=?, currency=?, language=? WHERE id=?',
      [name, avatar_url, currency, language, req.user.id]
    );
    const [rows] = await pool.query('SELECT * FROM users WHERE id = ?', [req.user.id]);
    res.json({ success: true, message: 'Profil diperbarui', data: sanitize(rows[0]) });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

// PUT /auth/password
exports.changePassword = async (req, res) => {
  const { old_password, new_password } = req.body;
  try {
    const [rows] = await pool.query('SELECT * FROM users WHERE id = ?', [req.user.id]);
    const ok = await bcrypt.compare(old_password, rows[0].password);
    if (!ok)
      return res.status(400).json({ success: false, message: 'Password lama salah' });

    const hash = await bcrypt.hash(new_password, 12);
    await pool.query('UPDATE users SET password=? WHERE id=?', [hash, req.user.id]);
    res.json({ success: true, message: 'Password berhasil diubah' });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

const sanitize = (u) => {
  const { password, ...safe } = u;
  return safe;
};
