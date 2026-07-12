# Panduan Pengguna — Mark-Up

Aplikasi **Mark-Up** adalah platform pembelajaran & mentoring: jelajahi produk
(modul, kelas, bootcamp), beli lewat pembayaran online, dan akses materinya.

## 1. Instalasi

1. Salin file `app-release.apk` ke perangkat Android.
2. Buka file → izinkan **Install from unknown sources** bila diminta.
3. Buka aplikasi **Mark-Up**.

> Backend harus aktif dan perangkat berada di jaringan yang sama (lihat README untuk konfigurasi `ApiConfig`).

## 2. Daftar & Masuk

- **Register:** buka *Create Account*, isi nama, email, password (min 8 karakter),
  dan konfirmasi password, centang *Terms of Service*, lalu **Create Account**.
  Form memvalidasi tiap kolom secara langsung (pesan merah di bawah input).
- **Login:** masukkan email & password terdaftar.
- **Google Sign-In** tersedia di Android/iOS.

## 3. Beranda (Dashboard)

Menampilkan ringkasan, menu cepat, produk unggulan, mentor, dan info lomba.
Bilah navigasi bawah memiliki 4 tab: **Beranda, Produk, Pembelajaran, Profil**.

## 4. Menjelajah & Membeli Produk

1. Buka tab **Produk**, pilih kategori (Modul/Kelas/Bootcamp).
2. Ketuk produk untuk melihat **detail** (deskripsi, harga, review).
3. Tekan **Tambah ke Keranjang**.
4. Buka **Keranjang** (ikon di pojok) → atur jumlah → **Checkout**.

## 5. Pembayaran

1. Setelah checkout, transaksi dibuat dengan status **Menunggu Pembayaran**.
2. Tekan **Bayar Sekarang** → halaman pembayaran **Midtrans** terbuka.
3. Pilih metode (QRIS, VA bank, e-wallet, dll) dan selesaikan pembayaran.
4. Kembali ke aplikasi, tekan **Cek Status Pembayaran**.
   - Jika berhasil, status berubah menjadi **Lunas** dan produk terbuka.

> Pembayaran ditangani oleh gateway Midtrans yang aman. Aplikasi tidak menyimpan data kartu/akun pembayaran.

## 6. Riwayat & Laporan Transaksi

- **Riwayat Transaksi** (dari Profil atau Beranda): daftar semua transaksi
  beserta status. Ketuk untuk melihat **Detail Transaksi**.
- **Laporan** (tombol di kanan atas Riwayat):
  - Filter berdasarkan **rentang tanggal** (ikon kalender).
  - Ringkasan: total nilai transaksi lunas, jumlah transaksi, jumlah menunggu, dan batal/gagal.
  - Rincian transaksi terfilter.

## 7. Pembelajaran

Tab **Pembelajaran** menampilkan produk yang sudah dibeli (Lunas). Ketuk untuk
membuka materi/konten.

## 8. Profil

- Lihat & **edit profil** (nama, institusi).
- Akses **Riwayat Transaksi**.
- **Panel Admin** muncul khusus untuk akun ber-role admin (kelola produk, mentor, lomba).
- **Keluar (Logout)**.

## 9. Pemecahan Masalah

| Masalah | Solusi |
|---|---|
| Tidak bisa login/daftar | Pastikan backend aktif & email/password benar; cek pesan error di bawah kolom |
| Status tetap "Menunggu" setelah bayar | Tekan **Cek Status Pembayaran** untuk sinkron manual |
| Gambar tidak muncul | Pastikan terhubung ke jaringan/host backend yang benar |
| Aplikasi tidak memuat data | Tarik untuk refresh (pull-to-refresh) atau cek koneksi |
