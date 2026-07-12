// ============================================
// FILE: lib/views/transaction_screen/transaction_detail_screen.dart
// ============================================

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/cart_item_model.dart';
import '../../models/transaction_model.dart';
import '../../services/transaction_service.dart';
import '../../viewmodels/transaction_viewmodel.dart';
import '../learning/learning_content_screen.dart';
import 'transaction_history_screen.dart' show TransactionStatusBadge;

class TransactionDetailScreen extends StatefulWidget {
  const TransactionDetailScreen({super.key, required this.transactionId});

  final int transactionId;

  @override
  State<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  static const Color _bg = Color(0xFFFBFAFF);
  static const Color _navy = Color(0xFF001261);
  static const Color _purple = Color(0xFFA600B2);
  static const Color _muted = Color(0xFF757684);
  static const Color _border = Color(0x14001261);

  bool _isPaying = false;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<TransactionViewModel>();
      // Jika detail di-VM masih dari transaksi yang sama (misal hasil checkout
      // barusan) skip request ulang.
      if (vm.detail?.id != widget.transactionId) {
        vm.loadDetail(widget.transactionId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        bottom: false,
        child: Consumer<TransactionViewModel>(
          builder: (context, vm, _) {
            return Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildBody(vm)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 16, 4),
      child: Row(
        children: [
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
              'Detail Transaksi',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: _navy,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(TransactionViewModel vm) {
    final detail = vm.detail;

    if (vm.isDetailLoading && (detail == null || detail.id != widget.transactionId)) {
      return const Center(child: CircularProgressIndicator(color: _purple));
    }

    if (vm.detailError != null && detail == null) {
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
                vm.detailError!,
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(fontSize: 13, color: _muted),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => vm.loadDetail(widget.transactionId),
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

    if (detail == null) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSummaryCard(detail),
          const SizedBox(height: 16),
          _buildStatusCard(detail),
          if (detail.status == TransactionStatus.pending) ...[
            const SizedBox(height: 12),
            _buildPaymentActions(detail),
          ],
          const SizedBox(height: 16),
          _buildItemsCard(detail),
          const SizedBox(height: 16),
          _buildTotalCard(detail),
        ],
      ),
    );
  }

  // ─── Summary ─────────────────────────────────────────────────────────────

  Widget _buildSummaryCard(TransactionModel trx) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  trx.code,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _navy,
                  ),
                ),
              ),
              TransactionStatusBadge(status: trx.status),
            ],
          ),
          const SizedBox(height: 12),
          _SummaryRow(label: 'Tanggal', value: _formatDate(trx.createdAt)),
          const SizedBox(height: 8),
          _SummaryRow(
            label: 'Metode Pembayaran',
            value: trx.paymentMethod.label,
          ),
          if (trx.paidAt != null) ...[
            const SizedBox(height: 8),
            _SummaryRow(label: 'Dibayar Pada', value: _formatDate(trx.paidAt)),
          ],
        ],
      ),
    );
  }

  // ─── Status pembayaran ────────────────────────────────────────────────────

  Widget _buildStatusCard(TransactionModel trx) {
    if (trx.status == TransactionStatus.paid) {
      return _statusPanel(
        color: const Color(0xFF1FAA59),
        icon: Icons.verified_rounded,
        title: 'Pembayaran Terkonfirmasi',
        subtitle: 'Pembayaranmu sudah diverifikasi. Produk kini terbuka.',
      );
    }

    if (trx.status == TransactionStatus.failed ||
        trx.status == TransactionStatus.cancelled) {
      return _statusPanel(
        color: _muted,
        icon: Icons.cancel_rounded,
        title: trx.status.label,
        subtitle: 'Transaksi ini tidak aktif lagi.',
      );
    }

    // status pending → menunggu pembayaran (akan ditangani Midtrans).
    return _statusPanel(
      color: const Color(0xFFF59E0B),
      icon: Icons.hourglass_top_rounded,
      title: 'Menunggu Pembayaran',
      subtitle: 'Selesaikan pembayaran untuk membuka produk.',
    );
  }

  Widget _statusPanel({
    required Color color,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _navy,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.manrope(
                      fontSize: 12, color: _muted, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  // ─── Aksi pembayaran (Midtrans) ──────────────────────────────────────────

  Widget _buildPaymentActions(TransactionModel trx) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: _isPaying ? null : () => _openPayment(trx),
          style: FilledButton.styleFrom(
            backgroundColor: _purple,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
          icon: _isPaying
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.account_balance_wallet_rounded, size: 18),
          label: Text(
            _isPaying ? 'Membuka pembayaran...' : 'Bayar Sekarang',
            style: GoogleFonts.manrope(
                fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: (_isPaying || _isSyncing) ? null : _checkStatus,
          style: OutlinedButton.styleFrom(
            foregroundColor: _navy,
            side: BorderSide(color: _navy.withValues(alpha: 0.25)),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
          icon: _isSyncing
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: _navy),
                )
              : const Icon(Icons.refresh_rounded, size: 18),
          label: Text(
            _isSyncing ? 'Mengecek...' : 'Cek Status Pembayaran',
            style: GoogleFonts.manrope(
                fontSize: 13, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  /// Ambil URL pembayaran Snap (regenerasi token) lalu buka di browser/tab baru.
  Future<void> _openPayment(TransactionModel trx) async {
    setState(() => _isPaying = true);
    try {
      // Pakai payment_url yang sudah ada bila tersedia, jika tidak minta baru.
      final url = trx.hasPaymentUrl
          ? trx.paymentUrl!
          : await TransactionService.getPaymentUrl(trx.id);

      if (url.isEmpty) {
        throw 'URL pembayaran belum tersedia. Coba lagi sebentar.';
      }

      final ok = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
      if (!ok) throw 'Tidak bisa membuka halaman pembayaran.';

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Setelah membayar, tekan "Cek Status Pembayaran".',
            style: GoogleFonts.manrope(fontSize: 13),
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString(), style: GoogleFonts.manrope(fontSize: 13)),
          backgroundColor: const Color(0xFFE53935),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isPaying = false);
    }
  }

  /// Tarik status terbaru dari Midtrans lewat VM lalu beri feedback hasilnya.
  Future<void> _checkStatus() async {
    setState(() => _isSyncing = true);
    try {
      final trx =
          await context.read<TransactionViewModel>().syncStatus(widget.transactionId);
      if (!mounted) return;

      final lunas = trx.status == TransactionStatus.paid;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            lunas
                ? 'Pembayaran terkonfirmasi — transaksi Lunas.'
                : 'Status: ${trx.status.label}. Belum ada pembayaran masuk.',
            style: GoogleFonts.manrope(fontSize: 13),
          ),
          backgroundColor: lunas ? const Color(0xFF1FAA59) : null,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString(), style: GoogleFonts.manrope(fontSize: 13)),
          backgroundColor: const Color(0xFFE53935),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  Widget _buildItemsCard(TransactionModel trx) {
    final isPaid = trx.status == TransactionStatus.paid;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Item Pembelian',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _navy,
            ),
          ),
          if (isPaid) ...[
            const SizedBox(height: 4),
            Text(
              'Ketuk item untuk membuka materinya.',
              style: GoogleFonts.manrope(fontSize: 11, color: _muted),
            ),
          ],
          const SizedBox(height: 12),
          for (var i = 0; i < trx.items.length; i++) ...[
            if (i > 0)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1, color: _border),
              ),
            _ItemRow(
              item: trx.items[i],
              onTap: (isPaid && trx.items[i].productId != null)
                  ? () => _openContent(trx.items[i])
                  : null,
            ),
          ],
        ],
      ),
    );
  }

  /// Buka layar materi belajar untuk item yang sudah lunas.
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

  Widget _buildTotalCard(TransactionModel trx) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_navy, Color(0xFF002196)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Pembayaran',
                  style: GoogleFonts.manrope(
                      fontSize: 12, color: Colors.white.withValues(alpha: 0.8)),
                ),
                const SizedBox(height: 2),
                Text(
                  trx.formattedTotal,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.receipt_long_rounded,
              color: Colors.white, size: 36),
        ],
      ),
    );
  }

  // ─── Helpers ────────────────────────────────────────────────────────────

  static const _months = [
    'Jan','Feb','Mar','Apr','Mei','Jun','Jul','Ags','Sep','Okt','Nov','Des'
  ];

  static String _formatDate(DateTime? d) {
    if (d == null) return '-';
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return '${d.day} ${_months[d.month - 1]} ${d.year} • $hh:$mm';
  }
}

// ─── Widgets ────────────────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Text(
            label,
            style: GoogleFonts.manrope(
                fontSize: 12, color: const Color(0xFF757684)),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF001261),
            ),
          ),
        ),
      ],
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item, this.onTap});
  final TransactionItemModel item;
  final VoidCallback? onTap;

  static const Color _navy = Color(0xFF001261);
  static const Color _purple = Color(0xFFA600B2);
  static const Color _muted = Color(0xFF757684);
  static const Color _surface = Color(0xFFF2F0F8);

  @override
  Widget build(BuildContext context) {
    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 56,
            height: 56,
            child: _Image(url: item.productImageUrl),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (item.productType != null && item.productType!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _surface,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item.productType!.toUpperCase(),
                    style: GoogleFonts.manrope(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: _muted,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                item.productTitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _navy,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${Cart.rupiah(item.price)} × ${item.quantity}',
                style: GoogleFonts.manrope(fontSize: 11, color: _muted),
              ),
              if (onTap != null) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.play_circle_fill_rounded,
                        size: 15, color: _purple),
                    const SizedBox(width: 4),
                    Text(
                      'Mulai belajar',
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _purple,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              Cart.rupiah(item.subtotal),
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _navy,
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(height: 14),
              const Icon(Icons.chevron_right_rounded,
                  size: 20, color: _purple),
            ],
          ],
        ),
      ],
    );

    if (onTap == null) return row;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: row,
        ),
      ),
    );
  }
}

class _Image extends StatelessWidget {
  const _Image({required this.url});
  final String? url;

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) return _placeholder();
    return CachedNetworkImage(
      imageUrl: url!,
      fit: BoxFit.cover,
      placeholder: (_, __) => _placeholder(),
      errorWidget: (_, __, ___) => _placeholder(),
    );
  }

  Widget _placeholder() => Container(
        color: const Color(0xFFF2F0F8),
        alignment: Alignment.center,
        child: const Icon(Icons.image_outlined,
            size: 22, color: Color(0xFF757684)),
      );
}
