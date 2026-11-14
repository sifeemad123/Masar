import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:masar/Screens/subject_details.dart';
import 'package:masar/components/motion.dart';
import 'package:masar/components/study_kit.dart';
import 'package:masar/providers/lessons_provider.dart';
import 'package:masar/theme/AppColors.dart';
import 'package:provider/provider.dart';

class SubjectCard extends StatefulWidget {
  final String subjectName;
  final String subjectDescription;
  final int subjectId;
  final String? teacherName;

  final void Function(BuildContext)? deleteFunction;
  final void Function(BuildContext)? editFunction;

  /// Position in the list, used to stagger the entrance animation.
  final int index;

  const SubjectCard({
    super.key,
    required this.subjectName,
    required this.subjectDescription,
    required this.deleteFunction,
    required this.editFunction,
    required this.subjectId,
    this.teacherName,
    this.index = 0,
  });

  @override
  State<SubjectCard> createState() => _SubjectCardState();
}

class _SubjectCardState extends State<SubjectCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enter;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    Future.delayed(
      Duration(milliseconds: math.min(widget.index, 10) * 80),
          () {
        if (mounted) _enter.forward();
      },
    );
  }

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  void _openDetails() {
    Navigator.push<void>(
      context,
      fadeScaleRoute<void>(
        SubjectDetails(
          subjectName: widget.subjectName,
          subjectDescription: widget.subjectDescription,
          subjectId: widget.subjectId,
          teacherName: widget.teacherName,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // Pieces
  // ---------------------------------------------------------------

  Widget _icon(bool complete) {
    return Hero(
      tag: 'subject-icon-${widget.subjectId}',
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: complete
                ? const [Color(0xFF3DDC97), AppColors.success]
                : const [AppColors.accent, AppColors.accentDark],
          ),
          borderRadius: BorderRadius.circular(19),
          boxShadow: [
            BoxShadow(
              color: (complete ? AppColors.success : AppColors.accent)
                  .withValues(alpha: 0.3),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(
          complete ? Icons.workspace_premium_rounded : Icons.menu_book_rounded,
          color: AppColors.onAccent,
          size: 29,
        ),
      ),
    );
  }

  Widget _progressRow({
    required int total,
    required int done,
    required double progress,
    required Color color,
  }) {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: progress),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (context, v, _) => LinearProgressIndicator(
                value: v,
                minHeight: 8,
                backgroundColor: color.withValues(alpha: 0.12),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          total == 0 ? 'ابدأ بدرس' : '$done / $total',
          style: TextStyle(
            color: total == 0 ? AppColors.textMuted : color,
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
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
    final lessons = context
        .watch<LessonsProvider>()
        .lessons
        .where((l) => l.subjectId == widget.subjectId)
        .toList();
    final total = lessons.length;
    final done = lessons.where((l) => l.lessonCompleted).length;
    final progress = total == 0 ? 0.0 : done / total;
    final complete = total > 0 && done == total;

    final stateColor = complete ? AppColors.success : AppColors.accent;
    final teacher = widget.teacherName?.trim() ?? '';
    final desc = widget.subjectDescription.trim();

    final bgTop = complete
        ? Color.alphaBlend(
      AppColors.success.withValues(alpha: 0.1),
      AppColors.surface,
    )
        : AppColors.surface;
    final bgBottom = Color.alphaBlend(
      stateColor.withValues(alpha: complete ? 0.04 : 0.07),
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
            offset: Offset(0, 26 * (1 - v)),
            child: Transform.scale(scale: 0.94 + 0.06 * v, child: child),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
        child: Slidable(
          key: ValueKey('subject-slidable-${widget.subjectId}'),
          endActionPane: ActionPane(
            motion: const BehindMotion(),
            extentRatio: 0.42,
            children: [
              SlidableAction(
                onPressed: widget.editFunction,
                icon: Icons.edit_rounded,
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.onAccent,
                borderRadius: BorderRadius.zero,
              ),
              SlidableAction(
                onPressed: widget.deleteFunction,
                icon: Icons.delete_outline_rounded,
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(26),
                ),
              ),
            ],
          ),
          child: Pressable(
            pressedScale: 0.97,
            haptic: true,
            onTap: _openDetails,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: stateColor.withValues(alpha: complete ? 0.06 : 0.14),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 350),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: [bgTop, bgBottom],
                          ),
                          border: Border.all(
                            color: complete
                                ? AppColors.success.withValues(alpha: 0.35)
                                : AppColors.border,
                          ),
                          borderRadius: BorderRadius.circular(26),
                        ),
                      ),
                    ),
                    PositionedDirectional(
                      end: -35,
                      top: -45,
                      child: IgnorePointer(
                        child: Container(
                          width: 125,
                          height: 125,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: stateColor.withValues(alpha: 0.05),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              _icon(complete),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.subjectName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    if (desc.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        desc,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 13,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 10),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 6,
                                      children: [
                                        InfoPill(
                                          icon: Icons.layers_rounded,
                                          text: lessonsCountText(total),
                                          color: AppColors.accent,
                                        ),
                                        if (teacher.isNotEmpty)
                                          InfoPill(
                                            icon: Icons.person_outline_rounded,
                                            text: teacher,
                                            color: AppColors.textSecondary,
                                            background: AppColors.overlay,
                                            borderColor: AppColors.border,
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
                          const SizedBox(height: 16),
                          _progressRow(
                            total: total,
                            done: done,
                            progress: progress,
                            color: stateColor,
                          ),
                        ],
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