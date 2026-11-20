
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:masar/components/motion.dart';
import 'package:masar/theme/AppColors.dart';

class HabitTile extends StatefulWidget {
  final String habitName;
  final String habitDescription;
  final bool habitComplete;
  final int streakCount;
  final int protectionRemaining;
  final bool protectionNeeded;

  final String? alarmText;

  final Function(bool?)? onChanged;
  final Function(BuildContext)? deleteTask;
  final Function(BuildContext)? updateTask;

  final int index;

  const HabitTile({
    super.key,
    required this.habitName,
    required this.habitDescription,
    required this.habitComplete,
    required this.onChanged,
    required this.streakCount,
    required this.deleteTask,
    required this.updateTask,
    this.alarmText,
    this.protectionRemaining = 3,
    this.protectionNeeded = false,
    this.index = 0,
  });

  @override
  State<HabitTile> createState() => _HabitTileState();
}

class _HabitTileState extends State<HabitTile>
    with TickerProviderStateMixin {
  late final AnimationController _enter;
  late final AnimationController _burst;
  late final AnimationController _flame;

  bool get done => widget.habitComplete;

  bool _protectedSuccess = false;

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

    _flame = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    Future.delayed(
      Duration(milliseconds: math.min(widget.index, 10) * 80),
          () {
        if (mounted) _enter.forward();
      },
    );

    _syncFlame();
  }

  @override
  void didUpdateWidget(covariant HabitTile oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!oldWidget.habitComplete && widget.habitComplete) {
      HapticFeedback.mediumImpact();
      _burst.forward(from: 0);

      // A consumed chance means this completion protected the existing streak.
      _protectedSuccess = oldWidget.protectionNeeded &&
          oldWidget.protectionRemaining > widget.protectionRemaining;
    } else if (oldWidget.habitComplete && !widget.habitComplete) {
      _protectedSuccess = false;
    }

    _syncFlame();
  }

  void _syncFlame() {
    if (done && widget.streakCount > 0) {
      if (!_flame.isAnimating) {
        _flame.repeat(reverse: true);
      }
    } else {
      _flame.stop();
    }
  }

  @override
  void dispose() {
    _enter.dispose();
    _burst.dispose();
    _flame.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------
  // Details sheet
  // ---------------------------------------------------------------

  void _showDetails(BuildContext context) {
    final streak = widget.streakCount;

    Widget section(String title, String value) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value.isEmpty ? "مفيش وصف" : value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
          ),
        ],
      );
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(sheetContext).size.height * 0.85,
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 2, 22, 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "تفاصيل العادة",
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      widget.habitName,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                        height: 1.35,
                      ),
                    ),

                    const SizedBox(height: 18),

                    section(
                      "وصف العادة",
                      widget.habitDescription,
                    ),

                    const SizedBox(height: 16),

                    _protectionInfoCard(),

                    const SizedBox(height: 18),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [
                            AppColors.flameActive.withValues(alpha: 0.18),
                            AppColors.flameActive.withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.local_fire_department_rounded,
                            color: streak > 0
                                ? AppColors.flameActive
                                : AppColors.flameInactive,
                            size: 44,
                          ),

                          const SizedBox(height: 6),

                          Text(
                            streak == 0
                                ? "لسه البداية"
                                : "$streak يوم متواصل",
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 21,
                              fontWeight: FontWeight.w900,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            streak == 0
                                ? "ابدأ النهاردة وخليها عادة"
                                : "كمّل، إنت ماشي كويس",
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (widget.alarmText != null) ...[
                      const SizedBox(height: 14),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.overlay,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.alarm_rounded,
                              color: AppColors.accent,
                              size: 24,
                            ),

                            const SizedBox(width: 12),

                            const Text(
                              "التنبيه",
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),

                            const Spacer(),

                            Text(
                              widget.alarmText!,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

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
                            colors: [
                              AppColors.accent,
                              AppColors.accentDark,
                            ],
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
              ),
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------
  // Pieces
  // ---------------------------------------------------------------

  Widget _checkCircle() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (done) HapticFeedback.selectionClick();
        widget.onChanged?.call(!done);
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
                    child: CustomPaint(
                      painter: _BurstPainter(t),
                    ),
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
                        colors: [
                          Color(0xFF3DDC97),
                          AppColors.success,
                        ],
                      )
                          : null,
                      border: Border.all(
                        color: done
                            ? Colors.transparent
                            : AppColors.textMuted,
                        width: 2,
                      ),
                      boxShadow: done
                          ? [
                        BoxShadow(
                          color: AppColors.success.withValues(
                            alpha: 0.4,
                          ),
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

  Widget _streakBadge() {
    final active = done && widget.streakCount > 0;
    final color = active ? AppColors.flameActive : AppColors.textMuted;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      decoration: BoxDecoration(
        gradient: active
            ? LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.flameActive.withValues(alpha: 0.2),
            AppColors.flameActive.withValues(alpha: 0.06),
          ],
        )
            : null,
        color: active ? null : AppColors.overlay,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: color.withValues(alpha: 0.28),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _flame,
            builder: (context, child) {
              final t = Curves.easeInOut.transform(_flame.value);
              return Transform.scale(
                scale: 1 + 0.14 * t,
                child: Transform.rotate(
                  angle: (t - 0.5) * 0.16,
                  child: child,
                ),
              );
            },
            child: Icon(
              Icons.local_fire_department_rounded,
              color: active
                  ? AppColors.flameActive
                  : AppColors.flameInactive,
              size: 21,
            ),
          ),
          const SizedBox(width: 5),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: animation,
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            ),
            child: Text(
              "${widget.streakCount}",
              key: ValueKey(widget.streakCount),
              style: TextStyle(
                color: active
                    ? AppColors.textPrimary
                    : AppColors.textMuted,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _protectionInfoCard() {
    final remaining = widget.protectionRemaining.clamp(0, 3);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.overlay,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.flameActive.withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.flameActive.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.shield_rounded,
              color: AppColors.flameActive,
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "رصيد حماية السلسلة",
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  remaining == 0
                      ? "استهلكت فرص الحماية المتاحة للشهر ده"
                      : "متبقي $remaining من 3 فرص حماية للشهر ده",
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          Row(
            children: List.generate(3, (index) {
              final active = index < remaining;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(left: 4),
                width: 8,
                height: 20,
                decoration: BoxDecoration(
                  color: active
                      ? AppColors.flameActive
                      : AppColors.textMuted.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(5),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _protectionStatus() {
    if (_protectedSuccess && done) {
      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 450),
          transitionBuilder: (child, animation) => SizeTransition(
            sizeFactor: animation,
            axisAlignment: -1,
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          ),
          child: Container(
            key: const ValueKey('protected-success'),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 11,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: AppColors.success.withValues(alpha: 0.24),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.verified_rounded,
                  color: AppColors.success,
                  size: 17,
                ),
                SizedBox(width: 7),
                Expanded(
                  child: Text(
                    "سلسلتك في أمان! استخدمت فرصة حماية، وهنبدأ يوم جديد بالتزام أقوى.",
                    style: TextStyle(
                      color: AppColors.success,
                      fontSize: 11.5,
                      height: 1.45,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }



    return const SizedBox.shrink();
  }

  Widget _protectionCover() {
    if (!widget.protectionNeeded || done) {
      return const SizedBox.shrink();
    }

    final remaining = widget.protectionRemaining.clamp(0, 3);

    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              AppColors.flameActive.withValues(alpha: 0.16),
              AppColors.flameActive.withValues(alpha: 0.07),
              AppColors.surface.withValues(alpha: 0.35),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.flameActive.withValues(alpha: 0.34),
            width: 1.1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.flameActive.withValues(alpha: 0.08),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 39,
              height: 39,
              decoration: BoxDecoration(
                color: AppColors.flameActive.withValues(alpha: 0.17),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: AppColors.flameActive.withValues(alpha: 0.22),
                ),
              ),
              child: const Icon(
                Icons.shield_moon_rounded,
                color: AppColors.flameActive,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "فرصة لحماية سلسلتك",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w900,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    "كمّل العادة والحماية هتتحسب تلقائيًا",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 9,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: AppColors.flameActive.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "$remaining/3",
                    style: const TextStyle(
                      color: AppColors.flameActive,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 1),
                  const Text(
                    "متبقي",
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
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

  Widget _protectionBadge() {
    final remaining = widget.protectionRemaining.clamp(0, 3);

    return Padding(
      padding: const EdgeInsets.only(top: 7),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.shield_outlined,
            size: 14,
            color: remaining > 0
                ? AppColors.flameActive
                : AppColors.textMuted,
          ),

          const SizedBox(width: 4),

          Text(
            "$remaining/3 حماية",
            style: TextStyle(
              color: remaining > 0
                  ? AppColors.flameActive
                  : AppColors.textMuted,
              fontSize: 11.5,
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
            final t = const Interval(
              0.35,
              1.0,
              curve: Curves.easeInOut,
            ).transform(_enter.value);

            if (t <= 0 || t >= 1) {
              return const SizedBox.shrink();
            }

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
    final stateColor = done ? AppColors.success : AppColors.accent;

    final stripe = done
        ? const [
      Color(0xFF3DDC97),
      AppColors.success,
    ]
        : [
      AppColors.accentLight,
      AppColors.accent,
    ];

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

    final curved = CurvedAnimation(
      parent: _enter,
      curve: const Interval(
        0,
        0.5,
        curve: Curves.easeOutCubic,
      ),
    );

    return AnimatedBuilder(
      animation: curved,
      builder: (context, child) {
        final v = curved.value;

        return Opacity(
          opacity: v,
          child: Transform.translate(
            offset: Offset(26 * (1 - v), 0),
            child: Transform.scale(
              scale: 0.94 + 0.06 * v,
              child: child,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 7,
        ),
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
            onTap: () => _showDetails(context),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: widget.protectionNeeded && !done
                        ? AppColors.flameActive.withValues(alpha: 0.13)
                        : stateColor.withValues(
                      alpha: done ? 0.0 : 0.16,
                    ),
                    blurRadius: widget.protectionNeeded && !done ? 25 : 22,
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
                          colors: [
                            bgTop,
                            bgBottom,
                          ],
                        ),
                        border: Border.all(
                          color: done
                              ? AppColors.success.withValues(alpha: 0.3)
                              : widget.protectionNeeded
                              ? AppColors.flameActive.withValues(alpha: 0.38)
                              : AppColors.border,
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(13, 13, 11, 13),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _protectionCover(),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                _checkCircle(),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
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
                                          height: 1.3,
                                          decoration: done
                                              ? TextDecoration.lineThrough
                                              : TextDecoration.none,
                                          decorationColor: AppColors.success,
                                          decorationThickness: 2.5,
                                        ),
                                        child: Text(
                                          widget.habitName,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (widget.habitDescription.isNotEmpty) ...[
                                        const SizedBox(height: 5),
                                        Text(
                                          widget.habitDescription,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 13,
                                            height: 1.35,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 7),
                                _streakBadge(),
                              ],
                            ),
                            if (widget.alarmText != null ||
                                widget.protectionRemaining >= 0) ...[
                              const SizedBox(height: 12),
                              Divider(
                                height: 1,
                                thickness: 1,
                                color: AppColors.border.withValues(alpha: 0.7),
                              ),
                              const SizedBox(height: 9),
                              Row(
                                children: [
                                  if (widget.alarmText != null) ...[
                                    Icon(
                                      Icons.alarm_rounded,
                                      size: 15,
                                      color: done
                                          ? AppColors.textMuted
                                          : AppColors.accent,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      widget.alarmText!,
                                      style: TextStyle(
                                        color: done
                                            ? AppColors.textMuted
                                            : AppColors.accent,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const Spacer(),
                                  ] else
                                    const Spacer(),
                                  _protectionBadge(),
                                ],
                              ),
                            ],
                            _protectionStatus(),
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
        Paint()
          ..color = _colors[i % _colors.length].withValues(alpha: 1 - t),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BurstPainter old) => old.t != t;
}
