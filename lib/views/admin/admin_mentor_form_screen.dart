// ============================================
// FILE: lib/views/admin/admin_mentor_form_screen.dart
// ============================================

import 'package:flutter/material.dart';

import '../../services/admin_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import 'admin_form_widgets.dart';
import 'admin_theme.dart';

class AdminMentorFormScreen extends StatefulWidget {
  const AdminMentorFormScreen({super.key, this.initial});
  final Map<String, dynamic>? initial;

  @override
  State<AdminMentorFormScreen> createState() => _AdminMentorFormScreenState();
}

class _AdminMentorFormScreenState extends State<AdminMentorFormScreen> {
  final _admin = AdminService();
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _name;
  late final TextEditingController _title;
  late final TextEditingController _price;
  late final TextEditingController _rating;
  late final TextEditingController _sessions;
  late final TextEditingController _tags;
  late final TextEditingController _about;
  late final TextEditingController _responseTime;

  bool _available = true;
  String _avatarUrl = '';
  bool _saving = false;

  bool get _isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final i = widget.initial ?? const {};
    _name = TextEditingController(text: (i['name'] ?? '').toString());
    _title = TextEditingController(text: (i['title'] ?? '').toString());
    _price = TextEditingController(
        text: i['price_per_session'] == null ? '' : i['price_per_session'].toString());
    _rating = TextEditingController(
        text: i['rating'] == null ? '' : i['rating'].toString());
    _sessions = TextEditingController(
        text: i['sessions'] == null ? '' : i['sessions'].toString());
    _tags = TextEditingController(text: _tagsToText(i['tags']));
    _about = TextEditingController(text: (i['about'] ?? '').toString());
    _responseTime = TextEditingController(text: (i['response_time'] ?? '').toString());
    _available = i['available'] == null ? true : (i['available'] == true || i['available'] == 1);
    _avatarUrl = (i['avatar_url'] ?? '').toString();
  }

  String _tagsToText(dynamic tags) {
    if (tags is List) return tags.join(', ');
    return (tags ?? '').toString();
  }

  @override
  void dispose() {
    _name.dispose();
    _title.dispose();
    _price.dispose();
    _rating.dispose();
    _sessions.dispose();
    _tags.dispose();
    _about.dispose();
    _responseTime.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final tagList = _tags.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final payload = <String, dynamic>{
      'name': _name.text.trim(),
      'title': _title.text.trim(),
      'price_per_session': int.tryParse(_price.text.trim()) ?? 0,
      'available': _available,
      'tags': tagList,
      if (_rating.text.trim().isNotEmpty) 'rating': double.tryParse(_rating.text.trim()),
      if (_sessions.text.trim().isNotEmpty) 'sessions': int.tryParse(_sessions.text.trim()),
      if (_about.text.trim().isNotEmpty) 'about': _about.text.trim(),
      if (_responseTime.text.trim().isNotEmpty) 'response_time': _responseTime.text.trim(),
      if (_avatarUrl.isNotEmpty) 'avatar_url': _avatarUrl,
    };

    try {
      if (_isEdit) {
        await _admin.updateMentor(widget.initial!['id'] as int, payload);
      } else {
        await _admin.createMentor(payload);
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
      appBar: buildAdminAppBar(_isEdit ? 'Edit Mentor' : 'Tambah Mentor'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            CustomTextField(controller: _name, label: 'Nama', hint: 'cth: Rizka Nabilah'),
            const SizedBox(height: 16),
            CustomTextField(
                controller: _title,
                label: 'Jabatan / Title',
                hint: 'cth: Case Competition Champion'),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _price,
              label: 'Harga / Sesi (Rp)',
              hint: '150000',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _tags,
              label: 'Tags (pisahkan koma)',
              hint: 'Business Case, Pitch Deck',
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _rating,
              label: 'Rating (opsional, 0-5)',
              hint: '5.0',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _sessions,
              label: 'Jumlah Sesi (opsional)',
              hint: '142',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _responseTime,
              label: 'Response Time (opsional)',
              hint: '< 2j',
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _about,
              label: 'Tentang (opsional)',
              hint: 'Deskripsi singkat mentor',
              keyboardType: TextInputType.multiline,
            ),
            const SizedBox(height: 16),
            AdminImageField(
              label: 'Foto Mentor',
              initialUrl: _avatarUrl.isEmpty ? null : _avatarUrl,
              onUploaded: (url) => _avatarUrl = url,
            ),
            const SizedBox(height: 16),
            AdminSwitchRow(
              label: 'Tersedia untuk booking',
              value: _available,
              onChanged: (v) => setState(() => _available = v),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: _isEdit ? 'Simpan Perubahan' : 'Tambah Mentor',
              isLoading: _saving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
