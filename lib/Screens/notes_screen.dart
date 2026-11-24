
import 'package:flutter/material.dart';
import 'package:masar/components/empty_state.dart';
import 'package:masar/components/motion.dart';
import 'package:masar/components/note_card.dart';
import 'package:masar/components/note_sheets.dart';
import 'package:masar/components/study_kit.dart';
import 'package:masar/models/notes_model.dart';
import 'package:masar/providers/lessons_provider.dart';
import 'package:masar/providers/notes_provider.dart';
import 'package:masar/theme/AppColors.dart';
import 'package:provider/provider.dart';

class NotesScreen extends StatelessWidget {
  final String lessonName;
  final String lessonDescription;
  final int lessonId;

  const NotesScreen({
    super.key,
    required this.lessonName,
    required this.lessonDescription,
    required this.lessonId,
  });

  // ---------------------------------------------------------------
  // Top Bar
  // ---------------------------------------------------------------

  Widget _topBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: FadeSlideIn(
        child: Row(
          children: [
            RoundIconButton(
              icon: Icons.arrow_back_rounded,
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(width: 13),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'دفتر الدرس',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'ملاحظاتك وملخصاتك في مكان واحد',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.divider),
              ),
              child: const Icon(
                Icons.auto_stories_rounded,
                color: AppColors.accent,
                size: 21,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // Hero Card
  // ---------------------------------------------------------------

  Widget _heroCard({
    required String name,
    required String description,
    required int notesCount,
    required bool hasSummary,
    required bool completed,
  }) {
    return FadeSlideIn(
      index: 1,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 17, 20, 8),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                AppColors.accentDark,
                AppColors.accent,
                Color(0xFF187F83),
              ],
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.23),
                blurRadius: 25,
                offset: const Offset(0, 11),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              children: [
                PositionedDirectional(
                  top: -55,
                  end: -35,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.07),
                        width: 28,
                      ),
                    ),
                  ),
                ),
                PositionedDirectional(
                  bottom: -65,
                  start: -40,
                  child: Container(
                    width: 155,
                    height: 155,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.045),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(21),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top label
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 11,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.13),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.12),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.menu_book_rounded,
                                  color: AppColors.secondaryLight,
                                  size: 14,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'مساحة المذاكرة',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            completed
                                ? Icons.verified_rounded
                                : Icons.bookmark_outline_rounded,
                            color: Colors.white.withValues(alpha: 0.85),
                            size: 22,
                          ),
                        ],
                      ),

                      const SizedBox(height: 23),

                      // Lesson title
                      Text(
                        name,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                          height: 1.4,
                        ),
                      ),

                      if (description.isNotEmpty) ...[
                        const SizedBox(height: 9),
                        Text(
                          description,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.78),
                            fontSize: 12.5,
                            height: 1.75,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],

                      const SizedBox(height: 22),

                      // Lesson status
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.11),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'حالة الدرس',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  completed ? 'مكتمل' : 'قيد المذاكرة',
                                  style: TextStyle(
                                    color: completed
                                        ? AppColors.secondaryLight
                                        : Colors.white.withValues(alpha: 0.85),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Icon(
                                  completed
                                      ? Icons.check_circle_rounded
                                      : Icons.timelapse_rounded,
                                  color: completed
                                      ? AppColors.secondaryLight
                                      : Colors.white,
                                  size: 16,
                                ),
                              ],
                            ),
                            const SizedBox(height: 11),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: completed ? 1 : 0,
                                minHeight: 6,
                                backgroundColor:
                                Colors.white.withValues(alpha: 0.18),
                                valueColor:
                                const AlwaysStoppedAnimation<Color>(
                                  AppColors.secondaryLight,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 15),

                      // Statistics
                      Row(
                        children: [
                          Expanded(
                            child: _heroStat(
                              icon: Icons.sticky_note_2_rounded,
                              value: '$notesCount',
                              label: 'ملاحظة',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _heroStat(
                              icon: Icons.auto_stories_rounded,
                              value: hasSummary ? 'متوفر' : 'غير موجود',
                              label: 'ملخص الدرس',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _heroStat({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.secondaryLight,
            size: 19,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.68),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // Section Header
  // ---------------------------------------------------------------

  Widget _sectionHeader({
    required String title,
    required String subtitle,
    required int count,
    required int index,
    VoidCallback? onAdd,
    bool isSummary = false,
  }) {
    return FadeSlideIn(
      index: index,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 13),
        child: Row(
          children: [
            Container(
              width: 43,
              height: 43,
              decoration: BoxDecoration(
                color: isSummary
                    ? AppColors.warmLight.withValues(alpha: 0.7)
                    : AppColors.secondary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                isSummary
                    ? Icons.auto_stories_rounded
                    : Icons.sticky_note_2_rounded,
                color: isSummary ? AppColors.warmDark : AppColors.accent,
                size: 21,
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceAlt,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$count',
                          style: const TextStyle(
                            color: AppColors.accent,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (onAdd != null)
              Material(
                color: AppColors.accent.withValues(alpha: 0.09),
                borderRadius: BorderRadius.circular(13),
                child: InkWell(
                  borderRadius: BorderRadius.circular(13),
                  onTap: onAdd,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add_rounded,
                          size: 17,
                          color: AppColors.accent,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'إضافة',
                          style: TextStyle(
                            color: AppColors.accent,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // Summary Empty State
  // ---------------------------------------------------------------

  Widget _summaryCta(BuildContext context) {
    return FadeSlideIn(
      index: 3,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 2, 20, 4),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(23),
            onTap: () => NoteSheets.show(
              context,
              lessonId: lessonId,
              isSummary: true,
            ),
            child: Ink(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(23),
                border: Border.all(
                  color: AppColors.secondary.withValues(alpha: 0.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.055),
                    blurRadius: 17,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Stack(
                  children: [
                    PositionedDirectional(
                      end: -24,
                      top: -30,
                      child: Icon(
                        Icons.auto_stories_rounded,
                        size: 120,
                        color: AppColors.secondary.withValues(alpha: 0.13),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(17),
                      child: Row(
                        children: [
                          Container(
                            width: 55,
                            height: 55,
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
                                  color: AppColors.accent.withValues(
                                    alpha: 0.2,
                                  ),
                                  blurRadius: 12,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.edit_note_rounded,
                              color: Colors.white,
                              size: 29,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'أنشئ ملخص الدرس',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'اجمع أهم الأفكار في ملخص يسهل عليك مراجعته',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 11,
                                    height: 1.6,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withValues(
                                alpha: 0.2,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back_rounded,
                              color: AppColors.accent,
                              size: 17,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // Notes Empty State
  // ---------------------------------------------------------------

  Widget _notesEmptyState() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 18),
      child: EmptyState(
        icon: Icons.sticky_note_2_rounded,
        title: 'لسه مفيش ملاحظات',
        subtitle: 'ابدأ بإضافة أول ملاحظة ليك واجمع أفكارك المهمة هنا',
      ),
    );
  }

  // ---------------------------------------------------------------
  // Note Card
  // ---------------------------------------------------------------

  Widget _noteCard(
      BuildContext context,
      NotesModel note,
      int index,
      ) {
    return NoteCard(
      key: ObjectKey(note),
      index: index,
      noteName: note.noteName,
      noteDescription: note.noteDescription,
      noteContent: note.noteContent,
      noteColor: note.noteColor,
      isSummary: note.isSummary,
      onTap: () => NoteSheets.details(
        context,
        note,
        onEdit: () => NoteSheets.show(
          context,
          lessonId: lessonId,
          note: note,
        ),
      ),
      onDelete: (_) => NoteSheets.confirmDelete(context, note),
      onEdit: (_) => NoteSheets.show(
        context,
        lessonId: lessonId,
        note: note,
      ),
    );
  }

  // ---------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final lesson = context
        .watch<LessonsProvider>()
        .lessons
        .where((l) => l.id == lessonId)
        .firstOrNull;

    final name = lesson?.lessonName ?? lessonName;
    final description =
    (lesson?.lessonDescription ?? lessonDescription).trim();
    final completed = lesson?.lessonCompleted ?? false;

    final all = context
        .watch<NotesProvider>()
        .notes
        .where((n) => n.lessonId == lessonId)
        .toList();

    final summaries = all.where((n) => n.isSummary).toList();
    final notes = all.where((n) => !n.isSummary).toList();

    return Scaffold(
      body: PageBackground(
        child: SafeArea(
          bottom: false,
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: ListView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: const EdgeInsets.only(bottom: 125),
              children: [
                _topBar(context),

                _heroCard(
                  name: name,
                  description: description,
                  notesCount: notes.length,
                  hasSummary: summaries.isNotEmpty,
                  completed: completed,
                ),

                // Summary section
                _sectionHeader(
                  title: 'ملخص الدرس',
                  subtitle: 'أهم النقاط للمراجعة السريعة',
                  count: summaries.length,
                  index: 2,
                  isSummary: true,
                  onAdd: () => NoteSheets.show(
                    context,
                    lessonId: lessonId,
                    isSummary: true,
                  ),
                ),

                if (summaries.isEmpty)
                  _summaryCta(context)
                else
                  for (var i = 0; i < summaries.length; i++)
                    _noteCard(context, summaries[i], i),

                // Notes section
                _sectionHeader(
                  title: 'الملاحظات',
                  subtitle: 'أفكارك وتفاصيلك المهمة في الدرس',
                  count: notes.length,
                  index: 4,
                  onAdd: () => NoteSheets.show(
                    context,
                    lessonId: lessonId,
                  ),
                ),

                if (notes.isEmpty)
                  _notesEmptyState()
                else
                  for (var i = 0; i < notes.length; i++)
                    _noteCard(context, notes[i], i),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: AddFab(
        onTap: () => NoteSheets.show(
          context,
          lessonId: lessonId,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
