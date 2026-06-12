// ============================================
// FILE: lib/views/cart_screen.dart
// ============================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/transaction_model.dart';
import '../viewmodels/cart_viewmodel.dart';
import '../viewmodels/transaction_viewmodel.dart';
import '../widgets/cart_item_card.dart';
import '../widgets/payment_method_sheet.dart';
import '../widgets/qris_payment_sheet.dart';
import 'transaction_screen/transaction_detail_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  static const Color _bg = Color(0xFFFBFAFF);
  static const Color _navy = Color(0xFF001261);
  static const Color _blue = Color(0xFF002196);
  static const Color _purple = Color(0xFFA600B2);
  static const Color _muted = Color(0xFF757684);
  static const Color _border = Color(0x14001261);
  static const Color _red = Color(0xFFE53935);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartViewModel>().loadCart();
    });
  }

  Future<void> _checkout(CartViewModel cartVm) async {
    final txVm = context.read<TransactionViewModel>();
    final method = await showPaymentMethodSheet(
      context,
      totalAmount: cartVm.subtotal,
    );
    if (method == null || !mounted) return;

    // QRIS punya alur khusus: tampilkan QR dulu, tunggu konfirmasi user,
    // baru lanjut hit API checkout.
    if (method == PaymentMethod.qris) {
      final paid = await showQrisPaymentSheet(
        context,
        totalAmount: cartVm.subtotal,
        merchantName: 'Mark-Up Indonesia',
      );
      if (paid != true || !mounted) return;
    }

    // Tampilkan loading dialog selama proses checkout.
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: _purple),
      ),
    );

    final trx = await txVm.checkout(method);

    if (!mounted) return;
    Navigator.of(context).pop(); // tutup loading

    if (trx == null) {
      _showError(txVm.checkoutError ?? 'Checkout gagal, coba lagi.');
      return;
    }

    // Cart sudah dikosongkan di server — sinkronkan state lokal.
    await cartVm.refresh();
    if (!mounted) return;

    await _showSuccessDialog(trx);
    if (!mounted) return;

    // Replace cart screen dengan halaman detail transaksi.
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => TransactionDetailScreen(transactionId: trx.id),
      ),
    );
  }

  Future<void> _showSuccessDialog(TransactionModel trx) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0x14F59E0B),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.hourglass_top_rounded,
                  color: Color(0xFFF59E0B), size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Pesanan Dibuat',
                style: GoogleFonts.spaceGrotesk(
                    fontWeight: FontWeight.w700, color: _navy),
              ),
            ),
          ],
        ),
        content: Text(
          'Transaksi ${trx.code} sebesar ${trx.formattedTotal} dibuat dan '
          'menunggu pembayaran. Unggah bukti bayar di halaman detail, lalu '
          'admin akan memverifikasi sebelum produk terbuka.',
          style: GoogleFonts.manrope(fontSize: 13, color: _muted, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Lihat Detail',
              style: GoogleFonts.manrope(
                  color: _navy, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message, style: GoogleFonts.manrope(fontSize: 13)),
            ),
          ],
        ),
        backgroundColor: _red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _confirmClear(CartViewModel vm) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Kosongkan Keranjang?',
          style: GoogleFonts.spaceGrotesk(
              fontWeight: FontWeight.w700, color: _navy),
        ),
        content: Text(
          'Semua item akan dihapus dari keranjangmu.',
          style: GoogleFonts.manrope(fontSize: 13, color: _muted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Batal',
                style: GoogleFonts.manrope(color: _muted)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Hapus Semua',
                style: GoogleFonts.manrope(
                    color: _red, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (ok == true) vm.clearCart();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        bottom: false,
        child: Consumer<CartViewModel>(
          builder: (context, vm, _) {
            return Column(
              children: [
                _buildHeader(vm),
                Expanded(child: _buildBody(vm)),
                if (!vm.isEmpty && !vm.isLoading)
                  Consumer<TransactionViewModel>(
                    builder: (_, txVm, __) =>
                        _buildCheckoutBar(vm, isProcessing: txVm.isCheckingOut),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ─── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(CartViewModel vm) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 16, 4),
      child: Row(
        children: [
          // Back
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.of(context).pop(),
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(Icons.arrow_back_ios_new_rounded,
                    size: 18, color: _navy),
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Keranjang',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: _navy,
              ),
            ),
          ),
          if (!vm.isEmpty && !vm.isLoading)
            TextButton(
              onPressed: () => _confirmClear(vm),
              style: TextButton.styleFrom(
                foregroundColor: _red,
                textStyle: GoogleFonts.manrope(
                    fontSize: 12, fontWeight: FontWeight.w700),
              ),
              child: const Text('Hapus Semua'),
            ),
        ],
      ),
    );
  }

  // ─── Body ─────────────────────────────────────────────────────────────────

  Widget _buildBody(CartViewModel vm) {
    if (vm.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: _purple),
      );
    }

    if (vm.state == CartState.error) {
      return _ErrorView(
        message: vm.error ?? 'Gagal memuat keranjang',
        onRetry: vm.refresh,
      );
    }

    if (vm.isEmpty) return const _EmptyCartView();

    return RefreshIndicator(
      color: _purple,
      onRefresh: vm.refresh,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: vm.items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final item = vm.items[i];
          return CartItemCard(
            item: item,
            isBusy: vm.isBusy(item.id),
            onIncrement: () => vm.increment(item),
            onDecrement: () => vm.decrement(item),
            onRemove: () => vm.removeItem(item),
          );
        },
      ),
    );
  }

  // ─── Checkout footer ───────────────────────────────────────────────────────

  Widget _buildCheckoutBar(CartViewModel vm, {required bool isProcessing}) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 14, 20, MediaQuery.of(context).padding.bottom + 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _border.withValues(alpha: 2))),
        boxShadow: [
          BoxShadow(
            color: _navy.withValues(alpha: 0.07),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Total (${vm.totalItems} item)',
                  style: GoogleFonts.manrope(fontSize: 11, color: _muted),
                ),
                const SizedBox(height: 2),
                Text(
                  vm.formattedSubtotal,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: _navy,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_navy, _blue],
              ),
              boxShadow: [
                BoxShadow(
                  color: _navy.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: isProcessing ? null : () => _checkout(vm),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 14),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isProcessing)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      else
                        const Icon(Icons.shopping_cart_checkout_rounded,
                            size: 16, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        isProcessing ? 'Memproses...' : 'Checkout',
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Empty state ─────────────────────────────────────────────────────────────

class _EmptyCartView extends StatelessWidget {
  const _EmptyCartView();

  static const Color _navy = Color(0xFF001261);
  static const Color _muted = Color(0xFF757684);
  static const Color _purpleFaint = Color(0x14A600B2);
  static const Color _purple = Color(0xFFA600B2);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: _purpleFaint,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.shopping_bag_outlined,
                  size: 44, color: _purple),
            ),
            const SizedBox(height: 20),
            Text(
              'Keranjang Kosong',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _navy,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tambahkan produk dari halaman\nProduk untuk mulai belajar.',
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                fontSize: 13,
                color: _muted,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: _navy,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 12),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Jelajahi Produk',
                style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Error state ─────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded,
                color: Colors.grey.shade400, size: 44),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                  fontSize: 13, color: const Color(0xFF757684)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF001261),
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
}
