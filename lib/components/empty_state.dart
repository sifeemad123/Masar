import 'package:flutter/material.dart';
import 'package:masar/components/motion.dart';
import 'package:masar/theme/AppColors.dart';

/// Friendly animated empty state, reused by every list screen.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.4, end: 1),
              duration: const Duration(milliseconds: 900),
              curve: Curves.elasticOut,
              builder: (context, v, child) =>
                  Transform.scale(scale: v, child: child),
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accent.withValues(alpha: 0.16),
                      AppColors.accent.withValues(alpha: 0.04),
                    ],
                  ),
                ),
                child: Icon(icon, size: 52, color: AppColors.accent),
              ),
            ),
            const SizedBox(height: 22),
            FadeSlideIn(
              index: 1,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 8),
            FadeSlideIn(
              index: 2,
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}