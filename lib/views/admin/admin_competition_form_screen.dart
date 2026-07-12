// ============================================
// FILE: lib/views/admin/admin_competition_form_screen.dart
// ============================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/admin_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import 'admin_form_widgets.dart';
import 'admin_theme.dart';

class AdminCompetitionFormScreen extends StatefulWidget {
  const AdminCompetitionFormScreen({super.key, this.initial});
  final Map<String, dynamic>? initial;

  @override
  State<AdminCompetitionFormScreen> createState() =>
      _AdminCompetitionFormScreenState();
}

class _AdminCompetitionFormScreenState
    extends State<AdminCompetitionFormScreen> {
  static const _categories = [
    'Business Case',
    'Business Plan',
    'Business Model Canvas',
    'UI/UX',
    'LKTI',
  ];

  final _admin = AdminService();
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _title;
  late final TextEditingController _organizer;
  late final TextEditingController _fee;
  late final TextEditingController _prize;
  late final TextEditingController _link;

  String _category = _categories.first;
  String _audience = 'Mahasiswa';
  DateTime? _startDate;
  DateTime? _endDate;
  String _imageUrl = '';
  bool _saving = false;

  bool get _isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final i = widget.initial ?? const {};
    _title = TextEditingController(text: (i['title'] ?? '').toString());
    _organizer = TextEditingController(text: (i['organizer'] ?? '').toString());
    _fee = TextEditingController(
        text: i['registration_fee'] == null ? '' : i['registration_fee'].toString());
    _prize = TextEditingController(
        text: i['total_prize'] == null ? '' : i['total_prize'].toString());
    _link = TextEditingController(text: (i['link_pendaftaran'] ?? '').toString());
    if (_categories.contains(i['category'])) _category = i['category'].toString();
    if (i['target_audience'] == 'Umum') _audience = 'Umum';
    _startDate = DateTime.tryParse((i['start_date'] ?? '').toString());
    _endDate = DateTime.tryParse((i['end_date'] ?? '').toString());
    _imageUrl = (i['image_url'] ?? '').toString();
  }

  @override
  void dispose() {
    _title.dispose();
    _organizer.dispose();
    _fee.dispose();
    _prize.dispose();
    _link.dispose();
    super.dispose();
  }

  String? _fmt(DateTime? d) =>
      d == null ? null : '${d.year.toString().padLeft(4, '0')}-'
          '${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _pickDate(bool isStart) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: (isStart ? _startDate : _endDate) ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() => isStart ? _startDate = picked : _endDate = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tanggal mulai & selesai wajib diisi.')),
      );
      return;
    }
    setState(() => _saving = true);

    final payload = <String, dynamic>{
      'title': _title.text.trim(),
      'category': _category,
      'start_date': _fmt(_startDate),
      'end_date': _fmt(_endDate),
      'target_audience': _audience,
      'organizer': _organizer.text.trim(),
      'registration_fee': int.tryParse(_fee.text.trim()) ?? 0,
      'total_prize': int.tryParse(_prize.text.trim()) ?? 0,
      if (_link.text.trim().isNotEmpty) 'link_pendaftaran': _link.text.trim(),
      if (_imageUrl.isNotEmpty) 'image_url': _imageUrl,
    };

    try {
      if (_isEdit) {
        await _admin.updateCompetition(widget.initial!['id'] as int, payload);
      } else {
        await _admin.createCompetition(payload);
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminTheme.bg,
      appBar: buildAdminAppBar(_isEdit ? 'Edit Lomba' : 'Tambah Lomba'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            CustomTextField(controller: _title, label: 'Judul Lomba', hint: 'cth: National Business Case'),
            const SizedBox(height: 16),
            _dropdown('Kategori', _category, _categories,
                (v) => setState(() => _category = v)),
            const SizedBox(height: 16),
            _dropdown('Target Peserta', _audience, const ['Mahasiswa', 'Umum'],
                (v) => setState(() => _audience = v)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _dateField('Tanggal Mulai', _startDate, () => _pickDate(true))),
                const SizedBox(width: 12),
                Expanded(child: _dateField('Tanggal Selesai', _endDate, () => _pickDate(false))),
              ],
            ),
            const SizedBox(height: 16),
            CustomTextField(controller: _organizer, label: 'Penyelenggara', hint: 'cth: BEM FEB UI'),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _fee,
              label: 'Biaya Pendaftaran (Rp)',
              hint: '0 = gratis',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _prize,
              label: 'Total Hadiah (Rp)',
              hint: '5000000',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _link,
              label: 'Link Pendaftaran (opsional)',
              hint: 'https://...',
            ),
            const SizedBox(height: 16),
            AdminImageField(
              label: 'Poster / Gambar',
              initialUrl: _imageUrl.isEmpty ? null : _imageUrl,
              onUploaded: (url) => _imageUrl = url,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: _isEdit ? 'Simpan Perubahan' : 'Tambah Lomba',
              isLoading: _saving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade800,
          letterSpacing: 1.0,
        ),
      );

  Widget _dropdown(String label, String value, List<String> options,
      ValueChanged<String> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          isExpanded: true,
          items: options
              .map((o) => DropdownMenuItem(value: o, child: Text(o)))
              .toList(),
          onChanged: (v) => onChanged(v ?? value),
        ),
      ],
    );
  }

  Widget _dateField(String label, DateTime? value, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_rounded, size: 16, color: AdminTheme.muted),
                const SizedBox(width: 8),
                Text(
                  value == null ? 'Pilih' : _fmt(value)!,
                  style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: value == null ? AdminTheme.muted : AdminTheme.navy),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
