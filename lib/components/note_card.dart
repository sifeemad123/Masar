import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:masar/components/ocean_kit.dart';
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
  final userName = Provider.of<UserDataProvider>(
    context,
    listen: false,
  ).userName;

  final text = isSummary
      ? '''
📚 $name

$content

━━━━━━━━━━━━━━━━
✍️ إعداد ومشاركة: $userName
📱 عبر تطبيق مسار | Masar
'''
      : '''
📝 $name

$description

$content

━━━━━━━━━━━━━━━━
✍️ إعداد ومشاركة: $userName
📱 عبر تطبيق مسار | Masar
'''
            .trim();

  await SharePlus.instance.share(
    ShareParams(text: text, subject: 'تطبيق مسار'),
  );
}

Color _legible(Color c) => c.computeLuminance() > 0.78
    ? Color.lerp(c, AppColors.textPrimary, 0.3)!
    : c;

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
  /// موج هيدر الملخص.
  late final AnimationController _wave = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 7),
  );

  @override
  void initState() {
    super.initState();
    if (widget.isSummary) _wave.repeat();
  }

  @override
  void didUpdateWidget(covariant NoteCard old) {
    super.didUpdateWidget(old);
    if (widget.isSummary && !_wave.isAnimating) {
      _wave.repeat();
    } else if (!widget.isSummary && _wave.isAnimating) {
      _wave.stop();
    }
  }

  @override
  void dispose() {
    _wave.dispose();
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
  // Summary card
  // ---------------------------------------------------------------

  Widget _summaryBody(BuildContext context) {
    final content = widget.noteContent.trim();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.55),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.12),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    AppColors.accentDark,
                    AppColors.accent,
                    Color(0xFF268B8B),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: IgnorePointer(
                      child: AnimatedBuilder(
                        animation: _wave,
                        builder: (context, _) => CustomPaint(
                          painter: WavePainter(
                            level: 0.3,
                            phase: _wave.value * 2,
                            color: Colors.white.withValues(alpha: 0.12),
                            amplitude: 6,
                            layers: 3,
                          ),
                        ),
                      ),
                    ),
                  ),
                  PositionedDirectional(
                    end: -10,
                    top: -25,
                    child: Icon(
                      Icons.auto_stories_rounded,
                      size: 125,
                      color: Colors.white.withValues(alpha: 0.075),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.15),
                                ),
                              ),
                              child: const Icon(
                                Icons.auto_stories_rounded,
                                size: 23,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 11),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'STUDY NOTES',
                                  style: TextStyle(
                                    color: AppColors.secondaryLight,
                                    fontSize: 9,
                                    letterSpacing: 2,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'ملخص الدرس',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            OceanTap(
                              pressedScale: 0.88,
                              onTap: () => _share(context),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.15),
                                ),
                                child: const Icon(
                                  Icons.ios_share_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          widget.noteName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'مراجعة مركزة لأهم أفكار الدرس',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.75),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Body
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 17),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'محتوى الملخص',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.menu_book_rounded,
                              size: 13,
                              color: AppColors.accent,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'للمراجعة',
                              style: TextStyle(
                                color: AppColors.accentDark,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 13),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: AppColors.pearl,
                      borderRadius: BorderRadius.circular(17),
                      border: Border.all(
                        color: AppColors.divider.withValues(alpha: 0.8),
                      ),
                    ),
                    child: Text(
                      content.isEmpty ? 'لا يوجد محتوى للملخص' : content,
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: content.isEmpty
                            ? AppColors.textMuted
                            : AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        height: 1.85,
                      ),
                    ),
                  ),
                  const SizedBox(height: 17),
                  const Row(
                    children: [
                      Icon(
                        Icons.auto_awesome_rounded,
                        color: AppColors.warm,
                        size: 17,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'راجع أفكارك وثبّت معلوماتك',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 13,
                        color: AppColors.accent,
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

  Widget _noteBody(BuildContext context) {
    final color = _legible(widget.noteColor);
    final description = widget.noteDescription.trim();
    final content = widget.noteContent.trim();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.09),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(23),
        child: Stack(
          children: [
            // Rail
            PositionedDirectional(
              top: 0,
              bottom: 0,
              start: 0,
              child: Container(
                width: 5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [color, color.withValues(alpha: 0.45)],
                  ),
                ),
              ),
            ),

            // Decorative background
            PositionedDirectional(
              top: -40,
              end: -35,
              child: Container(
                width: 145,
                height: 145,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.075),
                ),
              ),
            ),
            PositionedDirectional(
              top: 20,
              end: 30,
              child: Icon(
                Icons.sticky_note_2_rounded,
                size: 95,
                color: color.withValues(alpha: 0.09),
              ),
            ),

            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(20, 17, 18, 16),
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
                          color: color.withValues(alpha: 0.13),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.sticky_note_2_rounded,
                              size: 14,
                              color: color,
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'ملاحظة',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      OceanTap(
                        pressedScale: 0.88,
                        onTap: () => _share(context),
                        child: Container(
                          padding: const EdgeInsets.all(9),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.surfaceAlt,
                          ),
                          child: const Icon(
                            Icons.ios_share_rounded,
                            size: 17,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 17),
                  Text(
                    widget.noteName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      height: 1.4,
                    ),
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 7),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        height: 1.6,
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.pearl,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.divider.withValues(alpha: 0.8),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 4,
                              height: 16,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'معاينة المحتوى',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          content.isEmpty ? 'لا يوجد محتوى للمعاينة' : content,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: content.isEmpty
                                ? AppColors.textMuted
                                : AppColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            height: 1.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.menu_book_rounded, size: 18, color: color),
                      const SizedBox(width: 8),
                      const Text(
                        'افتح الملاحظة',
                        style: TextStyle(
                          color: AppColors.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
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
  // Build
  // ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Reveal(
      index: widget.index,
      dy: 34,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
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
          child: OceanTap(
            pressedScale: 0.975,
            onTap: widget.onTap,
            child: widget.isSummary
                ? _summaryBody(context)
                : _noteBody(context),
          ),
        ),
      ),
    );
  }
}
