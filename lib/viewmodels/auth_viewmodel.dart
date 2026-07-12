// ============================================
// FILE: lib/viewmodels/auth_viewmodel.dart
// ============================================

import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/auth_service.dart';
import '../services/google_signin_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;
  String _role = 'user';
  String _name = '';
  String _email = '';

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAdmin => _role == 'admin';

  /// Sumber kebenaran data user untuk seluruh UI (mis. ProfileScreen).
  /// View cukup pakai Consumer<AuthViewModel> agar reaktif terhadap perubahan.
  String get name => _name;
  String get email => _email;
  String get role => _role;

  /// Muat data user (nama/email/role) dari storage lokal saat startup.
  Future<void> hydrate() async {
    _role = await StorageService.getUserRole();
    _name = await StorageService.getUserName() ?? '';
    _email = await StorageService.getUserEmail() ?? '';
    notifyListeners();
  }

  /// Tarik profil terbaru dari server dan sinkronkan ke storage + state.
  /// Gagal silent (mis. offline) — UI tetap pakai data lokal terakhir.
  Future<void> loadProfile() async {
    final result = await _authService.getProfile();
    if (result['success'] != true) return;

    final user = result['user'];
    if (user == null) return;
    _name  = (user['name'] ?? _name).toString();
    _email = (user['email'] ?? _email).toString();
    _role  = (user['role'] ?? _role).toString();
    await StorageService.saveUserInfo(_name, _email, role: _role);
    notifyListeners();
  }

  /// Perbarui profil ke server. Mengembalikan true bila sukses; saat gagal,
  /// pesan tersimpan di [errorMessage]. Ganti password bersifat opsional.
  Future<bool> updateProfile({
    required String name,
    required String email,
    String? currentPassword,
    String? newPassword,
    String? newPasswordConfirmation,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.updateProfile(
      name: name,
      email: email,
      currentPassword: currentPassword,
      newPassword: newPassword,
      newPasswordConfirmation: newPasswordConfirmation,
    );

    _isLoading = false;

    if (result['success'] == true) {
      final user = result['user'];
      _name  = (user?['name'] ?? name).toString();
      _email = (user?['email'] ?? email).toString();
      _role  = (user?['role'] ?? _role).toString();
      await StorageService.saveUserInfo(_name, _email, role: _role);
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      notifyListeners();
      return false;
    }
  }

  // ================= FUNGSI LOGIN (SUDAH KONEK API) =================
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // 1. Panggil API melalui AuthService
    var result = await _authService.login(email, password);

    _isLoading = false;

    if (result['success'] == true) {
      await _saveSession(result, fallbackEmail: email);
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      notifyListeners();
      return false;
    }
  }

  // ================= FUNGSI REGISTER (SUDAH KONEK API) =================
  Future<bool> register(
      String name, String email, String password, String passwordConfirmation) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    var result =
        await _authService.register(name, email, password, passwordConfirmation);

    _isLoading = false;

    if (result['success'] == true) {
      // Backend mengirim token saat register → langsung simpan sesi (auto-login)
      await _saveSession(result, fallbackEmail: email);
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      notifyListeners();
      return false;
    }
  }

  // ================= LOGIN DENGAN GOOGLE =================
  // Orkestrasi: flow native Google → kirim ID token ke backend → simpan sesi.
  // Mengembalikan true bila sukses. Jika user membatalkan pemilih akun,
  // mengembalikan false TANPA mengisi errorMessage (bukan kegagalan).
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    String? idToken;
    try {
      idToken = await GoogleSignInService.getIdToken();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Gagal masuk dengan Google';
      notifyListeners();
      return false;
    }

    // User membatalkan dialog → diam-diam berhenti.
    if (idToken == null) {
      _isLoading = false;
      notifyListeners();
      return false;
    }

    final result = await _authService.loginWithGoogle(idToken);
    _isLoading = false;

    if (result['success'] == true) {
      await _saveSession(result, fallbackEmail: '');
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      notifyListeners();
      return false;
    }
  }

  // Simpan token + info user dari respons login/register ke storage lokal.
  Future<void> _saveSession(Map<String, dynamic> result,
      {required String fallbackEmail}) async {
    await StorageService.saveToken(result['token']);

    final user = result['user'];
    _name = (user?['name'] ?? 'User Mark-Up').toString();
    _email = (user?['email'] ?? fallbackEmail).toString();
    _role = (user?['role'] ?? 'user').toString();
    await StorageService.saveUserInfo(_name, _email, role: _role);
  }

  // ================= FUNGSI LOGOUT (SUDAH KONEK API) =================
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    // 1. Beritahu Laravel untuk menghancurkan Token
    await _authService.logout();

    // 1b. Hapus sesi Google lokal agar login berikutnya memilih akun lagi
    await GoogleSignInService.signOut();

    // 2. Kosongkan brankas di HP
    await StorageService.clearAll();
    _role = 'user';
    _name = '';
    _email = '';

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> checkLoginStatus() async {
    return await StorageService.isLoggedIn();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
