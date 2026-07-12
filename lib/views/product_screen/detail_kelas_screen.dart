// ============================================
// FILE: lib/views/product_screen/detail_kelas_screen.dart
// ============================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../models/product_model.dart';
import '../../services/product_service.dart';
import '../../viewmodels/cart_viewmodel.dart';
import '../../viewmodels/transaction_viewmodel.dart';
import '../../widgets/detail_widgets.dart';
import '../../widgets/review_section.dart';
import '../cart_screen.dart';
import '../learning/learning_content_screen.dart';
import 'detail_data_helpers.dart';

class DetailKelasScreen extends StatefulWidget {
  const DetailKelasScreen({super.key, required this.product});
  final ProductModel product;

  @override
  State<DetailKelasScreen> createState() => _DetailKelasScreenState();
}

class _DetailKelasScreenState extends State<DetailKelasScreen> {
  int _activeTab = 0;
  bool _addingToCart = false;

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
          content: Text('Gagal: $e',
              style: GoogleFonts.manrope(fontSize: 13)),
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

  static const List<String> _tabs = ['Deskripsi', 'Kurikulum', 'Ulasan'];

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
      // UI tetap pakai data dasar dari widget.product.
    } finally {
      if (mounted) setState(() => _loadingDetail = false);
    }
  }

  // ── Helper data (real dari API, fallback ke nilai dasar) ────────────────
  int _asInt(dynamic v) => v is int ? v : int.tryParse('${v ?? ''}') ?? 0;

  int get _students =>
      _detail?['students'] is int ? _detail!['students'] as int : widget.product.students;
  double get _rating {
    final v = _detail?['rating'];
    return v is num ? v.toDouble() : widget.product.rating;
  }

  // Rating dinamis dari rata-rata seluruh review user (endpoint show).
  int get _totalReviews => _asInt(_detail?['total_reviews']);
  double get _ratingAvg {
    final v = _detail?['rating_avg'];
    return v is num ? v.toDouble() : 0;
  }

  String get _ratingStat =>
      _totalReviews > 0 ? '${_ratingAvg.toStringAsFixed(1)}★' : 'Baru';

  String get _duration {
    final v = (_detail?['duration'] ?? widget.product.duration).toString();
    return v;
  }

  String get _description => (_detail?['description'] ?? '').toString();
  List<String> get _learnings => detailStringList(_detail?['learnings']);
  List<Map<String, dynamic>> get _includes => detailMapList(_detail?['includes']);
  List<Map<String, dynamic>> get _sections =>
      detailMapList(_detail?['curriculum_sections']);
  Map<String, dynamic>? get _author => _detail?['author'] is Map
      ? Map<String, dynamic>.from(_detail!['author'] as Map)
      : null;

  String get _studentsLabel =>
      _students >= 1000 ? '${(_students / 1000).toStringAsFixed(1)}k+' : '$_students+';

  int get _itemCount =>
      _sections.fold(0, (sum, s) => sum + detailMapList(s['items']).length);

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
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: DetailColors.navy,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 10),
                        StarRatingRow(
                          rating: _rating,
                          count: '$_students siswa',
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
              ctaLabel: _addingToCart ? 'Menambahkan...' : 'Beli Sekarang',
              ctaIcon: Icons.shopping_cart_outlined,
              ctaGradient: const [DetailColors.navy, DetailColors.blue],
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
              stops: [0.0, 0.5, 1.0],
              colors: [
                DetailColors.navy,
                DetailColors.blue,
                Color(0xE6A600B2),
              ],
            ),
          ),
        ),
        Positioned(
          right: -30,
          top: -30,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: DetailColors.purple.withValues(alpha: 0.2),
            ),
          ),
        ),
        // Faded book icon background
        Positioned(
          left: 0,
          right: 0,
          top: 60,
          child: Center(
            child: Icon(
              Icons.menu_book_rounded,
              size: 88,
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
        ),
        // Play button
        Positioned(
          left: 0,
          right: 0,
          top: 92,
          child: Center(
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.18),
                border:
                    Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2),
              ),
              child: const Icon(Icons.play_arrow_rounded,
                  size: 28, color: Colors.white),
            ),
          ),
        ),
        // Top controls
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 16,
          child: DetailBackButton(onTap: () => Navigator.of(context).pop()),
        ),
        // Hero badges
        Positioned(
          top: MediaQuery.of(context).padding.top + 54,
          left: 16,
          child: Row(
            children: [
              const HeroBadge(label: 'KELAS'),
              const SizedBox(width: 8),
              if (widget.product.isFeatured || widget.product.isBestseller)
                HeroBadge(
                  label: '🔥 TERPOPULER',
                  background: DetailColors.purple.withValues(alpha: 0.7),
                  foreground: Colors.white,
                ),
            ],
          ),
        ),
        const Positioned(
          left: 0,
          right: 0,
          bottom: 12,
          child: Center(
            child: Text(
              'PREVIEW GRATIS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xB3FFFFFF),
                letterSpacing: 0.6,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetaPills() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        DetailMetaPill(
            icon: Icons.groups_rounded, text: '$_studentsLabel siswa'),
        if (_duration.isNotEmpty)
          DetailMetaPill(icon: Icons.access_time_rounded, text: _duration),
        if (_itemCount > 0)
          DetailMetaPill(
              icon: Icons.menu_book_rounded, text: '$_itemCount materi'),
      ],
    );
  }

  Widget _buildAuthor() {
    final author = _author;
    if (author == null) return const SizedBox.shrink();
    final name = (author['name'] ?? '-').toString();
    return AuthorMiniCard(
      label: 'Dibuat oleh',
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
        icon: Icons.play_circle_fill_rounded,
        value: 'Online',
        label: 'Format',
      ),
      const StatPill(
        icon: Icons.all_inclusive_rounded,
        value: 'Selamanya',
        label: 'Akses',
      ),
      // Kanan: dinamis dari rata-rata rating semua user.
      StatPill(
        icon: Icons.bolt_rounded,
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
        return _buildKurikulum();
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
                : (_loadingDetail
                    ? 'Memuat deskripsi…'
                    : 'Deskripsi belum tersedia.'),
            style: GoogleFonts.manrope(
              fontSize: 13,
              color: DetailColors.muted,
              height: 1.7,
            ),
          ),
          if (_learnings.isNotEmpty) ...[
          const SizedBox(height: 20),
          const DetailSectionTitle('Yang akan kamu pelajari'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: DetailColors.border),
            ),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 3,
              ),
              itemCount: _learnings.length,
              itemBuilder: (_, i) => Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    margin: const EdgeInsets.only(top: 1),
                    decoration: BoxDecoration(
                      color: DetailColors.purpleFaint,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Icon(Icons.check_rounded,
                        size: 11, color: DetailColors.purple),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _learnings[i],
                      style: GoogleFonts.manrope(
                        fontSize: 11.5,
                        color: DetailColors.text,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ],
          if (_includes.isNotEmpty) ...[
            const SizedBox(height: 20),
            const DetailSectionTitle('Termasuk dalam kelas ini'),
            Column(
              children: _includes
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
        ],
      ),
    );
  }

  Widget _buildKurikulum() {
    final sections = _sections;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${sections.length} bagian · $_itemCount materi'
            '${_duration.isNotEmpty ? ' · $_duration' : ''}',
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: DetailColors.muted,
            ),
          ),
          const SizedBox(height: 12),
          if (sections.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                _loadingDetail
                    ? 'Memuat kurikulum…'
                    : 'Kurikulum belum tersedia.',
                style: GoogleFonts.manrope(
                    fontSize: 13, color: DetailColors.muted),
              ),
            ),
          for (int i = 0; i < sections.length; i++)
            _buildSectionTile(i, sections[i]),
        ],
      ),
    );
  }

  Widget _buildSectionTile(int i, Map<String, dynamic> section) {
    final items = detailMapList(section['items']);
    final subtitle =
        (section['subtitle']?.toString().isNotEmpty ?? false)
            ? section['subtitle'].toString()
            : '${items.length} materi';
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: CollapsibleSection(
        numberLabel: (i + 1).toString().padLeft(2, '0'),
        title: (section['title'] ?? '-').toString(),
        subtitle: subtitle,
        initiallyOpen: i == 0,
        children: [
          for (int j = 0; j < items.length; j++)
            _buildCurriculumItemRow(items[j], j < items.length - 1),
        ],
      ),
    );
  }

  Widget _buildCurriculumItemRow(Map<String, dynamic> item, bool showBorder) {
    final isVideo = (item['type']?.toString().toLowerCase() == 'video');
    return CurriculumItem(
      title: (item['title'] ?? '-').toString(),
      duration: (item['duration'] ?? '').toString(),
      icon: isVideo ? Icons.play_arrow_rounded : Icons.description_rounded,
      iconColor: isVideo ? DetailColors.blue : DetailColors.purple,
      iconBg: isVideo ? const Color(0x140033A6) : DetailColors.purpleFaint,
      showBorder: showBorder,
    );
  }

  Widget _buildUlasan() {
    return ReviewSection(productId: widget.product.id);
  }
}
