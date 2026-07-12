// ============================================
// FILE: lib/views/admin/admin_repeatable.dart
// ============================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'admin_theme.dart';

/// Section daftar editor yang bisa ditambah/hapus (learnings, includes,
/// chapters, curriculum sections + items, batches).
///
/// Tiap baris dirender via [rowBuilder]; widget ini hanya mengurus layout
/// kartu, tombol hapus per-baris, dan tombol "Tambah".
class RepeatableList extends StatelessWidget {
  const RepeatableList({
    super.key,
    required this.title,
    required this.count,
    required this.rowBuilder,
    required this.onAdd,
    required this.onRemove,
    this.addLabel = 'Tambah',
    this.subtitle,
    this.keyBuilder,
  });

  final String title;
  final String? subtitle;
  final int count;
  final Widget Function(int index) rowBuilder;
  final VoidCallback onAdd;
  final void Function(int index) onRemove;
  final String addLabel;

  /// Key stabil per-baris (mis. `ObjectKey(rowMap)`) agar state field tidak
  /// tertukar saat baris ditambah/dihapus.
  final Key? Function(int index)? keyBuilder;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
            letterSpacing: 1.0,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(subtitle!,
              style: GoogleFonts.poppins(fontSize: 11, color: AdminTheme.muted)),
        ],
        const SizedBox(height: 8),
        for (int i = 0; i < count; i++)
          Container(
            key: keyBuilder?.call(i),
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.fromLTRB(12, 8, 4, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: rowBuilder(i)),
                IconButton(
                  icon: const Icon(Icons.close_rounded,
                      size: 18, color: AdminTheme.danger),
                  visualDensity: VisualDensity.compact,
                  onPressed: () => onRemove(i),
                ),
              ],
            ),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: Text(addLabel),
            style: OutlinedButton.styleFrom(
              foregroundColor: AdminTheme.purple,
              side: BorderSide(color: AdminTheme.purple.withValues(alpha: 0.4)),
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }
}

/// Field teks ringkas tanpa controller (pakai initialValue + onChanged),
/// cocok untuk baris dinamis yang sering ditambah/hapus.
class AdminInlineField extends StatelessWidget {
  const AdminInlineField({
    super.key,
    required this.initialValue,
    required this.onChanged,
    this.label,
    this.hint,
    this.keyboardType,
    this.maxLines = 1,
  });

  final String initialValue;
  final ValueChanged<String> onChanged;
  final String? label;
  final String? hint;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!,
              style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AdminTheme.muted)),
          const SizedBox(height: 4),
        ],
        TextFormField(
          initialValue: initialValue,
          onChanged: onChanged,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: InputDecoration(
            isDense: true,
            hintText: hint,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }
}

/// Dropdown ringkas untuk baris dinamis (type item, status batch, icon include).
class AdminInlineDropdown extends StatelessWidget {
  const AdminInlineDropdown({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
    this.label,
  });

  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final safeValue = options.contains(value) ? value : options.first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!,
              style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AdminTheme.muted)),
          const SizedBox(height: 4),
        ],
        DropdownButtonFormField<String>(
          initialValue: safeValue,
          isDense: true,
          style: GoogleFonts.poppins(fontSize: 13, color: AdminTheme.navy),
          items: options
              .map((o) => DropdownMenuItem(value: o, child: Text(o)))
              .toList(),
          onChanged: (v) => onChanged(v ?? safeValue),
          decoration: InputDecoration(
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }
}
