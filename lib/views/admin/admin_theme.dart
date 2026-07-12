// ============================================
// FILE: lib/views/admin/admin_theme.dart
// ============================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Token warna ringkas yang dipakai bersama oleh seluruh layar admin,
/// selaras dengan palette app (navy/purple).
class AdminTheme {
  static const Color bg = Color(0xFFFBFAFF);
  static const Color navy = Color(0xFF00146B);
  static const Color purple = Color(0xFF8B008B);
  static const Color muted = Color(0xFF757684);
  static const Color danger = Color(0xFFC73A2E);
}

/// AppBar navy dengan judul & ikon putih.
///
/// Perlu eksplisit karena `AppBarTheme` global menetapkan `titleTextStyle`
/// dan `iconTheme` berwarna navy, sehingga `foregroundColor: white` saja
/// tidak cukup (judul jadi navy-di-atas-navy / tidak terbaca).
AppBar buildAdminAppBar(String title) {
  return AppBar(
    title: Text(title),
    backgroundColor: AdminTheme.navy,
    foregroundColor: Colors.white,
    iconTheme: const IconThemeData(color: Colors.white),
    titleTextStyle: GoogleFonts.poppins(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
  );
}
