// ============================================
// FILE: lib/views/admin/admin_product_form_screen.dart
// ============================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/admin_service.dart';
import '../../services/product_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import 'admin_form_widgets.dart';
import 'admin_repeatable.dart';
import 'admin_theme.dart';

/// Form tambah/edit produk lengkap dengan konten bersarang
/// (learnings, includes, chapters/kurikulum/batch sesuai tipe).
/// [initial] = data produk untuk mode edit (null = tambah).
class AdminProductFormScreen extends StatefulWidget {
  const AdminProductFormScreen({super.key, this.initial});
  final Map<String, dynamic>? initial;

  @override
  State<AdminProductFormScreen> createState() => _AdminProductFormScreenState();
}

class _AdminProductFormScreenState extends State<AdminProductFormScreen> {
  static const _iconOptions = [
    'check', 'file', 'video', 'book', 'live', 'download',
    'trophy', 'users', 'clock', 'bolt', 'verified',
  ];
  static const _typeOptions = ['video', 'pdf', 'live'];
  static const _statusOptions = ['open', 'soon', 'closed'];

  final _admin = AdminService();
  final _products = ProductService();
  final _formKey = GlobalKey<FormState>();

  final _title = TextEditingController();
  final _price = TextEditingController();
  final _originalPrice = TextEditingController();
  final _duration = TextEditingController();
  final _description = TextEditingController();

  String _type = 'kelas';
  bool _isFeatured = false;
  bool _isBestseller = false;
  String _imageUrl = '';
  bool _saving = false;
  bool _loadingDetail = false;

  // Konten bersarang — tiap baris adalah Map agar bisa di-key dengan ObjectKey.
  final List<Map<String, dynamic>> _learnings = [];
  final List<Map<String, dynamic>> _includes = [];
  final List<Map<String, dynamic>> _chapters = [];
  final List<Map<String, dynamic>> _sections = [];
  final List<Map<String, dynamic>> _batches = [];

  bool get _isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final i = widget.initial ?? const {};
    _fillBase(i);
    if (_isEdit) _loadDetail(i['id'] as int);
  }

  void _fillBase(Map<String, dynamic> i) {
    _title.text = (i['title'] ?? '').toString();
    _price.text = i['price'] == null ? '' : i['price'].toString();
    _originalPrice.text =
        i['original_price'] == null ? '' : i['original_price'].toString();
    _duration.text = (i['duration'] ?? '').toString();
    _description.text = (i['description'] ?? '').toString();
    _type = (i['type'] ?? 'kelas').toString();
    _isFeatured = i['is_featured'] == true || i['is_featured'] == 1;
    _isBestseller = i['is_bestseller'] == true || i['is_bestseller'] == 1;
    _imageUrl = (i['image_url'] ?? '').toString();
  }

  /// Saat edit, ambil detail penuh untuk mengisi field + konten bersarang.
  Future<void> _loadDetail(int id) async {
    setState(() => _loadingDetail = true);
    try {
      final d = await _products.fetchProductDetail(id);
      _fillBase(d);
      _learnings
        ..clear()
        ..addAll(_asList(d['learnings'])
            .map((e) => {'value': e.toString()}));
      _includes
        ..clear()
        ..addAll(_asMapList(d['includes']).map((e) => {
              'icon': (e['icon'] ?? 'check').toString(),
              'text': (e['text'] ?? '').toString(),
            }));
      _chapters
        ..clear()
        ..addAll(_asMapList(d['chapters']).map((e) => {
              'chapter_number': (e['chapter_number'] ?? '').toString(),
              'title': (e['title'] ?? '').toString(),
              'page_range': (e['page_range'] ?? '').toString(),
              'file_url': (e['file_url'] ?? '').toString(),
              'is_free': e['is_free'] == true || e['is_free'] == 1,
            }));
      _sections
        ..clear()
        ..addAll(_asMapList(d['curriculum_sections']).map((s) => {
              'title': (s['title'] ?? '').toString(),
              'subtitle': (s['subtitle'] ?? '').toString(),
              'items': _asMapList(s['items'])
                  .map((it) => {
                        'title': (it['title'] ?? '').toString(),
                        'duration': (it['duration'] ?? '').toString(),
                        'type': (it['type'] ?? 'video').toString(),
                        'content_url': (it['content_url'] ?? '').toString(),
                        'is_free': it['is_free'] == true || it['is_free'] == 1,
                      })
                  .toList(),
            }));
      _batches
        ..clear()
        ..addAll(_asMapList(d['batches']).map((b) => {
              'label': (b['label'] ?? '').toString(),
              'date_range': (b['date_range'] ?? '').toString(),
              'spots': b['spots'] == null ? '' : b['spots'].toString(),
              'status': (b['status'] ?? 'open').toString(),
            }));
    } catch (_) {
      // biarkan; field dasar dari list tetap terisi
    } finally {
      if (mounted) setState(() => _loadingDetail = false);
    }
  }

  List _asList(dynamic v) => v is List ? v : const [];
  List<Map<String, dynamic>> _asMapList(dynamic v) => v is List
      ? v.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
      : <Map<String, dynamic>>[];

  @override
  void dispose() {
    _title.dispose();
    _price.dispose();
    _originalPrice.dispose();
    _duration.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final payload = <String, dynamic>{
      'type': _type,
      'title': _title.text.trim(),
      'price': int.tryParse(_price.text.trim()) ?? 0,
      'duration': _duration.text.trim(),
      'description': _description.text.trim(),
      'is_featured': _isFeatured,
      'is_bestseller': _isBestseller,
      if (_originalPrice.text.trim().isNotEmpty)
        'original_price': int.tryParse(_originalPrice.text.trim()),
      if (_imageUrl.isNotEmpty) 'image_url': _imageUrl,
      'learnings': _learnings
          .map((m) => (m['value'] ?? '').toString().trim())
          .where((s) => s.isNotEmpty)
          .toList(),
      'includes': _includes
          .where((m) => (m['text'] ?? '').toString().trim().isNotEmpty)
          .map((m) => {'icon': m['icon'], 'text': (m['text']).toString().trim()})
          .toList(),
    };

    if (_type == 'modul') {
      payload['chapters'] = _chapters
          .where((c) => (c['title'] ?? '').toString().trim().isNotEmpty)
          .map((c) => {
                'chapter_number': c['chapter_number'],
                'title': (c['title']).toString().trim(),
                'page_range': c['page_range'],
                'file_url': (c['file_url'] ?? '').toString().trim(),
                'is_free': c['is_free'] == true,
              })
          .toList();
    } else {
      payload['curriculum_sections'] = _sections
          .where((s) => (s['title'] ?? '').toString().trim().isNotEmpty)
          .map((s) => {
                'title': (s['title']).toString().trim(),
                'subtitle': s['subtitle'],
                'items': _asMapList(s['items'])
                    .where((it) => (it['title'] ?? '').toString().trim().isNotEmpty)
                    .map((it) => {
                          'title': (it['title']).toString().trim(),
                          'duration': it['duration'],
                          'type': it['type'] ?? 'video',
                          'content_url': (it['content_url'] ?? '').toString().trim(),
                          'is_free': it['is_free'] == true,
                        })
                    .toList(),
              })
          .toList();
      if (_type == 'bootcamp') {
        payload['batches'] = _batches
            .where((b) => (b['label'] ?? '').toString().trim().isNotEmpty)
            .map((b) => {
                  'label': (b['label']).toString().trim(),
                  'date_range': b['date_range'],
                  'spots': int.tryParse((b['spots'] ?? '').toString()) ?? 0,
                  'status': b['status'] ?? 'open',
                })
            .toList();
      }
    }

    try {
      if (_isEdit) {
        await _admin.updateProduct(widget.initial!['id'] as int, payload);
      } else {
        await _admin.createProduct(payload);
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
      appBar: buildAdminAppBar(_isEdit ? 'Edit Produk' : 'Tambah Produk'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (_loadingDetail)
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: LinearProgressIndicator(),
              ),
            _typeDropdown(),
            const SizedBox(height: 16),
            CustomTextField(
                controller: _title,
                label: 'Judul',
                hint: 'cth: Winner Class: Business Case'),
            const SizedBox(height: 16),
            CustomTextField(
                controller: _price,
                label: 'Harga (Rp)',
                hint: '99000',
                keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            CustomTextField(
                controller: _originalPrice,
                label: 'Harga Coret (opsional)',
                hint: '149000',
                keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            CustomTextField(
                controller: _duration,
                label: 'Durasi (opsional)',
                hint: 'cth: 12 Jam'),
            const SizedBox(height: 16),
            CustomTextField(
                controller: _description,
                label: 'Deskripsi (opsional)',
                hint: 'Ringkasan produk',
                keyboardType: TextInputType.multiline),
            const SizedBox(height: 16),
            AdminImageField(
              label: 'Gambar',
              initialUrl: _imageUrl.isEmpty ? null : _imageUrl,
              onUploaded: (url) => _imageUrl = url,
            ),
            const SizedBox(height: 20),
            _buildLearnings(),
            const SizedBox(height: 20),
            _buildIncludes(),
            const SizedBox(height: 20),
            if (_type == 'modul') _buildChapters() else _buildSections(),
            if (_type == 'bootcamp') ...[
              const SizedBox(height: 20),
              _buildBatches(),
            ],
            const SizedBox(height: 20),
            AdminSwitchRow(
              label: 'Tampilkan sebagai Featured',
              value: _isFeatured,
              onChanged: (v) => setState(() => _isFeatured = v),
            ),
            AdminSwitchRow(
              label: 'Tandai Bestseller',
              value: _isBestseller,
              onChanged: (v) => setState(() => _isBestseller = v),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: _isEdit ? 'Simpan Perubahan' : 'Tambah Produk',
              isLoading: _saving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }

  // ── Nested editors ─────────────────────────────────────────────────────
  Widget _buildLearnings() {
    return RepeatableList(
      title: 'Yang akan dipelajari',
      count: _learnings.length,
      addLabel: 'Tambah poin',
      keyBuilder: (i) => ObjectKey(_learnings[i]),
      onAdd: () => setState(() => _learnings.add({'value': ''})),
      onRemove: (i) => setState(() => _learnings.removeAt(i)),
      rowBuilder: (i) => AdminInlineField(
        initialValue: (_learnings[i]['value'] ?? '').toString(),
        hint: 'cth: Analisis kasus dengan framework',
        onChanged: (v) => _learnings[i]['value'] = v,
      ),
    );
  }

  Widget _buildIncludes() {
    return RepeatableList(
      title: 'Termasuk dalam produk',
      count: _includes.length,
      addLabel: 'Tambah item',
      keyBuilder: (i) => ObjectKey(_includes[i]),
      onAdd: () => setState(() => _includes.add({'icon': 'check', 'text': ''})),
      onRemove: (i) => setState(() => _includes.removeAt(i)),
      rowBuilder: (i) => Column(
        children: [
          AdminInlineDropdown(
            label: 'Ikon',
            value: (_includes[i]['icon'] ?? 'check').toString(),
            options: _iconOptions,
            onChanged: (v) => setState(() => _includes[i]['icon'] = v),
          ),
          const SizedBox(height: 8),
          AdminInlineField(
            label: 'Teks',
            initialValue: (_includes[i]['text'] ?? '').toString(),
            hint: 'cth: Akses seumur hidup',
            onChanged: (v) => _includes[i]['text'] = v,
          ),
        ],
      ),
    );
  }

  Widget _buildChapters() {
    return RepeatableList(
      title: 'Daftar Bab (Modul)',
      count: _chapters.length,
      addLabel: 'Tambah bab',
      keyBuilder: (i) => ObjectKey(_chapters[i]),
      onAdd: () => setState(() => _chapters.add({
            'chapter_number': '',
            'title': '',
            'page_range': '',
            'file_url': '',
            'is_free': false,
          })),
      onRemove: (i) => setState(() => _chapters.removeAt(i)),
      rowBuilder: (i) => Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 70,
                child: AdminInlineField(
                  label: 'No',
                  initialValue: (_chapters[i]['chapter_number'] ?? '').toString(),
                  hint: '01',
                  onChanged: (v) => _chapters[i]['chapter_number'] = v,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AdminInlineField(
                  label: 'Judul bab',
                  initialValue: (_chapters[i]['title'] ?? '').toString(),
                  onChanged: (v) => _chapters[i]['title'] = v,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: AdminInlineField(
                  label: 'Rentang halaman',
                  initialValue: (_chapters[i]['page_range'] ?? '').toString(),
                  hint: '1–18',
                  onChanged: (v) => _chapters[i]['page_range'] = v,
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Gratis',
                      style: GoogleFonts.poppins(
                          fontSize: 11, color: AdminTheme.muted)),
                  Switch(
                    value: _chapters[i]['is_free'] == true,
                    activeThumbColor: AdminTheme.purple,
                    onChanged: (v) => setState(() => _chapters[i]['is_free'] = v),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          AdminInlineField(
            label: 'Link PDF (file_url)',
            initialValue: (_chapters[i]['file_url'] ?? '').toString(),
            hint: 'cth: https://drive.google.com/file/d/.../view',
            onChanged: (v) => _chapters[i]['file_url'] = v,
          ),
        ],
      ),
    );
  }

  Widget _buildSections() {
    return RepeatableList(
      title: 'Kurikulum',
      subtitle: 'Tiap bagian berisi beberapa materi.',
      count: _sections.length,
      addLabel: 'Tambah bagian',
      keyBuilder: (i) => ObjectKey(_sections[i]),
      onAdd: () =>
          setState(() => _sections.add({'title': '', 'subtitle': '', 'items': []})),
      onRemove: (i) => setState(() => _sections.removeAt(i)),
      rowBuilder: (i) {
        final items = _asMapList(_sections[i]['items']);
        // pastikan list 'items' adalah list mutable yang sama
        _sections[i]['items'] = items;
        return Column(
          children: [
            AdminInlineField(
              label: 'Judul bagian',
              initialValue: (_sections[i]['title'] ?? '').toString(),
              onChanged: (v) => _sections[i]['title'] = v,
            ),
            const SizedBox(height: 8),
            AdminInlineField(
              label: 'Subjudul (opsional)',
              initialValue: (_sections[i]['subtitle'] ?? '').toString(),
              hint: 'cth: 4 materi',
              onChanged: (v) => _sections[i]['subtitle'] = v,
            ),
            const SizedBox(height: 8),
            RepeatableList(
              title: 'Materi',
              count: items.length,
              addLabel: 'Tambah materi',
              keyBuilder: (j) => ObjectKey(items[j]),
              onAdd: () => setState(() => items.add({
                    'title': '',
                    'duration': '',
                    'type': 'video',
                    'content_url': '',
                    'is_free': false,
                  })),
              onRemove: (j) => setState(() => items.removeAt(j)),
              rowBuilder: (j) => Column(
                children: [
                  AdminInlineField(
                    label: 'Judul materi',
                    initialValue: (items[j]['title'] ?? '').toString(),
                    onChanged: (v) => items[j]['title'] = v,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: AdminInlineField(
                          label: 'Durasi',
                          initialValue: (items[j]['duration'] ?? '').toString(),
                          hint: 'cth: 8 mnt',
                          onChanged: (v) => items[j]['duration'] = v,
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 110,
                        child: AdminInlineDropdown(
                          label: 'Tipe',
                          value: (items[j]['type'] ?? 'video').toString(),
                          options: _typeOptions,
                          onChanged: (v) => setState(() => items[j]['type'] = v),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  AdminInlineField(
                    label: 'Link materi (content_url)',
                    initialValue: (items[j]['content_url'] ?? '').toString(),
                    hint: 'cth: https://youtu.be/... / link Drive / link Meet',
                    onChanged: (v) => items[j]['content_url'] = v,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text('Preview gratis',
                          style: GoogleFonts.poppins(
                              fontSize: 11, color: AdminTheme.muted)),
                      const Spacer(),
                      Switch(
                        value: items[j]['is_free'] == true,
                        activeThumbColor: AdminTheme.purple,
                        onChanged: (v) =>
                            setState(() => items[j]['is_free'] = v),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBatches() {
    return RepeatableList(
      title: 'Batch (Bootcamp)',
      count: _batches.length,
      addLabel: 'Tambah batch',
      keyBuilder: (i) => ObjectKey(_batches[i]),
      onAdd: () => setState(() => _batches.add(
          {'label': '', 'date_range': '', 'spots': '', 'status': 'open'})),
      onRemove: (i) => setState(() => _batches.removeAt(i)),
      rowBuilder: (i) => Column(
        children: [
          AdminInlineField(
            label: 'Label batch',
            initialValue: (_batches[i]['label'] ?? '').toString(),
            hint: 'cth: Batch 5 — Mei 2026',
            onChanged: (v) => _batches[i]['label'] = v,
          ),
          const SizedBox(height: 8),
          AdminInlineField(
            label: 'Rentang tanggal',
            initialValue: (_batches[i]['date_range'] ?? '').toString(),
            hint: 'cth: 5 Mei – 2 Jun 2026',
            onChanged: (v) => _batches[i]['date_range'] = v,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              SizedBox(
                width: 90,
                child: AdminInlineField(
                  label: 'Kuota',
                  initialValue: (_batches[i]['spots'] ?? '').toString(),
                  hint: '20',
                  keyboardType: TextInputType.number,
                  onChanged: (v) => _batches[i]['spots'] = v,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AdminInlineDropdown(
                  label: 'Status',
                  value: (_batches[i]['status'] ?? 'open').toString(),
                  options: _statusOptions,
                  onChanged: (v) => setState(() => _batches[i]['status'] = v),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _typeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TIPE',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _type,
          items: const [
            DropdownMenuItem(value: 'modul', child: Text('Modul')),
            DropdownMenuItem(value: 'kelas', child: Text('Kelas')),
            DropdownMenuItem(value: 'bootcamp', child: Text('Bootcamp')),
          ],
          onChanged: (v) => setState(() => _type = v ?? 'kelas'),
        ),
      ],
    );
  }
}
