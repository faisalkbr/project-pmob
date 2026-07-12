// ============================================
// FILE: lib/widgets/cart_item_card.dart
// ============================================

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/cart_item_model.dart';
import 'product_type_badge.dart';

class CartItemCard extends StatelessWidget {
  const CartItemCard({
    super.key,
    required this.item,
    required this.isBusy,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  final CartItem item;
  final bool isBusy;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  static const Color _navy = Color(0xFF001261);
  static const Color _purple = Color(0xFFA600B2);
  static const Color _muted = Color(0xFF757684);
  static const Color _text = Color(0xFF1A1B22);
  static const Color _border = Color(0x14001261);
  static const Color _surface = Color(0xFFF2F0F8);
  static const Color _red = Color(0xFFE53935);

  @override
  Widget build(BuildContext context) {
    final style = ProductTypeStyle.of(item.product.type);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: _navy.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildThumbnail(style),
          const SizedBox(width: 12),
          Expanded(child: _buildInfo()),
        ],
      ),
    );
  }

  Widget _buildThumbnail(ProductTypeStyle style) {
    final imageUrl = item.product.resolvedImage;
    final hasImage = imageUrl.isNotEmpty;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 68,
        height: 68,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (hasImage)
              CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => _gradient(style),
                errorWidget: (_, __, ___) => _gradient(style),
              )
            else
              _gradient(style),
            Positioned(
              bottom: 4,
              left: 4,
              child: ProductTypeBadge(type: item.product.type, small: true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gradient(ProductTypeStyle style) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: style.gradient,
          ),
        ),
        alignment: Alignment.center,
        child: Icon(style.icon, size: 28, color: Colors.white.withValues(alpha: 0.5)),
      );

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                item.product.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _text,
                  height: 1.3,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Remove button
            GestureDetector(
              onTap: isBusy ? null : onRemove,
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: _red.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.delete_outline_rounded,
                  size: 15,
                  color: isBusy ? _muted : _red,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Price
            Text(
              Cart.rupiah(item.lineTotal),
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _navy,
              ),
            ),
            // Qty stepper
            _buildStepper(),
          ],
        ),
      ],
    );
  }

  Widget _buildStepper() {
    return Container(
      height: 30,
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepperBtn(
            icon: Icons.remove_rounded,
            onTap: isBusy ? null : onDecrement,
            color: item.quantity <= 1 ? _red : _muted,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: isBusy
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _purple,
                    ),
                  )
                : Text(
                    '${item.quantity}',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _text,
                    ),
                  ),
          ),
          _StepperBtn(
            icon: Icons.add_rounded,
            onTap: isBusy ? null : onIncrement,
            color: _purple,
          ),
        ],
      ),
    );
  }
}

class _StepperBtn extends StatelessWidget {
  const _StepperBtn({
    required this.icon,
    required this.onTap,
    required this.color,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 30,
        height: 30,
        child: Icon(icon, size: 16, color: onTap == null ? Colors.grey.shade400 : color),
      ),
    );
  }
}
