// ============================================
// FILE: lib/views/product_screen/detail_modul_screen.dart
// ============================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../models/product_model.dart';
import '../../viewmodels/cart_viewmodel.dart';
import '../../viewmodels/transaction_viewmodel.dart';
import '../../widgets/detail_widgets.dart';
import '../../widgets/review_section.dart';
import '../cart_screen.dart';

class DetailModulScreen extends StatefulWidget {
  const DetailModulScreen({super.key, required this.product});
  final ProductModel product;

  @override
  State<DetailModulScreen> createState() => _DetailModulScreenState();
}

class _DetailModulScreenState extends State<DetailModulScreen> {
  int _activeTab = 0;
  bool _addingToCart = false;

  static const _tabs = ['Deskripsi', 'Daftar Isi', 'Ulasan'];

  Future<void> _addToCart() async {
    if (_addingToCart) return;
    setState(() => _addingToCart = true);
    try {
      await context.read<CartViewModel>().addProduct(widget.product);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${widget.product.title} ditambahkan ke keranjang',
            style: GoogleFonts.manrope(fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          backgroundColor: const Color(0xFF001261),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          action: SnackBarAction(
            label: 'Lihat',
            textColor: const Color(0xFFF8E545),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const CartScreen()),
            ),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal: $e', style: GoogleFonts.manrope(fontSize: 13)),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      if (mounted) setState(() => _addingToCart = false);
    }
  }

  void _onAccessContent() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Kamu sudah memiliki akses ke ${widget.product.title}',
                style: GoogleFonts.manrope(fontSize: 13),
                maxLines: 2,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF16A34A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static const _toc = [
    ('01', 'Pengantar Dunia Debat Kompetitif', '1–18'),
    ('02', 'Struktur Argumen yang Memenangkan Juri', '19–42'),
    ('03', 'Teknik Riset Kilat untuk Debat', '43–62'),
    ('04', 'Rebuttal & Cross-Examination', '63–84'),
    ('05', 'Manajemen Waktu & Strategi Tim', '85–102'),
    ('06', 'Studi Kasus: Lomba Debat Nasional', '103–128'),
    ('07', 'Template & Lembar Persiapan', '129–145'),
  ];

  static const _includes = [
    (Icons.description_rounded, '145 halaman PDF berkualitas tinggi'),
    (Icons.download_rounded, 'Download sekali, akses selamanya'),
    (Icons.menu_book_rounded, '7 bab + 3 bonus template siap pakai'),
    (Icons.emoji_events_rounded, 'Studi kasus lomba debat nyata'),
    (Icons.verified_rounded, 'Sertifikat digital setelah selesai'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DetailColors.bg,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHero(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product.title,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 21,
                            fontWeight: FontWeight.w700,
                            color: DetailColors.navy,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 10),
                        StarRatingRow(
                          rating: widget.product.rating,
                          count: '${widget.product.students} ulasan',
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: const [
                            DetailMetaPill(
                                icon: Icons.description_rounded,
                                text: '145 halaman'),
                            DetailMetaPill(
                                icon: Icons.menu_book_rounded, text: '7 bab'),
                            DetailMetaPill(
                                icon: Icons.download_rounded,
                                text: 'Download PDF'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const AuthorMiniCard(
                          label: 'Ditulis oleh',
                          name: 'Kartika Ayu',
                          subtitle: 'Juara 1 Debat Nasional 2024',
                          initials: 'KA',
                          gradient: [Color(0xFFA600B2), Color(0xFF6B0075)],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const StatsRow(pills: [
                      StatPill(
                        icon: Icons.description_rounded,
                        value: '145',
                        label: 'Halaman',
                      ),
                      StatPill(
                        icon: Icons.groups_rounded,
                        value: '800+',
                        label: 'Pembaca',
                      ),
                      StatPill(
                        icon: Icons.star_rounded,
                        value: '4.8★',
                        label: 'Rating',
                      ),
                    ]),
                  ),
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: DetailTabBar(
                      tabs: _tabs,
                      activeIndex: _activeTab,
                      onTap: (i) => setState(() => _activeTab = i),
                      activeColor: DetailColors.purple,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTabContent(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          Selector<TransactionViewModel, bool>(
            selector: (_, vm) => vm.hasPurchased(widget.product.id),
            builder: (context, isPurchased, _) => DetailStickyFooter(
              originalPrice: widget.product.formattedOriginalPrice,
              price: widget.product.formattedPriceFull,
              ctaLabel: _addingToCart ? 'Menambahkan...' : 'Beli & Download',
              ctaIcon: Icons.download_rounded,
              ctaGradient: const [DetailColors.purple, Color(0xFF6B0075)],
              shadowColor: DetailColors.purple,
              onTap: _addingToCart ? null : _addToCart,
              isPurchased: isPurchased,
              onAccessContent: isPurchased ? _onAccessContent : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Stack(
      children: [
        Container(
          height: 220,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [0.0, 0.6, 1.0],
              colors: [
                Color(0xFF6B0075),
                Color(0xFFA600B2),
                Color(0xB3A600B2),
              ],
            ),
          ),
        ),
        Positioned(
          right: -20,
          top: -20,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.07),
            ),
          ),
        ),
        // Document mockup visual
        Positioned(
          left: 0,
          right: 0,
          top: 60,
          child: Center(
            child: SizedBox(
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 80,
                    child: _docPaper(60, 100, 0.12),
                  ),
                  Positioned(
                    right: 80,
                    child: _docPaper(60, 110, 0.12),
                  ),
                  Container(
                    width: 68,
                    height: 88,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.35),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.menu_book_rounded,
                            size: 22, color: Colors.white),
                        const SizedBox(height: 6),
                        Container(
                          width: 36,
                          height: 2,
                          color: Colors.white.withOpacity(0.6),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 28,
                          height: 2,
                          color: Colors.white.withOpacity(0.35),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 16,
          child: DetailBackButton(onTap: () => Navigator.of(context).pop()),
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 54,
          left: 16,
          child: const HeroBadge(label: 'MODUL PDF'),
        ),
        Container(
            height: 220, color: Colors.transparent, width: double.infinity),
      ],
    );
  }

  Widget _docPaper(double w, double h, double opacity) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(opacity),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(6),
          bottom: Radius.circular(3),
        ),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_activeTab) {
      case 0:
        return _buildDeskripsi();
      case 1:
        return _buildDaftarIsi();
      case 2:
        return _buildUlasan();
    }
    return const SizedBox.shrink();
  }

  Widget _buildDeskripsi() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Modul komprehensif ini merangkum seluruh strategi yang '
            'digunakan oleh juara-juara lomba debat nasional. Cocok untuk '
            'persiapan individu maupun tim, dari pemula hingga advanced.',
            style: GoogleFonts.manrope(
              fontSize: 13,
              color: DetailColors.muted,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 20),
          const DetailSectionTitle('Termasuk dalam modul'),
          Column(
            children: _includes
                .map((h) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: HighlightRow(icon: h.$1, text: h.$2),
                    ))
                .toList(),
          ),
          const SizedBox(height: 18),
          // Preview teaser card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [DetailColors.navy, DetailColors.blue],
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'PDF',
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Bab 1 — Gratis',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Preview 18 halaman pertama',
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.65),
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DetailColors.yellow,
                    foregroundColor: DetailColors.yellowDark,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Baca',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaftarIsi() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '145 halaman · 7 bab utama',
            style: GoogleFonts.manrope(
              fontSize: 12,
              color: DetailColors.muted,
            ),
          ),
          const SizedBox(height: 12),
          for (int i = 0; i < _toc.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: DetailColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: i == 0
                            ? DetailColors.purple
                            : DetailColors.purpleFaint,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _toc[i].$1,
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: i == 0
                              ? Colors.white
                              : DetailColors.purple,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _toc[i].$2,
                            style: GoogleFonts.manrope(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: DetailColors.text,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Hal. ${_toc[i].$3}',
                            style: GoogleFonts.manrope(
                              fontSize: 11,
                              color: DetailColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (i == 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: DetailColors.greenFaint,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'GRATIS',
                          style: GoogleFonts.manrope(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: DetailColors.green,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUlasan() {
    return ReviewSection(
      productId: widget.product.id,
      barColor: DetailColors.purple,
    );
  }
}
