// ============================================
// FILE: lib/views/dashboard_screen/dashboard_screen.dart
// ============================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../config/app_routes.dart';
import '../../models/competition_model.dart';
import '../../models/product_model.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/competition_viewmodel.dart';
import '../../viewmodels/dashboard_viewmodel.dart';
import '../../viewmodels/product_viewmodel.dart';
import '../../viewmodels/transaction_viewmodel.dart';
import '../../widgets/cart_icon_button.dart';
import '../../widgets/competition_image_preview.dart' as preview;
import '../../widgets/product_grid_card.dart';
import '../cart_screen.dart';
import '../main_navigation.dart';
import '../product_screen/detail_bootcamp_screen.dart';
import '../product_screen/detail_kelas_screen.dart';
import '../product_screen/detail_modul_screen.dart';
import '../transaction_screen/transaction_history_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const Color _bg = Color(0xFFFBFAFF);
  static const Color _navy = Color(0xFF001261);
  static const Color _purple = Color(0xFFA600B2);
  static const Color _muted = Color(0xFF757684);
  static const Color _surface = Color(0xFFF2F0F8);
  static const Color _yellow = Color(0xFFF8E545);
  static const Color _yellowDark = Color(0xFF201C00);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardViewModel>().loadUserName();
      // Pre-load data dari section produk & lomba supaya saat user pindah tab
      // datanya sudah siap.
      context.read<ProductViewModel>().init();
      context.read<CompetitionViewModel>().init();
      context.read<TransactionViewModel>().loadPurchasedIds();
    });
  }

  // ─── Navigation helpers ────────────────────────────────────────────────────

  void _switchToTab(int index) {
    MainNavigationScope.of(context)?.switchTab(index);
  }

  void _openCart() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const CartScreen()),
    );
  }

  void _openTransactionHistory() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
          builder: (_) => const TransactionHistoryScreen()),
    );
  }

  void _openProductDetail(ProductModel p) {
    final route = MaterialPageRoute<void>(
      builder: (_) {
        switch (p.type) {
          case ProductType.modul:
            return DetailModulScreen(product: p);
          case ProductType.bootcamp:
            return DetailBootcampScreen(product: p);
          case ProductType.kelas:
          case ProductType.mentoring:
            return DetailKelasScreen(product: p);
        }
      },
    );
    Navigator.of(context).push(route);
  }

  void _openCompetitionPreview(CompetitionModel c) {
    preview.showCompetitionImagePreview(context, c);
  }

  // ─── Featured produk picker ────────────────────────────────────────────────

  List<ProductModel> _featured(ProductViewModel vm) {
    final featured = vm.products.where((p) => p.isFeatured).toList();
    final pool = featured.isNotEmpty ? featured : vm.products;
    return pool.take(5).toList();
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
              const SizedBox(height: 16),
              _buildHeader(),
              const SizedBox(height: 18),
              _buildSearchBar(),
              const SizedBox(height: 18),
              _buildBanner(),
              const SizedBox(height: 24),
              _buildFeaturedProducts(),
              const SizedBox(height: 24),
              _buildCompetitionSection(),
            ],
          ),
        ),
      ),
    );
  }

  // ─── HEADER ────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Consumer<DashboardViewModel>(
        builder: (_, dashboardVM, __) => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, ${dashboardVM.userName}!',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: _navy,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Ready to win your next\ncompetition?',
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _purple,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _HistoryButton(onTap: _openTransactionHistory),
            const SizedBox(width: 8),
            CartIconButton(onTap: _openCart),
            const SizedBox(width: 8),
            _LogoutButton(onTap: () => _showLogoutDialog(context)),
          ],
        ),
      ),
    );
  }

  // ─── SEARCH BAR ────────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Material(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _switchToTab(2), // → Produk
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, size: 18, color: _muted),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Cari kelas, modul, atau bootcamp...',
                    style: GoogleFonts.manrope(fontSize: 13, color: _muted),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── BANNER MENTORING ──────────────────────────────────────────────────────

  Widget _buildBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_navy, Color(0xFF002196), Color(0xFF6B0075)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: _navy.withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _yellow,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'EXCLUSIVE ACCESS',
                      style: GoogleFonts.manrope(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: _yellowDark,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Master your pitch with\n1-on-1 Mentoring',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: () => _switchToTab(2),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: _yellow,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Book a Session',
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _yellowDark,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_forward_rounded,
                              size: 14, color: _yellowDark),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Opacity(
              opacity: 0.25,
              child: Icon(
                Icons.psychology_rounded,
                size: 90,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── FEATURED PRODUCTS (real data) ─────────────────────────────────────────

  Widget _buildFeaturedProducts() {
    return Consumer<ProductViewModel>(
      builder: (_, vm, __) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SectionTitle(
              title: 'Produk Unggulan',
              actionLabel: 'Lihat Semua',
              actionColor: _purple,
              onAction: () => _switchToTab(2),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 234,
              child: _buildFeaturedBody(vm),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFeaturedBody(ProductViewModel vm) {
    if (vm.isProductLoading && vm.products.isEmpty) {
      return const Center(
          child: CircularProgressIndicator(color: _purple));
    }
    if (vm.productState == ProductSectionState.error && vm.products.isEmpty) {
      return _ErrorRow(
        message: vm.productError ?? 'Gagal memuat produk',
        onRetry: vm.retryProducts,
      );
    }

    final items = _featured(vm);
    if (items.isEmpty) return const _EmptyRow(label: 'Belum ada produk');

    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(width: 12),
      itemBuilder: (_, i) => SizedBox(
        width: 170,
        child: ProductGridCard(
          product: items[i],
          onTap: () => _openProductDetail(items[i]),
        ),
      ),
    );
  }

  // ─── COMPETITION SECTION (real data, dark bg) ──────────────────────────────

  Widget _buildCompetitionSection() {
    return Container(
      decoration: const BoxDecoration(
        color: _navy,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.only(top: 28, bottom: 32),
      child: Consumer<CompetitionViewModel>(
        builder: (_, vm, __) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Info Lomba Terbaru',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _switchToTab(1),
                      child: Row(
                        children: [
                          Text(
                            'Lihat Semua',
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _yellow,
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(Icons.arrow_forward_rounded,
                              size: 14, color: _yellow),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildCompetitionBody(vm),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCompetitionBody(CompetitionViewModel vm) {
    if (vm.isLoading && vm.competitions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator(color: _yellow)),
      );
    }
    if (vm.hasError && vm.competitions.isEmpty) {
      return _ErrorRow(
        message: vm.errorMessage ?? 'Gagal memuat lomba',
        onRetry: () => vm.fetchCompetitions(),
        darkMode: true,
      );
    }

    final items = vm.competitions.take(3).toList();
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: _EmptyRow(label: 'Belum ada lomba aktif', darkMode: true),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          for (final c in items) ...[
            _DashboardCompetitionCard(
              competition: c,
              onTap: () => _openCompetitionPreview(c),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  // ─── LOGOUT DIALOG ─────────────────────────────────────────────────────────

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18)),
          title: Text(
            'Konfirmasi Logout',
            style: GoogleFonts.spaceGrotesk(
              fontWeight: FontWeight.w700,
              color: _navy,
            ),
          ),
          content: Text(
            'Apakah kamu yakin ingin keluar dari sesi ini?',
            style: GoogleFonts.manrope(fontSize: 13, color: _muted),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Batal',
                  style: GoogleFonts.manrope(
                      fontWeight: FontWeight.w600, color: _muted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              onPressed: () async {
                Navigator.pop(dialogContext);
                final authVM = context.read<AuthViewModel>();
                await authVM.logout();
                if (!context.mounted) return;
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              },
              child: Text('Keluar',
                  style: GoogleFonts.manrope(fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );
  }
}

// ─── Reusable: Section title row ──────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.actionLabel,
    required this.actionColor,
    required this.onAction,
  });

  final String title;
  final String actionLabel;
  final Color actionColor;
  final VoidCallback onAction;

  static const Color _navy = Color(0xFF001261);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _navy,
            ),
          ),
          GestureDetector(
            onTap: onAction,
            child: Row(
              children: [
                Text(
                  actionLabel,
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: actionColor,
                  ),
                ),
                const SizedBox(width: 2),
                Icon(Icons.arrow_forward_rounded,
                    size: 14, color: actionColor),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Logout button ───────────────────────────────────────────────────────────

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0x14E53935),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: const SizedBox(
          width: 40,
          height: 40,
          child: Icon(Icons.logout_rounded,
              size: 18, color: Color(0xFFE53935)),
        ),
      ),
    );
  }
}

class _HistoryButton extends StatelessWidget {
  const _HistoryButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0x14001261),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: const SizedBox(
          width: 40,
          height: 40,
          child: Icon(Icons.receipt_long_rounded,
              size: 18, color: Color(0xFF001261)),
        ),
      ),
    );
  }
}

// ─── Competition card khusus dashboard (dark bg) ─────────────────────────────

class _DashboardCompetitionCard extends StatelessWidget {
  const _DashboardCompetitionCard({
    required this.competition,
    required this.onTap,
  });

  final CompetitionModel competition;
  final VoidCallback onTap;

  static const Color _navy = Color(0xFF001261);
  static const Color _yellow = Color(0xFFF8E545);
  static const Color _purple = Color(0xFFA600B2);

  String get _month {
    final d = competition.startDate;
    if (d == null) return '';
    const m = ['JAN','FEB','MAR','APR','MEI','JUN','JUL','AGS','SEP','OKT','NOV','DES'];
    return m[d.month - 1];
  }

  String get _day {
    final d = competition.startDate;
    if (d == null) return '';
    return d.day.toString().padLeft(2, '0');
  }

  String get _prizeOrFee {
    if (competition.prize > 0) {
      final p = competition.prize;
      if (p >= 1000000) {
        final juta = (p / 1000000);
        return 'Hadiah Rp ${juta % 1 == 0 ? juta.toInt() : juta.toStringAsFixed(1)}jt';
      }
      return 'Hadiah Rp $p';
    }
    return competition.registrationFeeLabel ?? 'Free Registration';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: SizedBox(
            height: 160,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _CompImage(url: competition.imageUrl),
                // Gradient overlay
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.4),
                        Colors.black.withValues(alpha: 0.85),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          // Date pill
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: _navy,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _month,
                                  style: GoogleFonts.manrope(
                                    fontSize: 8,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                                Text(
                                  _day,
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 14,
                                    color: _yellow,
                                    fontWeight: FontWeight.w700,
                                    height: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Category pill
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: _purple,
                                borderRadius: BorderRadius.circular(99),
                              ),
                              child: Text(
                                competition.category.toUpperCase(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.manrope(
                                  fontSize: 9,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        competition.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.emoji_events_rounded,
                              color: _yellow, size: 13),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _prizeOrFee,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.manrope(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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

class _CompImage extends StatelessWidget {
  const _CompImage({required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return _placeholder();
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _placeholder(),
      loadingBuilder: (_, child, prog) =>
          prog == null ? child : _placeholder(),
    );
  }

  Widget _placeholder() => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF002196), Color(0xFF6B0075)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        alignment: Alignment.center,
        child: Icon(Icons.emoji_events_rounded,
            size: 36, color: Colors.white.withValues(alpha: 0.4)),
      );
}

// ─── Empty / error helpers ──────────────────────────────────────────────────

class _EmptyRow extends StatelessWidget {
  const _EmptyRow({required this.label, this.darkMode = false});
  final String label;
  final bool darkMode;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        label,
        style: GoogleFonts.manrope(
          fontSize: 13,
          color: darkMode ? Colors.white70 : const Color(0xFF757684),
        ),
      ),
    );
  }
}

class _ErrorRow extends StatelessWidget {
  const _ErrorRow({
    required this.message,
    required this.onRetry,
    this.darkMode = false,
  });
  final String message;
  final VoidCallback onRetry;
  final bool darkMode;

  @override
  Widget build(BuildContext context) {
    final fg = darkMode ? Colors.white70 : const Color(0xFF757684);
    final btnBg = darkMode ? const Color(0xFFF8E545) : const Color(0xFF001261);
    final btnFg =
        darkMode ? const Color(0xFF201C00) : Colors.white;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 32, color: fg),
            const SizedBox(height: 6),
            Text(message,
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(fontSize: 12, color: fg)),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: btnBg,
                foregroundColor: btnFg,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Text('Coba Lagi',
                  style: GoogleFonts.manrope(
                      fontSize: 12, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}
