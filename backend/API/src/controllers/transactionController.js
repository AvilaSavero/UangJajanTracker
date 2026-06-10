const pool = require('../config/database');
const { validationResult } = require('express-validator');

// GET /transactions
exports.getAll = async (req, res) => {
  const { type, category_id, start_date, end_date, limit = 20, page = 1 } = req.query;
  const offset = (page - 1) * limit;
  const userId = req.user.id;

  let where = 'WHERE t.user_id = ?';
  const params = [userId];

  if (type) { where += ' AND t.type = ?'; params.push(type); }
  if (category_id) { where += ' AND t.category_id = ?'; params.push(category_id); }
  if (start_date) { where += ' AND t.date >= ?'; params.push(start_date); }
  if (end_date) { where += ' AND t.date <= ?'; params.push(end_date); }

  try {
    const [[{ total }]] = await pool.query(
      `SELECT COUNT(*) AS total FROM transactions t ${where}`, params
    );
    const [rows] = await pool.query(
      `SELECT t.*, c.name AS category_name, c.icon AS category_icon, c.color AS category_color
       FROM transactions t
       LEFT JOIN categories c ON t.category_id = c.id
       ${where}
       ORDER BY t.date DESC, t.created_at DESC
       LIMIT ? OFFSET ?`,
      [...params, Number(limit), Number(offset)]
    );

    res.json({
      success: true,
      data: rows,
      pagination: { total, page: Number(page), limit: Number(limit), pages: Math.ceil(total / limit) },
    });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

// GET /transactions/:id
exports.getOne = async (req, res) => {
  try {
    const [rows] = await pool.query(
      `SELECT t.*, c.name AS category_name, c.icon AS category_icon, c.color AS category_color
       FROM transactions t LEFT JOIN categories c ON t.category_id = c.id
       WHERE t.id = ? AND t.user_id = ?`,
      [req.params.id, req.user.id]
    );
    if (!rows.length) return res.status(404).json({ success: false, message: 'Transaksi tidak ditemukan' });
    res.json({ success: true, data: rows[0] });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

// POST /transactions
exports.create = async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) return res.status(422).json({ success: false, errors: errors.array() });

  const { type, amount, title, category_id, note, date } = req.body;
  try {
    await pool.query(
      'INSERT INTO transactions (user_id, category_id, type, amount, title, note, date) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [req.user.id, category_id || null, type, amount, title, note || null, date]
    );
    const [rows] = await pool.query(
      `SELECT t.*, c.name AS category_name, c.icon AS category_icon, c.color AS category_color
       FROM transactions t LEFT JOIN categories c ON t.category_id = c.id
       WHERE t.user_id = ? ORDER BY t.created_at DESC LIMIT 1`,
      [req.user.id]
    );
    res.status(201).json({ success: true, message: 'Transaksi ditambahkan', data: rows[0] });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

// PUT /transactions/:id
exports.update = async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) return res.status(422).json({ success: false, errors: errors.array() });

  const { type, amount, title, category_id, note, date } = req.body;
  try {
    const [check] = await pool.query(
      'SELECT id FROM transactions WHERE id = ? AND user_id = ?', [req.params.id, req.user.id]
    );
    if (!check.length) return res.status(404).json({ success: false, message: 'Transaksi tidak ditemukan' });

    await pool.query(
      'UPDATE transactions SET type=?, amount=?, title=?, category_id=?, note=?, date=? WHERE id=?',
      [type, amount, title, category_id || null, note || null, date, req.params.id]
    );
    const [rows] = await pool.query(
      `SELECT t.*, c.name AS category_name, c.icon AS category_icon, c.color AS category_color
       FROM transactions t LEFT JOIN categories c ON t.category_id = c.id WHERE t.id = ?`,
      [req.params.id]
    );
    res.json({ success: true, message: 'Transaksi diperbarui', data: rows[0] });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

// DELETE /transactions/:id
exports.remove = async (req, res) => {
  try {
    const [check] = await pool.query(
      'SELECT id FROM transactions WHERE id = ? AND user_id = ?', [req.params.id, req.user.id]
    );
    if (!check.length) return res.status(404).json({ success: false, message: 'Transaksi tidak ditemukan' });
    await pool.query('DELETE FROM transactions WHERE id = ?', [req.params.id]);
    res.json({ success: true, message: 'Transaksi dihapus' });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

// GET /transactions/summary  - ringkasan untuk dashboard Flutter
exports.summary = async (req, res) => {
  const { month, year } = req.query;
  const now = new Date();
  const m = month || (now.getMonth() + 1);
  const y = year || now.getFullYear();

  const start = `${y}-${String(m).padStart(2, '0')}-01`;
  const end   = new Date(y, m, 0).toISOString().split('T')[0];

  try {
    const userId = req.user.id;

    // Total income & expense bulan ini
    const [[totals]] = await pool.query(
      `SELECT
         COALESCE(SUM(CASE WHEN type='income'  THEN amount ELSE 0 END),0) AS total_income,
         COALESCE(SUM(CASE WHEN type='expense' THEN amount ELSE 0 END),0) AS total_expense
       FROM transactions
       WHERE user_id = ? AND date BETWEEN ? AND ?`,
      [userId, start, end]
    );

    // Saldo total (semua waktu)
    const [[{ balance }]] = await pool.query(
      `SELECT COALESCE(SUM(CASE WHEN type='income' THEN amount ELSE -amount END),0) AS balance
       FROM transactions WHERE user_id = ?`,
      [userId]
    );

    // Spending limit
    const [[limit]] = await pool.query(
      'SELECT * FROM spending_limits WHERE user_id = ?', [userId]
    );

    // Hitung status limit
    let limit_status = 'aman';
    let limit_percentage = null;
    if (limit && limit.monthly_limit) {
      limit_percentage = Math.round((totals.total_expense / limit.monthly_limit) * 100);
      if (limit_percentage >= 100) limit_status = 'melebihi';
      else if (limit_percentage >= (limit.alert_threshold || 80)) limit_status = 'waspada';
    }

    // Transaksi terbaru (5 terakhir)
    const [recent] = await pool.query(
      `SELECT t.*, c.name AS category_name, c.icon AS category_icon, c.color AS category_color
       FROM transactions t LEFT JOIN categories c ON t.category_id = c.id
       WHERE t.user_id = ? ORDER BY t.date DESC, t.created_at DESC LIMIT 5`,
      [userId]
    );

    // Pengeluaran per kategori bulan ini
    const [by_category] = await pool.query(
      `SELECT c.name, c.icon, c.color,
              SUM(t.amount) AS total,
              COUNT(*) AS count
       FROM transactions t
       LEFT JOIN categories c ON t.category_id = c.id
       WHERE t.user_id = ? AND t.type = 'expense' AND t.date BETWEEN ? AND ?
       GROUP BY t.category_id, c.name, c.icon, c.color
       ORDER BY total DESC`,
      [userId, start, end]
    );

    res.json({
      success: true,
      data: {
        period: { month: Number(m), year: Number(y), start, end },
        balance: Number(balance) || 0,
        total_income:  Number(totals.total_income) || 0,
        total_expense: Number(totals.total_expense) || 0,
        spending_limit: limit ? {
          monthly_limit:   Number(limit.monthly_limit) || 0,
          daily_limit:     Number(limit.daily_limit) || 0,
          alert_threshold: Number(limit.alert_threshold) || 80,
          percentage_used: limit_percentage,
          status:          limit_status,
        } : null,
        recent_transactions: recent,
        expense_by_category: by_category.map(cat => ({
          ...cat,
          total: Number(cat.total) || 0,
          count: Number(cat.count) || 0,
        })),
      },
    });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

// GET /transactions/chart?type=daily|monthly&year=&month=
exports.chart = async (req, res) => {
  const { type = 'daily', month, year } = req.query;
  const now = new Date();
  const m = month || (now.getMonth() + 1);
  const y = year || now.getFullYear();

  try {
    let rows;
    if (type === 'daily') {
      const start = `${y}-${String(m).padStart(2,'0')}-01`;
      const end   = new Date(y, m, 0).toISOString().split('T')[0];
      [rows] = await pool.query(
        `SELECT DATE(date) AS label,
                SUM(CASE WHEN type='income'  THEN amount ELSE 0 END) AS income,
                SUM(CASE WHEN type='expense' THEN amount ELSE 0 END) AS expense
         FROM transactions WHERE user_id = ? AND date BETWEEN ? AND ?
         GROUP BY DATE(date) ORDER BY label`,
        [req.user.id, start, end]
      );
    } else {
      [rows] = await pool.query(
        `SELECT DATE_FORMAT(date,'%Y-%m') AS label,
                SUM(CASE WHEN type='income'  THEN amount ELSE 0 END) AS income,
                SUM(CASE WHEN type='expense' THEN amount ELSE 0 END) AS expense
         FROM transactions WHERE user_id = ? AND YEAR(date) = ?
         GROUP BY DATE_FORMAT(date,'%Y-%m') ORDER BY label`,
        [req.user.id, y]
      );
    }
    res.json({ success: true, data: rows });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};
