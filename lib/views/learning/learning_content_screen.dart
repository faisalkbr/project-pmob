// ============================================
// FILE: lib/views/learning/learning_content_screen.dart
// ============================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/product_content_model.dart';
import '../../services/product_service.dart';

/// Layar "belajar": menampilkan konten produk (modul/kelas/bootcamp) secara
/// adaptif. Item video/pdf/live dibuka lewat URL eksternal (url_launcher).
/// Item terkunci (belum dibeli & bukan preview) tampil dengan gembok.
class LearningContentScreen extends StatefulWidget {
  const LearningContentScreen({
    super.key,
    required this.productId,
    required this.productTitle,
    required this.productType,
  });

  final int productId;
  final String productTitle;
  final String productType; // modul | kelas | bootcamp

  @override
  State<LearningContentScreen> createState() => _LearningContentScreenState();
}

class _LearningContentScreenState extends State<LearningContentScreen> {
  static const Color _bg = Color(0xFFFBFAFF);
  static const Color _navy = Color(0xFF001261);
  static const Color _purple = Color(0xFFA600B2);
  static const Color _muted = Color(0xFF757684);
  static const Color _border = Color(0x14001261);
  static const Color _green = Color(0xFF16A34A);

  final _service = ProductService();
  ProductContent? _content;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final content = await _service.fetchProductContent(widget.productId);
      if (mounted) setState(() => _content = content);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openItem(ContentItem item) async {
    if (item.locked) {
      _snack('Beli produk ini untuk membuka materi.', _navy);
      return;
    }
    final url = item.contentUrl ?? '';
    if (url.isEmpty) {
      _snack('Materi belum tersedia.', _muted);
      return;
    }
    final uri = Uri.tryParse(url);
    if (uri == null) {
      _snack('Tautan materi tidak valid.', Colors.red.shade700);
      return;
    }
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      _snack('Tidak bisa membuka tautan materi.', Colors.red.shade700);
    }
  }

  void _snack(String msg, Color bg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.manrope(fontSize: 13)),
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: Text(
          'Materi Belajar',
          style: GoogleFonts.spaceGrotesk(
              fontWeight: FontWeight.w700, fontSize: 17, color: Colors.white),
        ),
        backgroundColor: _navy,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: _purple));
    }
    if (_error != null) {
      return _ErrorState(message: _error!, onRetry: _load);
    }
    final content = _content;
    if (content == null || content.sections.isEmpty) {
      return Center(
        child: Text('Belum ada materi.',
            style: GoogleFonts.manrope(color: _muted)),
      );
    }

    return RefreshIndicator(
      color: _purple,
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _buildHeaderCard(content),
          const SizedBox(height: 16),
          for (final section in content.sections) ...[
            _buildSectionHeader(section),
            const SizedBox(height: 8),
            for (final item in section.items) _buildItemTile(item),
            const SizedBox(height: 16),
          ],
          if (content.batches.isNotEmpty) _buildBatches(content.batches),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(ProductContent content) {
    final progress =
        content.totalItems == 0 ? 0.0 : content.unlockedItems / content.totalItems;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_navy, Color(0xFF4B0060)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _typeBadge(content.type),
              const Spacer(),
              if (content.purchased)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _green.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _green.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified_rounded,
                          size: 13, color: Color(0xFF34D399)),
                      const SizedBox(width: 4),
                      Text('Dimiliki',
                          style: GoogleFonts.manrope(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF34D399))),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content.title,
            style: GoogleFonts.spaceGrotesk(
                fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: Colors.white.withValues(alpha: 0.15),
              valueColor:
                  const AlwaysStoppedAnimation(Color(0xFF34D399)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${content.unlockedItems} dari ${content.totalItems} materi terbuka',
            style: GoogleFonts.manrope(
                fontSize: 12, color: Colors.white.withValues(alpha: 0.75)),
          ),
        ],
      ),
    );
  }

  Widget _typeBadge(String type) {
    final label = switch (type) {
      'kelas' => 'KELAS',
      'bootcamp' => 'BOOTCAMP',
      _ => 'MODUL',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: GoogleFonts.manrope(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: Colors.white)),
    );
  }

  Widget _buildSectionHeader(ContentSection section) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title,
            style: GoogleFonts.spaceGrotesk(
                fontSize: 15, fontWeight: FontWeight.w700, color: _navy),
          ),
          if ((section.subtitle ?? '').isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(section.subtitle!,
                style: GoogleFonts.manrope(fontSize: 12, color: _muted)),
          ],
        ],
      ),
    );
  }

  Widget _buildItemTile(ContentItem item) {
    final (icon, tint) = _visualFor(item.type);
    final locked = item.locked;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _openItem(item),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
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
                    color: locked
                        ? const Color(0x0A001261)
                        : tint.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    locked ? Icons.lock_rounded : icon,
                    size: 20,
                    color: locked ? _muted : tint,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.title,
                        style: GoogleFonts.manrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: locked ? _muted : _navy,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Text(_typeLabel(item.type),
                              style: GoogleFonts.manrope(
                                  fontSize: 11, color: _muted)),
                          if (item.duration.isNotEmpty) ...[
                            Text('  ·  ',
                                style: GoogleFonts.manrope(
                                    fontSize: 11, color: _muted)),
                            Text(item.duration,
                                style: GoogleFonts.manrope(
                                    fontSize: 11, color: _muted)),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (item.isFree && locked)
                  _pill('PREVIEW', _green)
                else if (item.isFree)
                  _pill('GRATIS', _green),
                const SizedBox(width: 6),
                Icon(
                  locked ? Icons.lock_outline_rounded : Icons.play_circle_fill_rounded,
                  size: 22,
                  color: locked ? _muted : _purple,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _pill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text,
          style: GoogleFonts.manrope(
              fontSize: 10, fontWeight: FontWeight.w700, color: color)),
    );
  }

  Widget _buildBatches(List<ContentBatch> batches) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Jadwal Batch',
            style: GoogleFonts.spaceGrotesk(
                fontSize: 15, fontWeight: FontWeight.w700, color: _navy)),
        const SizedBox(height: 8),
        for (final b in batches)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _border),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_rounded,
                    size: 18, color: _purple),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(b.label,
                          style: GoogleFonts.manrope(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _navy)),
                      if (b.dateRange.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(b.dateRange,
                            style: GoogleFonts.manrope(
                                fontSize: 11, color: _muted)),
                      ],
                    ],
                  ),
                ),
                Text('${b.spots} kursi',
                    style: GoogleFonts.manrope(fontSize: 11, color: _muted)),
              ],
            ),
          ),
      ],
    );
  }

  String _typeLabel(ContentType type) => switch (type) {
        ContentType.video => 'Video',
        ContentType.pdf => 'PDF',
        ContentType.live => 'Sesi Live',
      };

  (IconData, Color) _visualFor(ContentType type) => switch (type) {
        ContentType.video => (Icons.play_circle_fill_rounded, _purple),
        ContentType.pdf => (Icons.picture_as_pdf_rounded, const Color(0xFFE0245E)),
        ContentType.live => (Icons.podcasts_rounded, const Color(0xFF2563EB)),
      };
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded,
                size: 44, color: Color(0xFF757684)),
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
              child: Text('Coba Lagi',
                  style: GoogleFonts.manrope(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}
