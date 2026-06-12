// ============================================
// FILE: lib/views/profile_screen/profile_screen.dart
// ============================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../config/app_routes.dart';
import '../../services/storage_service.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/transaction_viewmodel.dart';
import '../transaction_screen/transaction_history_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color _bg     = Color(0xFFFBFAFF);
  static const Color _navy   = Color(0xFF001261);
  static const Color _blue   = Color(0xFF002196);
  static const Color _purple = Color(0xFFA600B2);
  static const Color _muted  = Color(0xFF757684);
  static const Color _border = Color(0x14001261);
  static const Color _red    = Color(0xFFE53935);
  static const Color _green  = Color(0xFF16A34A);

  String _name  = '';
  String _email = '';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final name  = await StorageService.getUserName()  ?? '';
    final email = await StorageService.getUserEmail() ?? '';
    if (mounted) setState(() { _name = name; _email = email; });
  }

  String get _initials {
    final parts = _name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  void _openHistory() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
          builder: (_) => const TransactionHistoryScreen()),
    );
  }

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Konfirmasi Logout',
            style: GoogleFonts.spaceGrotesk(
                fontWeight: FontWeight.w700, color: _navy)),
        content: Text('Apakah kamu yakin ingin keluar?',
            style: GoogleFonts.manrope(fontSize: 13, color: _muted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Batal',
                style: GoogleFonts.manrope(
                    color: _muted, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Keluar',
                style: GoogleFonts.manrope(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (ok != true || !mounted) return;
    await context.read<AuthViewModel>().logout();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildStatsRow(),
              const SizedBox(height: 24),
              _buildMenuSection(),
              const SizedBox(height: 16),
              _buildLogoutButton(),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 32),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Header / Avatar ────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_navy, _blue, Color(0xFF4B0060)],
        ),
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [_purple, Color(0xFF6B0075)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: Colors.white, width: 3),
            ),
            alignment: Alignment.center,
            child: Text(
              _initials,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            _name.isEmpty ? 'User Mark-Up' : _name,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _email,
            style: GoogleFonts.manrope(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.25)),
            ),
            child: Text(
              'Member Mark-Up',
              style: GoogleFonts.manrope(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Stats ──────────────────────────────────────────────────────────────────

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Consumer<TransactionViewModel>(
        builder: (_, vm, __) {
          final total   = vm.history.length;
          final paid    = vm.history
              .where((t) => t.status.name == 'paid')
              .length;
          final products = vm.purchasedProductIds.length;

          return Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _border),
              boxShadow: [
                BoxShadow(
                  color: _navy.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                _StatItem(value: '$total',    label: 'Transaksi'),
                _Divider(),
                _StatItem(value: '$paid',     label: 'Lunas'),
                _Divider(),
                _StatItem(value: '$products', label: 'Produk Dimiliki'),
              ],
            ),
          );
        },
      ),
    );
  }

  // ─── Menu ───────────────────────────────────────────────────────────────────

  Widget _buildMenuSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Akun',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _muted,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          _MenuTile(
            icon: Icons.receipt_long_rounded,
            label: 'Riwayat Transaksi',
            subtitle: 'Lihat semua pembelian kamu',
            iconBg: const Color(0x14001261),
            iconColor: _navy,
            onTap: _openHistory,
          ),
          const SizedBox(height: 8),
          _MenuTile(
            icon: Icons.lock_open_rounded,
            label: 'Produk Saya',
            subtitle: 'Akses konten yang sudah dibeli',
            iconBg: const Color(0x1416A34A),
            iconColor: _green,
            onTap: _openHistory,
          ),
          const SizedBox(height: 8),
          _MenuTile(
            icon: Icons.help_outline_rounded,
            label: 'Bantuan',
            subtitle: 'FAQ dan hubungi kami',
            iconBg: const Color(0x14F59E0B),
            iconColor: const Color(0xFFF59E0B),
            onTap: () => _showComingSoon('Bantuan'),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: _red,
          side: const BorderSide(color: Color(0x33E53935)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onPressed: _logout,
        icon: const Icon(Icons.logout_rounded, size: 18),
        label: Text('Keluar dari Akun',
            style: GoogleFonts.manrope(
                fontSize: 14, fontWeight: FontWeight.w700)),
      ),
    );
  }

  void _showComingSoon(String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name segera hadir!',
            style: GoogleFonts.manrope(fontSize: 13)),
        backgroundColor: _navy,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// ─── Reusable widgets ─────────────────────────────────────────────────────────

class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label});
  final String value;
  final String label;

  static const _navy  = Color(0xFF001261);
  static const _muted = Color(0xFF757684);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _navy)),
          const SizedBox(height: 2),
          Text(label,
              style:
                  GoogleFonts.manrope(fontSize: 11, color: _muted)),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 1, height: 36, color: const Color(0x14001261));
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.iconBg,
    required this.iconColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final Color iconBg;
  final Color iconColor;
  final VoidCallback onTap;

  static const _navy  = Color(0xFF001261);
  static const _muted = Color(0xFF757684);
  static const _border = Color(0x14001261);

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
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _navy)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: GoogleFonts.manrope(
                            fontSize: 11, color: _muted)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  size: 20, color: _muted),
            ],
          ),
        ),
      ),
    );
  }
}
