// ============================================
// FILE: lib/services/auth_service.dart
// ============================================

import 'package:dio/dio.dart';
import 'api_service.dart';

class AuthService {
  // ================= REGISTER =================
  Future<Map<String, dynamic>> register(
      String name, String email, String password, String passwordConfirmation) async {
    try {
      // Dio otomatis menggabungkan ApiConfig.baseUrl dengan '/register'
      final response = await ApiService.dio.post(
        '/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          // Laravel memvalidasi 'confirmed' → butuh field password_confirmation
          'password_confirmation': passwordConfirmation,
        },
      );

      // Status 201 artinya Created. Backend langsung mengirim token (auto-login).
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'token': response.data['access_token'],
          'user': response.data['user'],
        };
      }
      return {'success': false, 'message': 'Terjadi kesalahan tidak terduga'};
    } on DioException catch (e) {
      return {'success': false, 'message': _extractError(e, 'Gagal mendaftar')};
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server'};
    }
  }

  // Ambil pesan error dari respons Laravel. Untuk 422, ambil pesan validasi
  // pertama dari 'errors' bila ada, jika tidak pakai 'message'.
  String _extractError(DioException e, String fallback) {
    final data = e.response?.data;
    if (data is Map) {
      final errors = data['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final first = errors.values.first;
        if (first is List && first.isNotEmpty) return first.first.toString();
      }
      if (data['message'] != null) return data['message'].toString();
    }
    return fallback;
  }

  // ================= LOGIN =================
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await ApiService.dio.post(
        '/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'token': response.data['access_token'], // Token dari Laravel Sanctum
          'user': response.data['user'], // Data user (nama, email, role)
        };
      }
      return {'success': false, 'message': 'Login gagal'};
    } on DioException catch (e) {
      return {'success': false, 'message': _extractError(e, 'Email atau password salah')};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan jaringan'};
    }
  }

  // ================= LOGIN DENGAN GOOGLE =================
  // Kirim ID token Google ke backend; backend memverifikasi & menerbitkan
  // token Sanctum. Respons mengikuti bentuk yang sama dengan /login.
  Future<Map<String, dynamic>> loginWithGoogle(String idToken) async {
    try {
      final response = await ApiService.dio.post(
        '/auth/google',
        data: {'id_token': idToken},
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'token': response.data['access_token'],
          'user': response.data['user'],
        };
      }
      return {'success': false, 'message': 'Login Google gagal'};
    } on DioException catch (e) {
      return {'success': false, 'message': _extractError(e, 'Login Google gagal')};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan jaringan'};
    }
  }

  // ================= GET PROFILE =================
  // Ambil data user terbaru dari server (sinkronisasi nama/email/role).
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await ApiService.dio.get('/profile');
      if (response.statusCode == 200) {
        return {'success': true, 'user': response.data['user']};
      }
      return {'success': false, 'message': 'Gagal memuat profil'};
    } on DioException catch (e) {
      return {'success': false, 'message': _extractError(e, 'Gagal memuat profil')};
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server'};
    }
  }

  // ================= UPDATE PROFILE =================
  // Perbarui nama/email. Ganti password opsional: kirim currentPassword +
  // newPassword (beserta konfirmasi) hanya bila user ingin menggantinya.
  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String email,
    String? currentPassword,
    String? newPassword,
    String? newPasswordConfirmation,
  }) async {
    try {
      final data = <String, dynamic>{'name': name, 'email': email};
      if (newPassword != null && newPassword.isNotEmpty) {
        data['current_password'] = currentPassword;
        data['password'] = newPassword;
        data['password_confirmation'] = newPasswordConfirmation;
      }

      final response = await ApiService.dio.put('/profile', data: data);
      if (response.statusCode == 200) {
        return {'success': true, 'user': response.data['user']};
      }
      return {'success': false, 'message': 'Gagal memperbarui profil'};
    } on DioException catch (e) {
      return {'success': false, 'message': _extractError(e, 'Gagal memperbarui profil')};
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server'};
    }
  }

  // ================= LOGOUT =================
  Future<bool> logout() async {
    try {
      // Kita tidak perlu mengirim header Authorization manual di sini!
      // Interceptor dari api_service.dart otomatis menempelkan Token-nya.
      final response = await ApiService.dio.post('/logout');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
