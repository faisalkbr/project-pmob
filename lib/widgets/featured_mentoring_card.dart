// ============================================
// FILE: lib/widgets/featured_mentoring_card.dart
// Featured slot baru — highlight On-Demand Mentoring (gantikan
// FeaturedProductCard sesuai update design Mark-Up Prototype).
// ============================================

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/mentor_model.dart';

class FeaturedMentoringCard extends StatelessWidget {
  const FeaturedMentoringCard({
    super.key,
    required this.spotlightMentor,
    required this.totalActive,
    this.onCta,
  });

  final MentorModel? spotlightMentor;
  final int totalActive;
  final VoidCallback? onCta;

  static const Color _navy = Color(0xFF001261);
  static const Color _blue = Color(0xFF002196);
  static const Color _purple = Color(0xFFA600B2);
  static const Color _yellow = Color(0xFFF8E545);
  static const Color _yellowDark = Color(0xFF201C00);
  static const Color _liveGreen = Color(0xFF4ADE80);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.6, 1.0],
          colors: [_navy, _blue, _purple],
        ),
        boxShadow: [
          BoxShadow(
            color: _navy.withValues(alpha: 0.25),
            blurRadius: 40,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned(
              right: -28,
              top: -28,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _purple.withValues(alpha: 0.25),
                ),
              ),
            ),
            Positioned(
              left: 30,
              bottom: -16,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _yellow.withValues(alpha: 0.08),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBadgeRow(),
                  const SizedBox(height: 12),
                  _buildTitle(),
                  const SizedBox(height: 14),
                  if (spotlightMentor != null)
                    _buildSpotlightRow(spotlightMentor!),
                  const SizedBox(height: 16),
                  _buildCta(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgeRow() {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: _liveGreen.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: _liveGreen,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                'LIVE AVAILABLE',
                style: GoogleFonts.manrope(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: _liveGreen,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: _yellow,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Text(
            '$totalActive MENTOR AKTIF',
            style: GoogleFonts.manrope(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: _yellowDark,
              letterSpacing: 0.6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 240),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'On-Demand Mentoring',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 21,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '1-on-1 dengan mentor juara —\nfleksibel, sesuai kebutuhanmu.',
            style: GoogleFonts.manrope(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.7),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpotlightRow(MentorModel m) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: m.avatarGradient,
              ),
            ),
            alignment: Alignment.center,
            clipBehavior: Clip.antiAlias,
            child: m.resolvedAvatar.isEmpty
                ? Text(
                    m.initials,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  )
                : CachedNetworkImage(
                    imageUrl: m.resolvedAvatar,
                    width: 38,
                    height: 38,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Text(
                      m.initials,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        m.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.star_rounded,
                        size: 12, color: _yellow),
                    const SizedBox(width: 2),
                    Text(
                      m.formattedRating,
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  m.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.65),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCta() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Mulai dari',
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
              Text(
                'Rp 150K /sesi',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: onCta,
          icon: const Icon(Icons.calendar_today_rounded,
              size: 14, color: _yellowDark),
          label: Text(
            'Book Mentor',
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _yellowDark,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: _yellow,
            elevation: 0,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ],
    );
  }
}
