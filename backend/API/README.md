# 💰 Money Tracker API

REST API untuk aplikasi pengelola keuangan mobile (Flutter).

**Base URL:** `http://localhost:3000/api/v1`

---

## 🚀 Instalasi & Setup

```bash
# 1. Install dependensi
npm install

# 2. Salin file environment
cp .env.example .env
# Edit .env sesuai konfigurasi MySQL kamu

# 3. Jalankan migrasi database (buat semua tabel)
npm run db:migrate

# 4. Jalankan server
npm run dev        # development (auto-reload)
npm start          # production
```

---

## 🔐 Autentikasi

API menggunakan **JWT Bearer Token**.

Setelah login/register, sertakan token di setiap request:
```
Authorization: Bearer <token>
```

---

## 📋 Endpoint

### AUTH

| Method | Endpoint | Deskripsi | Auth |
|--------|----------|-----------|------|
| POST | `/auth/register` | Daftar akun baru | ❌ |
| POST | `/auth/login` | Login | ❌ |
| GET | `/auth/me` | Data profil user | ✅ |
| PUT | `/auth/profile` | Update profil | ✅ |
| PUT | `/auth/password` | Ganti password | ✅ |

#### POST `/auth/register`
```json
// Request body
{
  "name": "Budi Santoso",
  "email": "budi@example.com",
  "password": "password123"
}

// Response 201
{
  "success": true,
  "message": "Registrasi berhasil",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIs...",
    "user": { "id": "uuid", "name": "Budi Santoso", "email": "budi@example.com", "currency": "IDR" }
  }
}
```

#### POST `/auth/login`
```json
// Request body
{ "email": "budi@example.com", "password": "password123" }

// Response 200
{
  "success": true,
  "data": { "token": "eyJhbGci...", "user": { ... } }
}
```

---

### TRANSAKSI

| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| GET | `/transactions` | Daftar transaksi (dengan filter & paginasi) |
| GET | `/transactions/summary` | Ringkasan dashboard |
| GET | `/transactions/chart` | Data grafik |
| GET | `/transactions/:id` | Detail transaksi |
| POST | `/transactions` | Tambah transaksi |
| PUT | `/transactions/:id` | Update transaksi |
| DELETE | `/transactions/:id` | Hapus transaksi |

#### GET `/transactions` — Query params
| Param | Tipe | Contoh | Keterangan |
|-------|------|--------|------------|
| `type` | string | `income` atau `expense` | Filter jenis |
| `category_id` | string | `uuid` | Filter kategori |
| `start_date` | string | `2024-01-01` | Dari tanggal |
| `end_date` | string | `2024-01-31` | Sampai tanggal |
| `page` | number | `1` | Halaman |
| `limit` | number | `20` | Jumlah per halaman |

```json
// Response 200
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "type": "expense",
      "amount": "25000.00",
      "title": "Makan siang",
      "note": "Warung Padang",
      "date": "2024-01-15",
      "category_name": "Makan",
      "category_icon": "utensils",
      "category_color": "#EF4444"
    }
  ],
  "pagination": { "total": 50, "page": 1, "limit": 20, "pages": 3 }
}
```

#### POST `/transactions`
```json
// Request body
{
  "type": "expense",
  "amount": 25000,
  "title": "Makan siang",
  "category_id": "uuid-kategori",
  "note": "Warung Padang",
  "date": "2024-01-15"
}
```

#### GET `/transactions/summary` — Query params: `month`, `year`
```json
// Response — digunakan untuk halaman dashboard Flutter
{
  "success": true,
  "data": {
    "period": { "month": 1, "year": 2024, "start": "2024-01-01", "end": "2024-01-31" },
    "balance": 2500000.00,
    "total_income": 5000000.00,
    "total_expense": 2500000.00,
    "spending_limit": {
      "monthly_limit": 3000000.00,
      "daily_limit": null,
      "alert_threshold": 80,
      "percentage_used": 83,
      "status": "waspada"
    },
    "recent_transactions": [ ... ],
    "expense_by_category": [
      { "name": "Makan", "icon": "utensils", "color": "#EF4444", "total": 800000, "count": 20 }
    ]
  }
}
```

#### GET `/transactions/chart` — Query params: `type` (daily/monthly), `month`, `year`
```json
// Response — untuk grafik bar/line di Flutter
{
  "success": true,
  "data": [
    { "label": "2024-01-01", "income": 0, "expense": 25000 },
    { "label": "2024-01-02", "income": 5000000, "expense": 0 }
  ]
}
```

---

### KATEGORI

| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| GET | `/categories` | Semua kategori (default + milik user) |
| POST | `/categories` | Buat kategori kustom |
| PUT | `/categories/:id` | Update kategori kustom |
| DELETE | `/categories/:id` | Hapus kategori kustom |

#### GET `/categories` — Query params: `type` (income/expense)
```json
{
  "success": true,
  "data": [
    { "id": "uuid", "name": "Makan", "type": "expense", "icon": "utensils", "color": "#EF4444", "is_default": 1 },
    { "id": "uuid", "name": "Jajan", "type": "expense", "icon": "coffee",   "color": "#F59E0B", "is_default": 0 }
  ]
}
```

#### POST `/categories`
```json
{ "name": "Jajan", "type": "expense", "icon": "coffee", "color": "#F59E0B" }
```

---

### SPENDING LIMIT

| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| GET | `/limits` | Lihat limit saat ini |
| PUT | `/limits` | Set/update limit |

#### PUT `/limits`
```json
{
  "monthly_limit": 3000000,
  "daily_limit": 150000,
  "alert_threshold": 80
}
```

---

## 📦 Format Response

Semua response menggunakan format yang konsisten:

```json
// Sukses
{ "success": true, "message": "...", "data": { ... } }

// Error validasi (422)
{ "success": false, "errors": [{ "msg": "...", "path": "email" }] }

// Error lainnya
{ "success": false, "message": "Pesan error" }
```

### HTTP Status Codes
| Kode | Arti |
|------|------|
| 200 | Sukses |
| 201 | Data berhasil dibuat |
| 401 | Tidak terautentikasi |
| 404 | Data tidak ditemukan |
| 409 | Konflik (misal email sudah ada) |
| 422 | Validasi gagal |
| 500 | Server error |

---

## 🗄️ Struktur Database

```
users             → data akun user
categories        → kategori transaksi (default + kustom per user)
transactions      → semua transaksi income/expense
spending_limits   → batas pengeluaran per user
```

---

## 📁 Struktur Project

```
money-tracker-api/
├── src/
│   ├── app.js                 ← entry point
│   ├── config/
│   │   ├── database.js        ← koneksi MySQL
│   │   └── migrate.js         ← buat tabel & seed data
│   ├── controllers/
│   │   ├── authController.js
│   │   ├── transactionController.js
│   │   ├── categoryController.js
│   │   └── limitController.js
│   ├── middleware/
│   │   └── auth.js            ← JWT middleware
│   └── routes/
│       └── index.js           ← semua route
├── .env.example
└── package.json
```
