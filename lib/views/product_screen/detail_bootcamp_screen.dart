// ============================================
// FILE: lib/views/product_screen/detail_bootcamp_screen.dart
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

  static const _batches = [
    _Batch('Batch 5 — Mei 2026', '5 Mei – 2 Jun 2026', 8, 'open'),
    _Batch('Batch 6 — Juni 2026', '2 Jun – 30 Jun 2026', 20, 'soon'),
  ];

  static const _weeks = [
    _Week('Minggu 1', 'Fondasi & Mindset Juara', [
      'Orientasi & pengenalan tim',
      'Framework analisis bisnis',
      'Riset kompetitif cepat',
      'Live session: Mentor Q&A',
    ]),
    _Week('Minggu 2', 'Riset Mendalam & Ideasi', [
      'Metodologi riset advanced',
      'Design thinking untuk lomba',
      'Workshop ideasi solusi',
      'Review & feedback sesi 1',
    ]),
    _Week('Minggu 3', 'Bangun Solusi & Pitch Deck', [
      'Struktur solusi bisnis',
      'Storytelling dengan data',
      'Desain slide presentasi',
      'Mock pitch internal',
    ]),
    _Week('Minggu 4', 'Simulasi & Final Prep', [
      'Simulasi lomba penuh',
      'Teknik Q&A dengan juri',
      'Revisi final pitch',
      'Sesi motivasi & closing',
    ]),
  ];

  static const _includes = [
    (Icons.videocam_rounded, '16 live session Zoom (rekaman tersedia)'),
    (Icons.groups_rounded, '1 sesi 1-on-1 mentoring eksklusif'),
    (Icons.menu_book_rounded, 'Materi & workbook lengkap (150+ hal)'),
    (Icons.bolt_rounded, 'Grup WhatsApp mentor aktif 30 hari'),
    (Icons.emoji_events_rounded, 'Studi kasus lomba tingkat nasional'),
    (Icons.verified_rounded, 'Sertifikat bootcamp resmi Mark-Up'),
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
                                icon: Icons.calendar_today_rounded,
                                text: '30 hari program'),
                            DetailMetaPill(
                                icon: Icons.groups_rounded,
                                text: '320+ alumni'),
                            DetailMetaPill(
                                icon: Icons.videocam_rounded,
                                text: '16 live session'),
                          ],
                        ),
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
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const StatsRow(pills: [
                      StatPill(
                        icon: Icons.emoji_events_rounded,
                        value: '92%',
                        label: 'Finalis Lomba',
                        iconColor: DetailColors.navy,
                        iconBg: Color(0x14001261),
                      ),
                      StatPill(
                        icon: Icons.groups_rounded,
                        value: '320+',
                        label: 'Alumni',
                        iconColor: DetailColors.navy,
                        iconBg: Color(0x14001261),
                      ),
                      StatPill(
                        icon: Icons.bolt_rounded,
                        value: '4.9★',
                        label: 'Rating',
                        iconColor: DetailColors.navy,
                        iconBg: Color(0x14001261),
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

  Widget _buildBatchCard(int idx, _Batch batch) {
    final selected = idx == _selectedBatch;
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
                    batch.label,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: DetailColors.navy,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    batch.date,
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
                    color: batch.status == 'open'
                        ? const Color(0x14DC2626)
                        : DetailColors.surface,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    batch.status == 'open'
                        ? 'Sisa ${batch.spots} kursi'
                        : 'Segera Buka',
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: batch.status == 'open'
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
              color: DetailColors.yellow.withOpacity(0.08),
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
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.15)),
                      ),
                      alignment: Alignment.bottomCenter,
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Container(
                        width: 20,
                        height: h,
                        decoration: BoxDecoration(
                          color: DetailColors.yellow
                              .withOpacity(0.2 + (i + 1) * 0.18),
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
                    color: Colors.white.withOpacity(0.55),
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
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
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
        Container(
            height: 220, color: Colors.transparent, width: double.infinity),
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
            'Program bootcamp intensif 30 hari yang dirancang untuk membawa '
            'kamu dari nol hingga siap memenangkan lomba business plan '
            'tingkat nasional. Dengan metode learning-by-doing, setiap '
            'minggu kamu akan mengerjakan proyek nyata dengan bimbingan '
            'langsung dari mentor.',
            style: GoogleFonts.manrope(
              fontSize: 13,
              color: DetailColors.muted,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 20),
          const DetailSectionTitle('Termasuk dalam bootcamp'),
          Column(
            children: _includes
                .map((h) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: HighlightRow(
                        icon: h.$1,
                        text: h.$2,
                        iconColor: DetailColors.navy,
                        iconBg: const Color(0x14001261),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildKurikulum() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '4 minggu · 16 live session',
            style: GoogleFonts.manrope(
              fontSize: 12,
              color: DetailColors.muted,
            ),
          ),
          const SizedBox(height: 12),
          for (int i = 0; i < _weeks.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: CollapsibleSection(
                numberLabel: (i + 1).toString(),
                title: '${_weeks[i].week} · ${_weeks[i].title}',
                subtitle: '${_weeks[i].items.length} sesi',
                initiallyOpen: i == 0,
                activeColor: DetailColors.navy,
                activeBg: const Color(0x0A001261),
                children: [
                  for (int j = 0; j < _weeks[i].items.length; j++)
                    CurriculumItem(
                      title: _weeks[i].items[j],
                      duration: 'Live',
                      icon: Icons.videocam_rounded,
                      iconColor: DetailColors.navy,
                      iconBg: const Color(0x14001261),
                      showBorder: j < _weeks[i].items.length - 1,
                    ),
                ],
              ),
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

class _Batch {
  final String label;
  final String date;
  final int spots;
  final String status;
  const _Batch(this.label, this.date, this.spots, this.status);
}

class _Week {
  final String week;
  final String title;
  final List<String> items;
  const _Week(this.week, this.title, this.items);
}
