const pool = require('../config/database');

exports.get = async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT * FROM spending_limits WHERE user_id = ?', [req.user.id]);
    res.json({ success: true, data: rows[0] || null });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

exports.update = async (req, res) => {
  const { monthly_limit, daily_limit, alert_threshold } = req.body;
  try {
    await pool.query(
      `INSERT INTO spending_limits (user_id, monthly_limit, daily_limit, alert_threshold)
       VALUES (?, ?, ?, ?)
       ON DUPLICATE KEY UPDATE monthly_limit=?, daily_limit=?, alert_threshold=?`,
      [req.user.id, monthly_limit, daily_limit, alert_threshold ?? 80,
                    monthly_limit, daily_limit, alert_threshold ?? 80]
    );
    const [rows] = await pool.query('SELECT * FROM spending_limits WHERE user_id = ?', [req.user.id]);
    res.json({ success: true, message: 'Limit diperbarui', data: rows[0] });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};