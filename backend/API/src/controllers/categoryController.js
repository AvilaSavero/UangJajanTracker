const pool = require('../config/database');

exports.getAll = async (req, res) => {
  const { type } = req.query;
  let where = 'WHERE (user_id = ? OR is_default = 1)';
  const params = [req.user.id];
  if (type) { where += ' AND type = ?'; params.push(type); }

  try {
    const [rows] = await pool.query(
      `SELECT * FROM categories ${where} ORDER BY is_default DESC, name ASC`, params
    );
    res.json({ success: true, data: rows });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

exports.create = async (req, res) => {
  const { name, type, icon, color } = req.body;
  if (!name || !type)
    return res.status(422).json({ success: false, message: 'name dan type wajib diisi' });

  try {
    await pool.query(
      'INSERT INTO categories (user_id, name, type, icon, color) VALUES (?, ?, ?, ?, ?)',
      [req.user.id, name, type, icon || 'other', color || '#6B7280']
    );
    const [rows] = await pool.query(
      'SELECT * FROM categories WHERE user_id = ? ORDER BY created_at DESC LIMIT 1', [req.user.id]
    );
    res.status(201).json({ success: true, message: 'Kategori dibuat', data: rows[0] });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

exports.update = async (req, res) => {
  const { name, icon, color } = req.body;
  try {
    const [check] = await pool.query(
      'SELECT id FROM categories WHERE id = ? AND user_id = ? AND is_default = 0',
      [req.params.id, req.user.id]
    );
    if (!check.length)
      return res.status(404).json({ success: false, message: 'Kategori tidak ditemukan atau tidak bisa diubah' });

    await pool.query('UPDATE categories SET name=?, icon=?, color=? WHERE id=?', [name, icon, color, req.params.id]);
    const [rows] = await pool.query('SELECT * FROM categories WHERE id = ?', [req.params.id]);
    res.json({ success: true, message: 'Kategori diperbarui', data: rows[0] });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

exports.remove = async (req, res) => {
  try {
    const [check] = await pool.query(
      'SELECT id FROM categories WHERE id = ? AND user_id = ? AND is_default = 0',
      [req.params.id, req.user.id]
    );
    if (!check.length)
      return res.status(404).json({ success: false, message: 'Kategori tidak ditemukan atau tidak bisa dihapus' });

    await pool.query('DELETE FROM categories WHERE id = ?', [req.params.id]);
    res.json({ success: true, message: 'Kategori dihapus' });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};