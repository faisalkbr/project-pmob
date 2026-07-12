// ============================================
// FILE: lib/services/transaction_service.dart
// ============================================

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/api_config.dart';
import '../models/transaction_model.dart';
import 'api_service.dart';

class TransactionService {
  static final _dio = ApiService.dio;

  /// POST /api/transactions — checkout dari isi cart user yang sedang login.
  static Future<TransactionModel> checkout(PaymentMethod method) async {
    try {
      final res = await _dio.post(
        ApiConfig.transactions,
        data: {'payment_method': method.apiValue},
      );
      if (kDebugMode) debugPrint('[TransactionService] checkout: ${res.data}');
      return TransactionModel.fromJson(_unwrapSingle(res.data));
    } on DioException catch (e) {
      throw _message(e);
    }
  }

  /// GET /api/transactions — riwayat transaksi user.
  static Future<List<TransactionModel>> fetchHistory() async {
    try {
      final res = await _dio.get(ApiConfig.transactions);
      if (kDebugMode) debugPrint('[TransactionService] fetchHistory: ${res.data}');
      return _unwrapList(res.data)
          .map((e) => TransactionModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      throw _message(e);
    }
  }

  /// POST /api/transactions/{id}/pay — generate ulang token Snap & ambil URL
  /// pembayaran Midtrans (dipakai untuk retry bayar dari halaman detail).
  static Future<String> getPaymentUrl(int id) async {
    try {
      final res = await _dio.post(ApiConfig.transactionPay(id));
      if (kDebugMode) debugPrint('[TransactionService] getPaymentUrl($id): ${res.data}');
      final data = _unwrapSingle(res.data);
      return (data['payment_url'] ?? '').toString();
    } on DioException catch (e) {
      throw _message(e);
    }
  }

  /// POST /api/transactions/{id}/sync-status — tarik status terbaru langsung
  /// dari Midtrans lalu update DB. Dipakai tombol "Cek Status Pembayaran"
  /// supaya status tidak bergantung webhook saja (fallback bila webhook meleset).
  static Future<TransactionModel> syncStatus(int id) async {
    try {
      final res = await _dio.post(ApiConfig.transactionSyncStatus(id));
      if (kDebugMode) debugPrint('[TransactionService] syncStatus($id): ${res.data}');
      return TransactionModel.fromJson(_unwrapSingle(res.data));
    } on DioException catch (e) {
      throw _message(e);
    }
  }

  /// GET /api/my-products — set product_id yang sudah dibeli user (status paid).
  static Future<Set<int>> fetchPurchasedProductIds() async {
    try {
      final res = await _dio.get(ApiConfig.myProducts);
      if (kDebugMode) debugPrint('[TransactionService] fetchPurchasedIds: ${res.data}');
      final raw = _asMap(res.data);
      final list = raw['data'];
      if (list is List) {
        return list.whereType<int>().toSet();
      }
      return const {};
    } on DioException catch (e) {
      throw _message(e);
    }
  }

  /// GET /api/my-learning — produk yang sudah dimiliki user (transaksi paid),
  /// lengkap dengan judul/tipe/gambar. Sumber kebenaran "Produk Saya" — tidak
  /// diturunkan dari riwayat (yang dipaginasi & tak memuat items di list).
  static Future<List<TransactionItemModel>> fetchOwnedProducts() async {
    try {
      final res = await _dio.get(ApiConfig.myLearning);
      if (kDebugMode) debugPrint('[TransactionService] fetchOwnedProducts: ${res.data}');
      return _unwrapList(res.data)
          .map((e) => TransactionItemModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      throw _message(e);
    }
  }

  /// GET /api/transactions/{id} — detail termasuk items.
  static Future<TransactionModel> fetchById(int id) async {
    try {
      final res = await _dio.get(ApiConfig.transactionById(id));
      if (kDebugMode) debugPrint('[TransactionService] fetchById($id): ${res.data}');
      return TransactionModel.fromJson(_unwrapSingle(res.data));
    } on DioException catch (e) {
      throw _message(e);
    }
  }

  // ===== helpers =====

  static Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return {};
  }

  static Map<String, dynamic> _unwrapSingle(dynamic data) {
    var m = _asMap(data);
    int guard = 0;
    while (m['data'] is Map && guard < 4) {
      m = Map<String, dynamic>.from(m['data'] as Map);
      guard++;
    }
    return m;
  }

  static List<Map> _unwrapList(dynamic data) {
    dynamic source = data;
    int guard = 0;
    while (source is Map && source['data'] != null && source['data'] is! List && guard < 4) {
      source = source['data'];
      guard++;
    }
    if (source is Map && source['data'] is List) {
      return (source['data'] as List).whereType<Map>().toList();
    }
    if (source is List) return source.whereType<Map>().toList();
    return const [];
  }

  static String _message(DioException e) {
    final body = e.response?.data;
    if (body is Map) {
      final msg = body['message'] ?? body['error'];
      if (msg != null) return msg.toString();
    }
    return e.message ?? 'Terjadi kesalahan jaringan';
  }
}
