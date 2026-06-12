// ============================================
// FILE: lib/widgets/qris_payment_sheet.dart
// ============================================

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/cart_item_model.dart';

/// Bottom sheet QRIS — menampilkan gambar QR dan menunggu konfirmasi user.
///
/// Mengembalikan `true` jika user menekan "Saya Sudah Bayar" (lanjut checkout),
/// `false` / `null` jika dibatalkan atau timer habis.
Future<bool?> showQrisPaymentSheet(
  BuildContext context, {
  required int totalAmount,
  required String merchantName,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    builder: (_) => _QrisPaymentSheet(
      totalAmount: totalAmount,
      merchantName: merchantName,
    ),
  );
}

class _QrisPaymentSheet extends StatefulWidget {
  const _QrisPaymentSheet({
    required this.totalAmount,
    required this.merchantName,
  });

  final int totalAmount;
  final String merchantName;

  @override
  State<_QrisPaymentSheet> createState() => _QrisPaymentSheetState();
}

class _QrisPaymentSheetState extends State<_QrisPaymentSheet> {
  static const Color _navy = Color(0xFF001261);
  static const Color _blue = Color(0xFF002196);
  static const Color _purple = Color(0xFFA600B2);
  static const Color _muted = Color(0xFF757684);
  static const Color _border = Color(0x14001261);
  static const Color _surface = Color(0xFFF2F0F8);
  static const Color _green = Color(0xFF16A34A);

  static const Duration _expiryDuration = Duration(minutes: 5);

  late Timer _ticker;
  Duration _remaining = _expiryDuration;
  bool _expired = false;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      final next = _remaining - const Duration(seconds: 1);
      if (next <= Duration.zero) {
        t.cancel();
        setState(() {
          _remaining = Duration.zero;
          _expired = true;
        });
      } else {
        setState(() => _remaining = next);
      }
    });
  }

  @override
  void dispose() {
    _ticker.cancel();
    super.dispose();
  }

  String get _timerText {
    final m = _remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = _remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _copyAmount() {
    Clipboard.setData(ClipboardData(text: widget.totalAmount.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Nominal disalin', style: GoogleFonts.manrope(fontSize: 13)),
        backgroundColor: _navy,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.6,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            _buildHandle(),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 16),
                    _buildTimerCard(),
                    const SizedBox(height: 16),
                    _buildQrCard(),
                    const SizedBox(height: 14),
                    _buildAmountCard(),
                    const SizedBox(height: 14),
                    _buildInstructions(),
                  ],
                ),
              ),
            ),
            _buildFooterActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 6),
      child: Center(
        child: Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: _border,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.qr_code_2_rounded, color: _navy, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bayar dengan QRIS',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _navy,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.merchantName,
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _muted,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Tutup',
          onPressed: () => Navigator.of(context).pop(false),
          icon: const Icon(Icons.close_rounded, color: _navy),
        ),
      ],
    );
  }

  Widget _buildTimerCard() {
    final color = _expired ? const Color(0xFFE53935) : _purple;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(
            _expired ? Icons.timer_off_rounded : Icons.timer_rounded,
            size: 18,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _expired
                  ? 'Waktu pembayaran habis'
                  : 'Selesaikan pembayaran dalam',
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
          Text(
            _expired ? '00:00' : _timerText,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: _navy.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header logo strip ala QRIS resmi
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_navy, _blue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'QRIS',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  'Mark-Up',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // QR image
          AspectRatio(
            aspectRatio: 1,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: ColorFiltered(
                    colorFilter: _expired
                        ? const ColorFilter.matrix([
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0,      0,      0,      1, 0,
                          ])
                        : const ColorFilter.mode(
                            Colors.transparent, BlendMode.dst),
                    child: Image.asset(
                      'assets/images/qris.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => _qrPlaceholder(),
                    ),
                  ),
                ),
                if (_expired)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE53935),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'KEDALUWARSA',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'NMID: ID1023456789012  ·  A01',
            style: GoogleFonts.manrope(
              fontSize: 10,
              color: _muted,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _qrPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.qr_code_2_rounded, size: 80, color: _muted),
            const SizedBox(height: 8),
            Text('QR code tidak tersedia',
                style: GoogleFonts.manrope(fontSize: 12, color: _muted)),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
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
                    fontSize: 11,
                    color: _muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  Cart.rupiah(widget.totalAmount),
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: _navy,
                  ),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: _copyAmount,
            icon: const Icon(Icons.copy_rounded, size: 16, color: _navy),
            label: Text(
              'Salin',
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _navy,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    const steps = <String>[
      'Buka aplikasi e-wallet atau m-banking favoritmu.',
      'Pilih menu Scan / Pay / QRIS, lalu arahkan ke kode QR di atas.',
      'Pastikan nominal yang muncul sesuai, lalu konfirmasi pembayaran.',
      'Tekan "Saya Sudah Bayar" setelah transaksi sukses.',
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cara Membayar',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _navy,
            ),
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < steps.length; i++) ...[
            _stepRow(i + 1, steps[i]),
            if (i != steps.length - 1) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  Widget _stepRow(int n, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: _purple.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '$n',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _purple,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              text,
              style: GoogleFonts.manrope(
                fontSize: 12,
                color: _navy.withValues(alpha: 0.85),
                height: 1.45,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooterActions() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, MediaQuery.of(context).padding.bottom + 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: _expired
                  ? null
                  : const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [_green, Color(0xFF0E8A3E)],
                    ),
              color: _expired ? const Color(0xFFE5E7EB) : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: _expired ? null : () => Navigator.of(context).pop(true),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        size: 18,
                        color: _expired ? _muted : Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _expired
                            ? 'QR Kedaluwarsa'
                            : 'Saya Sudah Bayar',
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _expired ? _muted : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: _muted,
              minimumSize: const Size.fromHeight(40),
            ),
            child: Text(
              'Batalkan Pembayaran',
              style: GoogleFonts.manrope(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
