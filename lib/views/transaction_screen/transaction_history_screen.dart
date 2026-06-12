// ============================================
// FILE: lib/views/transaction_screen/transaction_history_screen.dart
// ============================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../models/transaction_model.dart';
import '../../viewmodels/transaction_viewmodel.dart';
import 'transaction_detail_screen.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  static const Color _bg = Color(0xFFFBFAFF);
  static const Color _navy = Color(0xFF001261);
  static const Color _purple = Color(0xFFA600B2);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionViewModel>().loadHistory();
    });
  }

  void _openDetail(TransactionModel trx) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TransactionDetailScreen(transactionId: trx.id),
      ),
    );
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
              'Riwayat Transaksi',
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
    if (vm.isHistoryLoading && vm.history.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: _purple));
    }

    if (vm.historyState == TransactionListState.error && vm.history.isEmpty) {
      return _ErrorView(
        message: vm.historyError ?? 'Gagal memuat riwayat',
        onRetry: vm.refreshHistory,
      );
    }

    if (vm.history.isEmpty) return const _EmptyHistoryView();

    return RefreshIndicator(
      color: _purple,
      onRefresh: vm.refreshHistory,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: vm.history.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _TransactionCard(
          transaction: vm.history[i],
          onTap: () => _openDetail(vm.history[i]),
        ),
      ),
    );
  }
}

// ─── Card ───────────────────────────────────────────────────────────────────

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({required this.transaction, required this.onTap});

  final TransactionModel transaction;
  final VoidCallback onTap;

  static const Color _navy = Color(0xFF001261);
  static const Color _muted = Color(0xFF757684);
  static const Color _border = Color(0x14001261);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction.code,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _navy,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatDate(transaction.createdAt),
                          style: GoogleFonts.manrope(
                              fontSize: 11, color: _muted),
                        ),
                      ],
                    ),
                  ),
                  TransactionStatusBadge(status: transaction.status),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(height: 1, color: _border),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.shopping_bag_outlined,
                      size: 14, color: _muted),
                  const SizedBox(width: 6),
                  Text(
                    '${transaction.itemsCount} item',
                    style:
                        GoogleFonts.manrope(fontSize: 12, color: _muted),
                  ),
                  const Spacer(),
                  Text(
                    transaction.formattedTotal,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _navy,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

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

// ─── Status badge (reused di detail screen) ─────────────────────────────────

class TransactionStatusBadge extends StatelessWidget {
  const TransactionStatusBadge({super.key, required this.status});

  final TransactionStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label) = switch (status) {
      TransactionStatus.paid => (
          const Color(0x141FAA59),
          const Color(0xFF1FAA59),
          status.label,
        ),
      TransactionStatus.pending => (
          const Color(0x14F59E0B),
          const Color(0xFFF59E0B),
          status.label,
        ),
      TransactionStatus.failed => (
          const Color(0x14E53935),
          const Color(0xFFE53935),
          status.label,
        ),
      TransactionStatus.cancelled => (
          const Color(0x14757684),
          const Color(0xFF757684),
          status.label,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.manrope(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}

// ─── Empty / Error ──────────────────────────────────────────────────────────

class _EmptyHistoryView extends StatelessWidget {
  const _EmptyHistoryView();

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
              child: const Icon(Icons.receipt_long_rounded,
                  size: 44, color: _purple),
            ),
            const SizedBox(height: 20),
            Text(
              'Belum Ada Transaksi',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _navy,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Riwayat transaksimu akan muncul\ndi sini setelah checkout pertama.',
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                fontSize: 13,
                color: _muted,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

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

