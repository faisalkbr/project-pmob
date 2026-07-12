// ============================================
// FILE: lib/services/admin_service.dart
// ============================================

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import 'api_service.dart';

/// Layanan CRUD khusus admin. Semua endpoint berada di bawah `/admin/*`
/// dan dijaga middleware `admin` di backend (role === 'admin').
///
/// Token otomatis dilampirkan oleh interceptor di [ApiService].
class AdminService {
  Dio get _dio => ApiService.dio;

  // ── Produk ────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> createProduct(Map<String, dynamic> data) =>
      _create('/admin/products', data);

  Future<Map<String, dynamic>> updateProduct(int id, Map<String, dynamic> data) =>
      _update('/admin/products/$id', data);

  Future<void> deleteProduct(int id) => _delete('/admin/products/$id');

  // ── Mentor ────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> createMentor(Map<String, dynamic> data) =>
      _create('/admin/mentors', data);

  Future<Map<String, dynamic>> updateMentor(int id, Map<String, dynamic> data) =>
      _update('/admin/mentors/$id', data);

  Future<void> deleteMentor(int id) => _delete('/admin/mentors/$id');

  // ── Lomba ─────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> createCompetition(Map<String, dynamic> data) =>
      _create('/admin/competitions', data);

  Future<Map<String, dynamic>> updateCompetition(
          int id, Map<String, dynamic> data) =>
      _update('/admin/competitions/$id', data);

  Future<void> deleteCompetition(int id) => _delete('/admin/competitions/$id');

  // ── List mentah (untuk layar admin; berisi semua field utk edit) ──────
  Future<List<Map<String, dynamic>>> listProducts() =>
      _list('/products', {'sort': 'terbaru'});

  Future<List<Map<String, dynamic>>> listMentors() =>
      _list('/mentors', {'limit': 100});

  Future<List<Map<String, dynamic>>> listCompetitions() =>
      _list('/competitions', {'per_page': 100});

  Future<List<Map<String, dynamic>>> _list(
      String path, Map<String, dynamic> query) async {
    try {
      final res = await _dio.get(path, queryParameters: query);
      return _extractList(res.data);
    } on DioException catch (e) {
      throw Exception(_readableError(e));
    }
  }

  List<Map<String, dynamic>> _extractList(dynamic body) {
    dynamic node = body;
    if (node is Map && node['data'] != null) node = node['data'];
    // Paginator Laravel: { data: { data: [...] } }
    if (node is Map && node['data'] is List) node = node['data'];
    if (node is List) {
      return node
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return <Map<String, dynamic>>[];
  }

  // ── Upload gambar ─────────────────────────────────────────────────────
  /// Unggah satu gambar, kembalikan path relatif (`/uploads/catalog/...`)
  /// untuk dipakai sebagai `image_url`/`avatar_url`.
  /// Terima [XFile] dari image_picker dan unggah via bytes agar kompatibel
  /// dengan Web (dart:io File/Platform tidak tersedia di web).
  Future<String> uploadImage(XFile file) async {
    try {
      final bytes = await file.readAsBytes();
      final name = file.name.isNotEmpty ? file.name : 'upload.jpg';
      final form = FormData.fromMap({
        'image': MultipartFile.fromBytes(bytes, filename: name),
      });
      final res = await _dio.post('/admin/uploads', data: form);
      return (res.data['url'] ?? '').toString();
    } on DioException catch (e) {
      throw Exception(_readableError(e));
    }
  }

  // ── Helpers internal ──────────────────────────────────────────────────
  Future<Map<String, dynamic>> _create(
      String path, Map<String, dynamic> data) async {
    try {
      final res = await _dio.post(path, data: data);
      return _extractData(res.data);
    } on DioException catch (e) {
      throw Exception(_readableError(e));
    }
  }

  Future<Map<String, dynamic>> _update(
      String path, Map<String, dynamic> data) async {
    try {
      final res = await _dio.patch(path, data: data);
      return _extractData(res.data);
    } on DioException catch (e) {
      throw Exception(_readableError(e));
    }
  }

  Future<void> _delete(String path) async {
    try {
      await _dio.delete(path);
    } on DioException catch (e) {
      throw Exception(_readableError(e));
    }
  }

  Map<String, dynamic> _extractData(dynamic body) {
    if (body is Map<String, dynamic> && body['data'] is Map) {
      return Map<String, dynamic>.from(body['data'] as Map);
    }
    if (body is Map<String, dynamic>) return body;
    return <String, dynamic>{};
  }

  String _readableError(DioException e) {
    if (kDebugMode) {
      debugPrint('[AdminService] ${e.requestOptions.method} '
          '${e.requestOptions.path} → ${e.response?.statusCode} ${e.response?.data}');
    }
    final status = e.response?.statusCode;
    final data = e.response?.data;

    // 422 — kumpulkan pesan validasi pertama agar jelas di UI.
    if (status == 422 && data is Map && data['errors'] is Map) {
      final errors = (data['errors'] as Map).values;
      if (errors.isNotEmpty && errors.first is List && (errors.first as List).isNotEmpty) {
        return (errors.first as List).first.toString();
      }
    }
    if (status == 403) return 'Akses ditolak — khusus admin.';
    if (data is Map && data['message'] is String) return data['message'];

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'Koneksi timeout, coba lagi.';
      case DioExceptionType.connectionError:
        return 'Tidak dapat terhubung ke server.';
      default:
        return 'Terjadi kesalahan. Coba lagi.';
    }
  }
}
