// ============================================
// FILE: lib/views/product_screen/detail_mentor_screen.dart
// ============================================

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/mentor_model.dart';
import '../../widgets/detail_widgets.dart';

class DetailMentorScreen extends StatefulWidget {
  const DetailMentorScreen({super.key, required this.mentor});
  final MentorModel mentor;

  @override
  State<DetailMentorScreen> createState() => _DetailMentorScreenState();
}

class _DetailMentorScreenState extends State<DetailMentorScreen> {
  static const _highlights = [
    (Icons.bolt_rounded, 'Respon cepat — rata-rata 2 jam'),
    (Icons.videocam_rounded, 'Sesi via Zoom + rekaman tersedia'),
    (Icons.description_rounded, 'Materi & feedback tertulis pasca-sesi'),
    (Icons.replay_rounded, 'Reschedule fleksibel hingga 24 jam sebelumnya'),
  ];

  @override
  Widget build(BuildContext context) {
    final m = widget.mentor;
    return Scaffold(
      backgroundColor: DetailColors.bg,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHero(m),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                m.name,
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: DetailColors.navy,
                                  height: 1.2,
                                ),
                              ),
                            ),
                            _buildAvailabilityChip(m.available),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          m.title,
                          style: GoogleFonts.manrope(
                            fontSize: 13,
                            color: DetailColors.muted,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        StarRatingRow(
                          rating: m.rating,
                          count: '${m.sessions} sesi',
                        ),
                        const SizedBox(height: 14),
                        if (m.tags.isNotEmpty)
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: m.tags
                                .map((t) => Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: DetailColors.purpleFaint,
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        t,
                                        style: GoogleFonts.manrope(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: DetailColors.purple,
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: StatsRow(pills: [
                      StatPill(
                        icon: Icons.person_rounded,
                        value: '1-on-1',
                        label: 'Format',
                      ),
                      StatPill(
                        icon: Icons.schedule_rounded,
                        value: '60 mnt',
                        label: 'Durasi',
                      ),
                      StatPill(
                        icon: Icons.videocam_rounded,
                        value: 'Zoom',
                        label: 'Platform',
                      ),
                    ]),
                  ),
                  const SizedBox(height: 20),
                  _buildTentang(m),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          DetailStickyFooter(
            price: '${m.formattedPrice} /sesi',
            ctaLabel: m.available ? 'Book Sesi' : 'Tidak Tersedia',
            ctaIcon: Icons.calendar_today_rounded,
            ctaGradient: m.available
                ? const [DetailColors.purple, Color(0xFF6B0075)]
                : const [DetailColors.muted, DetailColors.muted],
            shadowColor: DetailColors.purple,
            onTap: m.available ? () => _bookViaWhatsApp(m) : () {},
          ),
        ],
      ),
    );
  }

  // Nomor WhatsApp mentor dalam format internasional (tanpa 0/+).
  static const _whatsappNumber = '6287774938725';

  Future<void> _bookViaWhatsApp(MentorModel m) async {
    final message = Uri.encodeComponent(
      'Halo ${m.name}, saya tertarik untuk booking sesi mentoring 1-on-1.',
    );
    final uri = Uri.parse('https://wa.me/$_whatsappNumber?text=$message');

    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuka WhatsApp.')),
      );
    }
  }

  Widget _buildHero(MentorModel m) {
    return Stack(
      children: [
        Container(
          height: 260,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0.0, 1.0],
              colors: [
                m.avatarGradient.first,
                m.avatarGradient.last,
              ],
            ),
          ),
        ),
        Positioned(
          right: -30,
          top: -30,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 70,
          child: Center(
            child: Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.15),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.4), width: 3),
              ),
              alignment: Alignment.center,
              clipBehavior: Clip.antiAlias,
              child: m.resolvedAvatar.isEmpty
                  ? Text(
                      m.initials,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    )
                  : CachedNetworkImage(
                      imageUrl: m.resolvedAvatar,
                      width: 92,
                      height: 92,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Text(
                        m.initials,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
            ),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 16,
          child: DetailBackButton(onTap: () => Navigator.of(context).pop()),
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 54,
          left: 16,
          child: const HeroBadge(label: 'MENTORING'),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 14,
          child: Center(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                '1-on-1 SESSION',
                style: GoogleFonts.manrope(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvailabilityChip(bool available) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: available
            ? DetailColors.greenFaint
            : DetailColors.muted.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        available ? '● Tersedia' : '○ Sibuk',
        style: GoogleFonts.manrope(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: available ? DetailColors.green : DetailColors.muted,
        ),
      ),
    );
  }

  Widget _buildTentang(MentorModel m) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Halo, saya ${m.name.split(' ').first}! Saya sudah membantu '
            '${m.sessions}+ peserta lomba mempersiapkan strategi, '
            'pitch deck, dan menjawab pertanyaan juri. '
            'Mari konsultasikan kebutuhan lombamu — saya siap memberikan '
            'feedback personal yang spesifik untuk timmu.',
            style: GoogleFonts.manrope(
              fontSize: 13,
              color: DetailColors.muted,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 20),
          const DetailSectionTitle('Yang akan kamu dapatkan'),
          Column(
            children: _highlights
                .map((h) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: HighlightRow(icon: h.$1, text: h.$2),
                    ))
                .toList(),
          ),
          const SizedBox(height: 20),
          const DetailSectionTitle('Cocok untuk'),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              DetailMetaPill(
                  icon: Icons.school_rounded,
                  text: 'Persiapan lomba'),
              DetailMetaPill(
                  icon: Icons.feedback_rounded,
                  text: 'Review pitch deck'),
              DetailMetaPill(
                  icon: Icons.psychology_rounded,
                  text: 'Konsultasi strategi'),
            ],
          ),
        ],
      ),
    );
  }
}
