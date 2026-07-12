// ============================================
// FILE: lib/views/product_screen/detail_data_helpers.dart
// ============================================

import 'package:flutter/material.dart';

/// Helper bersama untuk layar detail produk (Modul / Kelas / Bootcamp)
/// yang merender data dari API.

/// Petakan nama ikon dari backend ('file','book','video','live',...) ke IconData.
IconData detailIconFor(String? name) {
  switch ((name ?? '').toLowerCase()) {
    case 'file':
    case 'pdf':
      return Icons.description_rounded;
    case 'book':
      return Icons.menu_book_rounded;
    case 'video':
    case 'play':
      return Icons.play_circle_fill_rounded;
    case 'live':
      return Icons.podcasts_rounded;
    case 'down':
    case 'download':
      return Icons.download_rounded;
    case 'check':
    case 'verified':
      return Icons.verified_rounded;
    case 'trophy':
      return Icons.emoji_events_rounded;
    case 'users':
      return Icons.groups_rounded;
    case 'clock':
      return Icons.schedule_rounded;
    case 'cal':
      return Icons.calendar_today_rounded;
    case 'bolt':
      return Icons.bolt_rounded;
    default:
      return Icons.check_circle_rounded;
  }
}

/// 2 huruf inisial dari nama, e.g. "Rizka Nabilah" → "RN".
String detailInitialsOf(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty || parts.first.isEmpty) return '?';
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return (parts.first.substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
}

/// Ubah list mentah dari JSON menjadi `List<Map<String,dynamic>>`.
List<Map<String, dynamic>> detailMapList(dynamic raw) {
  if (raw is List) {
    return raw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }
  return const [];
}

/// Ubah list mentah string (mis. `learnings`) menjadi `List<String>`.
List<String> detailStringList(dynamic raw) {
  if (raw is List) return raw.map((e) => e.toString()).toList();
  return const [];
}
