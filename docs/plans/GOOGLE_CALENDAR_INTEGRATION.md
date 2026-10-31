# Rencana Fitur: Integrasi Google Calendar (Two-Way Sync & Smart Dashboard)

- **Kategori:** Modul Kalender & Produktivitas
- **Status:** *On Hold (Backlog)*
- **Target Platform Pengguna:** iPhone (iOS Safari / PWA) & Web (Vercel)
- **Lingkup:** Widget Beranda (Hari H, H-1, & Countdown H-7) + Layar Kalender Penuh (Lihat, Tambah, Edit Acara)

---

## 1. Deskripsi Fitur & Tujuan
Menghubungkan aplikasi **ARIES** secara dua arah (*two-way sync*) dengan **Google Calendar**:
1. Menampilkan agenda hari ini (**Hari H**) dan besok (**H-1**) langsung di Beranda ([home_screen.dart](file:///c:/Tugas%20Kuliah/Project%20iseng/Personal%20Assistent/lib/screens/home_screen.dart)).
2. Menampilkan kartu pengingat (*countdown milestone*) untuk acara penting dalam 7 hari ke depan (**H-7**).
3. Menyediakan **Layar Kalender Khusus** bergaya Apple iOS Calendar untuk melihat kalender bulanan, rincian catatan/deskripsi acara, serta menambah dan mengedit acara langsung dari aplikasi ARIES yang seketika tersinkron ke Google Calendar.

---

## 2. Arsitektur Google Cloud: 1 Project untuk Semua Fitur 💡

> **Konsep Efisien:** Anda **CUKUP membuat 1 Google Cloud Project** untuk seluruh ekosistem aplikasi ARIES.

Di dalam **1 Google Cloud Project yang sama**, kita mengaktifkan 2 API sekaligus:
1. **Generative Language API** $\rightarrow$ Menghasilkan **API Key** (untuk Gemini Vision OCR pada fitur Split Bill).
2. **Google Calendar API** $\rightarrow$ Menghasilkan **OAuth 2.0 Client ID** (untuk login akun Google pengguna dan mengelola jadwal).

### Konfigurasi OAuth 2.0 di Google Cloud Console:
- **Jenis Aplikasi:** Web application.
- **Authorized JavaScript origins:**
  - `http://localhost:port` (untuk pengujian lokal)
  - `https://aries-seven-pearl.vercel.app` (untuk production di Vercel)
- **Authorized redirect URIs:**
  - `https://aries-seven-pearl.vercel.app/`
- **Scopes yang Diperlukan:**
  - `https://www.googleapis.com/auth/calendar.events` (baca, tambah, ubah, dan hapus acara kalender).

---

## 3. Komponen Layar & Antarmuka (UI/UX)

### A. Widget Beranda (Home Screen)
1. **Apple Calendar Agenda Widget (Hari H & H-1):**
   - Diletakkan di bawah *Activity Rings Card* pada Beranda.
   - Menampilkan tanggal hari ini dengan blok merah khas iOS.
   - Menampilkan daftar acara hari ini (jam, judul, lokasi/link Google Meet, dan catatan singkat).
   - Menampilkan preview acara besok (*H-1*).
2. **Countdown Milestone Banner (H-7):**
   - Jika terdapat acara penting/besar dalam jangka waktu 7 hari ke depan, muncul kartu countdown minimalis:
     > ✈️ **Flight ke Bali** • *3 Hari Lagi (2 Nov 2026)*  
     > 🎓 **Sidang Skripsi** • *6 Hari Lagi (5 Nov 2026)*

### B. Layar Kalender Penuh (Dedicated Calendar Screen)
- Diakses melalui **Apple Navigation Drawer** ([apple_drawer.dart](file:///c:/Tugas%20Kuliah/Project%20iseng/Personal%20Assistent/lib/widgets/apple_drawer.dart)) dengan menu baru: **"Kalender & Jadwal"** (ikon `CupertinoIcons.calendar`).
- **Kalender Interaktif:** Kalender bulanan yang menandai tanggal-tanggal yang memiliki jadwal aktif.
- **Daftar Rincian Harian:** Tap pada suatu tanggal akan menampilkan seluruh acara pada hari tersebut lengkap dengan deskripsi/catatan (*notes*).
- **Formulir Tambah Acara (+):**
  - Judul Acara (*Event Title*)
  - Tanggal & Waktu Mulai / Selesai (*Start & End DateTime*)
  - Catatan / Deskripsi Acara (*Notes / Description*)
  - Lokasi / Link Meeting (Opsional)
- **Fitur Ubah (Edit) & Hapus (Delete):** Mengedit catatan atau jam acara langsung meng-update event di Google Calendar melalui HTTP PATCH / DELETE.

---

## 4. Model Data & Service yang Akan Dibuat

### 1. Model: `CalendarEventItem` (`lib/models/calendar_event_item.dart`)
```dart
class CalendarEventItem {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final bool isAllDay;
  final String location;
  final String? meetLink;
  final String? colorHex;
  ...
}
```

### 2. Service: `GoogleCalendarService` (`lib/services/google_calendar_service.dart`)
- `signInWithGoogle()`: Menangani OAuth flow dan menyimpan access token.
- `fetchUpcomingEvents({int days = 14})`: Mengambil jadwal dari Google Calendar API.
- `createEvent(CalendarEventItem event)`: Mengirim HTTP POST ke `https://www.googleapis.com/calendar/v3/calendars/primary/events`.
- `updateEvent(CalendarEventItem event)`: Mengirim HTTP PATCH ke endpoint acara terkait.
- `deleteEvent(String eventId)`: Mengirim HTTP DELETE.

---

## 5. Rencana Tahapan Eksekusi (Ketika Siap Dikerjakan)

1. [ ] **Tahap 1 - Setup Google Cloud Console:**
   - Aktifkan Google Calendar API pada Google Cloud Project yang sudah ada.
   - Buat OAuth 2.0 Web Client ID dengan origin Vercel Anda.
2. [ ] **Tahap 2 - Service & State Management:**
   - Buat `GoogleCalendarService` dan integrasikan ke `DashboardState` (menyimpan token, state login, dan daftar jadwal).
3. [ ] **Tahap 3 - Widget Beranda:**
   - Buat widget agenda Hari H / H-1 dan countdown H-7 di `home_screen.dart` sesuai Apple HIG.
4. [ ] **Tahap 4 - Layar Kalender Penuh:**
   - Buat `calendar_screen.dart` dengan fitur lihat, tambah, dan edit jadwal.
   - Daftarkan menu "Kalender & Jadwal" ke `apple_drawer.dart`.

