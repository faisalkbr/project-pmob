// ============================================
// FILE: lib/views/profile_screen/edit_profile_screen.dart
// ============================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/auth_viewmodel.dart';

/// Form edit profil: ubah nama & email, plus ganti password opsional.
/// Sumber data awal diambil dari AuthViewModel (sumber kebenaran), dan
/// perubahan disimpan ke server lewat AuthViewModel.updateProfile.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const Color _bg     = Color(0xFFFBFAFF);
  static const Color _navy   = Color(0xFF001261);
  static const Color _purple = Color(0xFFA600B2);
  static const Color _muted  = Color(0xFF757684);
  static const Color _border = Color(0x14001261);
  static const Color _green  = Color(0xFF16A34A);

  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  final _currentPassCtrl = TextEditingController();
  final _newPassCtrl     = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool _changePassword = false;
  bool _obscureCurrent = true;
  bool _obscureNew     = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthViewModel>();
    _nameCtrl  = TextEditingController(text: auth.name);
    _emailCtrl = TextEditingController(text: auth.email);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _currentPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthViewModel>();
    final ok = await auth.updateProfile(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      currentPassword: _changePassword ? _currentPassCtrl.text : null,
      newPassword: _changePassword ? _newPassCtrl.text : null,
      newPasswordConfirmation: _changePassword ? _confirmPassCtrl.text : null,
    );

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profil berhasil diperbarui',
              style: GoogleFonts.manrope(fontSize: 13)),
          backgroundColor: _green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Gagal memperbarui profil',
              style: GoogleFonts.manrope(fontSize: 13)),
          backgroundColor: const Color(0xFFE53935),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthViewModel>().isLoading;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  // Batasi lebar di tablet/desktop agar form tetap nyaman dibaca.
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      padding: EdgeInsets.fromLTRB(
                        20, 8, 20,
                        MediaQuery.of(context).viewInsets.bottom + 32,
                      ),
                      children: [
                        _sectionLabel('Informasi Akun'),
                        const SizedBox(height: 10),
                        _LabeledField(
                          label: 'Nama Lengkap',
                          controller: _nameCtrl,
                          hint: 'Masukkan nama kamu',
                          icon: Icons.person_outline_rounded,
                          validator: (v) {
                            final t = (v ?? '').trim();
                            if (t.isEmpty) return 'Nama tidak boleh kosong';
                            if (t.length < 3) return 'Nama minimal 3 karakter';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _LabeledField(
                          label: 'Email',
                          controller: _emailCtrl,
                          hint: 'nama@email.com',
                          icon: Icons.alternate_email_rounded,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            final t = (v ?? '').trim();
                            if (t.isEmpty) return 'Email tidak boleh kosong';
                            final re = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                            if (!re.hasMatch(t)) return 'Format email tidak valid';
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        _buildPasswordToggle(),
                        if (_changePassword) ...[
                          const SizedBox(height: 16),
                          _LabeledField(
                            label: 'Password Saat Ini',
                            controller: _currentPassCtrl,
                            hint: 'Masukkan password lama',
                            icon: Icons.lock_outline_rounded,
                            obscure: _obscureCurrent,
                            onToggleObscure: () => setState(
                                () => _obscureCurrent = !_obscureCurrent),
                            validator: (v) {
                              if (!_changePassword) return null;
                              if ((v ?? '').isEmpty) {
                                return 'Wajib diisi untuk ganti password';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _LabeledField(
                            label: 'Password Baru',
                            controller: _newPassCtrl,
                            hint: 'Minimal 8 karakter',
                            icon: Icons.lock_reset_rounded,
                            obscure: _obscureNew,
                            onToggleObscure: () =>
                                setState(() => _obscureNew = !_obscureNew),
                            validator: (v) {
                              if (!_changePassword) return null;
                              if ((v ?? '').length < 8) {
                                return 'Password minimal 8 karakter';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _LabeledField(
                            label: 'Konfirmasi Password Baru',
                            controller: _confirmPassCtrl,
                            hint: 'Ulangi password baru',
                            icon: Icons.lock_outline_rounded,
                            obscure: _obscureConfirm,
                            onToggleObscure: () => setState(
                                () => _obscureConfirm = !_obscureConfirm),
                            validator: (v) {
                              if (!_changePassword) return null;
                              if (v != _newPassCtrl.text) {
                                return 'Konfirmasi tidak cocok';
                              }
                              return null;
                            },
                          ),
                        ],
                        const SizedBox(height: 28),
                        _buildSaveButton(isLoading),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 16, 8),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.of(context).pop(),
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(Icons.arrow_back_ios_new_rounded,
                    size: 18, color: _navy),
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Edit Profil',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: _navy,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.spaceGrotesk(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: _muted,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildPasswordToggle() {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => setState(() => _changePassword = !_changePassword),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _border),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: _purple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.password_rounded,
                    size: 19, color: _purple),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ganti Password',
                        style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _navy)),
                    Text('Opsional — kosongkan bila tidak diubah',
                        style: GoogleFonts.manrope(
                            fontSize: 11, color: _muted)),
                  ],
                ),
              ),
              Switch(
                value: _changePassword,
                activeTrackColor: _purple,
                onChanged: (v) => setState(() => _changePassword = v),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton(bool isLoading) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _navy,
          foregroundColor: Colors.white,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: isLoading ? null : _save,
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: Colors.white),
              )
            : Text('Simpan Perubahan',
                style: GoogleFonts.manrope(
                    fontSize: 14, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

// ─── Field bergaya konsisten dengan ProfileScreen ────────────────────────────

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.obscure = false,
    this.onToggleObscure,
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;
  final bool obscure;
  final VoidCallback? onToggleObscure;
  final String? Function(String?)? validator;

  static const Color _navy   = Color(0xFF001261);
  static const Color _muted  = Color(0xFF757684);
  static const Color _border = Color(0x22001261);
  static const Color _purple = Color(0xFFA600B2);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _navy)),
        const SizedBox(height: 7),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscure,
          validator: validator,
          style: GoogleFonts.manrope(
              fontSize: 14, color: _navy, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.manrope(fontSize: 13, color: _muted),
            filled: true,
            fillColor: Colors.white,
            prefixIcon: Icon(icon, size: 19, color: _muted),
            suffixIcon: onToggleObscure == null
                ? null
                : IconButton(
                    icon: Icon(
                        obscure
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        size: 19,
                        color: _muted),
                    onPressed: onToggleObscure,
                  ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _purple, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE53935)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE53935), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
