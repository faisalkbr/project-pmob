// ============================================
// FILE: lib/services/storage_service.dart
// ============================================

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _tokenKey = 'auth_token';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  static const String _userRoleKey = 'user_role';

  // Token auth disimpan terenkripsi (Keychain di iOS, Keystore di Android),
  // bukan di SharedPreferences yang plaintext. Info user non-sensitif tetap
  // di SharedPreferences agar ringan.
  static const FlutterSecureStorage _secure = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // Save token setelah login
  static Future<void> saveToken(String token) async {
    await _secure.write(key: _tokenKey, value: token);
  }

  // Get token
  static Future<String?> getToken() async {
    return _secure.read(key: _tokenKey);
  }

  // Save user info (Tanpa university)
  static Future<void> saveUserInfo(String name, String email,
      {String role = 'user'}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
    await prefs.setString(_userEmailKey, email);
    await prefs.setString(_userRoleKey, role);
  }

  // Get user role ('user' | 'admin')
  static Future<String> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userRoleKey) ?? 'user';
  }

  // Get user name
  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  // Get user email
  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  // Check apakah sudah login
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Clear semua data (logout) — hapus token terenkripsi + info user.
  static Future<void> clearAll() async {
    await _secure.delete(key: _tokenKey);
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
