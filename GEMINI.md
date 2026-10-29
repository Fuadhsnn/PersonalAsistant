# Panduan Proyek & Aturan Pengembangan (Personal Assistant - ARIES)

Dokumen ini berisi aturan permanen yang harus dipatuhi oleh agent saat menambahkan fitur, memperbaiki bug, atau memodifikasi kode di proyek ini.

---

## 1. Aturan Tampilan & Teks (Anti-Garis Kuning / No Yellow Underlines)

> **PENTING:** Flutter akan menampilkan garis bawah ganda warna kuning (*yellow double underline*) pada widget `Text` jika widget tersebut tidak memiliki ancestor `Material` atau `DefaultTextStyle` yang menetapkan `decoration: TextDecoration.none`.

### Pedoman Wajib untuk Setiap Layar / Modal / Sheet Baru:
1. Setiap halaman baru (`CupertinoPageScaffold` atau custom widget) yang dibuka via `Navigator.push` atau dialog HARUS dibungkus dengan:
   ```dart
   CupertinoTheme(
     data: AppleTheme.cupertinoTheme(isDark),
     child: Material(
       type: MaterialType.transparency,
       child: DefaultTextStyle(
         style: TextStyle(
           decoration: TextDecoration.none,
           fontFamily: GoogleFonts.inter().fontFamily,
           color: AppleColors.textPrimary(isDark),
           fontSize: 14,
         ),
         child: CupertinoPageScaffold(
           // ... isi halaman
         ),
       ),
     ),
   )
   ```
2. Saat membuat komponen atau widget mandiri, pastikan seluruh `TextStyle` memiliki `decoration: TextDecoration.none` atau berada di dalam lingkup `DefaultTextStyle`.
3. Gunakan selalu palet warna dari `AppleColors` dan font dari `AppleTheme` untuk menjaga konsistensi iOS Human Interface Guidelines (HIG).

---

## 2. Aturan Integrasi Gemini AI & Vision

1. **Model Utama:** Gunakan `gemini-3.1-flash-lite` karena memiliki latensi sangat rendah (~1.5 detik) dan kapasitas server yang jauh lebih tahan terhadap lonjakan trafik (*spikes in demand*).
2. **Model Cadangan (Multi-Model Failover):**
   Urutan fallback otomatis:
   `gemini-3.1-flash-lite` $\rightarrow$ `gemini-3.5-flash` $\rightarrow$ `gemini-3-flash-preview` $\rightarrow$ `gemini-3.8-flash`.
3. **Penanganan Error 503 / 429 / 404:**
   Jika menerima HTTP status `503` (High Demand), `429` (Rate Limit), atau `404` (Model deprecated), **JANGAN langsung melempar Exception**. Sistem harus otomatis dan senyap melanjutkan ke model berikutnya dalam daftar kandidat.

---

## 3. Aturan Build & Deployment (Vercel & Git)

1. **Struktur Hosting Vercel:**
   - Vercel menyajikan file statis langsung dari direktori `build/web/` sesuai konfigurasi `vercel.json`.
   - Vercel terhubung ke branch production **`main`**.
2. **Alur Wajib Setiap Kali Push Perubahan:**
   - Jalankan `flutter build web --release` untuk memperbarui bundle `build/web/main.dart.js`.
   - Stage berkas source code dan `build/web`.
   - Push ke **KEDUA** branch agar selalu sinkron:
     ```bash
     git push origin master
     git push origin master:main
     ```
