# UangJajanTracker
Aplikasi Tracking uang digital - Projek PSAS

# Link GitHub
https://github.com/AvilaSavero/UangJajanTracker.git

# Nama Anggota
- Arga Miftachul Alifta (Hacker - Front End)
- Avila Savero Iman (Hacker - Back End) 
- Constantine Rainer Simanjuntak (Hustler)
- Rafif Arga Pratama (Hipster)

# Apa itu Uang Jajan Tracker?
Uang Jajan Tracker adalah aplikasi manajemen keuangan yang ditunjukkan untuk anak SMP, SMA dan SMK.

## Konfigurasi API & Database
Jika backend dan database berada di server teman, kamu harus mengarahkan frontend ke API teman atau mengatur backend lokal agar terhubung ke database remote.

### Untuk frontend Flutter
Default: `http://localhost:3000/api/v1`

Jika kamu ingin gunakan API teman, jalankan Flutter dengan:

```bash
flutter run -d chrome --dart-define=API_URL=http://server-teman:3000/api/v1
```

atau untuk build:

```bash
flutter build web --dart-define=API_URL=http://server-teman:3000/api/v1
```

### Untuk backend lokal
Di folder `backend/API`, pastikan file `.env` berisi:

```env
PORT=3000
DB_HOST=alamat-server-teman
DB_PORT=3306
DB_USER=user_mysql
DB_PASSWORD=password_mysql
DB_NAME=money_tracker
JWT_SECRET=rahasia_panjang_dan_aman_123456
JWT_EXPIRES_IN=7d
```

Jika kamu tidak punya database lokal dan ingin tetap pakai backend lokal, minta akses database teman dan sesuaikan `DB_HOST`, `DB_USER`, `DB_PASSWORD`, serta `DB_NAME`.


