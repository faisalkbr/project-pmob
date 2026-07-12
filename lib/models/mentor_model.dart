// ============================================
// FILE: lib/models/mentor_model.dart
// ============================================

import 'package:flutter/material.dart';

import '../config/api_config.dart';

/// Model kaya untuk On-Demand Mentoring section di ProductScreen.
class MentorModel {
  final int id;
  final String name;
  final String title; // cth: "Case Competition Champion · 3× Juara Nasional"
  final double rating;
  final int sessions;
  final bool available;
  final int pricePerSession;
  final List<String> tags;
  final String? avatarUrl;

  const MentorModel({
    required this.id,
    required this.name,
    required this.title,
    required this.rating,
    required this.sessions,
    required this.available,
    required this.pricePerSession,
    required this.tags,
    this.avatarUrl,
  });

  factory MentorModel.fromJson(Map<String, dynamic> json) {
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
      return s == 'true' || s == '1' || s == 'yes' || s == 'tersedia';
    }

    final rawTags = json['tags'] ?? json['keahlian'] ?? json['spesialisasi'];
    List<String> tags = [];
    if (rawTags is List) {
      tags = rawTags.map((e) => e.toString()).toList();
    } else if (rawTags is String && rawTags.isNotEmpty) {
      tags = rawTags.split(',').map((e) => e.trim()).toList();
    }

    return MentorModel(
      id: parseInt(json['id']),
      name: (json['name'] ?? json['nama'] ?? '-').toString(),
      title: (json['title'] ??
              json['jabatan'] ??
              json['spesialisasi'] ??
              '')
          .toString(),
      rating: parseDouble(json['rating']),
      sessions: parseInt(json['sessions'] ?? json['jumlah_sesi']),
      available: parseBool(
          json['available'] ?? json['status_aktif'] ?? json['is_available']),
      pricePerSession: parseInt(
          json['price_per_session'] ?? json['harga_sesi'] ?? json['harga']),
      tags: tags,
      avatarUrl:
          (json['avatar_url'] ?? json['avatar'] ?? json['foto'])?.toString(),
    );
  }

  // ===== Helpers presentasi =====

  /// 2 huruf inisial dari nama, e.g. "Rizka Nabilah" → "RN".
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts[1].substring(0, 1))
        .toUpperCase();
  }

  /// Warna gradien deterministik berdasar id, biar konsisten antar render.
  List<Color> get avatarGradient {
    const palettes = <List<Color>>[
      [Color(0xFFA600B2), Color(0xFF6B0075)],
      [Color(0xFF001261), Color(0xFF002196)],
      [Color(0xFF002196), Color(0xFF1D4ED8)],
      [Color(0xFFA600B2), Color(0xFF002196)],
    ];
    return palettes[id.abs() % palettes.length];
  }

  String get formattedPrice {
    if (pricePerSession >= 1000) {
      final k = pricePerSession / 1000;
      final s = k % 1 == 0 ? k.toInt().toString() : k.toStringAsFixed(0);
      return 'Rp ${s}K';
    }
    return 'Rp $pricePerSession';
  }

  String get formattedRating => rating.toStringAsFixed(1);

  /// URL avatar siap pakai (relatif backend → full via media proxy).
  /// Kosong jika tidak ada avatar.
  String get resolvedAvatar => ApiConfig.resolveImageUrl(avatarUrl);
}
