// ============================================
// FILE: lib/widgets/review_section.dart
// ============================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/review_model.dart';
import '../viewmodels/review_viewmodel.dart';
import '../widgets/detail_widgets.dart';
import 'add_review_sheet.dart';

/// Widget pengganti _buildUlasan() di semua detail screen.
/// Mengurus state sendiri via ChangeNotifierProvider lokal.
class ReviewSection extends StatelessWidget {
  const ReviewSection({
    super.key,
    required this.productId,
    this.barColor = DetailColors.purple,
  });

  final int productId;
  final Color barColor;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ReviewViewModel>(
      create: (_) => ReviewViewModel()..load(productId),
      child: _ReviewBody(productId: productId, barColor: barColor),
    );
  }
}

class _ReviewBody extends StatefulWidget {
  const _ReviewBody({required this.productId, required this.barColor});

  final int productId;
  final Color barColor;

  @override
  State<_ReviewBody> createState() => _ReviewBodyState();
}

class _ReviewBodyState extends State<_ReviewBody> {
  static const Color _navy = Color(0xFF001261);
  static const Color _purple = Color(0xFFA600B2);
  static const Color _muted = Color(0xFF757684);
  static const Color _border = Color(0x14001261);
  static const Color _purpleFaint = Color(0x14A600B2);

  bool _expanded = false;

  Future<void> _openAddReview(ReviewViewModel vm) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => AddReviewSheet(productId: widget.productId, vm: vm),
    );
    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ulasan berhasil dikirim!',
              style: GoogleFonts.manrope(fontSize: 13)),
          backgroundColor: _navy,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReviewViewModel>(
      builder: (_, vm, __) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Summary card ──────────────────────────────────────────────
              _buildSummaryCard(vm),
              const SizedBox(height: 12),

              // ── Tulis Ulasan button ───────────────────────────────────────
              _buildAddButton(vm),
              const SizedBox(height: 14),

              // ── Review list ───────────────────────────────────────────────
              if (vm.isLoading)
                const _ReviewSkeleton()
              else if (vm.state == ReviewState.error)
                _ErrorBlock(
                  message: vm.error!,
                  onRetry: () => vm.retry(widget.productId),
                )
              else if (vm.reviews.isEmpty)
                _EmptyReviews(onAdd: () => _openAddReview(vm))
              else ...[
                _buildReviewList(vm),
                const SizedBox(height: 12),
                // Load more / collapse
                _buildExpandButton(vm),
              ],
            ],
          ),
        );
      },
    );
  }

  // ── Summary card ────────────────────────────────────────────────────────────

  Widget _buildSummaryCard(ReviewViewModel vm) {
    if (vm.isLoading || vm.state == ReviewState.error) {
      return RatingSummaryCard(
        rating: 0,
        totalReviews: 0,
        distribution: const [0, 0, 0, 0, 0],
        barColor: widget.barColor,
      );
    }
    return RatingSummaryCard(
      rating: vm.summary.ratingAvg,
      totalReviews: vm.summary.total,
      distribution: vm.summary.distribution,
      barColor: widget.barColor,
    );
  }

  // ── Add review button ────────────────────────────────────────────────────────

  Widget _buildAddButton(ReviewViewModel vm) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _openAddReview(vm),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: _purple, width: 1.5),
          foregroundColor: _purple,
          backgroundColor: _purpleFaint,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon: const Icon(Icons.edit_rounded, size: 15),
        label: Text(
          'Tulis Ulasan',
          style: GoogleFonts.manrope(
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  // ── Review list ─────────────────────────────────────────────────────────────

  Widget _buildReviewList(ReviewViewModel vm) {
    if (!_expanded) {
      // Preview: horizontal scroll (first 5)
      final preview = vm.reviews.take(5).toList();
      return SizedBox(
        height: 168,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: preview.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, i) => _LiveReviewCard(
            review: preview[i],
            onDelete: preview[i].canDelete
                ? () => vm.deleteReview(preview[i].id)
                : null,
          ),
        ),
      );
    }

    // Expanded: vertical list
    return Column(
      children: [
        for (final r in vm.reviews) ...[
          _LiveReviewCard(
            review: r,
            horizontal: false,
            onDelete: r.canDelete ? () => vm.deleteReview(r.id) : null,
          ),
          const SizedBox(height: 10),
        ],
        if (vm.isLoadingMore)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: CircularProgressIndicator(color: _purple),
          ),
      ],
    );
  }

  // ── Expand / load-more button ────────────────────────────────────────────────

  Widget _buildExpandButton(ReviewViewModel vm) {
    if (!_expanded) {
      final remaining = vm.summary.total - vm.reviews.take(5).length;
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () => setState(() => _expanded = true),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: _border, width: 1.5),
            foregroundColor: _navy,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
          child: Text(
            remaining > 0
                ? 'Lihat Semua $remaining+ Ulasan →'
                : 'Lihat Semua Ulasan →',
            style: GoogleFonts.manrope(
                fontSize: 13, fontWeight: FontWeight.w700),
          ),
        ),
      );
    }

    // Expanded: load more / collapse
    return Column(
      children: [
        if (vm.hasMore)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: vm.isLoadingMore
                  ? null
                  : () => vm.loadMore(widget.productId),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: _border, width: 1.5),
                foregroundColor: _navy,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                'Muat Lebih Banyak',
                style: GoogleFonts.manrope(
                    fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => setState(() => _expanded = false),
          child: Text(
            '↑ Tutup',
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _muted,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Live review card (dari API) ─────────────────────────────────────────────

class _LiveReviewCard extends StatelessWidget {
  const _LiveReviewCard({
    required this.review,
    this.horizontal = true,
    this.onDelete,
  });

  final ReviewModel review;
  final bool horizontal;
  final VoidCallback? onDelete;

  static const Color _muted = Color(0xFF757684);
  static const Color _border = Color(0x14001261);
  static const Color _text = Color(0xFF1A1B22);
  static const Color _red = Color(0xFFE53935);

  @override
  Widget build(BuildContext context) {
    final gradientColors = review.avatarGradientRaw
        .map((v) => Color(v))
        .toList();

    return Container(
      width: horizontal ? 240 : double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradientColors,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  review.initials,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      review.userName,
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _text,
                      ),
                    ),
                    Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          Icons.star_rounded,
                          size: 9,
                          color: i < review.rating
                              ? DetailColors.purple
                              : DetailColors.surface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (onDelete != null)
                GestureDetector(
                  onTap: onDelete,
                  child: const Icon(Icons.delete_outline_rounded,
                      size: 16, color: _red),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            review.comment,
            maxLines: horizontal ? 4 : 10,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.manrope(
              fontSize: 12,
              color: _muted,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            review.formattedDate,
            style: GoogleFonts.manrope(fontSize: 10, color: _muted),
          ),
        ],
      ),
    );
  }
}

// ── Skeleton loader ─────────────────────────────────────────────────────────

class _ReviewSkeleton extends StatelessWidget {
  const _ReviewSkeleton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 158,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, __) => Container(
          width: 240,
          decoration: BoxDecoration(
            color: const Color(0xFFF2F0F8),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

// ── Empty state ─────────────────────────────────────────────────────────────

class _EmptyReviews extends StatelessWidget {
  const _EmptyReviews({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.rate_review_outlined,
              size: 36, color: Color(0xFFD1CFE8)),
          const SizedBox(height: 8),
          Text(
            'Belum ada ulasan',
            style: GoogleFonts.manrope(
              fontSize: 13,
              color: const Color(0xFF757684),
            ),
          ),
          const SizedBox(height: 4),
          TextButton(
            onPressed: onAdd,
            child: Text(
              'Jadilah yang pertama!',
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFA600B2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Error block ─────────────────────────────────────────────────────────────

class _ErrorBlock extends StatelessWidget {
  const _ErrorBlock({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Icon(Icons.cloud_off_rounded,
              color: Colors.grey.shade400, size: 32),
          const SizedBox(height: 6),
          Text(message,
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                  fontSize: 12, color: const Color(0xFF757684))),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onRetry,
            child: Text('Coba Lagi',
                style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF001261))),
          ),
        ],
      ),
    );
  }
}
