// ============================================
// FILE: lib/viewmodels/transaction_viewmodel.dart
// ============================================

import 'package:flutter/foundation.dart';

import '../models/transaction_model.dart';
import '../services/transaction_service.dart';

enum TransactionListState { idle, loading, error }

/// Mengelola empat concern terkait transaksi:
/// 1. Riwayat (list) — di-load saat masuk halaman history.
/// 2. Detail satu transaksi — di-load saat masuk halaman detail.
/// 3. Proses checkout — dipanggil dari cart screen.
/// 4. Daftar product_id yang sudah dibeli — untuk badge "Sudah Dibeli".
class TransactionViewModel extends ChangeNotifier {
  // ─── History ───────────────────────────────────────────────────────────────

  List<TransactionModel> _history = [];
  TransactionListState _historyState = TransactionListState.idle;
  String? _historyError;

  // ─── Purchased product IDs ─────────────────────────────────────────────────

  Set<int> _purchasedIds = {};

  Set<int> get purchasedProductIds => _purchasedIds;

  bool hasPurchased(int productId) => _purchasedIds.contains(productId);

  Future<void> loadPurchasedIds() async {
    try {
      _purchasedIds = await TransactionService.fetchPurchasedProductIds();
      notifyListeners();
    } catch (_) {
      // Gagal silent — badge "sudah dibeli" tidak muncul, bukan error fatal.
    }
  }

  List<TransactionModel> get history => _history;
  TransactionListState get historyState => _historyState;
  String? get historyError => _historyError;
  bool get isHistoryLoading => _historyState == TransactionListState.loading;

  // ─── Produk yang dimiliki (untuk "Produk Saya") ─────────────────────────────

  List<TransactionItemModel> _ownedProducts = [];
  TransactionListState _ownedState = TransactionListState.idle;
  String? _ownedError;

  List<TransactionItemModel> get ownedProducts => _ownedProducts;
  TransactionListState get ownedState => _ownedState;
  String? get ownedError => _ownedError;
  bool get isOwnedLoading => _ownedState == TransactionListState.loading;

  /// Muat produk yang dimiliki dari endpoint khusus (/my-learning). Sumber
  /// kebenaran sendiri — tidak diturunkan dari riwayat yang dipaginasi.
  Future<void> loadOwnedProducts() async {
    _ownedState = TransactionListState.loading;
    _ownedError = null;
    notifyListeners();

    try {
      _ownedProducts = await TransactionService.fetchOwnedProducts();
      _ownedState = TransactionListState.idle;
    } catch (e) {
      _ownedError = e.toString();
      _ownedState = TransactionListState.error;
    }
    notifyListeners();
  }

  Future<void> loadHistory() async {
    _historyState = TransactionListState.loading;
    _historyError = null;
    notifyListeners();

    try {
      _history = await TransactionService.fetchHistory();
      _historyState = TransactionListState.idle;
      // Sekalian refresh purchased IDs supaya badge selalu sinkron.
      await loadPurchasedIds();
    } catch (e) {
      _historyError = e.toString();
      _historyState = TransactionListState.error;
    }
    notifyListeners();
  }

  Future<void> refreshHistory() => loadHistory();

  // ─── Detail ────────────────────────────────────────────────────────────────

  TransactionModel? _detail;
  bool _detailLoading = false;
  String? _detailError;

  TransactionModel? get detail => _detail;
  bool get isDetailLoading => _detailLoading;
  String? get detailError => _detailError;

  Future<void> loadDetail(int id) async {
    _detailLoading = true;
    _detailError = null;
    notifyListeners();

    try {
      _detail = await TransactionService.fetchById(id);
    } catch (e) {
      _detailError = e.toString();
    } finally {
      _detailLoading = false;
      notifyListeners();
    }
  }

  /// Tarik status terbaru dari Midtrans (Status API) lalu sinkronkan detail,
  /// history, dan purchasedIds. Dipakai tombol "Cek Status Pembayaran".
  /// Mengembalikan transaksi terbaru bila sukses, melempar bila gagal.
  Future<TransactionModel> syncStatus(int id) async {
    final trx = await TransactionService.syncStatus(id);
    _detail = trx;
    _history = _history.map((t) => t.id == trx.id ? trx : t).toList();
    // Kalau sudah lunas, refresh daftar produk yang terbuka (badge + Produk Saya).
    if (trx.status == TransactionStatus.paid) {
      await loadPurchasedIds();
      await loadOwnedProducts();
    }
    notifyListeners();
    return trx;
  }

  /// Set detail dari hasil checkout langsung — supaya halaman detail bisa
  /// menampilkan data tanpa request kedua.
  void setDetail(TransactionModel transaction) {
    _detail = transaction;
    _detailError = null;
    _detailLoading = false;
    notifyListeners();
  }

  void clearDetail() {
    _detail = null;
    _detailError = null;
    _detailLoading = false;
  }

  // ─── Checkout ──────────────────────────────────────────────────────────────

  bool _isCheckingOut = false;
  String? _checkoutError;

  bool get isCheckingOut => _isCheckingOut;
  String? get checkoutError => _checkoutError;

  /// Mengembalikan transaksi yang baru dibuat jika sukses, null jika gagal.
  /// Caller harus menampilkan feedback berdasarkan return value ini.
  Future<TransactionModel?> checkout(PaymentMethod method) async {
    _isCheckingOut = true;
    _checkoutError = null;
    notifyListeners();

    try {
      final trx = await TransactionService.checkout(method);
      // Prepend ke history supaya jika user buka halaman riwayat, transaksi
      // baru sudah ada di atas tanpa perlu refetch.
      _history = [trx, ..._history];
      _detail = trx;
      // CATATAN: transaksi mulai 'pending'. Produk BELUM terbuka di sini —
      // purchasedIds baru terisi setelah Midtrans mengonfirmasi 'paid'
      // (webhook/sync-status) dan user me-refresh (loadPurchasedIds).
      // Jangan grant optimistik.
      return trx;
    } catch (e) {
      _checkoutError = e.toString();
      return null;
    } finally {
      _isCheckingOut = false;
      notifyListeners();
    }
  }
}
