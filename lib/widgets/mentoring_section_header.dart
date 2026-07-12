// ============================================
// FILE: lib/widgets/mentoring_section_header.dart
// ============================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MentoringSectionHeader extends StatelessWidget {
  const MentoringSectionHeader({
    super.key,
    required this.activeMentorCount,
  });

  final int activeMentorCount;

  static const Color _navy = Color(0xFF001261);
  static const Color _purple = Color(0xFFA600B2);
  static const Color _liveGreen = Color(0xFF4ADE80);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_navy, _navy.withValues(alpha: 0.85)],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Decorative blob
            Positioned(
              right: -16,
              top: -16,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _purple.withValues(alpha: 0.18),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(child: _buildLeft()),
                _buildRight(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeft() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
              const SizedBox(width: 4),
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
        const SizedBox(height: 6),
        Text(
          'On-Demand Mentoring',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '1-on-1 dengan mentor berpengalaman',
          style: GoogleFonts.manrope(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildRight() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$activeMentorCount',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        Text(
          'mentor\naktif',
          textAlign: TextAlign.right,
          style: GoogleFonts.manrope(
            fontSize: 10,
            color: Colors.white.withValues(alpha: 0.55),
            height: 1.3,
          ),
        ),
      ],
    );
  }
}
