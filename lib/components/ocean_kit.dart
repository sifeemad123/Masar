import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:masar/components/motion.dart';
import 'package:masar/components/study_kit.dart';
import 'package:masar/theme/AppColors.dart';

class OceanTap extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;
  final bool haptic;

  const OceanTap({
    super.key,
    required this.child,
    this.onTap,
    this.pressedScale = 0.96,
    this.haptic = true,
  });

  @override
  State<OceanTap> createState() => _OceanTapState();
}

class _OceanTapState extends State<OceanTap> {
  bool _down = false;

  void _set(bool v) {
    if (_down != v && mounted) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _set(true),
      onTapUp: (_) => _set(false),
      onTapCancel: () => _set(false),
      onTap: widget.onTap == null
          ? null
          : () {
        if (widget.haptic) HapticFeedback.selectionClick();
        widget.onTap!();
      },
      child: AnimatedScale(
        scale: _down ? widget.pressedScale : 1,
        duration: const Duration(milliseconds: 130),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

class Reveal extends StatefulWidget {
  final Widget child;
  final int index;
  final double dy;

  const Reveal({super.key, required this.child, this.index = 0, this.dy = 30});

  @override
  State<Reveal> createState() => _RevealState();
}

class _RevealState extends State<Reveal> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final CurvedAnimation _curved;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
    _curved = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
    Future.delayed(Duration(milliseconds: math.min(widget.index, 10) * 90), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _curved.dispose();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curved,
      child: widget.child,
      builder: (context, child) {
        final v = _curved.value;
        return Opacity(
          opacity: v.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, widget.dy * (1 - v)),
            child: Transform.scale(scale: 0.96 + 0.04 * v, child: child),
          ),
        );
      },
    );
  }
}

Route<T> oceanRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 480),
    reverseTransitionDuration: const Duration(milliseconds: 320),
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, anim, __, child) {
      final curved = CurvedAnimation(
        parent: anim,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.06),
            end: Offset.zero,
          ).animate(curved),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1).animate(curved),
            child: child,
          ),
        ),
      );
    },
  );
}


class WavePainter extends CustomPainter {
  final double level;

  final double phase;
  final double amplitude;
  final Color color;
  final int layers;

  WavePainter({
    required this.level,
    required this.phase,
    required this.color,
    this.amplitude = 6,
    this.layers = 2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (level <= 0 || size.isEmpty) return;
    final base = size.height * (1 - level.clamp(0.0, 0.78));

    for (var l = 0; l < layers; l++) {
      final freq = 1.2 + l * 0.55;
      final shift = l * 1.7;
      final dir = l.isEven ? 1.0 : -1.0;
      final amp = amplitude * (1 - l * 0.28);
      final alphaK = layers == 1 ? 1.0 : 0.5 + 0.5 * l / (layers - 1);

      final path = Path()..moveTo(0, size.height);
      for (double x = 0; x <= size.width + 4; x += 4) {
        final y = base +
            math.sin((x / size.width) * 2 * math.pi * freq +
                phase * 2 * math.pi * dir +
                shift) *
                amp;
        path.lineTo(x, y);
      }
      path
        ..lineTo(size.width, size.height)
        ..close();

      canvas.drawPath(
        path,
        Paint()..color = color.withValues(alpha: color.a * alphaK),
      );
    }
  }

  @override
  bool shouldRepaint(covariant WavePainter old) =>
      old.level != level ||
          old.phase != phase ||
          old.color != color ||
          old.amplitude != amplitude;
}

class OceanBackground extends StatefulWidget {
  final Widget child;
  const OceanBackground({super.key, required this.child});

  @override
  State<OceanBackground> createState() => _OceanBackgroundState();
}

class _OceanBackgroundState extends State<OceanBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 60))
      ..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageBackground(
      child: Stack(
        fit: StackFit.expand,
        children: [
          IgnorePointer(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _SeaPainter(_c),
                size: Size.infinite,
              ),
            ),
          ),
          widget.child,
        ],
      ),
    );
  }
}

class _Bubble {
  final double x, r, phase;
  final int speed, sway;
  const _Bubble(this.x, this.r, this.phase, this.speed, this.sway);
}

class _SeaPainter extends CustomPainter {
  final Animation<double> anim;
  _SeaPainter(this.anim) : super(repaint: anim);

  static final List<_Bubble> _bubbles = () {
    final r = math.Random(11);
    return List.generate(
      18,
          (_) => _Bubble(
        r.nextDouble(),
        2 + r.nextDouble() * 5,
        r.nextDouble(),
        2 + r.nextInt(4),
        2 + r.nextInt(4),
      ),
    );
  }();

  @override
  void paint(Canvas canvas, Size size) {
    final t = anim.value;
    final w = size.width, h = size.height;

    // أشعة ضوء ناعمة
    final rayRect = Rect.fromLTWH(0, 0, w, h * 0.7);
    final rayPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.accentLight.withValues(alpha: 0.22),
          AppColors.accentLight.withValues(alpha: 0),
        ],
      ).createShader(rayRect);
    for (var i = 0; i < 4; i++) {
      final sway = math.sin(2 * math.pi * (t * 2 + i * 0.25));
      final x0 = w * (0.05 + i * 0.27) + sway * 24;
      final path = Path()
        ..moveTo(x0, 0)
        ..lineTo(x0 + 46, 0)
        ..lineTo(x0 + 260 + sway * 20, h * 0.7)
        ..lineTo(x0 + 110 + sway * 20, h * 0.7)
        ..close();
      canvas.drawPath(path, rayPaint);
    }

    for (final b in _bubbles) {
      final prog = (t * b.speed + b.phase) % 1.0;
      final y = h * (1 - prog);
      final x = w * b.x + math.sin(2 * math.pi * (t * b.sway + b.phase)) * 8;
      final fade = math.sin(math.pi * prog);
      canvas.drawCircle(
        Offset(x, y),
        b.r,
        Paint()..color = AppColors.accentLight.withValues(alpha: 0.14 * fade),
      );
      canvas.drawCircle(
        Offset(x, y),
        b.r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = AppColors.accent.withValues(alpha: 0.22 * fade),
      );
      canvas.drawCircle(
        Offset(x - b.r * 0.3, y - b.r * 0.3),
        b.r * 0.22,
        Paint()..color = Colors.white.withValues(alpha: 0.8 * fade),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SeaPainter old) => false;
}

class GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const GlassIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.color = AppColors.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return OceanTap(
      onTap: onTap,
      pressedScale: 0.88,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.surface,
          border: Border.all(color: AppColors.divider),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.08),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
}

class OceanEmpty extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const OceanEmpty({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  State<OceanEmpty> createState() => _OceanEmptyState();
}

class _OceanEmptyState extends State<OceanEmpty>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 150,
              height: 150,
              child: AnimatedBuilder(
                animation: _c,
                builder: (context, _) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      for (var k = 0; k < 2; k++)
                        Builder(builder: (context) {
                          final t = (_c.value + k * 0.5) % 1.0;
                          final size = 76 + 70 * t;
                          return Container(
                            width: size,
                            height: size,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.accent
                                    .withValues(alpha: 0.3 * (1 - t)),
                                width: 2,
                              ),
                            ),
                          );
                        }),
                      Transform.translate(
                        offset: Offset(0, math.sin(2 * math.pi * _c.value) * 6),
                        child: Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                              colors: [AppColors.accent, AppColors.accentDark],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accent.withValues(alpha: 0.3),
                                blurRadius: 22,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Icon(
                            widget.icon,
                            color: AppColors.onAccent,
                            size: 36,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14.5,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}