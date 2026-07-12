// ============================================
// FILE: lib/views/admin/admin_home_screen.dart
// ============================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'admin_competitions_screen.dart';
import 'admin_mentors_screen.dart';
import 'admin_products_screen.dart';
import 'admin_theme.dart';

/// Hub admin: pintu masuk ke pengelolaan Produk, Mentor, dan Lomba.
/// Hanya boleh diakses user dengan role 'admin' (di-gate dari UI + backend).
class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminTheme.bg,
      appBar: buildAdminAppBar('Panel Admin'),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Kelola Konten',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AdminTheme.navy,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tambah, ubah, atau hapus data yang tampil di aplikasi.',
            style: GoogleFonts.poppins(fontSize: 13, color: AdminTheme.muted),
          ),
          const SizedBox(height: 20),
          _MenuTile(
            icon: Icons.inventory_2_rounded,
            title: 'Produk',
            subtitle: 'Kelas, Modul, Bootcamp',
            color: AdminTheme.purple,
            onTap: () => _go(context, const AdminProductsScreen()),
          ),
          _MenuTile(
            icon: Icons.school_rounded,
            title: 'Mentor',
            subtitle: 'On-Demand Mentoring',
            color: AdminTheme.navy,
            onTap: () => _go(context, const AdminMentorsScreen()),
          ),
          _MenuTile(
            icon: Icons.emoji_events_rounded,
            title: 'Lomba',
            subtitle: 'Info & jadwal kompetisi',
            color: const Color(0xFF1D8348),
            onTap: () => _go(context, const AdminCompetitionsScreen()),
          ),
        ],
      ),
    );
  }

  void _go(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: onTap,
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: AdminTheme.navy,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(fontSize: 12, color: AdminTheme.muted),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: AdminTheme.muted),
      ),
    );
  }
}
