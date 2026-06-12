// ============================================
// FILE: lib/models/transaction_model.dart
// ============================================

import '../config/api_config.dart';
import 'cart_item_model.dart';

enum TransactionStatus { pending, paid, failed, cancelled }

extension TransactionStatusX on TransactionStatus {
  String get apiValue => name;

  String get label {
    switch (this) {
      case TransactionStatus.pending:
        return 'Menunggu Pembayaran';
      case TransactionStatus.paid:
        return 'Lunas';
      case TransactionStatus.failed:
        return 'Gagal';
      case TransactionStatus.cancelled:
        return 'Dibatalkan';
    }
  }

  static TransactionStatus fromString(String? raw) {
    final v = (raw ?? '').toLowerCase().trim();
    return TransactionStatus.values.firstWhere(
      (s) => s.name == v,
      orElse: () => TransactionStatus.pending,
    );
  }
}

enum PaymentMethod { transfer, eWallet, qris, cod }

extension PaymentMethodX on PaymentMethod {
  /// Nilai yang dikirim ke API (sesuai enum di backend).
  String get apiValue {
    switch (this) {
      case PaymentMethod.transfer:
        return 'transfer';
      case PaymentMethod.eWallet:
        return 'e_wallet';
      case PaymentMethod.qris:
        return 'qris';
      case PaymentMethod.cod:
        return 'cod';
    }
  }

  String get label {
    switch (this) {
      case PaymentMethod.transfer:
        return 'Transfer Bank';
      case PaymentMethod.eWallet:
        return 'E-Wallet';
      case PaymentMethod.qris:
        return 'QRIS';
      case PaymentMethod.cod:
        return 'Bayar di Tempat';
    }
  }

  static PaymentMethod fromString(String? raw) {
    final v = (raw ?? '').toLowerCase().trim();
    return PaymentMethod.values.firstWhere(
      (m) => m.apiValue == v,
      orElse: () => PaymentMethod.transfer,
    );
  }
}

class TransactionItemModel {
  final int id;
  final int? productId;
  final String productTitle;
  final String? productType;
  final String? productImageUrl;
  final int price;
  final int quantity;
  final int subtotal;

  const TransactionItemModel({
    required this.id,
    required this.productTitle,
    required this.price,
    required this.quantity,
    required this.subtotal,
    this.productId,
    this.productType,
    this.productImageUrl,
  });

  factory TransactionItemModel.fromJson(Map<String, dynamic> json) {
    return TransactionItemModel(
      id: _asInt(json['id']),
      productId: json['product_id'] == null ? null : _asInt(json['product_id']),
      productTitle: (json['product_title'] ?? '-').toString(),
      productType: json['product_type']?.toString(),
      productImageUrl:
          ApiConfig.resolveImageUrl(json['product_image_url']?.toString()),
      price: _asInt(json['price']),
      quantity: _asInt(json['quantity']),
      subtotal: _asInt(json['subtotal']),
    );
  }
}

class TransactionModel {
  final int id;
  final String code;
  final int totalAmount;
  final PaymentMethod paymentMethod;
  final TransactionStatus status;
  final DateTime? paidAt;
  final DateTime? createdAt;
  final int itemsCount;
  final List<TransactionItemModel> items;

  /// URL bukti bayar (sudah di-resolve ke host saat ini). Kosong jika belum diunggah.
  final String paymentProofUrl;

  const TransactionModel({
    required this.id,
    required this.code,
    required this.totalAmount,
    required this.paymentMethod,
    required this.status,
    required this.itemsCount,
    required this.items,
    this.paymentProofUrl = '',
    this.paidAt,
    this.createdAt,
  });

  bool get hasPaymentProof => paymentProofUrl.isNotEmpty;

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final items = rawItems is List
        ? rawItems
            .whereType<Map>()
            .map((e) =>
                TransactionItemModel.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : const <TransactionItemModel>[];

    return TransactionModel(
      id: _asInt(json['id']),
      code: (json['code'] ?? '').toString(),
      totalAmount: _asInt(json['total_amount']),
      paymentMethod: PaymentMethodX.fromString(json['payment_method']?.toString()),
      status: TransactionStatusX.fromString(json['status']?.toString()),
      paidAt: _asDate(json['paid_at']),
      createdAt: _asDate(json['created_at']),
      paymentProofUrl:
          ApiConfig.resolveImageUrl(json['payment_proof_url']?.toString()),
      itemsCount:
          json['items_count'] != null ? _asInt(json['items_count']) : items.length,
      items: items,
    );
  }

  String get formattedTotal => Cart.rupiah(totalAmount);
}

int _asInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is double) return v.toInt();
  return int.tryParse(v.toString().replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
}

DateTime? _asDate(dynamic v) {
  if (v == null) return null;
  return DateTime.tryParse(v.toString())?.toLocal();
}
