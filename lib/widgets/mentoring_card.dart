// ============================================
// FILE: lib/widgets/mentoring_card.dart
// ============================================

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/mentor_model.dart';

class MentoringCard extends StatelessWidget {
  const MentoringCard({
    super.key,
    required this.mentor,
    this.onBook,
  });

  final MentorModel mentor;
  final VoidCallback? onBook;

  static const Color _navy = Color(0xFF001261);
  static const Color _blue = Color(0xFF002196);
  static const Color _purple = Color(0xFFA600B2);
  static const Color _green = Color(0xFF16A34A);
  static const Color _muted = Color(0xFF757684);
  static const Color _text = Color(0xFF1A1B22);
  static const Color _surface = Color(0xFFF2F0F8);
  static const Color _border = Color(0x14001261);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: _navy.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopRow(),
          if (mentor.tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildTags(),
          ],
          const SizedBox(height: 12),
          _buildPriceAndCta(),
        ],
      ),
    );
  }

  Widget _buildTopRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAvatar(),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                mentor.name,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _text,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                mentor.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  color: _muted,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.star_rounded, size: 12, color: _purple),
                  const SizedBox(width: 3),
                  Text(
                    mentor.formattedRating,
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _text,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${mentor.sessions} sesi',
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      color: _muted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _buildAvailabilityChip(),
      ],
    );
  }

  Widget _buildAvatar() {
    final url = mentor.resolvedAvatar;
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: mentor.avatarGradient,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: url.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              width: 52,
              height: 52,
              errorWidget: (_, __, ___) => _initialsText(),
            )
          : _initialsText(),
    );
  }

  Widget _initialsText() {
    return Text(
      mentor.initials,
      style: GoogleFonts.spaceGrotesk(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    );
  }

  Widget _buildAvailabilityChip() {
    final color = mentor.available ? _green : _muted;
    final bg = mentor.available
        ? _green.withValues(alpha: 0.1)
        : _muted.withValues(alpha: 0.1);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        mentor.available ? '● Tersedia' : '○ Sibuk',
        style: GoogleFonts.manrope(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Widget _buildTags() {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: mentor.tags
          .map((t) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  t,
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    color: _muted,
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildPriceAndCta() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Mulai dari ',
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    color: _muted,
                  ),
                ),
                TextSpan(
                  text: mentor.formattedPrice,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _navy,
                  ),
                ),
                TextSpan(
                  text: '/sesi',
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    color: _muted,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        _buildBookButton(),
      ],
    );
  }

  Widget _buildBookButton() {
    final disabled = !mentor.available;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: disabled
            ? null
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_navy, _blue],
              ),
        color: disabled ? _surface : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: disabled ? null : onBook,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 13,
                  color: disabled ? _muted : Colors.white,
                ),
                const SizedBox(width: 5),
                Text(
                  'Book Sesi',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: disabled ? _muted : Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
