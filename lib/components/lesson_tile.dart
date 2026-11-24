import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:masar/components/motion.dart';
import 'package:masar/components/ocean_kit.dart';
import 'package:masar/components/study_kit.dart';
import 'package:masar/providers/notes_provider.dart';
import 'package:masar/theme/AppColors.dart';
import 'package:provider/provider.dart';

/// كارت الدرس — كل درس "محطة" على خط رحلة.
class LessonTile extends StatefulWidget {
  final String lessonName;
  final String lessonDescription;
  final bool lessonCompleted;
  final void Function(bool?) onChanged;
  final void Function() onTap;
  final int lessonId;
  final void Function(BuildContext) onDelete;
  final void Function(BuildContext) onEdit;

  /// موضع الكارت في القائمة (للأنيميشن).
  final int index;

  /// رقم الدرس الحقيقي (بيظهر جوه العقدة).
  final int? lessonNumber;

  /// بيحدد أطراف خط الرحلة.
  final bool isFirst;
  final bool isLast;

  /// الدرس الجاي (أول درس لسه مخلصش) — بياخد نبض وإضاءة.
  final bool isNext;

  const LessonTile({
    super.key,
    required this.lessonName,
    required this.lessonDescription,
    required this.lessonCompleted,
    required this.onChanged,
    required this.onTap,
    required this.lessonId,
    required this.onDelete,
    required this.onEdit,
    this.index = 0,
    this.lessonNumber,
    this.isFirst = false,
    this.isLast = false,
    this.isNext = false,
  });

  @override
  State<LessonTile> createState() => _LessonTileState();
}

class _LessonTileState extends State<LessonTile> with TickerProviderStateMixin {
  static const double _railWidth = 56;

  late final AnimationController _enter;
  late final AnimationController _burst;
  late final AnimationController _fill;
  late final AnimationController _pulse;
  late final CurvedAnimation _curved;

  bool get done => widget.lessonCompleted;
  bool get _shouldPulse => widget.isNext && !done;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _burst = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fill = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
      value: done ? 1 : 0,
    );
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _curved = CurvedAnimation(
      parent: _enter,
      curve: const Interval(0, 0.55, curve: Curves.easeOutCubic),
    );

    if (_shouldPulse) _pulse.repeat();

    Future.delayed(
      Duration(milliseconds: math.min(widget.index, 10) * 80),
          () {
        if (mounted) _enter.forward();
      },
    );
  }

  @override
  void didUpdateWidget(covariant LessonTile old) {
    super.didUpdateWidget(old);

    if (!old.lessonCompleted && widget.lessonCompleted) {
      HapticFeedback.mediumImpact();
      _burst.forward(from: 0);
      _fill.forward(from: 0);
    } else if (old.lessonCompleted && !widget.lessonCompleted) {
      _fill.reverse();
    }

    if (_shouldPulse) {
      if (!_pulse.isAnimating) _pulse.repeat();
    } else if (_pulse.isAnimating) {
      _pulse
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _curved.dispose();
    _enter.dispose();
    _burst.dispose();
    _fill.dispose();
    _pulse.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------
  // Timeline node (tappable check)
  // ---------------------------------------------------------------

  Widget _node() {
    return Semantics(
      button: true,
      checked: done,
      label: done ? 'درس مكتمل' : 'علّم الدرس كمكتمل',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (done) HapticFeedback.selectionClick();
          widget.onChanged(!done);
        },
        child: SizedBox(
          width: _railWidth,
          height: 52,
          child: AnimatedBuilder(
            animation: Listenable.merge([_burst, _pulse]),
            builder: (context, _) {
              final bt = _burst.value;
              final bounce = 1 + 0.3 * math.sin(math.pi * bt);
              return Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  if (_pulse.isAnimating)
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _RipplePainter(_pulse.value),
                      ),
                    ),
                  if (bt > 0 && bt < 1)
                    Positioned.fill(
                      child: CustomPaint(painter: _BubbleBurstPainter(bt)),
                    ),
                  Transform.scale(
                    scale: bounce,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOutCubic,
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: done
                            ? const LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [
                            AppColors.secondaryDark,
                            AppColors.success,
                          ],
                        )
                            : null,
                        color: done ? null : AppColors.surface,
                        border: Border.all(
                          color: done
                              ? Colors.transparent
                              : AppColors.accent.withValues(
                            alpha: widget.isNext ? 1 : 0.5,
                          ),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (done ? AppColors.success : AppColors.accent)
                                .withValues(
                              alpha: done ? 0.4 : (widget.isNext ? 0.3 : 0.0),
                            ),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        switchInCurve: Curves.easeOutBack,
                        transitionBuilder: (c, a) =>
                            ScaleTransition(scale: a, child: c),
                        child: done
                            ? const Icon(
                          Icons.check_rounded,
                          key: ValueKey('check'),
                          size: 22,
                          color: AppColors.onSuccess,
                        )
                            : Center(
                          key: const ValueKey('num'),
                          child: widget.lessonNumber == null
                              ? const Icon(
                            Icons.circle,
                            size: 8,
                            color: AppColors.accent,
                          )
                              : Text(
                            '${widget.lessonNumber}',
                            style: const TextStyle(
                              color: AppColors.accent,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // Pieces
  // ---------------------------------------------------------------

  Widget _water() {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _fill,
          builder: (context, _) {
            final v = Curves.easeOutCubic.transform(_fill.value);
            if (v <= 0) return const SizedBox.shrink();
            return CustomPaint(
              painter: WavePainter(
                level: 0.26 * v,
                // الموج بيتحرك وهو طالع وبعدين بيثبت
                phase: _fill.value * 2.5,
                color: AppColors.success.withValues(alpha: 0.16),
                amplitude: 5 * (1 - 0.4 * v),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _sheen() {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _enter,
          builder: (context, _) {
            final t = const Interval(0.3, 1.0, curve: Curves.easeInOut)
                .transform(_enter.value);
            if (t <= 0 || t >= 1) return const SizedBox.shrink();
            return LayoutBuilder(
              builder: (context, c) {
                final w = c.maxWidth;
                return Stack(
                  children: [
                    Positioned(
                      left: -w * 0.4 + t * w * 1.6,
                      top: 0,
                      bottom: 0,
                      width: w * 0.35,
                      child: Transform(
                        transform: Matrix4.skewX(-0.35),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.accentLight.withValues(alpha: 0),
                                AppColors.accentLight.withValues(alpha: 0.35),
                                AppColors.accentLight.withValues(alpha: 0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _metaChip({
    required IconData icon,
    required String text,
    required Color color,
    Color? textColor,
    bool filled = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: filled ? color.withValues(alpha: 0.14) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: textColor ?? color,
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _nextBadge() {
    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sailing_rounded, size: 13, color: AppColors.accent),
          SizedBox(width: 5),
          Text(
            'كمّل من هنا',
            style: TextStyle(
              color: AppColors.accent,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({
    required int notesCount,
    required bool hasSummary,
  }) {
    final desc = widget.lessonDescription.trim();

    final top = done
        ? Color.alphaBlend(
      AppColors.success.withValues(alpha: 0.10),
      AppColors.surface,
    )
        : AppColors.surface;
    final bottom = Color.alphaBlend(
      (done ? AppColors.success : AppColors.accent)
          .withValues(alpha: done ? 0.04 : 0.06),
      AppColors.surface,
    );

    return OceanTap(
      pressedScale: 0.97,
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [top, bottom],
          ),
          border: Border.all(
            color: done
                ? AppColors.success.withValues(alpha: 0.32)
                : (widget.isNext
                ? AppColors.accent.withValues(alpha: 0.55)
                : AppColors.border),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withValues(
                alpha: done ? 0 : (widget.isNext ? 0.2 : 0.1),
              ),
              blurRadius: widget.isNext ? 26 : 20,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(23),
          child: Stack(
            children: [
              _water(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.isNext && !done) _nextBadge(),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 250),
                            style: TextStyle(
                              color: done
                                  ? AppColors.textMuted
                                  : AppColors.textPrimary,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              height: 1.25,
                              decoration: done
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              decorationColor: AppColors.success,
                              decorationThickness: 2.5,
                            ),
                            child: Text(
                              widget.lessonName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (desc.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              desc,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13.5,
                              ),
                            ),
                          ],
                          const SizedBox(height: 9),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              _metaChip(
                                icon: Icons.sticky_note_2_rounded,
                                text: notesCountText(notesCount),
                                color: notesCount == 0
                                    ? AppColors.textMuted
                                    : AppColors.warm,
                                textColor: notesCount == 0
                                    ? AppColors.textMuted
                                    : AppColors.textSecondary,
                                filled: notesCount > 0,
                              ),
                              if (hasSummary)
                                _metaChip(
                                  icon: Icons.auto_stories_rounded,
                                  text: 'ملخص',
                                  color: AppColors.accent,
                                  filled: true,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: AppColors.overlay,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: AppColors.accent,
                        size: 14,
                      ),
                    ),
                  ],
                ),
              ),
              _sheen(),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final notesCount = context.select<NotesProvider, int>(
          (p) => p.notes
          .where((n) => n.lessonId == widget.lessonId && !n.isSummary)
          .length,
    );
    final hasSummary = context.select<NotesProvider, bool>(
          (p) => p.notes.any((n) => n.lessonId == widget.lessonId && n.isSummary),
    );

    return AnimatedBuilder(
      animation: _curved,
      builder: (context, child) {
        final v = _curved.value;
        return Opacity(
          opacity: v.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(34 * (1 - v), 0),
            child: Transform.scale(scale: 0.92 + 0.08 * v, child: child),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            // خط الرحلة
            PositionedDirectional(
              start: 0,
              top: 0,
              bottom: 0,
              width: _railWidth,
              child: CustomPaint(
                painter: _RailPainter(
                  isFirst: widget.isFirst,
                  isLast: widget.isLast,
                  done: done,
                ),
              ),
            ),
            // الكارت
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                _railWidth,
                7,
                0,
                7,
              ),
              child: Slidable(
                key: ValueKey('lesson-slidable-${widget.lessonId}'),
                endActionPane: ActionPane(
                  motion: const BehindMotion(),
                  extentRatio: 0.42,
                  children: [
                    SlidableAction(
                      onPressed: widget.onEdit,
                      icon: Icons.edit_rounded,
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.onAccent,
                      borderRadius: BorderRadius.zero,
                    ),
                    SlidableAction(
                      onPressed: widget.onDelete,
                      icon: Icons.delete_outline_rounded,
                      backgroundColor: AppColors.danger,
                      foregroundColor: Colors.white,
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(24),
                      ),
                    ),
                  ],
                ),
                child: _card(
                  notesCount: notesCount,
                  hasSummary: hasSummary,
                ),
              ),
            ),
            // العقدة
            PositionedDirectional(
              start: 0,
              top: 0,
              bottom: 0,
              width: _railWidth,
              child: Center(child: _node()),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------
// Painters
// ------------------------------------------------------------------

/// خط الرحلة: متصل ومتوهج للدرس المكتمل، ومنقّط للباقي.
class _RailPainter extends CustomPainter {
  final bool isFirst;
  final bool isLast;
  final bool done;

  _RailPainter({
    required this.isFirst,
    required this.isLast,
    required this.done,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    const gap = 26.0;

    void seg(double y1, double y2) {
      if (y2 <= y1) return;
      if (done) {
        canvas.drawLine(
          Offset(cx, y1),
          Offset(cx, y2),
          Paint()
            ..strokeWidth = 8
            ..color = AppColors.success.withValues(alpha: 0.12),
        );
        canvas.drawLine(
          Offset(cx, y1),
          Offset(cx, y2),
          Paint()
            ..strokeWidth = 3
            ..strokeCap = StrokeCap.round
            ..shader = const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.secondaryDark, AppColors.success],
            ).createShader(Rect.fromLTWH(cx - 2, y1, 4, y2 - y1)),
        );
      } else {
        final p = Paint()
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round
          ..color = AppColors.border;
        for (double y = y1; y < y2; y += 8) {
          canvas.drawLine(
            Offset(cx, y),
            Offset(cx, math.min(y + 3.5, y2)),
            p,
          );
        }
      }
    }

    if (!isFirst) seg(0, cy - gap);
    if (!isLast) seg(cy + gap, size.height);
  }

  @override
  bool shouldRepaint(covariant _RailPainter old) =>
      old.isFirst != isFirst || old.isLast != isLast || old.done != done;
}

/// دوايـر نبض حوالين الدرس الجاي.
class _RipplePainter extends CustomPainter {
  final double t;
  _RipplePainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    for (var k = 0; k < 2; k++) {
      final p = (t + k * 0.5) % 1.0;
      canvas.drawCircle(
        c,
        19 + 14 * p,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2 * (1 - p) + 0.4
          ..color = AppColors.accent.withValues(alpha: 0.5 * (1 - p)),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RipplePainter old) => old.t != t;
}

/// فقاعات بتطلع من العقدة لما الدرس يخلص.
class _BubbleBurstPainter extends CustomPainter {
  final double t;
  _BubbleBurstPainter(this.t);

  static const _colors = [
    AppColors.accent,
    AppColors.success,
    AppColors.secondary,
    AppColors.warm,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final eased = Curves.easeOutCubic.transform(t);

    // موجة صدمة
    canvas.drawCircle(
      c,
      19 + 20 * eased,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3 * (1 - t)
        ..color = AppColors.success.withValues(alpha: 0.6 * (1 - t)),
    );

    // فقاعات بتطلع لفوق وتتفرق
    const count = 12;
    for (var i = 0; i < count; i++) {
      final a = (2 * math.pi / count) * i;
      final spread = 14 + 20 * eased;
      final rise = 26 * eased * (0.5 + (i % 3) * 0.3);
      final pos = c +
          Offset(math.cos(a) * spread, math.sin(a) * spread * 0.6 - rise);
      final r = (2.2 + (i % 4)) * (1 - t) + 0.4;
      final col = _colors[i % _colors.length];
      canvas.drawCircle(
        pos,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..color = col.withValues(alpha: 1 - t),
      );
      if (i.isEven) {
        canvas.drawCircle(
          pos,
          r * 0.5,
          Paint()..color = col.withValues(alpha: 0.5 * (1 - t)),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BubbleBurstPainter old) => old.t != t;
}