// ============================================
// FILE: lib/views/admin/admin_form_widgets.dart
// ============================================

import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../config/api_config.dart';
import '../../services/admin_service.dart';
import 'admin_theme.dart';

/// Field pemilih + pengunggah gambar yang dipakai di semua form admin.
/// Saat user memilih gambar, file langsung diunggah ke `/admin/uploads`
/// dan path hasilnya dikembalikan lewat [onUploaded].
class AdminImageField extends StatefulWidget {
  const AdminImageField({
    super.key,
    required this.label,
    required this.initialUrl,
    required this.onUploaded,
  });

  final String label;
  final String? initialUrl;
  final ValueChanged<String> onUploaded;

  @override
  State<AdminImageField> createState() => _AdminImageFieldState();
}

class _AdminImageFieldState extends State<AdminImageField> {
  final _admin = AdminService();
  final _picker = ImagePicker();

  String? _url; // path relatif tersimpan
  Uint8List? _localPreview; // bytes gambar terpilih (web-safe)
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _url = widget.initialUrl;
  }

  Future<void> _pick() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    setState(() {
      _uploading = true;
      _localPreview = bytes;
    });
    try {
      final url = await _admin.uploadImage(picked);
      widget.onUploaded(url);
      if (mounted) setState(() => _url = url);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
        setState(() => _localPreview = null);
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final preview = _localPreview != null
        ? Image.memory(_localPreview!, fit: BoxFit.cover)
        : (_url != null && _url!.isNotEmpty)
            ? CachedNetworkImage(
                imageUrl: ApiConfig.resolveImageUrl(_url),
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => _placeholder())
            : _placeholder();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label.toUpperCase(),
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _uploading ? null : _pick,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            clipBehavior: Clip.antiAlias,
            child: _uploading
                ? const Center(child: CircularProgressIndicator())
                : preview,
          ),
        ),
      ],
    );
  }

  Widget _placeholder() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.add_a_photo_rounded, color: AdminTheme.muted),
          const SizedBox(height: 6),
          Text('Pilih gambar',
              style: GoogleFonts.poppins(fontSize: 12, color: AdminTheme.muted)),
        ],
      ),
    );
  }
}

/// Baris switch berlabel untuk field boolean.
class AdminSwitchRow extends StatelessWidget {
  const AdminSwitchRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AdminTheme.navy,
            ),
          ),
        ),
        Switch(
          value: value,
          activeThumbColor: AdminTheme.purple,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
