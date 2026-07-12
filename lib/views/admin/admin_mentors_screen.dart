// ============================================
// FILE: lib/views/admin/admin_mentors_screen.dart
// ============================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../services/admin_service.dart';
import '../../viewmodels/product_viewmodel.dart';
import 'admin_list_scaffold.dart';
import 'admin_mentor_form_screen.dart';
import 'admin_theme.dart';

class AdminMentorsScreen extends StatefulWidget {
  const AdminMentorsScreen({super.key});

  @override
  State<AdminMentorsScreen> createState() => _AdminMentorsScreenState();
}

class _AdminMentorsScreenState extends State<AdminMentorsScreen> {
  final _admin = AdminService();
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _admin.listMentors();
  }

  void _reload() {
    setState(() => _future = _admin.listMentors());
    // Sinkronkan daftar mentor di katalog (cache di ProductViewModel).
    context.read<ProductViewModel>().fetchMentors();
  }

  Future<void> _openForm([Map<String, dynamic>? initial]) async {
    final ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => AdminMentorFormScreen(initial: initial)),
    );
    if (ok == true) _reload();
  }

  Future<void> _delete(Map<String, dynamic> item) async {
    final confirmed =
        await showAdminDeleteDialog(context, item['name']?.toString() ?? 'mentor ini');
    if (confirmed != true) return;
    try {
      await _admin.deleteMentor(item['id'] as int);
      _reload();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminListScaffold(
      title: 'Mentor',
      future: _future,
      onAdd: () => _openForm(),
      itemBuilder: (item) {
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          title: Text(
            (item['name'] ?? '-').toString(),
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600, color: AdminTheme.navy),
          ),
          subtitle: Text(
            '${item['title'] ?? '-'} · Rp ${item['price_per_session'] ?? '-'}/sesi',
            style: GoogleFonts.poppins(fontSize: 12, color: AdminTheme.muted),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_rounded, color: AdminTheme.purple),
                onPressed: () => _openForm(item),
              ),
              IconButton(
                icon: const Icon(Icons.delete_rounded, color: AdminTheme.danger),
                onPressed: () => _delete(item),
              ),
            ],
          ),
        );
      },
    );
  }
}
