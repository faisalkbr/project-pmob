// ============================================
// FILE: lib/views/product_screen/detail_bootcamp_screen.dart
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

class DetailBootcampScreen extends StatefulWidget {
  const DetailBootcampScreen({super.key, required this.product});
  final ProductModel product;

  @override
  State<DetailBootcampScreen> createState() => _DetailBootcampScreenState();
}

class _DetailBootcampScreenState extends State<DetailBootcampScreen> {
  int _activeTab = 0;
  int _selectedBatch = 0;
  bool _addingToCart = false;

  static const _tabs = ['Deskripsi', 'Kurikulum', 'Ulasan'];

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

  String get _duration =>
      (_detail?['duration'] ?? widget.product.duration).toString();
  String get _description => (_detail?['description'] ?? '').toString();
  List<Map<String, dynamic>> get _includes => detailMapList(_detail?['includes']);
  List<Map<String, dynamic>> get _sections =>
      detailMapList(_detail?['curriculum_sections']);
  List<Map<String, dynamic>> get _batches => detailMapList(_detail?['batches']);

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
                            fontSize: 21,
                            fontWeight: FontWeight.w700,
                            color: DetailColors.navy,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 10),
                        StarRatingRow(
                          rating: _rating,
                          count: '$_students alumni',
                        ),
                        const SizedBox(height: 14),
                        _buildMetaPills(),
                        if (_batches.isNotEmpty) ...[
                          const SizedBox(height: 18),
                          Text(
                            'PILIH BATCH',
                            style: GoogleFonts.manrope(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: DetailColors.muted,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 10),
                          for (int i = 0; i < _batches.length; i++)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: _buildBatchCard(i, _batches[i]),
                            ),
                        ],
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
              ctaLabel: _addingToCart ? 'Menambahkan...' : 'Daftar Sekarang',
              ctaIcon: Icons.bolt_rounded,
              ctaGradient: const [DetailColors.navy, Color(0xFF1E3A8A)],
              onTap: _addingToCart ? null : _addToCart,
              isPurchased: isPurchased,
              onAccessContent: isPurchased ? _onAccessContent : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaPills() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (_duration.isNotEmpty)
          DetailMetaPill(icon: Icons.calendar_today_rounded, text: _duration),
        DetailMetaPill(
            icon: Icons.groups_rounded, text: '$_studentsLabel alumni'),
        if (_itemCount > 0)
          DetailMetaPill(
              icon: Icons.videocam_rounded, text: '$_itemCount live session'),
      ],
    );
  }

  Widget _buildStats() {
    return StatsRow(pills: [
      // Kiri & tengah: fakta produk yang memang statis.
      const StatPill(
        icon: Icons.videocam_rounded,
        value: 'Live',
        label: 'Format',
        iconColor: DetailColors.navy,
        iconBg: Color(0x14001261),
      ),
      const StatPill(
        icon: Icons.person_rounded,
        value: '1-on-1',
        label: 'Mentoring',
        iconColor: DetailColors.navy,
        iconBg: Color(0x14001261),
      ),
      // Kanan: dinamis dari rata-rata rating semua user.
      StatPill(
        icon: Icons.bolt_rounded,
        value: _ratingStat,
        label: 'Rating',
        iconColor: DetailColors.navy,
        iconBg: const Color(0x14001261),
      ),
    ]);
  }

  Widget _buildBatchCard(int idx, Map<String, dynamic> batch) {
    final selected = idx == _selectedBatch;
    final status = (batch['status'] ?? 'open').toString();
    final spots = _asInt(batch['spots']);
    return InkWell(
      onTap: () => setState(() => _selectedBatch = idx),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? DetailColors.navy : DetailColors.border,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    (batch['label'] ?? '-').toString(),
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: DetailColors.navy,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    (batch['date_range'] ?? '').toString(),
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      color: DetailColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: status == 'open'
                        ? const Color(0x14DC2626)
                        : DetailColors.surface,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    status == 'open'
                        ? 'Sisa $spots kursi'
                        : (status == 'closed' ? 'Ditutup' : 'Segera Buka'),
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: status == 'open'
                          ? DetailColors.red
                          : DetailColors.muted,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                if (selected)
                  Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: DetailColors.navy,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.check_rounded,
                        size: 11, color: Colors.white),
                  )
                else
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: DetailColors.border, width: 2),
                    ),
                  ),
              ],
            ),
          ],
        ),
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
                DetailColors.navy,
                Color(0xFF1E3A8A),
                Color(0xFF0F172A),
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
              color: DetailColors.yellow.withValues(alpha: 0.08),
            ),
          ),
        ),
        // Intensity bar visual
        Positioned(
          left: 0,
          right: 0,
          top: 60,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (i) {
                    final h = (i + 1) * 8.0;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 36,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15)),
                      ),
                      alignment: Alignment.bottomCenter,
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Container(
                        width: 20,
                        height: h,
                        decoration: BoxDecoration(
                          color: DetailColors.yellow
                              .withValues(alpha: 0.2 + (i + 1) * 0.18),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 10),
                Text(
                  '4 MINGGU INTENSIF',
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.55),
                    letterSpacing: 1.0,
                  ),
                ),
              ],
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
          child: Row(
            children: [
              const HeroBadge(label: 'BOOTCAMP'),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: Text(
                  '⚡ INTENSIF',
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
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
          if (_includes.isNotEmpty) ...[
            const SizedBox(height: 20),
            const DetailSectionTitle('Termasuk dalam bootcamp'),
            Column(
              children: _includes
                  .map((h) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: HighlightRow(
                          icon: detailIconFor(h['icon']?.toString()),
                          text: (h['text'] ?? '').toString(),
                          iconColor: DetailColors.navy,
                          iconBg: const Color(0x14001261),
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
            '${sections.length} bagian · $_itemCount sesi',
            style: GoogleFonts.manrope(
              fontSize: 12,
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
            : '${items.length} sesi';
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: CollapsibleSection(
        numberLabel: (i + 1).toString(),
        title: (section['title'] ?? '-').toString(),
        subtitle: subtitle,
        initiallyOpen: i == 0,
        activeColor: DetailColors.navy,
        activeBg: const Color(0x0A001261),
        children: [
          for (int j = 0; j < items.length; j++)
            CurriculumItem(
              title: (items[j]['title'] ?? '-').toString(),
              duration: (items[j]['duration']?.toString().isNotEmpty ?? false)
                  ? items[j]['duration'].toString()
                  : 'Live',
              icon: Icons.videocam_rounded,
              iconColor: DetailColors.navy,
              iconBg: const Color(0x14001261),
              showBorder: j < items.length - 1,
            ),
        ],
      ),
    );
  }

  Widget _buildUlasan() {
    return ReviewSection(
      productId: widget.product.id,
      barColor: DetailColors.navy,
    );
  }
}
