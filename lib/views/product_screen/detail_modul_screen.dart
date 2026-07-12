// ============================================
// FILE: lib/views/product_screen/detail_modul_screen.dart
// ============================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../models/product_model.dart';
import '../../services/product_service.dart';
import 'detail_data_helpers.dart';
import '../../viewmodels/cart_viewmodel.dart';
import '../../viewmodels/transaction_viewmodel.dart';
import '../../widgets/detail_widgets.dart';
import '../../widgets/review_section.dart';
import '../cart_screen.dart';
import '../learning/learning_content_screen.dart';

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

  final _productService = ProductService();
  Map<String, dynamic>? _detail;
  bool _loadingDetail = true;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    try {
      final data = await _productService.fetchProductDetail(widget.product.id);
      if (mounted) setState(() => _detail = data);
    } catch (_) {
      // Diamkan: UI tetap pakai data dasar dari widget.product.
    } finally {
      if (mounted) setState(() => _loadingDetail = false);
    }
  }

  // ── Helper data (real dari API, fallback ke nilai dasar) ────────────────
  int get _totalPages {
    final v = _detail?['total_pages'];
    if (v is int) return v;
    return int.tryParse('${v ?? ''}') ?? 0;
  }

  int get _students => _detail?['students'] is int
      ? _detail!['students'] as int
      : widget.product.students;

  double get _rating {
    final v = _detail?['rating'];
    if (v is num) return v.toDouble();
    return widget.product.rating;
  }

  // Rating dinamis dari rata-rata seluruh review user (endpoint show).
  int get _totalReviews {
    final v = _detail?['total_reviews'];
    return v is int ? v : int.tryParse('${v ?? ''}') ?? 0;
  }

  double get _ratingAvg {
    final v = _detail?['rating_avg'];
    return v is num ? v.toDouble() : 0;
  }

  String get _ratingStat =>
      _totalReviews > 0 ? '${_ratingAvg.toStringAsFixed(1)}★' : 'Baru';

  String get _description => (_detail?['description'] ?? '').toString();

  List<Map<String, dynamic>> get _includesData =>
      (_detail?['includes'] is List)
          ? (_detail!['includes'] as List)
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList()
          : const [];

  List<Map<String, dynamic>> get _chapters => (_detail?['chapters'] is List)
      ? (_detail!['chapters'] as List)
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList()
      : const [];

  Map<String, dynamic>? get _author =>
      _detail?['author'] is Map ? Map<String, dynamic>.from(_detail!['author'] as Map) : null;

  Map<String, dynamic>? get _freeChapter {
    for (final c in _chapters) {
      if (c['is_free'] == true || c['is_free'] == 1) return c;
    }
    return null;
  }


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
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LearningContentScreen(
          productId: widget.product.id,
          productTitle: widget.product.title,
          productType: widget.product.type.apiValue,
        ),
      ),
    );
  }

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
                          rating: _rating,
                          count: '$_students pembaca',
                        ),
                        const SizedBox(height: 14),
                        _buildMetaPills(),
                        const SizedBox(height: 16),
                        _buildAuthor(),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildStats(),
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
              color: Colors.white.withValues(alpha: 0.07),
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
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.35),
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
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 28,
                          height: 2,
                          color: Colors.white.withValues(alpha: 0.35),
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
      ],
    );
  }

  Widget _docPaper(double w, double h, double opacity) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: opacity),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(6),
          bottom: Radius.circular(3),
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
    );
  }

  Widget _buildMetaPills() {
    final pages = _totalPages;
    final chapters = _chapters.length;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        DetailMetaPill(
            icon: Icons.description_rounded,
            text: pages > 0 ? '$pages halaman' : 'PDF'),
        if (chapters > 0)
          DetailMetaPill(icon: Icons.menu_book_rounded, text: '$chapters bab'),
        const DetailMetaPill(
            icon: Icons.download_rounded, text: 'Download PDF'),
      ],
    );
  }

  Widget _buildAuthor() {
    final author = _author;
    if (author == null) return const SizedBox.shrink();
    final name = (author['name'] ?? '-').toString();
    return AuthorMiniCard(
      label: 'Ditulis oleh',
      name: name,
      subtitle: (author['title'] ?? '').toString(),
      initials: detailInitialsOf(name),
      gradient: const [Color(0xFFA600B2), Color(0xFF6B0075)],
    );
  }

  Widget _buildStats() {
    return StatsRow(pills: [
      // Kiri & tengah: fakta produk yang memang statis.
      const StatPill(
        icon: Icons.picture_as_pdf_rounded,
        value: 'PDF',
        label: 'Format',
      ),
      const StatPill(
        icon: Icons.all_inclusive_rounded,
        value: 'Selamanya',
        label: 'Akses',
      ),
      // Kanan: dinamis dari rata-rata rating semua user.
      StatPill(
        icon: Icons.star_rounded,
        value: _ratingStat,
        label: 'Rating',
      ),
    ]);
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
            _description.isNotEmpty
                ? _description
                : (_loadingDetail ? 'Memuat deskripsi…' : 'Deskripsi belum tersedia.'),
            style: GoogleFonts.manrope(
              fontSize: 13,
              color: DetailColors.muted,
              height: 1.7,
            ),
          ),
          if (_includesData.isNotEmpty) ...[
            const SizedBox(height: 20),
            const DetailSectionTitle('Termasuk dalam modul'),
            Column(
              children: _includesData
                  .map((h) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: HighlightRow(
                          icon: detailIconFor(h['icon']?.toString()),
                          text: (h['text'] ?? '').toString(),
                        ),
                      ))
                  .toList(),
            ),
          ],
          if (_freeChapter != null) ...[
          const SizedBox(height: 18),
          // Preview teaser card (bab gratis dari data produk)
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
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'PDF',
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.7),
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
                        'Bab ${_freeChapter!['chapter_number'] ?? '1'} — Gratis',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        (_freeChapter!['page_range'] ?? '').toString().isNotEmpty
                            ? 'Preview halaman ${_freeChapter!['page_range']}'
                            : 'Preview bab pertama',
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.65),
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
        ],
      ),
    );
  }

  Widget _buildDaftarIsi() {
    final chapters = _chapters;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _totalPages > 0
                ? '$_totalPages halaman · ${chapters.length} bab utama'
                : '${chapters.length} bab utama',
            style: GoogleFonts.manrope(
              fontSize: 12,
              color: DetailColors.muted,
            ),
          ),
          const SizedBox(height: 12),
          if (chapters.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                _loadingDetail
                    ? 'Memuat daftar isi…'
                    : 'Daftar isi belum tersedia.',
                style: GoogleFonts.manrope(
                    fontSize: 13, color: DetailColors.muted),
              ),
            ),
          for (int i = 0; i < chapters.length; i++)
            _buildChapterTile(i, chapters[i]),
        ],
      ),
    );
  }

  Widget _buildChapterTile(int i, Map<String, dynamic> ch) {
    final isFree = ch['is_free'] == true || ch['is_free'] == 1;
    final number = (ch['chapter_number'] ?? '${i + 1}').toString();
    final title = (ch['title'] ?? '-').toString();
    final pageRange = (ch['page_range'] ?? '').toString();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                color: isFree ? DetailColors.purple : DetailColors.purpleFaint,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                number,
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isFree ? Colors.white : DetailColors.purple,
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
                    title,
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: DetailColors.text,
                    ),
                  ),
                  if (pageRange.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Hal. $pageRange',
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        color: DetailColors.muted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isFree)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
    );
  }

  Widget _buildUlasan() {
    return ReviewSection(
      productId: widget.product.id,
      barColor: DetailColors.purple,
    );
  }
}
