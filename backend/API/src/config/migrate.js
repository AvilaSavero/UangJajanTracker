const pool = require('./database');

const migrate = async () => {
  const conn = await pool.getConnection();
  try {
    console.log('Menjalankan migrasi database...');

    // Tabel users
    await conn.query(`
      CREATE TABLE IF NOT EXISTS users (
        id         VARCHAR(36)  PRIMARY KEY DEFAULT (UUID()),
        name       VARCHAR(100) NOT NULL,
        email      VARCHAR(100) NOT NULL UNIQUE,
        password   VARCHAR(255) NOT NULL,
        avatar_url VARCHAR(255) DEFAULT NULL,
        currency   VARCHAR(10)  DEFAULT 'IDR',
        language   VARCHAR(10)  DEFAULT 'id',
        created_at TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP    DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
      )
    `);
    console.log('✓ Tabel users');

    // Tabel categories
    await conn.query(`
      CREATE TABLE IF NOT EXISTS categories (
        id         VARCHAR(36)  PRIMARY KEY DEFAULT (UUID()),
        user_id    VARCHAR(36)  DEFAULT NULL,
        name       VARCHAR(100) NOT NULL,
        type       ENUM('income','expense') NOT NULL,
        icon       VARCHAR(50)  DEFAULT 'other',
        color      VARCHAR(7)   DEFAULT '#6B7280',
        is_default TINYINT(1)   DEFAULT 0,
        created_at TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    `);
    console.log('✓ Tabel categories');

    // Tabel transactions
    await conn.query(`
      CREATE TABLE IF NOT EXISTS transactions (
        id          VARCHAR(36)    PRIMARY KEY DEFAULT (UUID()),
        user_id     VARCHAR(36)    NOT NULL,
        category_id VARCHAR(36)    DEFAULT NULL,
        type        ENUM('income','expense') NOT NULL,
        amount      DECIMAL(15,2)  NOT NULL,
        title       VARCHAR(200)   NOT NULL,
        note        TEXT           DEFAULT NULL,
        date        DATE           NOT NULL,
        created_at  TIMESTAMP      DEFAULT CURRENT_TIMESTAMP,
        updated_at  TIMESTAMP      DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id)     REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL,
        INDEX idx_user_date (user_id, date),
        INDEX idx_user_type (user_id, type)
      )
    `);
    console.log('✓ Tabel transactions');

    // Tabel spending_limits
    await conn.query(`
      CREATE TABLE IF NOT EXISTS spending_limits (
        id              VARCHAR(36)   PRIMARY KEY DEFAULT (UUID()),
        user_id         VARCHAR(36)   NOT NULL UNIQUE,
        monthly_limit   DECIMAL(15,2) DEFAULT NULL,
        daily_limit     DECIMAL(15,2) DEFAULT NULL,
        alert_threshold INT           DEFAULT 80,
        updated_at      TIMESTAMP     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    `);
    console.log('✓ Tabel spending_limits');

    // Insert default categories
    await conn.query(`
      INSERT IGNORE INTO categories (id, name, type, icon, color, is_default) VALUES
        (UUID(), 'Gaji',         'income',  'wallet',      '#10B981', 1),
        (UUID(), 'Top Up',       'income',  'plus-circle', '#3B82F6', 1),
        (UUID(), 'Bonus',        'income',  'gift',        '#8B5CF6', 1),
        (UUID(), 'Investasi',    'income',  'trending-up', '#F59E0B', 1),
        (UUID(), 'Makan',        'expense', 'utensils',    '#EF4444', 1),
        (UUID(), 'Transport',    'expense', 'car',         '#F97316', 1),
        (UUID(), 'Belanja',      'expense', 'shopping-bag','#EC4899', 1),
        (UUID(), 'Hiburan',      'expense', 'gamepad',     '#A855F7', 1),
        (UUID(), 'Kesehatan',    'expense', 'heart',       '#14B8A6', 1),
        (UUID(), 'Tagihan',      'expense', 'file-text',   '#6366F1', 1),
        (UUID(), 'Lainnya',      'expense', 'more-horizontal','#6B7280', 1)
    `);
    console.log('✓ Default categories');

    console.log('\n✅ Migrasi selesai!');
  } catch (err) {
    console.error('❌ Migrasi gagal:', err.message);
  } finally {
    conn.release();
    process.exit();
  }
};

migrate();
