// ============================================
// FILE: lib/widgets/detail_widgets.dart
// Reusable building blocks untuk Detail Produk screens
// (Kelas / Modul / Bootcamp / Mentor).
// ============================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DetailColors {
  static const Color navy = Color(0xFF001261);
  static const Color blue = Color(0xFF002196);
  static const Color purple = Color(0xFFA600B2);
  static const Color purpleFaint = Color(0x14A600B2);
  static const Color yellow = Color(0xFFF8E545);
  static const Color yellowDark = Color(0xFF201C00);
  static const Color bg = Color(0xFFFBFAFF);
  static const Color surface = Color(0xFFF2F0F8);
  static const Color border = Color(0x14001261);
  static const Color muted = Color(0xFF757684);
  static const Color text = Color(0xFF1A1B22);
  static const Color green = Color(0xFF16A34A);
  static const Color greenFaint = Color(0x1A16A34A);
  static const Color red = Color(0xFFDC2626);
}

/// Tombol back transparan di atas hero gelap.
class DetailBackButton extends StatelessWidget {
  const DetailBackButton({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.28),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: const SizedBox(
          width: 36,
          height: 36,
          child: Icon(Icons.arrow_back_rounded,
              color: Colors.white, size: 18),
        ),
      ),
    );
  }
}

/// Tombol wishlist heart.
class DetailWishlistButton extends StatelessWidget {
  const DetailWishlistButton({
    super.key,
    required this.active,
    required this.onTap,
    this.activeColor,
  });
  final bool active;
  final VoidCallback onTap;
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    final aColor = activeColor ?? DetailColors.purple.withOpacity(0.5);
    return Material(
      color: active ? aColor : Colors.black.withOpacity(0.28),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(
            active ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: Colors.white,
            size: 17,
          ),
        ),
      ),
    );
  }
}

/// Badge kuning di pojok kiri-atas hero (cth: "KELAS", "MODUL PDF").
class HeroBadge extends StatelessWidget {
  const HeroBadge({
    super.key,
    required this.label,
    this.background = DetailColors.yellow,
    this.foreground = DetailColors.yellowDark,
  });
  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.manrope(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: foreground,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

/// 5 bintang + rating + count.
class StarRatingRow extends StatelessWidget {
  const StarRatingRow({
    super.key,
    required this.rating,
    this.count,
    this.size = 13,
  });
  final double rating;
  final String? count;
  final double size;

  @override
  Widget build(BuildContext context) {
    final filled = rating.floor();
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (i) {
            return Icon(
              Icons.star_rounded,
              size: size,
              color: i < filled ? DetailColors.purple : DetailColors.surface,
            );
          }),
        ),
        Text(
          rating.toStringAsFixed(1),
          style: GoogleFonts.manrope(
            fontSize: size,
            fontWeight: FontWeight.w700,
            color: DetailColors.text,
          ),
        ),
        if (count != null)
          Text(
            '($count)',
            style: GoogleFonts.manrope(
              fontSize: size - 1,
              color: DetailColors.muted,
            ),
          ),
      ],
    );
  }
}

/// Pill kecil untuk meta info: ikon + teks.
class DetailMetaPill extends StatelessWidget {
  const DetailMetaPill({super.key, required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: DetailColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: DetailColors.muted),
          const SizedBox(width: 5),
          Text(
            text,
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: DetailColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}

/// Stat pill (icon, value, label) — 1 dari 3 di stats row.
class StatPill extends StatelessWidget {
  const StatPill({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.iconColor = DetailColors.purple,
    this.iconBg = DetailColors.purpleFaint,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;
  final Color iconBg;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, size: 17, color: iconColor),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: DetailColors.navy,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.manrope(
            fontSize: 10,
            color: DetailColors.muted,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

/// Container white card with 3 stat pills + dividers.
class StatsRow extends StatelessWidget {
  const StatsRow({super.key, required this.pills});
  final List<StatPill> pills;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: DetailColors.border),
        boxShadow: [
          BoxShadow(
            color: DetailColors.navy.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (int i = 0; i < pills.length; i++) ...[
            if (i > 0)
              Container(width: 1, height: 60, color: DetailColors.border),
            Expanded(child: pills[i]),
          ],
        ],
      ),
    );
  }
}

/// Author/mentor mini card di atas stats.
class AuthorMiniCard extends StatelessWidget {
  const AuthorMiniCard({
    super.key,
    required this.label,
    required this.name,
    required this.subtitle,
    required this.initials,
    required this.gradient,
  });

  final String label;
  final String name;
  final String subtitle;
  final String initials;
  final List<Color> gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DetailColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradient,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    color: DetailColors.muted,
                  ),
                ),
                Text(
                  name,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: DetailColors.navy,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    color: DetailColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Tab bar 3 segment style detail screen.
class DetailTabBar extends StatelessWidget {
  const DetailTabBar({
    super.key,
    required this.tabs,
    required this.activeIndex,
    required this.onTap,
    this.activeColor = DetailColors.navy,
  });

  final List<String> tabs;
  final int activeIndex;
  final ValueChanged<int> onTap;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(tabs.length, (i) {
        final active = i == activeIndex;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < tabs.length - 1 ? 6 : 0),
            child: Material(
              color: active ? activeColor : Colors.white,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => onTap(i),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: active ? activeColor : DetailColors.border,
                      width: 1.5,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    tabs[i],
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: active ? Colors.white : DetailColors.muted,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

/// Item collapsible curriculum/section.
class CollapsibleSection extends StatefulWidget {
  const CollapsibleSection({
    super.key,
    required this.numberLabel,
    required this.title,
    required this.subtitle,
    required this.children,
    this.initiallyOpen = false,
    this.activeColor = DetailColors.purple,
    this.activeBg = DetailColors.surface,
  });

  final String numberLabel;
  final String title;
  final String subtitle;
  final List<Widget> children;
  final bool initiallyOpen;
  final Color activeColor;
  final Color activeBg;

  @override
  State<CollapsibleSection> createState() => _CollapsibleSectionState();
}

class _CollapsibleSectionState extends State<CollapsibleSection> {
  late bool _open = widget.initiallyOpen;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: DetailColors.border),
        ),
        child: Column(
          children: [
            InkWell(
              onTap: () => setState(() => _open = !_open),
              child: Container(
                color: _open ? widget.activeBg : Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                child: Row(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: _open
                            ? widget.activeColor
                            : DetailColors.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        widget.numberLabel,
                        style: GoogleFonts.manrope(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _open
                              ? Colors.white
                              : DetailColors.muted,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: GoogleFonts.manrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: DetailColors.text,
                        ),
                      ),
                    ),
                    Text(
                      widget.subtitle,
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        color: DetailColors.muted,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      _open
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: DetailColors.muted,
                    ),
                  ],
                ),
              ),
            ),
            if (_open)
              Container(
                color: Colors.white,
                child: Column(children: widget.children),
              ),
          ],
        ),
      ),
    );
  }
}

class CurriculumItem extends StatelessWidget {
  const CurriculumItem({
    super.key,
    required this.title,
    required this.duration,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    this.showBorder = true,
  });

  final String title;
  final String duration;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(52, 11, 16, 11),
      decoration: BoxDecoration(
        border: showBorder
            ? const Border(
                bottom: BorderSide(color: DetailColors.border, width: 1),
              )
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 11, color: iconColor),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.manrope(
                fontSize: 12,
                color: DetailColors.text,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            duration,
            style: GoogleFonts.manrope(
              fontSize: 11,
              color: DetailColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}

/// Card breakdown rating dengan distribusi bar.
class RatingSummaryCard extends StatelessWidget {
  const RatingSummaryCard({
    super.key,
    required this.rating,
    required this.totalReviews,
    required this.distribution,
    this.barColor = DetailColors.purple,
  });

  final double rating;
  final int totalReviews;
  final List<int> distribution; // % for stars [5,4,3,2,1]
  final Color barColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: DetailColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                rating.toStringAsFixed(1),
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 44,
                  fontWeight: FontWeight.w700,
                  color: DetailColors.navy,
                  height: 1,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  5,
                  (i) => const Icon(Icons.star_rounded,
                      size: 11, color: DetailColors.purple),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$totalReviews ulasan',
                style: GoogleFonts.manrope(
                  fontSize: 10,
                  color: DetailColors.muted,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              children: List.generate(5, (i) {
                final stars = 5 - i;
                final pct = i < distribution.length ? distribution[i] : 0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 8,
                        child: Text(
                          '$stars',
                          style: GoogleFonts.manrope(
                            fontSize: 10,
                            color: DetailColors.muted,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.star_rounded,
                          size: 9, color: DetailColors.yellow),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Container(
                          height: 5,
                          decoration: BoxDecoration(
                            color: DetailColors.surface,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: pct / 100,
                            child: Container(
                              decoration: BoxDecoration(
                                color: barColor,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      SizedBox(
                        width: 24,
                        child: Text(
                          '$pct%',
                          textAlign: TextAlign.right,
                          style: GoogleFonts.manrope(
                            fontSize: 10,
                            color: DetailColors.muted,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

/// Card review individual (horizontal scroll).
class ReviewCard extends StatelessWidget {
  const ReviewCard({
    super.key,
    required this.initials,
    required this.name,
    required this.stars,
    required this.text,
    required this.gradient,
    this.date,
  });

  final String initials;
  final String name;
  final int stars;
  final String text;
  final List<Color> gradient;
  final String? date;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DetailColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradient,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: DetailColors.text,
                    ),
                  ),
                  Row(
                    children: List.generate(
                      5,
                      (i) => Icon(
                        Icons.star_rounded,
                        size: 9,
                        color: i < stars
                            ? DetailColors.purple
                            : DetailColors.surface,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            text,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.manrope(
              fontSize: 12,
              color: DetailColors.muted,
              height: 1.5,
            ),
          ),
          if (date != null) ...[
            const SizedBox(height: 8),
            Text(
              date!,
              style: GoogleFonts.manrope(
                fontSize: 10,
                color: DetailColors.muted.withOpacity(0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Sticky footer dengan harga + tombol CTA (gradient bisa dicustom).
class DetailStickyFooter extends StatelessWidget {
  const DetailStickyFooter({
    super.key,
    required this.price,
    required this.ctaLabel,
    required this.ctaIcon,
    required this.ctaGradient,
    this.onTap,
    this.originalPrice,
    this.shadowColor,
    this.isPurchased = false,
    this.onAccessContent,
  });

  final String price;
  final String? originalPrice;
  final String ctaLabel;
  final IconData ctaIcon;
  final List<Color> ctaGradient;
  final VoidCallback? onTap;
  final Color? shadowColor;

  /// Jika true, footer menampilkan state "Sudah Dibeli" dengan tombol
  /// "Akses Konten" hijau dan tanda lunas.
  final bool isPurchased;
  final VoidCallback? onAccessContent;

  static const _green = Color(0xFF16A34A);
  static const _greenFaint = Color(0x1A16A34A);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: const BoxDecoration(
        color: Color(0xF2FBFAFF),
        border: Border(top: BorderSide(color: DetailColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isPurchased) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _greenFaint,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'SUDAH DIBELI',
                        style: GoogleFonts.manrope(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: _green,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                  ] else ...[
                    if (originalPrice != null)
                      Text(
                        originalPrice!,
                        style: GoogleFonts.manrope(
                          fontSize: 11,
                          color: DetailColors.muted,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                  ],
                  Text(
                    price,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: isPurchased ? _green : DetailColors.navy,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: isPurchased
                  ? _AccessContentButton(onTap: onAccessContent)
                  : _BuyButton(
                      label: ctaLabel,
                      icon: ctaIcon,
                      gradient: ctaGradient,
                      shadowColor: shadowColor,
                      onTap: onTap,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BuyButton extends StatelessWidget {
  const _BuyButton({
    required this.label,
    required this.icon,
    required this.gradient,
    required this.onTap,
    this.shadowColor,
  });

  final String label;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback? onTap;
  final Color? shadowColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        boxShadow: [
          BoxShadow(
            color: (shadowColor ?? gradient.first).withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 16, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
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

class _AccessContentButton extends StatelessWidget {
  const _AccessContentButton({this.onTap});
  final VoidCallback? onTap;

  static const _green = Color(0xFF16A34A);
  static const _greenLight = Color(0xFF22C55E);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_green, _greenLight],
        ),
        boxShadow: [
          BoxShadow(
            color: _green.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_open_rounded,
                    size: 16, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'Akses Konten',
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
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

/// Section heading di body (cth: "Yang akan kamu pelajari").
class DetailSectionTitle extends StatelessWidget {
  const DetailSectionTitle(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: GoogleFonts.spaceGrotesk(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: DetailColors.navy,
        ),
      ),
    );
  }
}

/// Highlight item: ikon kotak ungu + teks.
class HighlightRow extends StatelessWidget {
  const HighlightRow({
    super.key,
    required this.icon,
    required this.text,
    this.iconColor = DetailColors.purple,
    this.iconBg = DetailColors.purpleFaint,
  });
  final IconData icon;
  final String text;
  final Color iconColor;
  final Color iconBg;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(9),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 14, color: iconColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.manrope(
              fontSize: 13,
              color: DetailColors.text,
            ),
          ),
        ),
      ],
    );
  }
}
