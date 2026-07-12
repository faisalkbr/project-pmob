# Dokumentasi API — Mark-Up

Base URL (dev): `http://<host>:8000/api`
(Mobile memilih host otomatis: emulator Android `10.0.2.2`, web/desktop `localhost`.)

**Autentikasi:** sebagian besar endpoint butuh header
`Authorization: Bearer {access_token}` (token diperoleh dari login/register).
Format respons: JSON. Error non-2xx mengembalikan `{ "message": "..." }`.

---

## Autentikasi

### POST `/register`
Buat akun baru dan langsung menerbitkan token (auto-login).

Request:
```json
{ "name": "Budi Santoso", "email": "budi@mail.com", "password": "rahasia123", "password_confirmation": "rahasia123" }
```
Response `201`:
```json
{
  "message": "Registrasi Berhasil",
  "access_token": "12|abcdef...",
  "token_type": "Bearer",
  "user": { "id": 5, "name": "Budi Santoso", "email": "budi@mail.com", "role": "user" }
}
```

### POST `/login`
Request: `{ "email": "budi@mail.com", "password": "rahasia123" }`
Response `200`: sama seperti register (berisi `access_token` + `user`).
Error `422`: `{ "message": "Email atau Password salah" }`

### POST `/auth/google`
Request: `{ "id_token": "<google-id-token>" }` → Response `200` berisi `access_token` + `user`.

### POST `/logout`  *(auth)*
Menghapus token request saat ini. Response `200`.

---

## Profil

| Method | Endpoint | Keterangan |
|---|---|---|
| GET | `/profile` | Data user yang login |
| PUT | `/profile` | Update profil (name, institution, dll) |

---

## Produk & Konten

| Method | Endpoint | Auth | Keterangan |
|---|---|---|---|
| GET | `/products` | ✔ | Daftar produk (modul/kelas/bootcamp) |
| GET | `/products/{id}` | ✔ | Detail produk |
| GET | `/products/{id}/content` | ✔ | Konten produk (hanya jika sudah `paid`) |
| GET | `/products/{id}/reviews` | publik | Daftar review |
| POST | `/products/{id}/reviews` | ✔ | Tambah review `{ rating, comment }` |
| DELETE | `/reviews/{id}` | ✔ | Hapus review milik sendiri |

Contoh item produk:
```json
{ "id": 1, "title": "Bootcamp Bisnis", "type": "bootcamp", "price": 299000, "image_url": "http://.../api/media/img/x.png" }
```

---

## Mentor & Lomba

| Method | Endpoint | Keterangan |
|---|---|---|
| GET | `/mentors`, `/mentors/{id}` | Daftar / detail mentor |
| GET | `/competitions`, `/competitions/{id}` | Daftar / detail lomba (publik) |

---

## Keranjang

| Method | Endpoint | Body |
|---|---|---|
| GET | `/cart` | — |
| POST | `/cart` | `{ "product_id": 1, "quantity": 1 }` |
| PUT | `/cart/{id}` | `{ "quantity": 2 }` |
| DELETE | `/cart/{id}` | — |
| DELETE | `/cart/clear` | Kosongkan keranjang |

---

## Transaksi & Pembayaran

### POST `/transactions`  *(auth)*
Checkout isi keranjang → membuat transaksi `pending` + token Snap.

Request: `{ "payment_method": "qris" }`
Response `201`:
```json
{
  "data": {
    "id": 12, "code": "TRX-ABCD1234", "total_amount": 299000,
    "payment_method": "qris", "status": "pending",
    "snap_token": "xxxx", "payment_url": "https://app.sandbox.midtrans.com/snap/v4/redirection/xxxx",
    "items": [ { "product_title": "Bootcamp Bisnis", "price": 299000, "quantity": 1, "subtotal": 299000 } ]
  }
}
```

### GET `/transactions`  *(auth)*
Riwayat transaksi user (paginated), terbaru di atas.

### GET `/transactions/{id}`  *(auth)*
Detail transaksi termasuk `items`.

### POST `/transactions/{id}/pay`  *(auth)*
Ambil/reuse token Snap untuk melanjutkan pembayaran transaksi `pending`.
Response: `{ "data": { "snap_token": "...", "payment_url": "..." } }`

### POST `/transactions/{id}/sync-status`  *(auth)*
Tarik status terbaru dari Midtrans (Status API) lalu update DB. Mengembalikan
`TransactionResource` terbaru. Dipakai tombol **Cek Status Pembayaran**.

### POST `/midtrans/notification`  *(publik, server-to-server)*
Webhook Midtrans. Diamankan verifikasi `signature_key` (SHA-512). Memetakan
`transaction_status` Midtrans → status internal:

| Midtrans | Internal |
|---|---|
| `capture`/`settlement` | `paid` |
| `pending` | `pending` |
| `deny` | `failed` |
| `expire`/`cancel` | `cancelled` |

---

## Produk Milik User

| Method | Endpoint | Keterangan |
|---|---|---|
| GET | `/my-products` | Array `product_id` yang sudah dibeli (status `paid`) |
| GET | `/my-learning` | Produk lengkap yang sudah dibeli |

---

## Admin  *(role = admin)*

Prefix `/admin`, butuh token admin.

| Method | Endpoint |
|---|---|
| POST/PUT/DELETE | `/admin/products`, `/admin/products/{id}` |
| POST/PUT/DELETE | `/admin/mentors`, `/admin/mentors/{id}` |
| POST/PUT/DELETE | `/admin/competitions`, `/admin/competitions/{id}` |
| POST | `/admin/uploads` (upload gambar) |

---

## Media

`GET /media/{path}` — menyajikan file dari `public/` lewat Laravel (agar dapat header CORS untuk Flutter Web).
