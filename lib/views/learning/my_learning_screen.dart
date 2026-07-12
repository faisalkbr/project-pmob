// ============================================
// FILE: lib/views/learning/my_learning_screen.dart
// ============================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../models/transaction_model.dart';
import '../../viewmodels/transaction_viewmodel.dart';
import 'learning_content_screen.dart';

/// "Produk Saya" — daftar produk yang sudah dibeli (transaksi lunas), pintu
/// masuk ke konten belajar. Data diambil dari endpoint khusus /my-learning
/// (lewat TransactionViewModel.loadOwnedProducts) agar lengkap & tidak
/// bergantung pada pagination riwayat.
class MyLearningScreen extends StatefulWidget {
  const MyLearningScreen({super.key});

  @override
  State<MyLearningScreen> createState() => _MyLearningScreenState();
}

class _MyLearningScreenState extends State<MyLearningScreen> {
  static const Color _bg = Color(0xFFFBFAFF);
  static const Color _navy = Color(0xFF001261);
  static const Color _purple = Color(0xFFA600B2);
  static const Color _muted = Color(0xFF757684);
  static const Color _border = Color(0x14001261);

  @override
  void initState() {
    super.initState();
    // Muat produk yang dimiliki dari endpoint khusus saat layar dibuka.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionViewModel>().loadOwnedProducts();
    });
  }

  void _openContent(TransactionItemModel item) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LearningContentScreen(
          productId: item.productId!,
          productTitle: item.productTitle,
          productType: item.productType ?? 'modul',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: Text('Produk Saya',
            style: GoogleFonts.spaceGrotesk(
                fontWeight: FontWeight.w700, fontSize: 17, color: Colors.white)),
        backgroundColor: _navy,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Consumer<TransactionViewModel>(
        builder: (_, vm, __) {
          if (vm.isOwnedLoading && vm.ownedProducts.isEmpty) {
            return const Center(
                child: CircularProgressIndicator(color: _purple));
          }

          if (vm.ownedState == TransactionListState.error &&
              vm.ownedProducts.isEmpty) {
            return _errorState(vm);
          }

          final owned = vm.ownedProducts;
          if (owned.isEmpty) return _emptyState();

          return RefreshIndicator(
            color: _purple,
            onRefresh: vm.loadOwnedProducts,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              itemCount: owned.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _productCard(owned[i]),
            ),
          );
        },
      ),
    );
  }

  Widget _productCard(TransactionItemModel item) {
    final (icon, tint, label) = _visualFor(item.productType);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openContent(item),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: tint, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: tint.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(label,
                          style: GoogleFonts.manrope(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              color: tint)),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      item.productTitle,
                      style: GoogleFonts.manrope(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: _navy),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const _StartBadge(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: _purple.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.school_rounded,
                  size: 36, color: _purple),
            ),
            const SizedBox(height: 16),
            Text('Belum ada produk',
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _navy)),
            const SizedBox(height: 6),
            Text(
              'Produk yang sudah lunas akan muncul di sini\ndan bisa langsung kamu akses.',
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(fontSize: 13, color: _muted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorState(TransactionViewModel vm) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 44, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              vm.ownedError ?? 'Gagal memuat produk',
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(fontSize: 13, color: _muted),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: vm.loadOwnedProducts,
              style: ElevatedButton.styleFrom(
                backgroundColor: _navy,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  (IconData, Color, String) _visualFor(String? type) {
    switch ((type ?? '').toLowerCase()) {
      case 'kelas':
        return (Icons.play_lesson_rounded, _purple, 'KELAS');
      case 'bootcamp':
        return (Icons.rocket_launch_rounded, const Color(0xFF2563EB), 'BOOTCAMP');
      default:
        return (Icons.menu_book_rounded, const Color(0xFFE0245E), 'MODUL');
    }
  }
}

class _StartBadge extends StatelessWidget {
  const _StartBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFA600B2), Color(0xFF6B0075)],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.play_arrow_rounded, size: 16, color: Colors.white),
          const SizedBox(width: 2),
          Text('Mulai',
              style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
        ],
      ),
    );
  }
}
