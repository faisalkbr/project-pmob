// ============================================
// FILE: lib/views/product_screen/detail_kelas_screen.dart
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

  static const List<String> _tabs = ['Deskripsi', 'Kurikulum', 'Ulasan'];

  // Dummy data — di production diambil dari endpoint /products/{id}/curriculum
  static const _curriculum = [
    _Section(
      title: 'Fondasi Business Case',
      lessons: '4 materi',
      items: [
        _Item('Apa itu Business Case Competition?', '8 mnt', isVideo: true),
        _Item('Framework Analisis: SWOT & PESTLE', '14 mnt', isVideo: true),
        _Item('Modul Pendahuluan (PDF)', '12 hal', isVideo: false),
        _Item('Quiz Fondasi', '10 soal', isVideo: false),
      ],
    ),
    _Section(
      title: 'Riset & Analisis Data',
      lessons: '5 materi',
      items: [
        _Item('Metode Riset Cepat untuk Lomba', '18 mnt', isVideo: true),
        _Item('Mengolah Data dengan Storytelling', '22 mnt', isVideo: true),
        _Item('Template Riset Lomba', '8 hal', isVideo: false),
        _Item('Studi Kasus: FMCG Industry', '15 mnt', isVideo: true),
        _Item('Latihan Analisis Mandiri', '5 soal', isVideo: false),
      ],
    ),
    _Section(
      title: 'Membangun Solusi & Pitch',
      lessons: '4 materi',
      items: [
        _Item('Struktur Solusi yang Memenangkan Juri', '20 mnt', isVideo: true),
        _Item('Cara Membuat Pitch yang Berkesan', '25 mnt', isVideo: true),
        _Item('Template Slide Presentasi', '15 hal', isVideo: false),
        _Item('Mock Pitch Session', '30 mnt', isVideo: true),
      ],
    ),
    _Section(
      title: 'Simulasi Lomba & Q&A',
      lessons: '3 materi',
      items: [
        _Item('Simulasi Full Case Competition', '45 mnt', isVideo: true),
        _Item('Teknik Menjawab Pertanyaan Juri', '18 mnt', isVideo: true),
        _Item('Bank Soal Latihan (50 kasus)', '50 kasus', isVideo: false),
      ],
    ),
  ];

  static const _learnings = [
    'Analisis kasus dengan framework profesional',
    'Membangun solusi yang memenangkan juri',
    'Teknik riset dan storytelling data',
    'Pitch presentasi yang memukau',
    'Manajemen waktu saat kompetisi',
    'Strategi Q&A menghadapi juri',
  ];

  static const _highlights = [
    (Icons.videocam_rounded, '16 video materi (8+ jam total)'),
    (Icons.description_rounded, '12 modul PDF + template siap pakai'),
    (Icons.emoji_events_rounded, 'Studi kasus dari lomba nasional nyata'),
    (Icons.bolt_rounded, 'Akses seumur hidup + update gratis'),
    (Icons.groups_rounded, 'Komunitas alumni eksklusif'),
    (Icons.verified_rounded, 'Sertifikat penyelesaian resmi'),
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
                            fontSize: 22,
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
                                icon: Icons.groups_rounded, text: '1.2k+ siswa'),
                            DetailMetaPill(
                                icon: Icons.access_time_rounded,
                                text: '8+ jam materi'),
                            DetailMetaPill(
                                icon: Icons.menu_book_rounded, text: '16 modul'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const AuthorMiniCard(
                          label: 'Dibuat oleh',
                          name: 'Rizka Nabilah',
                          subtitle: '3× Juara Case Competition Nasional',
                          initials: 'RN',
                          gradient: [Color(0xFFA600B2), Color(0xFF6B0075)],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const StatsRow(pills: [
                      StatPill(
                        icon: Icons.emoji_events_rounded,
                        value: '87%',
                        label: 'Tingkat Menang',
                      ),
                      StatPill(
                        icon: Icons.groups_rounded,
                        value: '1.2k+',
                        label: 'Alumni',
                      ),
                      StatPill(
                        icon: Icons.bolt_rounded,
                        value: '4.9★',
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
              color: DetailColors.purple.withOpacity(0.2),
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
              color: Colors.white.withOpacity(0.12),
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
                color: Colors.white.withOpacity(0.18),
                border:
                    Border.all(color: Colors.white.withOpacity(0.4), width: 2),
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
                  background: DetailColors.purple.withOpacity(0.7),
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
        // Spacer to define height
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
            'Kelas ini dirancang khusus untuk mahasiswa yang ingin '
            'memenangkan lomba business case tingkat nasional dan '
            'internasional. Dipandu langsung oleh mentor berpengalaman '
            'yang telah memenangkan 3 kompetisi bergengsi.',
            style: GoogleFonts.manrope(
              fontSize: 13,
              color: DetailColors.muted,
              height: 1.7,
            ),
          ),
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
          const SizedBox(height: 20),
          const DetailSectionTitle('Termasuk dalam kelas ini'),
          Column(
            children: _highlights
                .map((h) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: HighlightRow(icon: h.$1, text: h.$2),
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
            '4 bagian · 16 materi · 8+ jam',
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: DetailColors.muted,
            ),
          ),
          const SizedBox(height: 12),
          for (int i = 0; i < _curriculum.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: CollapsibleSection(
                numberLabel: (i + 1).toString().padLeft(2, '0'),
                title: _curriculum[i].title,
                subtitle: _curriculum[i].lessons,
                initiallyOpen: i == 0,
                children: [
                  for (int j = 0; j < _curriculum[i].items.length; j++)
                    CurriculumItem(
                      title: _curriculum[i].items[j].title,
                      duration: _curriculum[i].items[j].duration,
                      icon: _curriculum[i].items[j].isVideo
                          ? Icons.play_arrow_rounded
                          : Icons.description_rounded,
                      iconColor: _curriculum[i].items[j].isVideo
                          ? DetailColors.blue
                          : DetailColors.purple,
                      iconBg: _curriculum[i].items[j].isVideo
                          ? const Color(0x140033A6)
                          : DetailColors.purpleFaint,
                      showBorder: j < _curriculum[i].items.length - 1,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUlasan() {
    return ReviewSection(productId: widget.product.id);
  }
}

class _Section {
  final String title;
  final String lessons;
  final List<_Item> items;
  const _Section({
    required this.title,
    required this.lessons,
    required this.items,
  });
}

class _Item {
  final String title;
  final String duration;
  final bool isVideo;
  const _Item(this.title, this.duration, {required this.isVideo});
}
