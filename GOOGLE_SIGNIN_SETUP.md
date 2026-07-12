# Setup Google Sign-In

Login & register dengan akun Google sudah diimplementasikan (alur **ID-token
verification**: app Flutter mengambil ID token Google → backend Laravel
memverifikasi & menerbitkan token Sanctum). Yang tersisa hanya mengisi kredensial
OAuth dari **Google Cloud Console** di tempat-tempat yang ditandai placeholder.

## 1. Buat kredensial di Google Cloud Console

1. Buka [Google Cloud Console](https://console.cloud.google.com/) → buat / pilih
   project → **APIs & Services → OAuth consent screen** (External, isi nama app &
   email). Tambahkan email penguji bila masih "Testing".
2. **APIs & Services → Credentials → Create Credentials → OAuth client ID**, buat
   **tiga** client:

   | Tipe client | Untuk apa | Dipakai di |
   |---|---|---|
   | **Web application** | audience ID token (server) | `GOOGLE_CLIENT_ID` (backend) **dan** `GOOGLE_SERVER_CLIENT_ID` (Flutter) |
   | **Android** | agar Android bisa menerbitkan ID token | hanya didaftarkan di Console (tak perlu file di app) |
   | **iOS** | login di iOS | `ios/Runner/Info.plist` |

   - **Android client** butuh *package name* `com.markup.app` dan *SHA-1*
     keystore. Ambil SHA-1:
     ```bash
     cd android && ./gradlew signingReport
     ```
     (atau `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android`)
   - **Satu SHA-1 per Android client.** Buat client Android terpisah (package
     sama `com.markup.app`) untuk tiap keystore: debug (dev), upload key (rilis),
     dan SHA-1 Play App Signing (bila ikut Play App Signing).
   - **PENTING:** semua client harus berada di **project yang sama**.

## 2. Tempel kredensial

### Backend (`C:\laragon\www\project-pweb\.env`)
```
GOOGLE_CLIENT_ID=<WEB_CLIENT_ID>.apps.googleusercontent.com
```
Lalu `php artisan config:clear`.

### Flutter — Web client ID
Pilih salah satu:
- Edit default di [lib/config/api_config.dart](lib/config/api_config.dart)
  (`googleServerClientId`), **atau**
- Jalankan dengan define (lebih aman, tidak ter-commit):
  ```bash
  flutter run --dart-define=GOOGLE_SERVER_CLIENT_ID=<WEB_CLIENT_ID>.apps.googleusercontent.com
  ```

### Flutter — iOS (opsional, hanya bila build iOS)
Isi dua placeholder di [ios/Runner/Info.plist](ios/Runner/Info.plist):
`GIDClientID` (= iOS client ID) dan URL scheme (= *reversed* iOS client ID).

> Android tidak butuh perubahan file — cukup daftarkan Android client (package +
> SHA-1) di Console. Web client ID tetap dipakai sebagai `serverClientId`.

## 3. Coba

```bash
flutter run --dart-define=GOOGLE_SERVER_CLIENT_ID=<WEB_CLIENT_ID>.apps.googleusercontent.com
```

Tombol **Continue with Google** muncul di layar Login & Register (disembunyikan di
Flutter Web karena `google_sign_in` v7 belum mendukung `authenticate()` di web).
Tap → pemilih akun Google → mendarat di Dashboard. Profil menampilkan nama/email
akun Google. Logout lalu login lagi akan memunculkan pemilih akun kembali.

### Tes endpoint backend langsung
```bash
curl -X POST http://localhost:8000/api/auth/google -d "id_token=<ID_TOKEN>"
```
ID token valid → `{ access_token, user }`. Token invalid → `422`.
