// ============================================
// FILE: lib/widgets/featured_product_card.dart
// ============================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/product_model.dart';
import 'product_type_badge.dart';

/// Hero/Featured card untuk produk unggulan.
/// Background gradient navy → blue → purple sesuai design.
class FeaturedProductCard extends StatelessWidget {
  const FeaturedProductCard({
    super.key,
    required this.product,
    this.onBuy,
  });

  final ProductModel product;
  final VoidCallback? onBuy;

  static const Color _navy = Color(0xFF001261);
  static const Color _blue = Color(0xFF002196);
  static const Color _purple = Color(0xFFA600B2);
  static const Color _yellow = Color(0xFFF8E545);
  static const Color _yellowDark = Color(0xFF201C00);

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
            color: _navy.withValues(alpha: 0.2),
            blurRadius: 40,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Decorative blobs
            Positioned(
              right: -20,
              top: -20,
              child: _Blob(size: 120, color: _purple.withValues(alpha: 0.2)),
            ),
            Positioned(
              right: 40,
              bottom: -10,
              child: _Blob(size: 80, color: _yellow.withValues(alpha: 0.08)),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBadgeRow(),
                  const SizedBox(height: 12),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 220),
                    child: Text(
                      product.title,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildMetaRow(),
                  const SizedBox(height: 16),
                  _buildPriceAndCta(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgeRow() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: _yellow,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Text(
            '🔥 TERPOPULER',
            style: GoogleFonts.manrope(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: _yellowDark,
              letterSpacing: 0.8,
            ),
          ),
        ),
        const SizedBox(width: 8),
        ProductTypeBadge(type: product.type, small: true),
      ],
    );
  }

  Widget _buildMetaRow() {
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star_rounded, size: 13, color: _purple),
            const SizedBox(width: 4),
            Text(
              product.formattedRating,
              style: GoogleFonts.manrope(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
        Text(
          '${product.formattedStudents} siswa',
          style: GoogleFonts.manrope(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
        if (product.duration.isNotEmpty)
          Text(
            product.duration,
            style: GoogleFonts.manrope(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
      ],
    );
  }

  Widget _buildPriceAndCta() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (product.formattedOriginalPrice != null)
                Text(
                  product.formattedOriginalPrice!,
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.45),
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              Text(
                product.formattedPriceFull,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: onBuy,
          icon: const Icon(Icons.shopping_cart_outlined,
              size: 14, color: _yellowDark),
          label: Text(
            'Beli Sekarang',
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _yellowDark,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: _yellow,
            foregroundColor: _yellowDark,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
