# Arsitektur Sistem — Mark-Up

Dokumen ini menjelaskan arsitektur aplikasi **Mark-Up** (platform pembelajaran & mentoring) dari sisi mobile sampai database.

## Gambaran Umum

```
┌─────────────────────┐      HTTPS / JSON      ┌──────────────────────┐        ┌─────────────┐
│   Flutter Mobile    │  ───────────────────▶  │   Laravel REST API   │  ────▶ │   MySQL     │
│  (Android / iOS)    │  ◀───────────────────  │  (Sanctum token)     │  ◀──── │  markup_db  │
└─────────────────────┘      Bearer token      └──────────────────────┘        └─────────────┘
        │                                                  ▲
        │                                                  │ webhook (server-to-server)
        ▼                                                  │
   Midtrans Snap  ───────────────────────────────────────┘
   (popup / redirect)
```

Backend yang sama juga melayani **web (Blade)** — satu sumber kebenaran untuk produk, transaksi, dan pembayaran.

## Lapisan Aplikasi Mobile (Flutter)

Pola: **MVVM + Provider** untuk state management, **Dio** untuk HTTP.

```
lib/
├── config/        # endpoint API, route, tema
├── models/        # DTO (TransactionModel, ProductModel, ...)
├── services/      # lapisan data: pemanggilan API & storage lokal
├── viewmodels/    # ChangeNotifier (logika bisnis & state)
├── views/         # layar (satu file per layar)
├── widgets/       # komponen UI bersama
├── app.dart       # MultiProvider + MaterialApp
└── main.dart      # entry point
```

**Alur request:**
```
View → ViewModel (ChangeNotifier) → Service → ApiService (Dio) → /api/... → Laravel → MySQL
```

- **ApiService** — klien Dio tunggal; interceptor menyuntik `Authorization: Bearer {token}` dari storage pada tiap request, dan menangani `401` dengan menghapus token + redirect ke login.
- **StorageService** — pembungkus `SharedPreferences` untuk token & info user.
- **ViewModel** memanggil `notifyListeners()` saat state berubah; View memakai `Consumer`/`context.watch`.

## Lapisan Backend (Laravel)

- **Autentikasi:** Laravel Sanctum (token) untuk mobile; session untuk web.
- **Resource:** `JsonResource` (mis. `TransactionResource`) memformat output API.
- **Pembayaran:** `MidtransService` memusatkan integrasi Snap (buat token, verifikasi signature webhook, sinkronisasi status). Lihat [API_DOCUMENTATION.md](API_DOCUMENTATION.md).

## Model Data Inti

| Tabel | Keterangan |
|---|---|
| `users` | Akun (username, first_name, last_name, email, role: admin/mentor/user) |
| `products` | Produk: modul, kelas, bootcamp (title, type, price, image_url) |
| `cart_items` | Keranjang per user |
| `transactions` | Header transaksi (code, total_amount, payment_method, status, snap_token) |
| `transaction_items` | Snapshot produk per transaksi (judul, harga, qty, subtotal) |
| `mentors`, `competitions`, `reviews`, `milestones` | Data pendukung |

**Status transaksi:** `pending → paid` (atau `failed`/`cancelled`). Akses produk digate `status = 'paid'`.

## Alur Pembayaran (Midtrans Snap)

1. User checkout → backend membuat `transaction` (`pending`) + `transaction_items`.
2. Backend memanggil Midtrans Snap → `snap_token` + `payment_url`.
3. Mobile membuka `payment_url`; web memakai `snap.js`.
4. User membayar → Midtrans mengirim **webhook** ke `POST /api/midtrans/notification` (diverifikasi signature) → status `paid`.
5. Fallback: tombol **Cek Status Pembayaran** menarik status langsung via `POST /api/transactions/{id}/sync-status` (Status API) bila webhook meleset.

## Teknologi

| Bagian | Teknologi |
|---|---|
| Mobile | Flutter, Provider, Dio, google_fonts, url_launcher |
| Backend | Laravel 12, Sanctum, midtrans-php |
| Database | MySQL (`markup_db`) |
| Pembayaran | Midtrans Snap (Sandbox) |
