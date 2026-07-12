// ============================================
// FILE: lib/models/product_model.dart
// ============================================

import '../config/api_config.dart';

/// Tipe produk Mark-Up. Modul/Kelas/Bootcamp masuk grid produk,
/// Mentoring punya section sendiri (lihat MentorModel).
enum ProductType { modul, kelas, bootcamp, mentoring }

extension ProductTypeX on ProductType {
  String get label {
    switch (this) {
      case ProductType.modul:
        return 'Modul';
      case ProductType.kelas:
        return 'Kelas';
      case ProductType.bootcamp:
        return 'Bootcamp';
      case ProductType.mentoring:
        return 'Mentoring';
    }
  }

  String get apiValue => name; // 'modul', 'kelas', 'bootcamp', 'mentoring'

  static ProductType fromString(String? raw) {
    final v = (raw ?? '').toLowerCase().trim();
    return ProductType.values.firstWhere(
      (t) => t.name == v || t.label.toLowerCase() == v,
      orElse: () => ProductType.modul,
    );
  }
}

class ProductModel {
  final int id;
  final ProductType type;
  final String title;
  final double rating;
  final int students;
  final int price;
  final int? originalPrice; // untuk tampilan "diskon" di featured card
  final String duration; // cth: "12 Jam"
  final bool isFeatured;
  final bool isBestseller;
  final String imageUrl;

  const ProductModel({
    required this.id,
    required this.type,
    required this.title,
    required this.rating,
    required this.students,
    required this.price,
    required this.duration,
    required this.isFeatured,
    required this.isBestseller,
    required this.imageUrl,
    this.originalPrice,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is double) return v.toInt();
      return int.tryParse(v.toString().replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    }

    double parseDouble(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0;
    }

    bool parseBool(dynamic v) {
      if (v == null) return false;
      if (v is bool) return v;
      final s = v.toString().toLowerCase();
      return s == 'true' || s == '1' || s == 'yes';
    }

    final origRaw = json['original_price'] ?? json['harga_asli'];
    final origPrice = origRaw == null ? null : parseInt(origRaw);

    return ProductModel(
      id: parseInt(json['id']),
      type: ProductTypeX.fromString(
          (json['type'] ?? json['tipe'] ?? json['kategori'] ?? 'modul')
              .toString()),
      title: (json['title'] ?? json['judul'] ?? json['nama'] ?? '-').toString(),
      rating: parseDouble(json['rating'] ?? json['rating_avg']),
      students: parseInt(json['students'] ?? json['jumlah_siswa'] ?? json['siswa']),
      price: parseInt(json['price'] ?? json['harga']),
      originalPrice:
          (origPrice != null && origPrice > 0) ? origPrice : null,
      duration: (json['duration'] ?? json['durasi'] ?? '').toString(),
      isFeatured: parseBool(json['is_featured'] ?? json['featured']),
      isBestseller: parseBool(json['is_bestseller'] ?? json['bestseller']),
      imageUrl:
          (json['image_url'] ?? json['image'] ?? json['gambar'] ?? '').toString(),
    );
  }

  // ===== Helpers presentasi =====

  /// "Rp 79K" untuk grid, "Rp 299.000" untuk featured.
  String get formattedPriceShort {
    if (price <= 0) return 'Gratis';
    if (price >= 1000) {
      final k = price / 1000;
      final s = k % 1 == 0 ? k.toInt().toString() : k.toStringAsFixed(0);
      return 'Rp ${s}K';
    }
    return 'Rp $price';
  }

  String get formattedPriceFull => price <= 0 ? 'Gratis' : _rupiah(price);
  String? get formattedOriginalPrice =>
      originalPrice == null ? null : _rupiah(originalPrice!);

  String get formattedRating => rating.toStringAsFixed(1);

  /// URL gambar siap pakai (relatif backend → full via media proxy).
  String get resolvedImage => ApiConfig.resolveImageUrl(imageUrl);

  String get formattedStudents =>
      students >= 1000 ? '${(students / 1000).toStringAsFixed(1)}k+' : '$students+';

  static String _rupiah(int value) {
    final s = value.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final remaining = s.length - i;
      buf.write(s[i]);
      if (remaining > 1 && remaining % 3 == 1) buf.write('.');
    }
    return 'Rp $buf';
  }
}

/// Wrapper pagination Laravel.
class PaginatedProducts {
  final List<ProductModel> data;
  final int currentPage;
  final int lastPage;
  final int total;

  const PaginatedProducts({
    required this.data,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  factory PaginatedProducts.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> source = json;
    int guard = 0;
    while (source['data'] is Map && guard < 4) {
      source = Map<String, dynamic>.from(source['data'] as Map);
      guard++;
    }

    final List rawList = source['data'] is List
        ? source['data'] as List
        : (json['data'] is List ? json['data'] as List : const []);

    final meta = source['meta'] is Map<String, dynamic>
        ? source['meta'] as Map<String, dynamic>
        : source;

    int asInt(dynamic v, {int fallback = 0}) {
      if (v is int) return v;
      if (v is double) return v.toInt();
      return int.tryParse('${v ?? ''}') ?? fallback;
    }

    return PaginatedProducts(
      data: rawList
          .whereType<Map>()
          .map((e) => ProductModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      currentPage: asInt(meta['current_page'], fallback: 1),
      lastPage: asInt(meta['last_page'], fallback: 1),
      total: asInt(meta['total'], fallback: rawList.length),
    );
  }
}
