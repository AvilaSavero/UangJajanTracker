const router = require('express').Router();
const { body } = require('express-validator');
const auth = require('../middleware/auth');

const authCtrl  = require('../controllers/authController');
const trxCtrl   = require('../controllers/transactionController');
const catCtrl   = require('../controllers/categoryController');
const limitCtrl = require('../controllers/limitController');

// ─── AUTH ────────────────────────────────────────────────────────────────────
router.post('/auth/register',
  [body('name').notEmpty(), body('email').isEmail(), body('password').isLength({ min: 6 })],
  authCtrl.register
);
router.post('/auth/login',
  [body('email').isEmail(), body('password').notEmpty()],
  authCtrl.login
);
router.get('/auth/me', auth, authCtrl.me);
router.put('/auth/profile', auth, authCtrl.updateProfile);
router.put('/auth/password', auth, authCtrl.changePassword);

// ─── TRANSACTIONS ─────────────────────────────────────────────────────────────
router.get('/transactions/summary', auth, trxCtrl.summary);
router.get('/transactions/chart',   auth, trxCtrl.chart);
router.get('/transactions',         auth, trxCtrl.getAll);
router.get('/transactions/:id',     auth, trxCtrl.getOne);
router.post('/transactions',
  auth,
  [body('type').isIn(['income','expense']),
   body('amount').isFloat({ min: 1 }),
   body('title').notEmpty(),
   body('date').isDate()],
  trxCtrl.create
);
router.put('/transactions/:id',
  auth,
  [body('type').isIn(['income','expense']),
   body('amount').isFloat({ min: 1 }),
   body('title').notEmpty(),
   body('date').isDate()],
  trxCtrl.update
);
router.delete('/transactions/:id', auth, trxCtrl.remove);

// ─── CATEGORIES ───────────────────────────────────────────────────────────────
router.get('/categories',       auth, catCtrl.getAll);
router.post('/categories',      auth, catCtrl.create);
router.put('/categories/:id',   auth, catCtrl.update);
router.delete('/categories/:id',auth, catCtrl.remove);

// ─── SPENDING LIMITS ─────────────────────────────────────────────────────────
router.get('/limits', auth, limitCtrl.get);
router.put('/limits', auth, limitCtrl.update);

module.exports = router;
