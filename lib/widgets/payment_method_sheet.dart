// ============================================
// FILE: lib/widgets/payment_method_sheet.dart
// ============================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/cart_item_model.dart';
import '../models/transaction_model.dart';

/// Bottom sheet untuk memilih metode pembayaran sebelum checkout.
///
/// Mengembalikan [PaymentMethod] yang dipilih user, atau null jika dibatalkan.
Future<PaymentMethod?> showPaymentMethodSheet(
  BuildContext context, {
  required int totalAmount,
}) {
  return showModalBottomSheet<PaymentMethod>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _PaymentMethodSheet(totalAmount: totalAmount),
  );
}

class _PaymentMethodSheet extends StatefulWidget {
  const _PaymentMethodSheet({required this.totalAmount});

  final int totalAmount;

  @override
  State<_PaymentMethodSheet> createState() => _PaymentMethodSheetState();
}

class _PaymentMethodSheetState extends State<_PaymentMethodSheet> {
  static const Color _navy = Color(0xFF001261);
  static const Color _blue = Color(0xFF002196);
  static const Color _purple = Color(0xFFA600B2);
  static const Color _muted = Color(0xFF757684);
  static const Color _border = Color(0x14001261);
  static const Color _surface = Color(0xFFF2F0F8);

  PaymentMethod _selected = PaymentMethod.transfer;

  static const _options = <(PaymentMethod, IconData, String)>[
    (PaymentMethod.transfer, Icons.account_balance_rounded, 'BCA / Mandiri / BNI'),
    (PaymentMethod.eWallet, Icons.account_balance_wallet_rounded, 'OVO / DANA / GoPay'),
    (PaymentMethod.qris, Icons.qr_code_rounded, 'Scan untuk semua e-wallet'),
    (PaymentMethod.cod, Icons.payments_rounded, 'Bayar saat sesi pertama'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        MediaQuery.of(context).padding.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHandle(),
          const SizedBox(height: 14),
          Text(
            'Pilih Metode Pembayaran',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _navy,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Total ${Cart.rupiah(widget.totalAmount)}',
            style: GoogleFonts.manrope(
                fontSize: 13, color: _muted, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          for (final opt in _options) ...[
            _buildOption(
              method: opt.$1,
              icon: opt.$2,
              subtitle: opt.$3,
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 6),
          _buildPayButton(),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: _border,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildOption({
    required PaymentMethod method,
    required IconData icon,
    required String subtitle,
  }) {
    final isSelected = _selected == method;
    return Material(
      color: isSelected ? _purple.withValues(alpha: 0.06) : Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => setState(() => _selected = method),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? _purple : _border,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: _navy, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method.label,
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
                          fontSize: 11, color: _muted),
                    ),
                  ],
                ),
              ),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? _purple : _muted.withValues(alpha: 0.4),
                    width: 2,
                  ),
                  color: isSelected ? _purple : Colors.transparent,
                ),
                alignment: Alignment.center,
                child: isSelected
                    ? const Icon(Icons.check_rounded,
                        size: 12, color: Colors.white)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPayButton() {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_navy, _blue],
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => Navigator.of(context).pop(_selected),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_rounded,
                    size: 16, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'Bayar Sekarang',
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
    );
  }
}
