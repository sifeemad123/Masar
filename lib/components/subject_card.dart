
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:masar/Screens/subject_details.dart';
import 'package:masar/components/motion.dart';
import 'package:masar/theme/AppColors.dart';

class SubjectCard extends StatefulWidget {
  final String subjectName;
  final String subjectDescription;
  final int subjectId;
  final String? teacherName;

  final void Function(BuildContext)? deleteFunction;
  final void Function(BuildContext)? editFunction;

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
  late final AnimationController _entrance;

  @override
  void initState() {
    super.initState();

    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );

    Future.delayed(
      Duration(milliseconds: math.min(widget.index, 10) * 75),
          () {
        if (mounted) _entrance.forward();
      },
    );
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  void _openDetails() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SubjectDetails(
          subjectName: widget.subjectName,
          subjectDescription: widget.subjectDescription,
          subjectId: widget.subjectId,
          teacherName: widget.teacherName,
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            AppColors.accent,
            AppColors.accentDark,
          ],
        ),
        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Icon(
        Icons.menu_book_rounded,
        color: AppColors.onAccent,
        size: 28,
      ),
    );
  }

  Widget _buildTeacher() {
    final teacher = widget.teacherName?.trim() ?? '';
    final hasTeacher = teacher.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.overlay,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.person_outline_rounded,
            size: 17,
            color: hasTeacher
                ? AppColors.accent
                : AppColors.textMuted,
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              hasTeacher ? teacher : 'بدون مدرس',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: hasTeacher
                    ? AppColors.textSecondary
                    : AppColors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.07),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            PositionedDirectional(
              end: -35,
              top: -45,
              child: Container(
                width: 125,
                height: 125,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accent.withValues(alpha: 0.045),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _buildIcon(),
                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Hero(
                          tag: 'subject-name-${widget.subjectName}',
                          child: Material(
                            color: Colors.transparent,
                            child: Text(
                              widget.subjectName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 6),

                        Hero(
                          tag: 'subject-desc-${widget.subjectName}',
                          child: Material(
                            color: Colors.transparent,
                            child: Text(
                              widget.subjectDescription,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 11),

                        _buildTeacher(),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
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
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: _entrance,
      curve: Curves.easeOutCubic,
    );

    return AnimatedBuilder(
      animation: curved,
      builder: (context, child) {
        final value = curved.value;

        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 24 * (1 - value)),
            child: Transform.scale(
              scale: 0.96 + (0.04 * value),
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
          key: ValueKey('subject-${widget.subjectId}'),

          endActionPane: ActionPane(
            motion: const BehindMotion(),
            extentRatio: 0.42,
            children: [
              SlidableAction(
                onPressed: widget.editFunction,
                icon: Icons.edit_rounded,
                label: 'تعديل',
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.onAccent,
                borderRadius: BorderRadius.circular(16),
              ),
              SlidableAction(
                onPressed: widget.deleteFunction,
                icon: Icons.delete_outline_rounded,
                label: 'حذف',
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ],
          ),

          child: Pressable(
            onTap: _openDetails,
            haptic: true,
            pressedScale: 0.975,
            child: _buildCard(),
          ),
        ),
      ),
    );
  }
}
