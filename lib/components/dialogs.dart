import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:masar/components/motion.dart';
import 'package:masar/theme/AppColors.dart';

/// App-wide dialogs: success, failed and confirm.
///
/// Why dialogs used to "disappear": they were opened with a BuildContext that
/// had already been popped (the bottom sheet / previous dialog), and Flutter
/// silently refuses to open a route from a dead context.
///
/// To make this impossible, plug [Dialogs.navigatorKey] into MaterialApp:
///
///   MaterialApp(navigatorKey: Dialogs.navigatorKey, ...)
///
/// Dialogs then always open on the live root navigator, whatever context
/// the caller passes.
class Dialogs {
  Dialogs._();

  static final GlobalKey<NavigatorState> navigatorKey =
  GlobalKey<NavigatorState>();

  static BuildContext? _resolve(BuildContext context) {
    final overlay = navigatorKey.currentState?.overlay?.context;
    if (overlay != null && overlay.mounted) return overlay;
    return context.mounted ? context : null;
  }

  // ---------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------

  static Future<void> success({
    required BuildContext context,
    required String message,
    String title = "تم بنجاح",
  }) {
    return _show(
      context,
      _DialogCard(
        icon: Icons.check_rounded,
        color: AppColors.success,
        title: title,
        message: message,
        autoCloseAfter: const Duration(milliseconds: 2400),
        primaryText: "تمام",
      ),
    );
  }

  static Future<void> failed({
    required BuildContext context,
    required String message,
    String title = "في مشكلة",
  }) {
    HapticFeedback.mediumImpact();
    return _show(
      context,
      _DialogCard(
        icon: Icons.priority_high_rounded,
        color: AppColors.warning,
        title: title,
        message: message,
        primaryText: "حاضر",
      ),
    );
  }

  /// Ask the user to confirm. [onConfirm] runs after the dialog closes.
  static Future<void> confirm({
    required BuildContext context,
    required String title,
    required String message,
    required VoidCallback onConfirm,
    String confirmText = "تأكيد",
    String cancelText = "إلغاء",
    bool danger = false,
  }) {
    return _show(
      context,
      _DialogCard(
        icon: danger ? Icons.delete_outline_rounded : Icons.help_outline_rounded,
        color: danger ? AppColors.danger : AppColors.accent,
        title: title,
        message: message,
        primaryText: confirmText,
        secondaryText: cancelText,
        onPrimary: onConfirm,
      ),
    );
  }

  // ---------------------------------------------------------------

  static Future<void> _show(BuildContext context, Widget card) async {
    final ctx = _resolve(context);
    if (ctx == null) return;

    await showGeneralDialog<void>(
      context: ctx,
      barrierDismissible: true,
      barrierLabel: 'إغلاق',
      barrierColor: Colors.black.withValues(alpha: 0.45),
      transitionDuration: const Duration(milliseconds: 340),
      pageBuilder: (_, __, ___) => Directionality(
        textDirection: TextDirection.rtl,
        child: Center(child: card),
      ),
      transitionBuilder: (_, animation, __, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
          reverseCurve: Curves.easeIn,
        );
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.82, end: 1).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}

class _DialogCard extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String message;
  final String primaryText;
  final String? secondaryText;
  final VoidCallback? onPrimary;
  final Duration? autoCloseAfter;

  const _DialogCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
    required this.primaryText,
    this.secondaryText,
    this.onPrimary,
    this.autoCloseAfter,
  });

  @override
  State<_DialogCard> createState() => _DialogCardState();
}

class _DialogCardState extends State<_DialogCard>
    with SingleTickerProviderStateMixin {
  AnimationController? _timer;

  @override
  void initState() {
    super.initState();
    final d = widget.autoCloseAfter;
    if (d != null) {
      _timer = AnimationController(vsync: this, duration: d)
        ..forward().whenComplete(() {
          if (!mounted) return;
          final route = ModalRoute.of(context);
          if (route != null && route.isCurrent) Navigator.pop(context);
        });
    }
  }

  @override
  void dispose() {
    _timer?.dispose();
    super.dispose();
  }

  void _primary() {
    Navigator.pop(context);
    widget.onPrimary?.call();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color;
    final hasSecondary = widget.secondaryText != null;

    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 28),
        constraints: const BoxConstraints(maxWidth: 340),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.22),
              blurRadius: 44,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 30, 24, 22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _IconBadge(icon: widget.icon, color: color),
                    const SizedBox(height: 20),
                    Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.message,
                      textAlign: TextAlign.center,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 15,
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: Pressable(
                            haptic: true,
                            onTap: _primary,
                            child: Container(
                              height: 52,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.35),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Text(
                                widget.primaryText,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (hasSecondary) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: Pressable(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                height: 52,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: AppColors.overlay,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  widget.secondaryText!,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (_timer != null)
                AnimatedBuilder(
                  animation: _timer!,
                  builder: (context, _) => Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: FractionallySizedBox(
                      widthFactor: 1 - _timer!.value,
                      child: Container(
                        height: 4,
                        color: color.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _IconBadge({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 900),
      curve: Curves.elasticOut,
      builder: (context, v, child) => Transform.scale(
        scale: v.clamp(0.0, 1.3),
        child: child,
      ),
      child: Container(
        width: 84,
        height: 84,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.12),
        ),
        child: Center(
          child: Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [color.withValues(alpha: 0.85), color],
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
        ),
      ),
    );
  }
}