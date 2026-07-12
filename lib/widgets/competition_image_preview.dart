// ============================================
// FILE: lib/widgets/competition_image_preview.dart
// ============================================

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/app_theme.dart';
import '../models/competition_model.dart';

/// Menampilkan full-screen preview gambar lomba + link pendaftaran.
/// Dipanggil lewat [showCompetitionImagePreview].
Future<void> showCompetitionImagePreview(
  BuildContext context,
  CompetitionModel competition,
) {
  return Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, __, ___) =>
          _CompetitionImagePreview(competition: competition),
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    ),
  );
}

class _CompetitionImagePreview extends StatelessWidget {
  const _CompetitionImagePreview({required this.competition});

  final CompetitionModel competition;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Stack(
          children: [
            // Image zoomable di tengah.
            Positioned.fill(
              child: Center(
                child: Hero(
                  tag: 'competition-image-${competition.id}',
                  child: InteractiveViewer(
                    minScale: 0.8,
                    maxScale: 4,
                    child: _buildImage(),
                  ),
                ),
              ),
            ),

            // Tombol close.
            Positioned(
              top: 12,
              right: 12,
              child: _CircleButton(
                icon: Icons.close_rounded,
                onTap: () => Navigator.of(context).pop(),
              ),
            ),

            // Footer: judul + link pendaftaran.
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildFooter(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    final imageUrl = competition.resolvedImage;
    if (imageUrl.isEmpty) {
      return Container(
        color: Colors.grey.shade800,
        padding: const EdgeInsets.all(32),
        child: const Icon(
          Icons.broken_image_rounded,
          color: Colors.white38,
          size: 64,
        ),
      );
    }
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.contain,
      placeholder: (_, __) => const Center(
        child: SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2.5,
          ),
        ),
      ),
      errorWidget: (_, __, ___) => Container(
        color: Colors.grey.shade800,
        padding: const EdgeInsets.all(32),
        child: const Icon(
          Icons.broken_image_rounded,
          color: Colors.white38,
          size: 64,
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black.withValues(alpha: 0.85), Colors.transparent],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            competition.category.toUpperCase(),
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFFFD700),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            competition.title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          if (competition.hasRegistrationLink)
            _RegistrationLinkBar(
              url: competition.registrationLink,
              onOpen: () => _openLink(context, competition.registrationLink),
              onCopy: () => _copyLink(context, competition.registrationLink),
            )
          else
            Text(
              'Link pendaftaran belum tersedia.',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _openLink(BuildContext context, String url) async {
    // Auto-prepend scheme kalau user simpan link tanpa http/https.
    var normalized = url.trim();
    if (!normalized.startsWith(RegExp(r'https?://', caseSensitive: false))) {
      normalized = 'https://$normalized';
    }

    final uri = Uri.tryParse(normalized);
    if (uri == null || uri.host.isEmpty) {
      _showSnack(context, 'Link tidak valid: $url');
      return;
    }

    try {
      // externalApplication → buka di browser default.
      var ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      // Fallback ke mode default jika gagal (in-app webview/custom tabs).
      if (!ok) {
        ok = await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
      if (!ok && context.mounted) {
        _showSnack(context, 'Tidak ada aplikasi yang bisa membuka link');
      }
    } on PlatformException catch (e) {
      if (context.mounted) _showSnack(context, 'Gagal: ${e.message}');
    } catch (e) {
      if (context.mounted) _showSnack(context, 'Gagal membuka link: $e');
    }
  }

  Future<void> _copyLink(BuildContext context, String url) async {
    await Clipboard.setData(ClipboardData(text: url));
    if (context.mounted) _showSnack(context, 'Link disalin');
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins(fontSize: 13)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.2),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

class _RegistrationLinkBar extends StatelessWidget {
  const _RegistrationLinkBar({
    required this.url,
    required this.onOpen,
    required this.onCopy,
  });

  final String url;
  final VoidCallback onOpen;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sumber / Link Pendaftaran',
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onOpen,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white24),
            ),
            child: Row(
              children: [
                const Icon(Icons.link_rounded,
                    color: Colors.white, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    url,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.white54,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onCopy,
                  child: const Icon(Icons.copy_rounded,
                      color: Colors.white70, size: 18),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onOpen,
            icon: const Icon(Icons.open_in_new_rounded, size: 18),
            label: const Text('Buka Halaman Pendaftaran'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
