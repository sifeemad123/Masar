import 'package:flutter/material.dart';
import 'package:masar/components/motion.dart';
import 'package:masar/theme/AppColors.dart';

/// Shared building blocks for the study section
/// (subjects, subject details, lessons, notes).

String lessonsCountText(int n) {
  if (n == 0) return 'لسه مفيش دروس';
  if (n == 1) return 'درس واحد';
  if (n == 2) return 'درسين';
  if (n <= 10) return '$n دروس';
  return '$n درس';
}

String notesCountText(int n) {
  if (n == 0) return 'مفيش ملاحظات';
  if (n == 1) return 'ملاحظة واحدة';
  if (n == 2) return 'ملاحظتين';
  if (n <= 10) return '$n ملاحظات';
  return '$n ملاحظة';
}

/// Same soft pearl gradient used by Home / Tasks / Habits.
class PageBackground extends StatelessWidget {
  final Widget child;
  const PageBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.pearlLight,
            AppColors.background,
            AppColors.pearlDark,
          ],
        ),
      ),
      child: child,
    );
  }
}

/// Round white button used in the top bars (back / edit / delete).
class RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const RoundIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Pressable(
      haptic: true,
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.08),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(icon, color: color ?? AppColors.textPrimary, size: 22),
      ),
    );
  }
}

/// Floating add button (same look as the main "+" button).
class AddFab extends StatelessWidget {
  final VoidCallback onTap;
  const AddFab({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 750),
      curve: Curves.elasticOut,
      builder: (context, v, child) => Transform.scale(scale: v, child: child),
      child: Pressable(
        haptic: true,
        pressedScale: 0.92,
        onTap: onTap,
        child: Container(
          width: 66,
          height: 66,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [AppColors.accent, AppColors.accentDark],
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.38),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.add_rounded,
            color: AppColors.onAccent,
            size: 34,
          ),
        ),
      ),
    );
  }
}

/// Animated circular progress with a percentage in the middle.
class ProgressRing extends StatelessWidget {
  final double progress;
  final double size;
  final double stroke;
  final Color color;
  final Color track;
  final Color labelColor;
  final double fontSize;

  const ProgressRing({
    super.key,
    required this.progress,
    this.size = 78,
    this.stroke = 8,
    this.color = AppColors.accent,
    this.track = const Color(0x1F006D77),
    this.labelColor = AppColors.textPrimary,
    this.fontSize = 17,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(
          begin: 0,
          end: progress.clamp(0.0, 1.0).toDouble(),
        ),
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeOutCubic,
        builder: (context, v, _) {
          return Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: v,
                strokeWidth: stroke,
                strokeCap: StrokeCap.round,
                backgroundColor: track,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
              Center(
                child: Text(
                  '${(v * 100).round()}%',
                  style: TextStyle(
                    color: labelColor,
                    fontSize: fontSize,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Section title with a small count badge.
class SectionTitle extends StatelessWidget {
  final String title;
  final int count;
  final int index;

  const SectionTitle({
    super.key,
    required this.title,
    required this.count,
    this.index = 3,
  });

  @override
  Widget build(BuildContext context) {
    return FadeSlideIn(
      index: index,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 22, 24, 8),
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 10),
            if (count > 0)
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Small rounded chip: icon + text.
class InfoPill extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final Color? background;
  final Color? borderColor;

  const InfoPill({
    super.key,
    required this.icon,
    required this.text,
    this.color = AppColors.accent,
    this.background,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background ?? color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor ?? color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}