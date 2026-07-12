// ============================================
// FILE: lib/config/api_config.dart
// ============================================

import 'package:flutter/foundation.dart';

class ApiConfig {
  // Host backend dipilih otomatis sesuai platform tempat app dijalankan.
  // Untuk Android, host bisa di-override saat run TANPA edit file ini:
  //   --dart-define=API_HOST=127.0.0.1    → HP fisik via USB + `adb reverse`
  //   --dart-define=API_HOST=192.168.x.x  → HP fisik satu Wi-Fi (IP LAN laptop)
  // Default 10.0.2.2 = alias localhost host untuk emulator Android.
  static const String _port = '8000';

  static const String _androidHost =
      String.fromEnvironment('API_HOST', defaultValue: '10.0.2.2');

  // Domain backend produksi yang sudah di-deploy di cPanel (lengkap + /api).
  // Dipakai OTOMATIS pada build rilis (kReleaseMode) sehingga tim cukup
  // menjalankan `flutter build apk --release` tanpa perlu mengingat string
  // --dart-define yang panjang. Tetap bisa di-override (lihat _prodBaseUrl).
  static const String _defaultProdBaseUrl = 'https://markup.si-project.my.id/api';

  // Override eksplisit URL backend (lengkap dengan skema + /api). Saat di-set,
  // nilai ini MENGALAHKAN baik default produksi maupun logika per-platform —
  // berguna untuk menunjuk ke staging atau server dev dari build apa pun:
  //   flutter build apk --release \
  //     --dart-define=API_BASE_URL=https://staging.markup.test/api
  static const String _prodBaseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: '');

  static String get baseUrl {
    // 1. Override eksplisit via --dart-define selalu menang.
    if (_prodBaseUrl.isNotEmpty) return _prodBaseUrl;
    // 2. Build rilis -> domain produksi cPanel.
    if (kReleaseMode) return _defaultProdBaseUrl;
    // 3. Debug/profile -> resolusi per-platform untuk development lokal.
    if (kIsWeb) return 'http://localhost:$_port/api';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://$_androidHost:$_port/api';
    }
    // iOS simulator, Windows, macOS, Linux desktop
    return 'http://localhost:$_port/api';
  }

  // Web client ID dari Google Cloud Console (tipe "Web application"), dipakai
  // sebagai serverClientId saat Google Sign-In agar ID token punya audience
  // yang sama dengan yang diverifikasi backend (config services.google.client_id).
  // Override saat run/build dengan --dart-define=GOOGLE_SERVER_CLIENT_ID=...
  static const String googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue: '531667844552-vnp8k5pimlla0d61pmqqvucinp9emhk9.apps.googleusercontent.com',
  );

  // Endpoints (akan dipakai di minggu-minggu berikutnya)
  static const String login = '/login';
  static const String register = '/register';
  static const String googleAuth = '/auth/google';
  static const String logout = '/logout';
  static const String profile = '/profile';
  static const String packages = '/packages';
  static const String modules = '/modules';
  static const String videos = '/videos';
  static const String mentors = '/mentors';
  static const String competitions = '/competitions';
  // Endpoint baru untuk halaman Produk (Modul, Kelas, Bootcamp)
  static const String products = '/products';
  static const String cart = '/cart';
  static const String transactions = '/transactions';
  static const String myProducts = '/my-products';
  static const String myLearning = '/my-learning';

  static String productContent(int productId) => '/products/$productId/content';
  static String productReviews(int productId) => '/products/$productId/reviews';
  static String reviewById(int reviewId) => '/reviews/$reviewId';
  static String transactionById(int id) => '/transactions/$id';
  static String transactionPay(int id) => '/transactions/$id/pay';
  static String transactionSyncStatus(int id) => '/transactions/$id/sync-status';

  // ===== Resolusi URL gambar (lintas platform) =====

  /// Origin backend (scheme://host:port) tanpa segmen `/api`.
  /// Contoh: 'http://10.0.2.2:8000'.
  static String get _origin => baseUrl.replaceFirst(RegExp(r'/api/?$'), '');

  /// Ubah URL gambar dari API menjadi URL yang bisa diakses dari platform
  /// saat ini. Database sering menyimpan host absolut yang basi
  /// (mis. IP laptop lama) sehingga gambar putus saat pindah platform.
  ///
  /// Gambar yang dihosting backend disajikan lewat endpoint `/api/media/...`
  /// (bukan file statis) supaya dapat header CORS — wajib untuk Flutter Web.
  /// Di mobile/desktop endpoint ini tetap mengembalikan file yang sama.
  ///
  /// Aturan:
  /// - kosong               -> '' (caller menampilkan placeholder)
  /// - path relatif         -> /api/media + path  ('/img/x.png')
  /// - host lokal/privat    -> ambil path-nya, lewatkan /api/media
  ///   (localhost, 127.0.0.1, 10.x, 172.16-31.x, 192.168.x, 10.0.2.2)
  /// - URL eksternal publik -> dibiarkan apa adanya (mis. CDN)
  static String resolveImageUrl(String? raw) {
    final url = (raw ?? '').trim();
    if (url.isEmpty) return '';

    final uri = Uri.tryParse(url);

    // Tidak ada scheme -> anggap path relatif terhadap backend.
    if (uri == null || !uri.hasScheme) {
      return _mediaUrl(url);
    }

    // URL absolut yang menunjuk ke host backend dev -> proxy lewat /api/media.
    if (_isLocalHost(uri.host)) {
      return _mediaUrl(uri.path);
    }

    // URL eksternal publik (https://cdn..., dsb) -> pakai apa adanya.
    return url;
  }

  /// Bungkus path file publik ('/img/x.png') menjadi URL endpoint media
  /// pada host platform saat ini: '$origin/api/media/img/x.png'.
  static String _mediaUrl(String path) {
    final clean = path.startsWith('/') ? path.substring(1) : path;
    return '$_origin/api/media/$clean';
  }

  static bool _isLocalHost(String host) {
    if (host == 'localhost' || host == '127.0.0.1' || host == '10.0.2.2') {
      return true;
    }
    if (host.startsWith('192.168.') || host.startsWith('10.')) return true;
    // Rentang privat 172.16.0.0 – 172.31.255.255
    final m = RegExp(r'^172\.(\d{1,3})\.').firstMatch(host);
    if (m != null) {
      final second = int.tryParse(m.group(1)!) ?? 0;
      return second >= 16 && second <= 31;
    }
    return false;
  }
}
