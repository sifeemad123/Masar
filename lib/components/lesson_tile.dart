import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:masar/components/motion.dart';
import 'package:masar/components/study_kit.dart';
import 'package:masar/providers/notes_provider.dart';
import 'package:masar/theme/AppColors.dart';
import 'package:provider/provider.dart';

class LessonTile extends StatefulWidget {
  final String lessonName;
  final String lessonDescription;
  final bool lessonCompleted;
  final void Function(bool?) onChanged;
  final void Function() onTap;
  final int lessonId;
  final void Function(BuildContext) onDelete;
  final void Function(BuildContext) onEdit;

  /// Position in the list, used to stagger the entrance animation.
  final int index;

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
  });

  @override
  State<LessonTile> createState() => _LessonTileState();
}

class _LessonTileState extends State<LessonTile>
    with TickerProviderStateMixin {
  late final AnimationController _enter;
  late final AnimationController _burst;

  bool get done => widget.lessonCompleted;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _burst = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    Future.delayed(
      Duration(milliseconds: math.min(widget.index, 10) * 80),
          () {
        if (mounted) _enter.forward();
      },
    );
  }

  @override
  void didUpdateWidget(covariant LessonTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.lessonCompleted && widget.lessonCompleted) {
      HapticFeedback.mediumImpact();
      _burst.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _enter.dispose();
    _burst.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------
  // Pieces
  // ---------------------------------------------------------------

  Widget _checkCircle() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (done) HapticFeedback.selectionClick();
        widget.onChanged(!done);
      },
      child: SizedBox(
        width: 52,
        height: 52,
        child: AnimatedBuilder(
          animation: _burst,
          builder: (context, _) {
            final t = _burst.value;
            final bounce = 1 + 0.28 * math.sin(math.pi * t);
            return Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                if (t > 0 && t < 1)
                  Positioned.fill(
                    child: CustomPaint(painter: _BurstPainter(t)),
                  ),
                Transform.scale(
                  scale: bounce,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: done
                          ? const LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [Color(0xFF3DDC97), AppColors.success],
                      )
                          : null,
                      border: Border.all(
                        color: done ? Colors.transparent : AppColors.textMuted,
                        width: 2,
                      ),
                      boxShadow: done
                          ? [
                        BoxShadow(
                          color: AppColors.success.withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                          : const [],
                    ),
                    child: AnimatedScale(
                      scale: done ? 1 : 0,
                      duration: const Duration(milliseconds: 320),
                      curve: Curves.easeOutBack,
                      child: const Icon(
                        Icons.check_rounded,
                        size: 21,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
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
            final t = const Interval(0.35, 1.0, curve: Curves.easeInOut)
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
                                Colors.white.withValues(alpha: 0),
                                Colors.white.withValues(alpha: 0.45),
                                Colors.white.withValues(alpha: 0),
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

  // ---------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final notesCount = context
        .watch<NotesProvider>()
        .notes
        .where((n) => n.lessonId == widget.lessonId)
        .length;

    final stateColor = done ? AppColors.success : AppColors.accent;
    final stripe = done
        ? const [Color(0xFF3DDC97), AppColors.success]
        : const [AppColors.accentLight, AppColors.accent];

    final bgTop = done
        ? Color.alphaBlend(
      AppColors.success.withValues(alpha: 0.12),
      AppColors.surface,
    )
        : AppColors.surface;
    final bgBottom = Color.alphaBlend(
      stateColor.withValues(alpha: done ? 0.04 : 0.08),
      AppColors.surface,
    );

    final desc = widget.lessonDescription.trim();

    final curved = CurvedAnimation(
      parent: _enter,
      curve: const Interval(0, 0.5, curve: Curves.easeOutCubic),
    );

    return AnimatedBuilder(
      animation: curved,
      builder: (context, child) {
        final v = curved.value;
        return Opacity(
          opacity: v,
          child: Transform.translate(
            offset: Offset(26 * (1 - v), 0),
            child: Transform.scale(scale: 0.94 + 0.06 * v, child: child),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
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
          child: Pressable(
            pressedScale: 0.97,
            haptic: true,
            onTap: widget.onTap,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: stateColor.withValues(alpha: done ? 0.0 : 0.14),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOutCubic,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [bgTop, bgBottom],
                        ),
                        border: Border.all(
                          color: done
                              ? AppColors.success.withValues(alpha: 0.3)
                              : AppColors.border,
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 350),
                              width: 6,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: stripe,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding:
                                const EdgeInsets.fromLTRB(14, 14, 10, 14),
                                child: Row(
                                  children: [
                                    _checkCircle(),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          AnimatedDefaultTextStyle(
                                            duration: const Duration(
                                              milliseconds: 250,
                                            ),
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
                                              decorationColor:
                                              AppColors.success,
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
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.sticky_note_2_rounded,
                                                size: 15,
                                                color: notesCount == 0
                                                    ? AppColors.textMuted
                                                    : AppColors.warm,
                                              ),
                                              const SizedBox(width: 5),
                                              Flexible(
                                                child: Text(
                                                  notesCountText(notesCount),
                                                  maxLines: 1,
                                                  overflow:
                                                  TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: notesCount == 0
                                                        ? AppColors.textMuted
                                                        : AppColors
                                                        .textSecondary,
                                                    fontSize: 12.5,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
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
                                        size: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    _sheen(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Little confetti ring that bursts out of the check circle.
class _BurstPainter extends CustomPainter {
  final double t;
  _BurstPainter(this.t);

  static const _colors = [
    Color(0xFF3DDC97),
    AppColors.accent,
    AppColors.warm,
    AppColors.accentLight,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final eased = Curves.easeOutCubic.transform(t);

    canvas.drawCircle(
      center,
      17 + 14 * eased,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3 * (1 - t)
        ..color = AppColors.success.withValues(alpha: 0.6 * (1 - t)),
    );

    const count = 10;
    for (var i = 0; i < count; i++) {
      final angle = (2 * math.pi / count) * i;
      final dist = 14 + 22 * eased;
      final radius = 3.2 * (1 - t) + 0.4;
      canvas.drawCircle(
        center + Offset(math.cos(angle), math.sin(angle)) * dist,
        radius,
        Paint()..color = _colors[i % _colors.length].withValues(alpha: 1 - t),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BurstPainter old) => old.t != t;
}