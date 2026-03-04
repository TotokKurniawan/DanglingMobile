# Dangling Mobile App

## Catatan Pengembangan

Dokumen ini mencatat fitur-fitur yang **ditunda / di-skip** selama proses pengembangan sprint, beserta alasan, syarat, dan panduan cara melengkapinya di masa mendatang.

---

## ⏳ Fitur yang Ditunda (Technical Debt)

### 1. Firebase Cloud Messaging (FCM) — Push Notification
**Sprint:** 4  
**Status:** ⛔ Ditunda — menunggu `google-services.json`

**Alasan di-skip:**  
Integrasi FCM membutuhkan file konfigurasi `google-services.json` yang dihasilkan dari Firebase Console. File ini belum tersedia saat Sprint 4 dikerjakan.

**Cara Melanjutkan:**
1. Buat project di [Firebase Console](https://console.firebase.google.com/)
2. Tambahkan aplikasi Android dengan package name `com.example.damping` (sesuaikan jika berbeda)
3. Unduh file `google-services.json` → letakkan di `android/app/`
4. Tambahkan dependency ke `pubspec.yaml`:
   ```yaml
   firebase_core: ^3.x.x
   firebase_messaging: ^15.x.x
   ```
5. Inisialisasi Firebase di `lib/main.dart`:
   ```dart
   await Firebase.initializeApp();
   FirebaseMessaging messaging = FirebaseMessaging.instance;
   ```
6. Tambahkan handler untuk notifikasi masuk (foreground, background, terminated)
7. Sambungkan FCM token ke backend via `POST /api/device-token`

**File yang perlu dibuat/diubah:**
- `lib/features/notifications/services/fcm_service.dart` ← Buat baru
- `lib/main.dart` ← Tambahkan Firebase init
- `android/app/build.gradle` ← Tambahkan `google-services` plugin
- `android/build.gradle` ← Tambahkan classpath google-services

---

### 2. Switch UI Dashboard (Buyer Mode vs Seller Mode)
**Sprint:** 3  
**Status:** ⛔ Ditunda — perlu desain UX yang matang

**Alasan di-skip:**  
Switch mode antara tampilan Buyer dan Seller membutuhkan perubahan desain UX yang signifikan, termasuk pergantian Navigation Bar, konten Home Screen, dan kondisi state yang kompleks berbasis role.

**Cara Melanjutkan:**
1. Tambahkan state `_activeMode` (buyer/seller) di `Sharedprovider`
2. Modifikasi `Navigation` (bottom nav) untuk menampilkan tab berbeda berdasarkan mode aktif
3. HomeScreen buyer menampilkan peta pedagang; HomeScreen seller menampilkan Dashboard Toko
4. Tombol toggle mode di AppBar / Profile Screen

**Contoh implementasi state:**
```dart
// Di Sharedprovider
String _activeMode = 'buyer'; // 'buyer' | 'seller'
String get activeMode => _activeMode;

void toggleMode() {
  _activeMode = _activeMode == 'buyer' ? 'seller' : 'buyer';
  notifyListeners();
}
```

**File yang perlu diubah:**
- `lib/core/providers/sharedProvider.dart` ← Tambah `activeMode`
- `lib/core/routing/navigation.dart` ← Conditional navigation berdasarkan mode
- `lib/features/home/views/home/homescreen.dart` ← Render berbeda per mode

---

### 3. Payment Gateway (Midtrans / Xendit)
**Sprint:** Belum dijadwalkan  
**Status:** ⛔ Ditunda — memerlukan akun & integrasi eksternal

**Alasan di-skip:**  
Integrasi payment gateway (seperti Midtrans atau Xendit) memerlukan akun merchant, API key production/sandbox, dan backend handler untuk webhook pembayaran.

**Cara Melanjutkan:**
1. Daftar akun di [Midtrans](https://midtrans.com/) atau [Xendit](https://xendit.co/)
2. Backend Laravel perlu mengintegrasikan Midtrans SDK / Xendit API
3. Mobile app menggunakan `webview_flutter` untuk membuka halaman pembayaran Midtrans Snap
4. Tambahkan endpoint: `POST /api/payments/initiate` dan `POST /api/payments/callback`

**Dependency:**
```yaml
webview_flutter: ^4.x.x
```

---

## 🟢 Cara Menjalankan Laravel Reverb (WebSocket Server)

1. Pastikan `.env` backend berisi konfigurasi berikut:
```env
BROADCAST_CONNECTION=reverb

REVERB_APP_ID=dangling-app
REVERB_APP_KEY=dangling-reverb-key
REVERB_APP_SECRET=dangling-reverb-secret
REVERB_HOST=127.0.0.1
REVERB_PORT=8080
REVERB_SCHEME=http
```
2. Jalankan WebSocket server:
```bash
php artisan reverb:start
```
3. Untuk development, jalankan dua proses sekaligus:
```bash
# Terminal 1
php artisan serve
# Terminal 2
php artisan reverb:start
```
4. Di Flutter, sesuaikan `ApiEndpoints.reverbAppKey` dengan nilai `REVERB_APP_KEY` di `.env`.

---



## ✅ Referensi Backend Endpoints Tersedia

Endpoint-endpoint di bawah sudah tersedia di backend namun belum atau baru sebagian dihubungkan dari sisi mobile:

| Endpoint | Metode | Status Mobile |
|---|---|---|
| `POST /api/device-token` | Simpan FCM token | ❌ Belum |
| `DELETE /api/account` | Hapus akun | ✅ Selesai |
| `GET /api/notifications/unread-count` | Jumlah notif belum dibaca | ✅ Selesai |
| `POST /api/payments/initiate` | Inisiasi pembayaran gateway | ❌ Belum ada |
| `GET /api/chat` | Daftar percakapan | ✅ Selesai (WebSocket Reverb) |


