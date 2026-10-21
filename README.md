#  Personal Assistant Dashboard (Apple HIG)

Personal Assistant Dashboard modern yang dirancang khusus untuk diakses melalui **Safari di iPhone 13**, dibangun menggunakan **Flutter Web** dengan bahasa desain murni **Apple Human Interface Guidelines (HIG)**.

---

## ✨ Fitur Utama

1. **Apple Header & Dynamic Glance**:
   - Sapaan cerdas otomatis (*"Selamat Pagi / Siang / Sore / Malam, Hasan"*).
   - Tanggal live dalam Bahasa Indonesia (misal: *RABU, 21 OKTOBER*).
   - Live search filter tugas dan catatan.

2. **Apple Activity Rings (Fitness / Health Style)**:
   - Cincin konsentris interaktif dengan custom painter.
   - Ring 1 (Merah Muda): Persentase penyelesaian tugas hari ini.
   - Ring 2 (Teal): Tugas prioritas tinggi terselesaikan.
   - Ring 3 (Indigo): Total progres seluruh tugas aktif.
   - Status motivasi harian.

3. **Smart Reminders Grid (4 Squircle Cards)**:
   - 📅 **Hari Ini**: Jumlah tugas dengan tenggat waktu hari ini.
   - ⏰ **Terjadwal**: Tugas dengan tenggat di masa depan.
   - 📋 **Semua**: Total seluruh tugas aktif.
   - ✅ **Selesai**: Arsip riwayat tugas yang sudah tuntas.
   - Klik pada salah satu kartu untuk langsung memfilter daftar to-do list!

4. **Interactive Category Pills**:
   - Filter cepat: `Semua`, `Kuliah` 🎓, `Project` 💻, `Pribadi` 👤, dan `Mendesak` ⚡.

5. **Apple-style To-Do List Tile**:
   - Checkbox bulat dengan animasi centang khas iOS.
   - Badge prioritas: `!!!` (Tinggi - Merah), `!!` (Sedang - Oranye), `!` (Rendah - Biru).
   - Tag kategori dan format tenggat waktu pintar (*"Hari ini 18:00"*, *"Besok"*, dsb).
   - Swipe to delete (geser ke kiri untuk menghapus tugas).

6. **Cupertino Modal Bottom Sheet**:
   - Formulir tambah dan edit tugas dengan Segmented Control prioritas dan date picker ala iOS.

7. **Penyimpanan Lokal iPhone (IndexedDB / SharedPreferences)**:
   - Offline-first: Data tersimpan langsung di browser/PWA iPhone tanpa perlu login.
   - **Fitur Cadangan 1-Tap (JSON Export & Import)**: Anda dapat menyalin teks JSON cadangan kapan saja untuk disimpan di Apple Notes / Files dan me-restore-nya sewaktu-waktu.
   - Dark Mode OLED Black toggle khusus untuk layar Super Retina XDR iPhone 13.

---

## 📱 Cara Akses Langsung di iPhone 13 (Uji Coba Lokal)

1. Pastikan iPhone 13 dan laptop terhubung ke jaringan **Wi-Fi yang sama**.
2. Buka **Safari** di iPhone 13 Anda, lalu ketik alamat IP lokal:
   ```
   http://192.168.18.4:8080
   ```
3. **Jadikan Aplikasi Native (PWA)**:
   - Ketuk tombol **Share** (ikon kotak dengan panah ke atas di bagian bawah Safari).
   - Gulir ke bawah dan pilih **"Add to Home Screen"** (*Tambahkan ke Layar Utama*).
   - Ketuk **Add**.
   - Buka ikon **Assistant** dari Home Screen iPhone Anda. Aplikasi akan terbuka **fullscreen** tanpa bilah navigasi Safari!

---

## 🚀 Panduan Deploy ke Vercel

Aplikasi ini sudah dilengkapi file konfigurasi [vercel.json](file:///c:/Tugas%20Kuliah/Project%20iseng/Personal%20Assistent/vercel.json).

### Opsi A: Deploy via GitHub (Paling Direkomendasikan)
1. Buat repository baru di GitHub (misal: `personal-assistant`).
2. Jalankan di terminal proyek:
   ```bash
   git init
   git add .
   git commit -m "feat: initial Apple HIG Personal Assistant Dashboard"
   git branch -M main
   git remote add origin <URL_REPO_GITHUB_ANDA>
   git push -u origin main
   ```
3. Buka dashboard [Vercel](https://vercel.com) -> Klik **"Add New Project"** -> Import repository GitHub Anda.
4. Pada **Build and Output Settings**:
   - **Build Command**: `flutter/bin/flutter build web --release` (atau compile di local, lalu upload folder `build/web`).
   - **Output Directory**: `build/web`
5. Klik **Deploy**!

### Opsi B: Deploy Langsung Folder `build/web` (Instan 1 Menit)
Jika Anda menginstal Vercel CLI (`npm i -g vercel`):
```bash
# Build release terbaru
flutter build web --release

# Masuk dan deploy folder build/web
cd build/web
vercel --prod
```

---

## 🛠️ Struktur Kode Proyek

- [lib/main.dart](file:///c:/Tugas%20Kuliah/Project%20iseng/Personal%20Assistent/lib/main.dart) - Titik masuk aplikasi, responsive container iPhone, dan controller scroll iOS.
- [lib/theme/apple_colors.dart](file:///c:/Tugas%20Kuliah/Project%20iseng/Personal%20Assistent/lib/theme/apple_colors.dart) - Palet warna Human Interface Guidelines (Light & OLED Dark).
- [lib/theme/apple_theme.dart](file:///c:/Tugas%20Kuliah/Project%20iseng/Personal%20Assistent/lib/theme/apple_theme.dart) - Konfigurasi tema Cupertino & font SF Pro / Inter.
- [lib/models/task_item.dart](file:///c:/Tugas%20Kuliah/Project%20iseng/Personal%20Assistent/lib/models/task_item.dart) - Model data tugas, prioritas, kategori, dan serialisasi JSON.
- [lib/services/storage_service.dart](file:///c:/Tugas%20Kuliah/Project%20iseng/Personal%20Assistent/lib/services/storage_service.dart) - Local storage SharedPreferences & backup JSON handler.
- [lib/state/dashboard_state.dart](file:///c:/Tugas%20Kuliah/Project%20iseng/Personal%20Assistent/lib/state/dashboard_state.dart) - State management reaktif untuk filter, progress rings, dan CRUD task.
- [lib/widgets/activity_rings_card.dart](file:///c:/Tugas%20Kuliah/Project%20iseng/Personal%20Assistent/lib/widgets/activity_rings_card.dart) - Cincin aktivitas konsentris ala Apple Watch.
- [lib/widgets/reminder_summary_grid.dart](file:///c:/Tugas%20Kuliah/Project%20iseng/Personal%20Assistent/lib/widgets/reminder_summary_grid.dart) - Grid 4 kartu ringkasan pintar ala Apple Reminders.
- [lib/widgets/task_list_tile.dart](file:///c:/Tugas%20Kuliah/Project%20iseng/Personal%20Assistent/lib/widgets/task_list_tile.dart) - Item daftar tugas dengan checklist iOS interaktif.
- [lib/widgets/add_task_sheet.dart](file:///c:/Tugas%20Kuliah/Project%20iseng/Personal%20Assistent/lib/widgets/add_task_sheet.dart) - Bottom sheet modal untuk input tugas baru.
- [lib/widgets/settings_sheet.dart](file:///c:/Tugas%20Kuliah/Project%20iseng/Personal%20Assistent/lib/widgets/settings_sheet.dart) - Menu pengaturan, dark mode, dan ekspor/impor cadangan JSON.
