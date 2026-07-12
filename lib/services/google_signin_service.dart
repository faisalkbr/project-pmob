// ============================================
// FILE: lib/services/google_signin_service.dart
// ============================================

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../config/api_config.dart';

/// Wrapper tipis di atas SDK google_sign_in (v7). Mengisolasi pemanggilan
/// native agar viewmodel/UI tidak bergantung langsung ke package.
///
/// Alur best practice (ID token): app meminta ID token dari Google, lalu
/// mengirimnya ke backend untuk diverifikasi. App tidak pernah memercayai
/// data profil mentah dari device.
class GoogleSignInService {
  static final GoogleSignIn _signIn = GoogleSignIn.instance;
  static bool _initialized = false;

  /// Platform yang didukung alur `authenticate()` (ID token) di app ini.
  /// google_sign_in v7 belum mendukung web; desktop (Windows/Linux) juga tidak.
  /// Dipakai UI untuk menampilkan/menyembunyikan tombol Google.
  static bool get isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  /// Inisialisasi sekali (idempotent). serverClientId = Web client ID agar
  /// audience ID token cocok dengan yang diverifikasi backend.
  static Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await _signIn.initialize(
      serverClientId: ApiConfig.googleServerClientId,
    );
    _initialized = true;
  }

  /// Jalankan flow Google Sign-In native dan kembalikan ID token (JWT).
  /// Mengembalikan `null` bila user membatalkan. Melempar [GoogleSignInException]
  /// untuk error lain (mis. konfigurasi/ jaringan) agar caller bisa
  /// menampilkan pesan yang sesuai.
  static Future<String?> getIdToken() async {
    await _ensureInitialized();

    final GoogleSignInAccount account;
    try {
      account = await _signIn.authenticate(scopeHint: const ['email']);
    } on GoogleSignInException catch (e) {
      // User menutup dialog / membatalkan → bukan error sesungguhnya.
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      rethrow;
    }

    return account.authentication.idToken;
  }

  /// Hapus sesi Google lokal agar login berikutnya memunculkan pemilih akun.
  /// Aman dipanggil meski belum pernah login (di-swallow).
  static Future<void> signOut() async {
    try {
      await _ensureInitialized();
      await _signIn.signOut();
    } catch (_) {
      // Abaikan: kegagalan sign-out Google tidak boleh menggagalkan logout app.
    }
  }
}
