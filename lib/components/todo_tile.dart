import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:masar/components/motion.dart';
import 'package:masar/theme/AppColors.dart';

class TodoTile extends StatefulWidget {
  final String taskName;
  final bool value;
  final DateTime time;
  final Function(bool?)? onChanged;
  final Function(BuildContext)? deleteTask;
  final Function(BuildContext)? updateTask;

  /// Position in the list, used to stagger the entrance animation.
  final int index;

  const TodoTile({
    super.key,
    required this.taskName,
    required this.value,
    required this.onChanged,
    required this.time,
    required this.deleteTask,
    required this.updateTask,
    this.index = 0,
  });

  @override
  State<TodoTile> createState() => _TodoTileState();
}

class _TodoTileState extends State<TodoTile> with TickerProviderStateMixin {
  late final AnimationController _enter; // entrance + sheen
  late final AnimationController _burst; // completion celebration
  late final AnimationController _pulse; // overdue dot

  String get taskName => widget.taskName;
  bool get value => widget.value;
  DateTime get time => widget.time;

  bool get _overdue {
    final now = DateTime.now();
    return !value && time.isBefore(DateTime(now.year, now.month, now.day));
  }

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
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    Future.delayed(
      Duration(milliseconds: math.min(widget.index, 10) * 80),
          () {
        if (mounted) _enter.forward();
      },
    );
    _syncPulse();
  }

  @override
  void didUpdateWidget(covariant TodoTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.value && widget.value) {
      HapticFeedback.mediumImpact();
      _burst.forward(from: 0);
    }
    _syncPulse();
  }

  void _syncPulse() {
    if (_overdue) {
      if (!_pulse.isAnimating) _pulse.repeat(reverse: true);
    } else {
      _pulse.stop();
    }
  }

  @override
  void dispose() {
    _enter.dispose();
    _burst.dispose();
    _pulse.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------
  // Details sheet
  // ---------------------------------------------------------------

  void _showDetails(BuildContext context, {required bool overdue}) {
    final statusColor = value
        ? AppColors.success
        : overdue
        ? AppColors.danger
        : AppColors.warm;
    final statusText = value
        ? "خلصت المهمة"
        : overdue
        ? "المهمة متأخرة"
        : "لسه مخلصتش";
    final statusIcon = value
        ? Icons.check_circle_rounded
        : overdue
        ? Icons.error_rounded
        : Icons.pending_rounded;

    Widget infoBox({
      required IconData icon,
      required String label,
      required String text,
    }) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.overlay,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.accent, size: 26),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  text,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "تفاصيل المهمة",
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                taskName,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 20),
              infoBox(
                icon: Icons.event_rounded,
                label: "الموعد النهائي",
                text: "${time.day} / ${time.month} / ${time.year}",
              ),
              const SizedBox(height: 12),
              infoBox(
                icon: Icons.access_time_rounded,
                label: "الساعة",
                text: TimeOfDay.fromDateTime(time).format(sheetContext),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding:
                const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Icon(statusIcon, color: statusColor, size: 26),
                    const SizedBox(width: 14),
                    Text(
                      statusText,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Pressable(
                onTap: () => Navigator.pop(sheetContext),
                child: Container(
                  height: 54,
                  width: double.infinity,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [AppColors.accent, AppColors.accentDark],
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Text(
                    "تمام",
                    style: TextStyle(
                      color: AppColors.onAccent,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------
  // Pieces
  // ---------------------------------------------------------------

  /// "باقي ساعتين" / "متأخرة من يومين" ...
  String _relative() {
    if (value) return "خلصت";
    final diff = time.difference(DateTime.now());
    if (diff.isNegative) {
      final late = -diff;
      if (late.inDays >= 1) return "متأخرة من ${late.inDays} يوم";
      if (late.inHours >= 1) return "متأخرة من ${late.inHours} ساعة";
      return "متأخرة";
    }
    if (diff.inMinutes < 60) return "باقي ${math.max(diff.inMinutes, 1)} دقيقة";
    if (diff.inHours < 24) return "باقي ${diff.inHours} ساعة";
    return "بعد ${diff.inDays} يوم";
  }

  Widget _checkCircle() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (!value) {
          // haptic for completion is fired in didUpdateWidget
        } else {
          HapticFeedback.selectionClick();
        }
        widget.onChanged?.call(!value);
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
                      gradient: value
                          ? const LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [Color(0xFF3DDC97), AppColors.success],
                      )
                          : null,
                      border: Border.all(
                        color: value ? Colors.transparent : AppColors.textMuted,
                        width: 2,
                      ),
                      boxShadow: value
                          ? [
                        BoxShadow(
                          color:
                          AppColors.success.withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                          : const [],
                    ),
                    child: AnimatedScale(
                      scale: value ? 1 : 0,
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

  Widget _metaRow(Color color) {
    final now = DateTime.now();
    final sameDay = DateUtils.isSameDay(time, now);
    final rel = _relative();

    return Row(
      children: [
        if (_overdue)
          AnimatedBuilder(
            animation: _pulse,
            builder: (context, _) => Container(
              width: 8,
              height: 8,
              margin: const EdgeInsetsDirectional.only(end: 6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.55 * _pulse.value),
                    blurRadius: 3 + 8 * _pulse.value,
                    spreadRadius: 1 + 2 * _pulse.value,
                  ),
                ],
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 5),
            child: Icon(
              value ? Icons.celebration_rounded : Icons.timelapse_rounded,
              size: 15,
              color: color,
            ),
          ),
        Flexible(
          child: Text(
            sameDay || value ? rel : "$rel • ${time.day}/${time.month}",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _timeBadge(BuildContext context, Color color) {
    final text = TimeOfDay.fromDateTime(time).format(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.schedule_rounded, size: 15, color: color),
          const SizedBox(height: 3),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
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
    final overdue = _overdue;

    final Color stateColor = value
        ? AppColors.success
        : overdue
        ? AppColors.danger
        : AppColors.accent;
    final Color metaColor = value ? AppColors.success : stateColor;

    final stripe = value
        ? const [Color(0xFF3DDC97), AppColors.success]
        : overdue
        ? [AppColors.danger, AppColors.warm]
        : [AppColors.accentLight, AppColors.accent];

    final bgTop = value
        ? Color.alphaBlend(
      AppColors.success.withValues(alpha: 0.12),
      AppColors.surface,
    )
        : AppColors.surface;
    final bgBottom = Color.alphaBlend(
      stateColor.withValues(alpha: value ? 0.04 : 0.08),
      AppColors.surface,
    );

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
          endActionPane: ActionPane(
            motion: const BehindMotion(),
            extentRatio: 0.42,
            children: [
              SlidableAction(
                onPressed: widget.updateTask,
                icon: Icons.edit_rounded,
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.onAccent,
                borderRadius: BorderRadius.zero,
              ),
              SlidableAction(
                onPressed: widget.deleteTask,
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
            onTap: () => _showDetails(context, overdue: overdue),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: stateColor.withValues(alpha: value ? 0.0 : 0.16),
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
                          color: overdue
                              ? AppColors.danger.withValues(alpha: 0.4)
                              : value
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
                                const EdgeInsets.fromLTRB(14, 14, 6, 14),
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
                                              color: value
                                                  ? AppColors.textMuted
                                                  : AppColors.textPrimary,
                                              fontSize: 17,
                                              fontWeight: FontWeight.w900,
                                              height: 1.25,
                                              decoration: value
                                                  ? TextDecoration.lineThrough
                                                  : TextDecoration.none,
                                              decorationColor:
                                              AppColors.success,
                                              decorationThickness: 2.5,
                                            ),
                                            child: Text(
                                              taskName,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(height: 7),
                                          _metaRow(metaColor),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    _timeBadge(
                                      context,
                                      value
                                          ? AppColors.textMuted
                                          : stateColor,
                                    ),
                                    const SizedBox(width: 8),
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

    // expanding ring
    canvas.drawCircle(
      center,
      17 + 14 * eased,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3 * (1 - t)
        ..color = AppColors.success.withValues(alpha: 0.6 * (1 - t)),
    );

    // dots
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