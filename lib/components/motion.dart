import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FadeSlideIn extends StatelessWidget {
  final Widget child;
  final int index;
  final Duration delay;
  final Duration duration;
  final Offset offset;

  const FadeSlideIn({
    super.key,
    required this.child,
    this.index = 0,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 550),
    this.offset = const Offset(0, 28),
  });

  @override
  Widget build(BuildContext context) {
    final stagger = Duration(milliseconds: (index.clamp(0, 10)) * 70);
    return _Delayed(
      delay: delay + stagger,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: duration,
        curve: Curves.easeOutCubic,
        builder: (context, v, child) => Opacity(
          opacity: v,
          child: Transform.translate(
            offset: Offset(offset.dx * (1 - v), offset.dy * (1 - v)),
            child: child,
          ),
        ),
        child: child,
      ),
    );
  }
}

/// Builds [child] only after [delay], so the tween above starts late.
class _Delayed extends StatefulWidget {
  final Duration delay;
  final Widget child;
  const _Delayed({required this.delay, required this.child});

  @override
  State<_Delayed> createState() => _DelayedState();
}

class _DelayedState extends State<_Delayed> {
  late bool _ready = widget.delay == Duration.zero;

  @override
  void initState() {
    super.initState();
    if (!_ready) {
      Future.delayed(widget.delay, () {
        if (mounted) setState(() => _ready = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) =>
      _ready ? widget.child : Opacity(opacity: 0, child: widget.child);
}

/// Scales down slightly while pressed. Wrap any tappable card/button.
class Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double pressedScale;
  final bool haptic;

  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.pressedScale = 0.96,
    this.haptic = false,
  });

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _set(bool v) {
    if (_down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _set(true),
      onTapCancel: () => _set(false),
      onTapUp: (_) => _set(false),
      onTap: widget.onTap == null
          ? null
          : () {
        if (widget.haptic) HapticFeedback.selectionClick();
        widget.onTap!();
      },
      onLongPress: widget.onLongPress,
      child: AnimatedScale(
        scale: _down ? widget.pressedScale : 1,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// Counts from 0 (or the previous value) up to [value].
class AnimatedCount extends StatelessWidget {
  final int value;
  final TextStyle? style;
  final String suffix;

  const AnimatedCount({
    super.key,
    required this.value,
    this.style,
    this.suffix = '',
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.toDouble()),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => Text('${v.round()}$suffix', style: style),
    );
  }
}

/// Fade + scale route used for pushing full screens.
Route<T> fadeScaleRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 450),
    reverseTransitionDuration: const Duration(milliseconds: 350),
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, animation, __, child) {
      final curved =
      CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.06),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}