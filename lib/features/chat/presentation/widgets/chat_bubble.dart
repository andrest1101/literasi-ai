import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../quick_check/presentation/screens/quick_check_session_screen.dart';
import '../../domain/entities/chat_message.dart';

/// Bubble chat: kanan biru untuk pengguna, kiri putih untuk AI.
///
/// Bubble AI gagal memakai border merah + tombol kirim ulang. Bubble AI yang
/// berhasil membawa tombol "Verifikasi ini" menuju sesi Quick Check dengan
/// seed klaim yang benar, sesuai PRD §4.1 Feature 2.
class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final ChatMessage message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (message.isUser) return _UserBubble(message: message);
    return _AiBubble(message: message, onRetry: onRetry);
  }
}

class _UserBubble extends StatelessWidget {
  const _UserBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Flexible(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 11,
                  ),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(18),
                      bottomLeft: Radius.circular(18),
                      bottomRight: Radius.circular(6),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF2F80ED), Color(0xFF1A5FCE)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x331A73E8),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    message.text,
                    style: const TextStyle(
                      fontSize: 14.5,
                      height: 1.55,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                _Timestamp(
                  time: message.createdAt,
                  align: TextAlign.right,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AiBubble extends StatelessWidget {
  const _AiBubble({required this.message, required this.onRetry});

  final ChatMessage message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final failed = message.isFailed;
    final typing = message.text.isEmpty && !failed;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2F80ED), Color(0xFF124A9B)],
            ),
          ),
          child: const Icon(
            Icons.verified_user_rounded,
            size: 16,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 11,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(18),
                      bottomLeft: Radius.circular(6),
                      bottomRight: Radius.circular(18),
                    ),
                    color: failed
                        ? AppColors.danger.withValues(alpha: 0.06)
                        : AppColors.surface,
                    border: Border.all(
                      color: failed
                          ? AppColors.danger.withValues(alpha: 0.4)
                          : AppColors.neutral.withValues(alpha: 0.2),
                    ),
                    boxShadow: failed
                        ? null
                        : const [
                            BoxShadow(
                              color: Color(0x0D101A33),
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ],
                  ),
                  child: typing
                      ? const _TypingDots()
                      : Text(
                          message.text,
                          style: const TextStyle(
                            fontSize: 14.5,
                            height: 1.55,
                            color: AppColors.textPrimary,
                          ),
                        ),
                ),
                const SizedBox(height: 4),
                _Timestamp(time: message.createdAt, align: TextAlign.left),
                if (failed) ...[
                  const SizedBox(height: 6),
                  _RetryButton(onRetry: onRetry),
                ] else if (!typing) ...[
                  const SizedBox(height: 6),
                  _VerifyButton(message: message),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Timestamp extends StatelessWidget {
  const _Timestamp({required this.time, required this.align});

  final DateTime time;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    final local = time.toLocal();
    final text =
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
    return SizedBox(
      width: double.infinity,
      child: Text(
        text,
        textAlign: align,
        style: const TextStyle(
          fontSize: 11,
          color: AppColors.textSecondary,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

class _RetryButton extends StatelessWidget {
  const _RetryButton({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: AppStrings.chatRetry,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onRetry,
          borderRadius: BorderRadius.circular(10),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.refresh_rounded,
                  size: 15,
                  color: AppColors.danger,
                ),
                SizedBox(width: 5),
                Text(
                  AppStrings.chatRetry,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.danger,
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

class _VerifyButton extends StatelessWidget {
  const _VerifyButton({required this.message});

  final ChatMessage message;

  void _openSession(BuildContext context) {
    final seed = message.verifySeed?.trim().isNotEmpty == true
        ? message.verifySeed!.trim()
        : message.text.trim();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuickCheckSessionScreen(initialClaim: seed),
        settings: const RouteSettings(name: QuickCheckSessionScreen.route),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: AppStrings.chatVerifyThis,
      child: Material(
        color: AppColors.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: () => _openSession(context),
          borderRadius: BorderRadius.circular(999),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.fact_check_outlined,
                  size: 15,
                  color: AppColors.primary,
                ),
                SizedBox(width: 6),
                Text(
                  AppStrings.chatVerifyThis,
                  style: TextStyle(
                    fontSize: 12.5,
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

class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 900),
      )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppStrings.chatTyping,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < 3; i++) ...[
                if (i > 0) const SizedBox(width: 5),
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(
                      alpha: 0.3 + 0.7 * ((_controller.value * 3 - i).clamp(0.0, 1.0)),
                    ),
                  ),
                ),
              ],
              const SizedBox(width: 8),
              const Text(
                AppStrings.chatTyping,
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
