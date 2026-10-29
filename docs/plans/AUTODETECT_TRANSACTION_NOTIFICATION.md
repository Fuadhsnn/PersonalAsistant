# Rencana Fitur: Deteksi Otomatis Transaksi Keuangan dari Notifikasi Bank

- **Kategori:** Modul Keuangan & Runway
- **Status:** *On Hold (Ide Ditampung di Backlog)*
- **Target Platform Pengguna:** iPhone (iOS) & Web / PWA (Vercel)
- **Target Bank & Aplikasi:** SeaBank, myBCA, Bank Jago, Bibit

---

## 1. Deskripsi Fitur & Tujuan
Membuat pencatatan pengeluaran dan pemasukan di modul Keuangan menjadi **otomatis tanpa perlu input manual**, dengan cara mendeteksi notifikasi mutasi/transaksi yang masuk dari aplikasi perbankan dan investasi yang digunakan oleh pengguna (SeaBank, myBCA, Bank Jago, dan Bibit).

---

## 2. Analisis Teknis & Tantangan Platform

### Kondisi Saat Ini:
- **Perangkat:** iPhone (iOS).
- **Runtime:** Web / PWA yang disajikan melalui Vercel (`aries-seven-pearl.vercel.app`).

### Tantangan Sandbox iOS & Web:
1. Browser (Safari/Chrome di iPhone) tidak memiliki izin dari Apple untuk mengakses *notification tray* sistem operasi iOS demi privasi pengguna (*security sandbox*).
2. Sistem operasi iOS tidak menyediakan API umum seperti `NotificationListenerService` milik Android bagi aplikasi pihak ketiga.

---

## 3. Strategi Arsitektur Terpilih (Solusi iPhone + Web Vercel)

Untuk mengatasi batasan di atas tanpa harus membuat aplikasi native yang rumit, solusi terbaik yang dirancang adalah:

### Opsi A: Apple Shortcuts Automation + Vercel Webhook (Paling Otomatis) 🌟
1. **Pemicu di iPhone (Apple Shortcuts Personal Automation):**
   - Menggunakan fitur bawaan iOS: **Aplikasi Pintasan (Shortcuts) $\rightarrow$ Tab Otomatisasi (Automation)**.
   - Pemicu (*Trigger*): *"Ketika menerima pemberitahuan dari aplikasi [myBCA / SeaBank / Bank Jago / Bibit]"*.
2. **Aksi Ekstraksi & Kirim:**
   - Shortcut mengambil isi teks notifikasi.
   - Shortcut menjalankan aksi HTTP POST (mengirim teks notifikasi) ke endpoint Vercel Serverless Function:
     `POST https://aries-seven-pearl.vercel.app/api/webhook/bank-transaction`
3. **Pemrosesan di Backend Vercel:**
   - Vercel function menerima teks notifikasi.
   - Menggunakan regex / Gemini AI untuk mengenali:
     - **Nominal:** (contoh: `Rp 50.000`)
     - **Tipe:** `Pengeluaran` (Transfer keluar, QRIS, beli reksadana) atau `Pemasukan` (Transfer masuk, bunga, cashback)
     - **Merchant / Tujuan:** (contoh: `Kopi Kenangan`, `SeaBank`, `Bibit Reksadana`)
     - **Kategori Otomatis:** (contoh: `Makan & Kopi`, `Belanja`, `Investasi`, `Lainnya`)
4. **Sinkronisasi ke Web ARIES:**
   - Saat pengguna membuka web ARIES di Safari/Chrome, aplikasi mengambil data transaksi terbaru dari penyimpanan/database dan langsung mengupdate saldo kas serta grafik pengeluaran.

---

### Opsi B: Smart Clipboard / Copy-Paste Mutasi (Semi-Otomatis)
- Pengguna cukup menyalin (*copy*) teks SMS perbankan atau notifikasi transfer.
- Begitu web ARIES dibuka, sistem mendeteksi format mutasi bank di *clipboard* dan menampilkan *action sheet* Apple:
  > *"Terdeteksi transaksi SeaBank Rp 85.000 (QRIS). Catat ke Pengeluaran Makan & Kopi?"*
  > `[Batal]` `[Catat Sekarang]`

---

### Opsi C: Screenshot Import (Vision AI)
- Pengguna mengambil tangkapan layar (*screenshot*) bukti transfer atau riwayat mutasi di myBCA/SeaBank.
- Upload ke modul Keuangan $\rightarrow$ Gemini Vision AI mengekstrak nominal, tanggal, dan nama penerima dalam 1.5 detik (menggunakan modul vision yang sudah dibangun pada fitur Split Bill).

---

## 4. Pola Format Notifikasi Bank Target

| Bank / Aplikasi | Contoh Format Notifikasi | Klasifikasi |
| :--- | :--- | :---: |
| **myBCA** | `m-Transfer berhasil Rp 75.000 ke BCA 1234567890 an KOPI KENANGAN` | Pengeluaran |
| **myBCA** | `Pembayaran QRIS Rp 25.000 di SOLARIA berhasil` | Pengeluaran |
| **SeaBank** | `Transfer Masuk: Kamu menerima Rp 1.500.000 dari PT ABC` | Pemasukan |
| **SeaBank** | `Pembayaran Berhasil: Pembayaran QRIS sebesar Rp 35.000 berhasil` | Pengeluaran |
| **Bank Jago** | `Uang keluar Rp 45.000 dari Kantong Utama untuk Merchant XYZ` | Pengeluaran |
| **Bibit** | `Pembelian Reksa Dana sebesar Rp 500.000 berhasil diverifikasi` | Investasi / Pengeluaran |

---

## 5. Rencana Tahapan Eksekusi (Ketika Fitur Mulai Dikerjakan)

1. [ ] **Tahap 1:** Buat serverless function di Vercel (`/api/webhook/bank-transaction.js`) yang menerima payload teks notifikasi.
2. [ ] **Tahap 2:** Implementasikan parser teks (regex + Gemini fallback) untuk mengonversi teks mentah menjadi objek JSON `FinanceTransaction`.
3. [ ] **Tahap 3:** Buat integrasi penyimpanan awan sederhana (misal: Supabase / Firebase / Vercel KV) agar data yang dikirim oleh iPhone Shortcuts bisa diunduh oleh web Flutter.
4. [ ] **Tahap 4:** Sediakan panduan langkah demi langkah (*tutorial*) di aplikasi untuk menyetel Apple Shortcuts di iPhone pengguna.

