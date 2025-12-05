# Plantify - Aplikasi Perawatan Tanaman

Buatkan aplikasi Flutter lengkap bernama **Plantify** dengan SQLite sebagai database lokal.

## Spesifikasi Teknis
- **Framework**: Flutter
- **Database**: SQLite (sqflite package)
- **State Management**: Provider atau setState
- **Packages yang dibutuhkan**:
  - sqflite: ^2.3.0
  - path: ^1.8.3
  - provider: ^6.1.1
  - intl: ^0.18.1

## Struktur Database SQLite

### Tabel: users
```sql
- id (INTEGER PRIMARY KEY AUTOINCREMENT)
- username (TEXT NOT NULL UNIQUE)
- email (TEXT NOT NULL UNIQUE)
- password (TEXT NOT NULL)
- hari_beruntun (INTEGER DEFAULT 0)
- total_lencana (INTEGER DEFAULT 0)
- created_at (TEXT)
```

### Tabel: tanaman_user
```sql
- id (INTEGER PRIMARY KEY AUTOINCREMENT)
- user_id (INTEGER)
- nama_tanaman (TEXT NOT NULL)
- jenis_tanaman (TEXT)
- jadwal_siram (TEXT) -- format: "Setiap 7 hari"
- terakhir_disiram (TEXT) -- format ISO
- foto_path (TEXT)
- created_at (TEXT)
```

### Tabel: galeri_tanaman (data master)
```sql
- id (INTEGER PRIMARY KEY AUTOINCREMENT)
- nama (TEXT NOT NULL)
- kategori (TEXT) -- Tropis, Kaktus, Sukulen, dll
- status_disiram (TEXT) -- Sudah Disiram / Belum
- deskripsi (TEXT)
```

### Tabel: jadwal_penyiraman
```sql
- id (INTEGER PRIMARY KEY AUTOINCREMENT)
- tanaman_user_id (INTEGER)
- tanggal_siram (TEXT)
- status (TEXT) -- selesai/pending
```

### Tabel: tantangan
```sql
- id (INTEGER PRIMARY KEY AUTOINCREMENT)
- user_id (INTEGER)
- nama_tantangan (TEXT)
- deskripsi (TEXT)
- progress_saat_ini (INTEGER DEFAULT 0)
- target (INTEGER)
- total_peserta (INTEGER DEFAULT 0)
- status (TEXT) -- aktif/selesai
- icon (TEXT) -- emoji/icon identifier
```

### Tabel: lencana
```sql
- id (INTEGER PRIMARY KEY AUTOINCREMENT)
- user_id (INTEGER)
- nama_lencana (TEXT)
- deskripsi (TEXT)
- icon (TEXT)
- tanggal_diperoleh (TEXT)
```

## Fitur & Halaman yang Harus Dibuat

### 1. Landing Page (Splash Screen)
- Logo tanaman di pot
- Judul "Plantify"
- Subtitle: "Pendamping Perawatan Tanamanmu"
- Tombol: "Ketuk di mana saja untuk Melanjutkan"
- Background: gradient hijau lembut (#C8E6C9)

### 2. Form Login
- Input: Email
- Input: Kata sandi (password)
- Tombol: "Login" (hijau)
- Link: "sudah punya akun? Register jika anda belum mempunyai akun"
- Background: hijau lembut
- Logo tanaman di atas form

### 3. Form Register
- Input: Nama
- Input: Email
- Input: Kata sandi
- Tombol: "Register" (hijau)
- Link: "silahkan Login jika anda sudah mempunyai akun"
- Background: hijau lembut
- Logo tanaman di atas form

### 4. Home / Tanamanku
- AppBar: "Plantify" dengan subtitle "Jaga tanamanmu tetap bahagia 🌱"
- Tombol: "+ Tambah" (hijau, pojok kanan atas)
- Icon notifikasi (kanan atas)
- Grid/List tanaman user dengan card:
  - Icon/gambar tanaman
  - Nama tanaman
  - Status (misal: "Setiap 7 hari", "Setiap 3 hari")
- Bottom Navigation: Beranda, Galeri, Komunitas, Tantangan, Profil

### 5. Tambah Tanaman
- AppBar: "Tambah Tanaman" dengan back button
- Form input:
  - Nama Tanaman
  - Jenis Tanaman (dropdown: Tropis, Kaktus, Sukulen, dll)
  - Foto Tanaman: tombol "Upload img"
- Tombol: "Simpan" (hijau)
- Background: hijau lembut
- Logo tanaman di atas form

### 6. Galeri Tanaman
- AppBar: "Galeri Tanaman" dengan subtitle "Temukan tanaman baru 🌿"
- Search bar: "Cari tanaman..."
- Grid tanaman (2 kolom) dengan card:
  - Icon tanaman
  - Nama tanaman
  - Kategori (misal: Kaktus, Tropis, Sukulen)
- Data galeri: HARDCODE 6-8 jenis tanaman populer
- Bottom Navigation tetap ada

### 7. Detail Tanaman (dari Galeri)
- AppBar: Nama tanaman dengan back button
- Icon tanaman besar
- Checklist: "✓ Sudah Disiram"
- Info card:
  - Jadwal Penyiraman: "Setiap 7 hari"
  - Terakhir Disiram: "14/10/2025"
  - Penyiraman Berikutnya: "Dalam 1 hari"
- Background: hijau lembut

### 8. Komunitas (HARDCODE - Static UI)
- AppBar: "Komunitas" dengan subtitle "Terhubung dengan pecinta tanaman 🌱"
- Tombol: "📸 Bagikan Tanamanmu"
- List postingan (HARDCODE 2-3 post):
  - Avatar user
  - Nama user: "Jane Si Hijau"
  - Waktu: "1 hari lalu"
  - Caption: "Kebun sukulen saya berkembang pesat! Ini bayi-bayi saya 🌱💚"
  - Gambar tanaman
  - Tombol: Like (❤️ 201), Komentar (💬 34), Share
- Bottom Navigation tetap ada

### 9. Postingan Detail (HARDCODE)
- AppBar: "Postingan" dengan back button
- Detail post seperti di list komunitas
- Bagian Komentar dengan 3 komentar static:
  - Avatar + Username + komentar
  - Contoh: "Pengguna 1: Keren banget! 🌱"
- Input komentar di bawah (tidak fungsional)

### 10. Tantangan
- AppBar: "Tantangan" dengan subtitle "Selesaikan tantangan 🏆"
- Card streak:
  - Icon trophy
  - "15 Hari Beruntun"
  - 3 lencana kecil
- Section "Tantangan Aktif" dengan card:
  - Nama: "Tantangan Hijau 30 Hari"
  - Deskripsi: "Siram tanaman secara konsisten selama 30 hari"
  - Progress bar: 15/30
  - Total peserta: 1,240
- Section lain: "Orang Tua Tanaman Pro", "Penolong Komunitas"
- Bottom Navigation tetap ada

### 11. Detail Tantangan
- AppBar: "Tantangan" dengan back button
- Card:
  - Icon achievement
  - Nama: "Orang Tua Tanaman Pro"
  - Deskripsi: "Tambahkan 5 jenis tanaman berbeda ke koleksimu"
  - Progress: 3/5
  - Icon lencana: "Lencana Pro"
  - Total peserta: 856
- Section "Aktivitas Terkini":
  - List 3 aktivitas dengan checkmark
  - "Pengguna 1: Menyelesaikan hari ke-3"

### 12. Profil
- AppBar: "Profil" dengan subtitle "Perjalanan tanamanmu 🌱"
- Avatar user (icon/emoji)
- Nama: "Pecinta Tanaman"
- Subtitle: "Penggemar Tanaman 🌱"
- Stats card (3 kolom):
  - Total tanaman: 3
  - Hari beruntun: 15
  - Lencana: 3
- Section "Lencana Saya" dengan 3 lencana:
  - Icon lencana + nama (Lencana 1, 2, 3)
- Menu list:
  - Edit Profil (dengan icon ⚙️)
  - Notifikasi (dengan icon 🔔)
  - Pencapaian (dengan icon 🏆)
- Tombol "Keluar" (merah muda, bawah)
- Bottom Navigation tetap ada

### 13. Edit Profil
- AppBar: "Edit Profile" dengan back button
- Logo tanaman
- Section "MY PROFILE":
  - Input Username
  - Input Email
  - Input Password (hidden)
- Tombol "Simpan" (hijau)
- Background: hijau lembut

## Desain & Styling

### Color Scheme
- Primary: #4CAF50 (hijau)
- Background: #C8E6C9 (hijau lembut)
- Card: #E8F5E9 (hijau sangat muda)
- Text: #2E7D32 (hijau tua)
- Button: #4CAF50 (hijau)
- Accent: #FF6B9D (pink untuk keluar)

### Typography
- Judul AppBar: Bold, 20-24px
- Card title: Semi-bold, 16-18px
- Body text: Regular, 14-16px
- Subtitle: Regular, 12-14px

### Komponen UI
- Rounded corners: 12-16px untuk card
- Rounded corners: 24px untuk button
- Shadow: elevation 2-4 untuk card
- Input field: rounded, background putih/pink muda
- Bottom Navigation: 5 item dengan icon dan label

## Fungsionalitas SQLite

### Authentication
- Register: insert user baru ke tabel users
- Login: validasi email & password dari tabel users
- Session: simpan user_id yang login (bisa pakai SharedPreferences)

### CRUD Tanaman User
- CREATE: tambah tanaman baru ke tanaman_user
- READ: tampilkan list tanaman milik user yang login
- UPDATE: edit data tanaman (nama, jenis, jadwal)
- DELETE: hapus tanaman dari database

### Jadwal Penyiraman
- Hitung next watering date berdasarkan terakhir_disiram
- Update terakhir_disiram saat user klik "Sudah Disiram"
- Tampilkan notifikasi/reminder (opsional)

### Tantangan
- Ambil list tantangan dari database
- Update progress tantangan saat user melakukan aksi tertentu
- Beri lencana saat tantangan selesai

### Galeri Tanaman
- Isi galeri_tanaman dengan seed data 6-8 tanaman populer
- Tampilkan sebagai master catalog
- Saat diklik, tampilkan detail (hardcode info perawatan)

## Data Seed (Contoh)

### Galeri Tanaman (Insert saat onCreate database)
```
1. Monstera - Tropis - "Tanaman hias populer dengan daun berlubang"
2. Lidah Mertua - Sukulen - "Tanaman pembersih udara yang tahan banting"
3. Kaktus - Kaktus - "Sukulen gurun yang memerlukan sedikit air"
4. Sirih Gading - Tropis - "Tanaman merambat yang mudah tumbuh"
5. Bunga Lili - Berbunga - "Bunga cantik dengan aroma harum"
6. Aloe Vera - Sukulen - "Tanaman obat serbaguna"
```

### Tantangan Default
```
1. Tantangan Hijau 30 Hari - Siram tanaman konsisten 30 hari - Target: 30
2. Orang Tua Tanaman Pro - Tambahkan 5 jenis tanaman - Target: 5
3. Penolong Komunitas - Bagikan 10 tips dengan komunitas - Target: 10
```

## Instruksi Implementasi

1. **Setup Project**
   - Buat project Flutter baru: `flutter create plantify`
   - Tambahkan dependencies di pubspec.yaml
   - Jalankan `flutter pub get`

2. **Struktur Folder**
   ```
   lib/
   ├── main.dart
   ├── database/
   │   └── database_helper.dart
   ├── models/
   │   ├── user.dart
   │   ├── tanaman_user.dart
   │   ├── galeri_tanaman.dart
   │   ├── tantangan.dart
   │   └── lencana.dart
   ├── screens/
   │   ├── splash_screen.dart
   │   ├── login_screen.dart
   │   ├── register_screen.dart
   │   ├── home_screen.dart
   │   ├── tambah_tanaman_screen.dart
   │   ├── galeri_screen.dart
   │   ├── detail_tanaman_screen.dart
   │   ├── komunitas_screen.dart
   │   ├── postingan_detail_screen.dart
   │   ├── tantangan_screen.dart
   │   ├── detail_tantangan_screen.dart
   │   ├── profil_screen.dart
   │   └── edit_profil_screen.dart
   └── widgets/
       ├── bottom_nav.dart
       ├── tanaman_card.dart
       └── custom_button.dart
   ```

3. **Database Helper**
   - Buat DatabaseHelper dengan singleton pattern
   - Implementasi semua tabel sesuai struktur di atas
   - Buat method CRUD untuk setiap tabel
   - Tambahkan seed data untuk galeri_tanaman

4. **Models**
   - Buat class model untuk setiap tabel
   - Tambahkan method `toMap()` dan `fromMap()`

5. **Screens**
   - Implementasi setiap screen sesuai desain
   - Gunakan consistent styling
   - Integrasikan dengan database
   - Untuk komunitas: buat UI static dengan data hardcode

6. **Navigation**
   - Splash → Login/Register
   - Login/Register → Home
   - Bottom Navigation untuk 5 main screens
   - Navigation untuk detail screens

7. **Testing**
   - Pastikan register & login berfungsi
   - Test CRUD tanaman
   - Test navigation antar halaman
   - Verifikasi data tersimpan di SQLite

## Catatan Penting

- Fokus pada fungsionalitas database SQLite untuk fitur utama
- Komunitas hanya tampilan static (hardcode), tidak perlu save ke database
- Like & komentar di komunitas hanya UI, tidak fungsional
- Gunakan emoji/icon bawaan Flutter untuk gambar tanaman (tidak perlu upload image sebenarnya)
- Password bisa disimpan plain text (untuk tugas kuliah, production harus di-hash)
- Buat UI semirip mungkin dengan desain Figma yang diberikan

## Output yang Diharapkan

Aplikasi Flutter lengkap yang:
✅ Bisa register dan login dengan SQLite
✅ Bisa menambah, melihat, edit, hapus tanaman user
✅ Menampilkan galeri tanaman (dari database)
✅ Menampilkan dan update tantangan & progress
✅ UI komunitas static yang menarik
✅ Profil user dengan statistik dari database
✅ Bottom navigation yang berfungsi
✅ Tampilan mirip dengan desain Figma