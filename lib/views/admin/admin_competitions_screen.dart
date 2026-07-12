// ============================================
// FILE: lib/views/admin/admin_competitions_screen.dart
// ============================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../services/admin_service.dart';
import '../../viewmodels/competition_viewmodel.dart';
import 'admin_competition_form_screen.dart';
import 'admin_list_scaffold.dart';
import 'admin_theme.dart';

class AdminCompetitionsScreen extends StatefulWidget {
  const AdminCompetitionsScreen({super.key});

  @override
  State<AdminCompetitionsScreen> createState() =>
      _AdminCompetitionsScreenState();
}

class _AdminCompetitionsScreenState extends State<AdminCompetitionsScreen> {
  final _admin = AdminService();
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _admin.listCompetitions();
  }

  void _reload() {
    setState(() => _future = _admin.listCompetitions());
    // init() hanya fetch sekali; paksa fetch ulang halaman pertama.
    context.read<CompetitionViewModel>().fetchCompetitions(page: 1);
  }

  Future<void> _openForm([Map<String, dynamic>? initial]) async {
    final ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
          builder: (_) => AdminCompetitionFormScreen(initial: initial)),
    );
    if (ok == true) _reload();
  }

  Future<void> _delete(Map<String, dynamic> item) async {
    final confirmed =
        await showAdminDeleteDialog(context, item['title']?.toString() ?? 'lomba ini');
    if (confirmed != true) return;
    try {
      await _admin.deleteCompetition(item['id'] as int);
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
      title: 'Lomba',
      future: _future,
      onAdd: () => _openForm(),
      itemBuilder: (item) {
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          title: Text(
            (item['title'] ?? '-').toString(),
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600, color: AdminTheme.navy),
          ),
          subtitle: Text(
            '${item['category'] ?? '-'} · ${item['organizer'] ?? '-'}',
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
