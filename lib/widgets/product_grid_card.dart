// ============================================
// FILE: lib/widgets/product_grid_card.dart
// ============================================

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/product_model.dart';
import 'product_type_badge.dart';

/// Card produk untuk grid 2 kolom.
class ProductGridCard extends StatelessWidget {
  const ProductGridCard({
    super.key,
    required this.product,
    this.onTap,
  });

  final ProductModel product;
  final VoidCallback? onTap;

  static const Color _navy = Color(0xFF001261);
  static const Color _purple = Color(0xFFA600B2);
  static const Color _yellow = Color(0xFFF8E545);
  static const Color _yellowDark = Color(0xFF201C00);
  static const Color _muted = Color(0xFF757684);
  static const Color _text = Color(0xFF1A1B22);
  static const Color _border = Color(0x14001261); // rgba(0,18,97,0.08)
  static const Color _purpleFaint = Color(0x14A600B2); // rgba(166,0,178,0.08)

  @override
  Widget build(BuildContext context) {
    final style = ProductTypeStyle.of(product.type);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
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
              _buildThumbnail(style),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 36, // ~ 2 baris
                      child: Text(
                        product.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _text,
                          height: 1.35,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 12, color: _purple),
                        const SizedBox(width: 3),
                        Text(
                          product.formattedRating,
                          style: GoogleFonts.manrope(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _text,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            product.formattedStudents,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.manrope(
                              fontSize: 10,
                              color: _muted,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            product.formattedPriceShort,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _navy,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: _purpleFaint,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Lihat',
                            style: GoogleFonts.manrope(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _purple,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(ProductTypeStyle style) {
    final imageUrl = product.resolvedImage;
    final hasImage = imageUrl.isNotEmpty;
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
      child: SizedBox(
        height: 100,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (hasImage)
              CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => _gradientPlaceholder(style),
                errorWidget: (_, __, ___) => _gradientPlaceholder(style),
              )
            else
              _gradientPlaceholder(style),

            Positioned(
              top: 8,
              left: 8,
              child: ProductTypeBadge(type: product.type, small: true),
            ),
            if (product.isBestseller)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _yellow,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'TOP',
                    style: GoogleFonts.manrope(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color: _yellowDark,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _gradientPlaceholder(ProductTypeStyle style) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: style.gradient,
        ),
      ),
      alignment: Alignment.center,
      child: Icon(
        style.icon,
        size: 36,
        color: Colors.white.withValues(alpha: 0.4),
      ),
    );
  }
}
