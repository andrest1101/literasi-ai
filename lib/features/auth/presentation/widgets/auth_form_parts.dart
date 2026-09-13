import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// Dekorasi input standar seluruh halaman auth.
///
/// Input dibuat sedikit lebih gelap daripada kartu putih agar hierarki form
/// tetap terbaca: sudut 14, isi abu kebiruan muda, fokus biru, error merah.
InputDecoration authInputDecoration({
  required String label,
  required String hint,
  required IconData icon,
}) {
  const radius = BorderRadius.all(Radius.circular(14));
  final border = OutlineInputBorder(
    borderRadius: radius,
    borderSide: BorderSide(color: AppColors.neutral.withValues(alpha: 0.28)),
  );
  return InputDecoration(
    labelText: label,
    hintText: hint,
    floatingLabelStyle: const TextStyle(
      color: AppColors.primary,
      fontWeight: FontWeight.w700,
    ),
    prefixIcon: Icon(icon, size: 20, color: AppColors.primary),
    prefixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 48),
    filled: true,
    fillColor: const Color(0xFFF1F4FA),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: border,
    enabledBorder: border,
    focusedBorder: const OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: AppColors.primary, width: 1.7),
    ),
    errorBorder: const OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: AppColors.danger, width: 1.2),
    ),
    focusedErrorBorder: const OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: AppColors.danger, width: 1.7),
    ),
  );
}

/// Tombol utama biru 54px seluruh halaman auth.
class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          elevation: 5,
          shadowColor: AppColors.primary.withValues(alpha: 0.38),
        ),
        child: loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(label),
      ),
    );
  }
}

/// Kartu utama untuk form auth.
///
/// Dipakai untuk mengelompokkan input + CTA primer agar layar auth terasa
/// fokus dan profesional tanpa perlu ilustrasi besar di atasnya.
class AuthFormCard extends StatelessWidget {
  const AuthFormCard({
    super.key,
    this.title,
    this.subtitle,
    required this.child,
  });

  final String? title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 104, 20, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: AppColors.surface,
        border: Border.all(color: AppColors.neutral.withValues(alpha: 0.22)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14101A33),
            blurRadius: 30,
            offset: Offset(0, 16),
          ),
          BoxShadow(
            color: Color(0x0A1A73E8),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
                color: AppColors.textPrimary,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: 16),
          ],
          child,
        ],
      ),
    );
  }
}

/// Panel aksi sekunder di bawah card form utama.
///
/// Dipakai untuk Google dan anonim agar hierarki tetap jelas tanpa membuat
/// card kedua yang menyaingi form primer.
class AuthSecondaryPanel extends StatelessWidget {
  const AuthSecondaryPanel({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withValues(alpha: 0.72),
        border: Border.all(color: AppColors.neutral.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}

/// Medallion verifikasi sebagai focal point hero auth.
///
/// Bentuk lingkaran berlapis memberi kesan radar dan pemeriksaan berlapis
/// tanpa memakai orb AI generik. Medallion ini sengaja dibuat overlap dengan
/// kartu form lewat [AuthPageShell].
class AuthTrustMedallion extends StatelessWidget {
  const AuthTrustMedallion({super.key, this.size = 120});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'LiterasiAI memverifikasi informasi',
      child: SizedBox(
        width: size + 24,
        height: size + 24,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: size + 24,
              height: size + 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.08),
              ),
            ),
            Container(
              width: size + 12,
              height: size + 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surface,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.18),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14101A33),
                    blurRadius: 22,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
            ),
            Container(
              width: size,
              height: size,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF4B8DF6), AppColors.primary],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x4D1A73E8),
                    blurRadius: 24,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: size * 0.78,
                    height: size * 0.78,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.34),
                        width: 1.4,
                      ),
                    ),
                  ),
                  Container(
                    width: size * 0.58,
                    height: size * 0.58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x2B0F2F66),
                          blurRadius: 12,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.verified_user_rounded,
                      size: size * 0.31,
                      color: AppColors.primary,
                    ),
                  ),
                  Positioned(
                    right: size * 0.22,
                    bottom: size * 0.20,
                    child: Container(
                      width: size * 0.21,
                      height: size * 0.21,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.success,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        size: size * 0.12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tombol kembali di halaman auth dengan latar terang.
class AuthBackButton extends StatelessWidget {
  const AuthBackButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Kembali',
      child: OutlinedButton(
        onPressed: onPressed ?? () => Navigator.of(context).maybePop(),
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: const Size(44, 44),
          shape: const CircleBorder(),
          backgroundColor: AppColors.surface,
          side: BorderSide(color: AppColors.neutral.withValues(alpha: 0.28)),
          foregroundColor: AppColors.textPrimary,
          elevation: 2,
          shadowColor: Colors.black.withValues(alpha: 0.08),
        ),
        child: const Icon(Icons.arrow_back_rounded, size: 20),
      ),
    );
  }
}

/// Tautan penutup di ujung bawah halaman auth.
///
/// Pola satu baris: awalan abu yang menjelaskan, aksi biru tebal yang bisa
/// ditekan. Contoh: "Belum punya akun?" + "Daftar". Selalu jadi elemen
/// terakhir halaman agar hierarki visual jelas.
class AuthBottomLink extends StatelessWidget {
  const AuthBottomLink({
    super.key,
    required this.prefix,
    required this.action,
    required this.onTap,
  });

  final String prefix;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$prefix $action',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
              children: [
                TextSpan(text: '$prefix '),
                TextSpan(
                  text: action,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Snackbar error atau info yang konsisten di halaman auth.
void showAuthMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      action: SnackBarAction(
        label: 'Tutup',
        onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
      ),
    ),
  );
}
