// ============================================
// FILE: lib/views/admin/admin_products_screen.dart
// ============================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../services/admin_service.dart';
import '../../viewmodels/product_viewmodel.dart';
import 'admin_list_scaffold.dart';
import 'admin_product_form_screen.dart';
import 'admin_theme.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  final _admin = AdminService();
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _admin.listProducts();
  }

  void _reload() {
    setState(() => _future = _admin.listProducts());
    // Sinkronkan katalog user agar perubahan langsung tampak.
    // (init() hanya fetch sekali; refresh() memaksa fetch ulang.)
    context.read<ProductViewModel>().refresh();
  }

  Future<void> _openForm([Map<String, dynamic>? initial]) async {
    final ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => AdminProductFormScreen(initial: initial)),
    );
    if (ok == true) _reload();
  }

  Future<void> _delete(Map<String, dynamic> item) async {
    final confirmed = await showAdminDeleteDialog(context, item['title']?.toString() ?? 'produk ini');
    if (confirmed != true) return;
    try {
      await _admin.deleteProduct(item['id'] as int);
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
      title: 'Produk',
      future: _future,
      onAdd: () => _openForm(),
      itemBuilder: (item) {
        final price = item['price'];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          title: Text(
            (item['title'] ?? '-').toString(),
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600, color: AdminTheme.navy),
          ),
          subtitle: Text(
            '${item['type'] ?? '-'} · Rp ${price ?? '-'}',
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
