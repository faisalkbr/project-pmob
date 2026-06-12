// ============================================
// FILE: lib/models/competition_model.dart
// ============================================

import '../config/api_config.dart';

/// Model utama untuk entity Lomba dari Laravel API.
class CompetitionModel {
  final int id;
  final String title;
  final String category; // cth: "BUSINESS CASE"
  final DateTime? startDate;
  final DateTime? endDate;
  final String eligibility; // cth: "Mahasiswa (D3/D4/S1)"
  final int registrationFee; // 0 = Gratis
  final String? registrationFeeLabel; // cth: "Rp 150.000 / Tim", opsional dari API
  final int prize;
  final String imageUrl;
  final String registrationLink; // URL eksternal ke halaman pendaftaran lomba

  const CompetitionModel({
    required this.id,
    required this.title,
    required this.category,
    required this.startDate,
    required this.endDate,
    required this.eligibility,
    required this.registrationFee,
    required this.prize,
    required this.imageUrl,
    required this.registrationLink,
    this.registrationFeeLabel,
  });

  bool get hasRegistrationLink => registrationLink.trim().isNotEmpty;

  factory CompetitionModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return v;
      return DateTime.tryParse(v.toString());
    }

    int parseInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is double) return v.toInt();
      return int.tryParse(v.toString().replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    }

    return CompetitionModel(
      id: parseInt(json['id']),
      title: (json['title'] ?? json['nama'] ?? '-').toString(),
      category: (json['category'] ?? json['kategori'] ?? 'UMUM').toString(),
      startDate: parseDate(json['start_date'] ?? json['tanggal_mulai']),
      endDate: parseDate(json['end_date'] ?? json['tanggal_selesai']),
      eligibility:
          (json['eligibility'] ?? json['peserta'] ?? 'Umum').toString(),
      registrationFee: parseInt(json['registration_fee'] ?? json['biaya']),
      registrationFeeLabel: json['registration_fee_label']?.toString(),
      prize: parseInt(json['prize'] ?? json['hadiah']),
      // Resolusi terhadap host backend saat ini agar gambar tetap muncul
      // walau DB menyimpan host absolut yang basi / saat pindah platform.
      imageUrl: ApiConfig.resolveImageUrl(
          (json['image_url'] ?? json['image'] ?? json['gambar'] ?? '').toString()),
      registrationLink: (json['link_pendaftaran'] ??
              json['registration_link'] ??
              json['link'] ??
              '')
          .toString(),
    );
  }

  // ===== Helpers presentasi =====

  String get formattedDateRange {
    if (startDate != null && endDate != null) {
      return '${_formatDate(startDate!)} - ${_formatDate(endDate!)}';
    }
    if (startDate != null) return _formatDate(startDate!);
    if (endDate != null) return _formatDate(endDate!);
    return 'Tanggal belum ditentukan';
  }

  String get formattedRegistrationFee {
    if (registrationFeeLabel != null && registrationFeeLabel!.isNotEmpty) {
      return registrationFeeLabel!;
    }
    if (registrationFee <= 0) return 'Gratis';
    return _rupiah(registrationFee);
  }

  String get formattedPrize => _rupiah(prize);

  // ===== Formatter manual (tanpa dependency `intl`) =====

  static const List<String> _monthsId = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  static String _formatDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mmm = _monthsId[d.month - 1];
    return '$dd $mmm ${d.year}';
  }

  static String _rupiah(int value) {
    final s = value.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final remaining = s.length - i;
      buf.write(s[i]);
      if (remaining > 1 && remaining % 3 == 1) buf.write('.');
    }
    return 'Rp ${buf.toString()}';
  }
}

/// Wrapper untuk respons pagination Laravel (baik default paginator
/// maupun ApiResource dengan meta/links).
class PaginatedCompetitions {
  final List<CompetitionModel> data;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  const PaginatedCompetitions({
    required this.data,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory PaginatedCompetitions.fromJson(Map<String, dynamic> json) {
    // Unwrap nested `data` sampai ketemu List (menangani response Laravel yang
    // sering dibungkus: { status, message, data: { current_page, data: [...] } }
    // atau { success, data: { data: [...], meta: {...} } }).
    Map<String, dynamic> source = json;
    int guard = 0;
    while (source['data'] is Map && guard < 4) {
      source = Map<String, dynamic>.from(source['data'] as Map);
      guard++;
    }

    // Ambil list item. Fallback: kalau tidak ketemu, coba `items` / `results`.
    List rawList = const [];
    if (source['data'] is List) {
      rawList = source['data'] as List;
    } else if (source['items'] is List) {
      rawList = source['items'] as List;
    } else if (source['results'] is List) {
      rawList = source['results'] as List;
    } else if (json['data'] is List) {
      rawList = json['data'] as List;
    }

    // Meta pagination bisa di `meta` atau langsung flat di source.
    final meta = source['meta'] is Map<String, dynamic>
        ? source['meta'] as Map<String, dynamic>
        : source;

    return PaginatedCompetitions(
      data: rawList
          .whereType<Map>()
          .map((e) => CompetitionModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      currentPage: _asInt(meta['current_page'], fallback: 1),
      lastPage: _asInt(meta['last_page'], fallback: 1),
      perPage: _asInt(meta['per_page'], fallback: rawList.length),
      total: _asInt(meta['total'], fallback: rawList.length),
    );
  }

  static int _asInt(dynamic v, {int fallback = 0}) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse('${v ?? ''}') ?? fallback;
  }
}

// ============================================
// Legacy model — dipakai DashboardViewModel untuk dummy data.
// Dibiarkan agar dashboard existing tidak perlu diubah.
// ============================================
class Competition {
  final String title;
  final String month;
  final String date;
  final String category;
  final String prizeInfo;
  final String imageUrl;

  Competition({
    required this.title,
    required this.month,
    required this.date,
    required this.category,
    required this.prizeInfo,
    required this.imageUrl,
  });
}
