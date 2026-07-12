// ============================================
// FILE: lib/models/product_content_model.dart
// ============================================

// Model konten belajar dari `GET /products/{id}/content`.
//
// Bentuknya seragam untuk ketiga tipe produk (modul/kelas/bootcamp):
// produk → sections → items. `content_url` hanya terisi bila item terbuka
// (sudah dibeli atau `is_free`); selain itu `locked == true` dan url null.

class ProductContent {
  final int id;
  final String type; // modul | kelas | bootcamp
  final String title;
  final bool purchased;
  final List<ContentSection> sections;
  final List<ContentBatch> batches; // hanya bootcamp

  const ProductContent({
    required this.id,
    required this.type,
    required this.title,
    required this.purchased,
    required this.sections,
    this.batches = const [],
  });

  /// Total item lintas section.
  int get totalItems =>
      sections.fold(0, (sum, s) => sum + s.items.length);

  /// Jumlah item yang sudah terbuka (tidak terkunci).
  int get unlockedItems => sections.fold(
      0, (sum, s) => sum + s.items.where((i) => !i.locked).length);

  factory ProductContent.fromJson(Map<String, dynamic> json) {
    final rawSections = json['sections'];
    final rawBatches = json['batches'];
    return ProductContent(
      id: _asInt(json['id']),
      type: (json['type'] ?? 'modul').toString(),
      title: (json['title'] ?? '-').toString(),
      purchased: json['purchased'] == true,
      sections: rawSections is List
          ? rawSections
              .whereType<Map>()
              .map((e) => ContentSection.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
      batches: rawBatches is List
          ? rawBatches
              .whereType<Map>()
              .map((e) => ContentBatch.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
    );
  }
}

class ContentSection {
  final String title;
  final String? subtitle;
  final List<ContentItem> items;

  const ContentSection({
    required this.title,
    required this.items,
    this.subtitle,
  });

  factory ContentSection.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    return ContentSection(
      title: (json['title'] ?? '-').toString(),
      subtitle: json['subtitle']?.toString(),
      items: rawItems is List
          ? rawItems
              .whereType<Map>()
              .map((e) => ContentItem.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
    );
  }
}

enum ContentType { video, pdf, live }

ContentType _contentTypeFrom(String? raw) {
  switch ((raw ?? '').toLowerCase()) {
    case 'pdf':
      return ContentType.pdf;
    case 'live':
      return ContentType.live;
    case 'video':
    default:
      return ContentType.video;
  }
}

class ContentItem {
  final int id;
  final String title;
  final ContentType type;
  final String duration; // durasi video / range halaman / "Live"
  final bool isFree;
  final bool locked;
  final String? contentUrl; // null bila terkunci

  const ContentItem({
    required this.id,
    required this.title,
    required this.type,
    required this.duration,
    required this.isFree,
    required this.locked,
    this.contentUrl,
  });

  /// Bisa dibuka jika tidak terkunci dan punya URL.
  bool get isOpenable => !locked && (contentUrl ?? '').isNotEmpty;

  factory ContentItem.fromJson(Map<String, dynamic> json) {
    return ContentItem(
      id: _asInt(json['id']),
      title: (json['title'] ?? '-').toString(),
      type: _contentTypeFrom(json['type']?.toString()),
      duration: (json['duration'] ?? '').toString(),
      isFree: json['is_free'] == true,
      locked: json['locked'] == true,
      contentUrl: json['content_url']?.toString(),
    );
  }
}

class ContentBatch {
  final String label;
  final String dateRange;
  final int spots;
  final String status;

  const ContentBatch({
    required this.label,
    required this.dateRange,
    required this.spots,
    required this.status,
  });

  factory ContentBatch.fromJson(Map<String, dynamic> json) {
    return ContentBatch(
      label: (json['label'] ?? '-').toString(),
      dateRange: (json['date_range'] ?? '').toString(),
      spots: _asInt(json['spots']),
      status: (json['status'] ?? 'open').toString(),
    );
  }
}

int _asInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is double) return v.toInt();
  return int.tryParse(v.toString()) ?? 0;
}
