// ============================================
// FILE: lib/views/admin/admin_list_scaffold.dart
// ============================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'admin_theme.dart';

/// Kerangka layar daftar admin: AppBar, FAB tambah, dan FutureBuilder dengan
/// state loading / error / kosong yang seragam untuk Produk, Mentor, Lomba.
class AdminListScaffold extends StatelessWidget {
  const AdminListScaffold({
    super.key,
    required this.title,
    required this.future,
    required this.itemBuilder,
    required this.onAdd,
  });

  final String title;
  final Future<List<Map<String, dynamic>>> future;
  final Widget Function(Map<String, dynamic> item) itemBuilder;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminTheme.bg,
      appBar: buildAdminAppBar('Kelola $title'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: onAdd,
        backgroundColor: AdminTheme.purple,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('Tambah',
            style: GoogleFonts.poppins(
                color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _Message(
              icon: Icons.error_outline_rounded,
              text: snapshot.error.toString().replaceFirst('Exception: ', ''),
            );
          }
          final items = snapshot.data ?? const [];
          if (items.isEmpty) {
            return const _Message(
              icon: Icons.inbox_rounded,
              text: 'Belum ada data. Tekan Tambah untuk membuat.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) => itemBuilder(items[i]),
          );
        },
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: AdminTheme.muted),
            const SizedBox(height: 12),
            Text(
              text,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: AdminTheme.muted),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dialog konfirmasi hapus yang dipakai bersama oleh layar daftar admin.
Future<bool?> showAdminDeleteDialog(BuildContext context, String name) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Hapus data?'),
      content: Text('Yakin ingin menghapus "$name"? Tindakan ini tidak bisa dibatalkan.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          style: TextButton.styleFrom(foregroundColor: AdminTheme.danger),
          child: const Text('Hapus'),
        ),
      ],
    ),
  );
}
