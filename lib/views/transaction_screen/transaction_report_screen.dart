// ============================================
// FILE: lib/views/transaction_screen/transaction_report_screen.dart
// ============================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../models/cart_item_model.dart';
import '../../models/transaction_model.dart';
import '../../viewmodels/transaction_viewmodel.dart';
import 'transaction_detail_screen.dart';
import 'transaction_history_screen.dart' show TransactionStatusBadge;

/// Laporan transaksi dengan filter rentang tanggal + ringkasan.
/// Memakai data riwayat yang sama (TransactionViewModel.history); filter
/// dilakukan di sisi klien sehingga tidak perlu endpoint tambahan.
class TransactionReportScreen extends StatefulWidget {
  const TransactionReportScreen({super.key});

  @override
  State<TransactionReportScreen> createState() =>
      _TransactionReportScreenState();
}

class _TransactionReportScreenState extends State<TransactionReportScreen> {
  static const Color _bg = Color(0xFFFBFAFF);
  static const Color _navy = Color(0xFF001261);
  static const Color _purple = Color(0xFFA600B2);
  static const Color _muted = Color(0xFF757684);
  static const Color _border = Color(0x14001261);

  DateTimeRange? _range; // null = semua periode

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<TransactionViewModel>();
      if (vm.history.isEmpty) vm.loadHistory();
    });
  }

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year, now.month, now.day),
      initialDateRange: _range,
      helpText: 'Pilih rentang tanggal',
      saveText: 'Terapkan',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: _purple),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _range = picked);
  }

  /// Filter riwayat sesuai rentang (inklusif per hari). null → semua.
  List<TransactionModel> _filtered(List<TransactionModel> all) {
    final r = _range;
    if (r == null) return all;
    final start = DateTime(r.start.year, r.start.month, r.start.day);
    final end = DateTime(r.end.year, r.end.month, r.end.day, 23, 59, 59);
    return all.where((t) {
      final d = t.createdAt;
      if (d == null) return false;
      return !d.isBefore(start) && !d.isAfter(end);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        bottom: false,
        child: Consumer<TransactionViewModel>(
          builder: (context, vm, _) {
            final data = _filtered(vm.history);
            return Column(
              children: [
                _buildHeader(),
                _buildFilterBar(),
                Expanded(child: _buildBody(vm, data)),
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
              'Laporan Transaksi',
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

  Widget _buildFilterBar() {
    final hasRange = _range != null;
    final label = hasRange
        ? '${_fmtDate(_range!.start)} – ${_fmtDate(_range!.end)}'
        : 'Semua periode';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _pickRange,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded,
                          size: 16, color: _purple),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          label,
                          style: GoogleFonts.manrope(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _navy,
                          ),
                        ),
                      ),
                      const Icon(Icons.expand_more_rounded,
                          size: 18, color: _muted),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (hasRange) ...[
            const SizedBox(width: 8),
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => setState(() => _range = null),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _border),
                  ),
                  child: const Icon(Icons.close_rounded,
                      size: 18, color: _muted),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBody(TransactionViewModel vm, List<TransactionModel> data) {
    if (vm.isHistoryLoading && vm.history.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: _purple));
    }

    return RefreshIndicator(
      color: _purple,
      onRefresh: vm.refreshHistory,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _buildSummary(data),
          const SizedBox(height: 16),
          Text(
            'Rincian (${data.length} transaksi)',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _navy,
            ),
          ),
          const SizedBox(height: 8),
          if (data.isEmpty)
            _buildEmpty()
          else
            ...data.map((t) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ReportRow(
                    transaction: t,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            TransactionDetailScreen(transactionId: t.id),
                      ),
                    ),
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildSummary(List<TransactionModel> data) {
    final total = data.length;
    final paid = data.where((t) => t.status == TransactionStatus.paid).toList();
    final pending =
        data.where((t) => t.status == TransactionStatus.pending).length;
    final batal = data
        .where((t) =>
            t.status == TransactionStatus.failed ||
            t.status == TransactionStatus.cancelled)
        .length;
    final totalPaid = paid.fold<int>(0, (s, t) => s + t.totalAmount);

    return Column(
      children: [
        // Kartu utama: total pemasukan lunas
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_navy, Color(0xFF002196)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Transaksi Lunas',
                style: GoogleFonts.manrope(
                    fontSize: 12, color: Colors.white.withValues(alpha: 0.8)),
              ),
              const SizedBox(height: 4),
              Text(
                Cart.rupiah(totalPaid),
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${paid.length} dari $total transaksi berstatus Lunas',
                style: GoogleFonts.manrope(
                    fontSize: 11, color: Colors.white.withValues(alpha: 0.7)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _statCard('Total', '$total', _navy, Icons.receipt_long_rounded),
            const SizedBox(width: 10),
            _statCard('Menunggu', '$pending', const Color(0xFFF59E0B),
                Icons.hourglass_top_rounded),
            const SizedBox(width: 10),
            _statCard('Batal/Gagal', '$batal', _muted, Icons.cancel_rounded),
          ],
        ),
      ],
    );
  }

  Widget _statCard(String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _navy,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.manrope(fontSize: 10, color: _muted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.search_off_rounded, size: 40, color: Colors.grey.shade400),
          const SizedBox(height: 10),
          Text(
            'Tidak ada transaksi pada periode ini',
            style: GoogleFonts.manrope(fontSize: 13, color: _muted),
          ),
        ],
      ),
    );
  }

  static const _months = [
    'Jan','Feb','Mar','Apr','Mei','Jun','Jul','Ags','Sep','Okt','Nov','Des'
  ];

  static String _fmtDate(DateTime d) =>
      '${d.day} ${_months[d.month - 1]} ${d.year}';
}

// ─── Baris rincian (kompak) ─────────────────────────────────────────────────

class _ReportRow extends StatelessWidget {
  const _ReportRow({required this.transaction, required this.onTap});

  final TransactionModel transaction;
  final VoidCallback onTap;

  static const Color _navy = Color(0xFF001261);
  static const Color _muted = Color(0xFF757684);
  static const Color _border = Color(0x14001261);

  static const _months = [
    'Jan','Feb','Mar','Apr','Mei','Jun','Jul','Ags','Sep','Okt','Nov','Des'
  ];

  String _fmt(DateTime? d) =>
      d == null ? '-' : '${d.day} ${_months[d.month - 1]} ${d.year}';

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.code,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _navy,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _fmt(transaction.createdAt),
                      style: GoogleFonts.manrope(fontSize: 11, color: _muted),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    transaction.formattedTotal,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _navy,
                    ),
                  ),
                  const SizedBox(height: 4),
                  TransactionStatusBadge(status: transaction.status),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
