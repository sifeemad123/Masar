import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:masar/components/motion.dart';
import 'package:masar/providers/user_data_provider.dart';
import 'package:masar/theme/AppColors.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

/// Readable text colors on top of any note color.
Color noteTextColor(Color color) {
  return color.computeLuminance() > 0.55
      ? const Color(0xFF12343B)
      : const Color(0xFFF8FAF9);
}

Color noteSecondaryColor(Color color) {
  return color.computeLuminance() > 0.55
      ? const Color(0xFF49676B)
      : const Color(0xFFD5DFDD);
}

/// Opens the system share sheet with the note text.
Future<void> shareNote(
    BuildContext context, {
      required String name,
      required String description,
      required String content,
      bool isSummary = false,
    }) async {
  final userName =
      Provider.of<UserDataProvider>(context, listen: false).userName;

  final text = isSummary
      ? '📚 ملخص: «$name»\n\n$content\n\nمن $userName\n\nمن تطبيق مسار'
      : '«$name»\n\n$description\n\n$content\n\nمن $userName\n\nمن تطبيق مسار';

  await SharePlus.instance.share(
    ShareParams(
      text: text,
      subject: 'تطبيق مسار',
    ),
  );
}

class NoteCard extends StatefulWidget {
  final String noteName;
  final String noteDescription;
  final String noteContent;
  final Color noteColor;
  final bool isSummary;
  final VoidCallback onTap;
  final void Function(BuildContext) onDelete;
  final void Function(BuildContext) onEdit;
  final int index;

  const NoteCard({
    super.key,
    required this.noteName,
    required this.noteDescription,
    required this.noteContent,
    required this.noteColor,
    required this.onTap,
    required this.onDelete,
    required this.onEdit,
    this.isSummary = false,
    this.index = 0,
  });

  @override
  State<NoteCard> createState() => _NoteCardState();
}

class _NoteCardState extends State<NoteCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enter;

  @override
  void initState() {
    super.initState();

    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    Future.delayed(
      Duration(milliseconds: math.min(widget.index, 8) * 65),
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

  void _share(BuildContext context) {
    shareNote(
      context,
      name: widget.noteName,
      description: widget.noteDescription,
      content: widget.noteContent,
      isSummary: widget.isSummary,
    );
  }

  // ---------------------------------------------------------------
  // Summary card (مختلف عن النوت العادية)
  // ---------------------------------------------------------------

  Widget _summaryBody() {
    final content = widget.noteContent.trim();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.35),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.14),
            blurRadius: 22,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [AppColors.accent, AppColors.accentDark],
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.auto_stories_rounded,
                    color: AppColors.onAccent,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'ملخص الدرس',
                    style: TextStyle(
                      color: AppColors.onAccent,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Spacer(),
                  Material(
                    color: Colors.white.withValues(alpha: 0.16),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => _share(context),
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(
                          Icons.ios_share_rounded,
                          size: 17,
                          color: AppColors.onAccent,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(17, 16, 17, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.noteName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: 44,
                    height: 3,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    content.isEmpty ? 'لا يوجد محتوى' : content,
                    maxLines: 6,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: content.isEmpty
                          ? AppColors.textMuted
                          : AppColors.textSecondary,
                      fontSize: 14,
                      height: 1.75,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: const [
                      Icon(
                        Icons.menu_book_rounded,
                        size: 16,
                        color: AppColors.accent,
                      ),
                      SizedBox(width: 7),
                      Text(
                        'اقرأ الملخص كامل',
                        style: TextStyle(
                          color: AppColors.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Spacer(),
                      Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 13,
                        color: AppColors.textMuted,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // Normal note card
  // ---------------------------------------------------------------

  Widget _noteBody() {
    final color = widget.noteColor;
    final isLight = color.computeLuminance() > 0.55;
    final description = widget.noteDescription.trim();
    final content = widget.noteContent.trim();

    final foreground = noteTextColor(color);
    final secondary = noteSecondaryColor(color);

    final surface = Color.lerp(AppColors.surface, color, 0.19)!;
    final accent = Color.lerp(color, AppColors.accent, 0.12)!;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: color.withValues(alpha: 0.28),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.16),
            blurRadius: 22,
            offset: const Offset(0, 9),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            PositionedDirectional(
              top: -38,
              end: -25,
              child: Container(
                width: 125,
                height: 125,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.12),
                ),
              ),
            ),
            PositionedDirectional(
              top: 35,
              end: 45,
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.09),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(17, 16, 17, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.20),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: color.withValues(alpha: 0.18),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.sticky_note_2_rounded,
                              size: 14,
                              color: foreground,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'ملاحظة',
                              style: TextStyle(
                                color: foreground,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Material(
                        color: color.withValues(alpha: 0.13),
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => _share(context),
                          child: Padding(
                            padding: const EdgeInsets.all(9),
                            child: Icon(
                              Icons.ios_share_rounded,
                              size: 18,
                              color: foreground,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.noteName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: foreground,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      height: 1.35,
                    ),
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 7),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: secondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.55,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: isLight
                          ? Colors.white.withValues(alpha: 0.55)
                          : Colors.black.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(17),
                      border: Border.all(
                        color: foreground.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 4,
                              height: 15,
                              decoration: BoxDecoration(
                                color: accent,
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            const SizedBox(width: 7),
                            Text(
                              'معاينة المحتوى',
                              style: TextStyle(
                                color: secondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 9),
                        Text(
                          content.isEmpty ? 'لا يوجد محتوى للمعاينة' : content,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: content.isEmpty ? secondary : foreground,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            height: 1.7,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.20),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.menu_book_rounded,
                          size: 16,
                          color: foreground,
                        ),
                      ),
                      const SizedBox(width: 9),
                      Text(
                        'افتح الملاحظة',
                        style: TextStyle(
                          color: foreground,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 13,
                        color: secondary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final animation = CurvedAnimation(
      parent: _enter,
      curve: Curves.easeOutCubic,
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final value = animation.value;

        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, 28 * (1 - value)),
            child: Transform.scale(
              scale: 0.95 + (0.05 * value),
              child: child,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 8,
        ),
        child: Slidable(
          key: ValueKey(
            'note-${widget.isSummary ? 's' : 'n'}-${widget.index}-${widget.noteName}',
          ),
          endActionPane: ActionPane(
            motion: const BehindMotion(),
            extentRatio: 0.43,
            children: [
              SlidableAction(
                onPressed: widget.onEdit,
                icon: Icons.edit_rounded,
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.onAccent,
                borderRadius: BorderRadius.circular(18),
              ),
              SlidableAction(
                onPressed: widget.onDelete,
                icon: Icons.delete_outline_rounded,
                backgroundColor: AppColors.danger,
                foregroundColor: AppColors.onDanger,
                borderRadius: BorderRadius.circular(18),
              ),
            ],
          ),
          child: Pressable(
            pressedScale: 0.975,
            haptic: true,
            onTap: widget.onTap,
            child: widget.isSummary ? _summaryBody() : _noteBody(),
          ),
        ),
      ),
    );
  }
}