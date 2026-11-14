import 'package:flutter/material.dart';
import 'package:masar/Screens/notes_screen.dart';
import 'package:masar/components/dialogs.dart';
import 'package:masar/components/empty_state.dart';
import 'package:masar/components/lesson_sheets.dart';
import 'package:masar/components/lesson_tile.dart';
import 'package:masar/components/motion.dart';
import 'package:masar/components/study_kit.dart';
import 'package:masar/components/subject_sheets.dart';
import 'package:masar/models/subjects_model.dart';
import 'package:masar/providers/lessons_provider.dart';
import 'package:masar/providers/subjects_provider.dart';
import 'package:masar/theme/AppColors.dart';
import 'package:provider/provider.dart';

class SubjectDetails extends StatelessWidget {
  final String subjectName;
  final String subjectDescription;
  final int subjectId;
  final String? teacherName;

  const SubjectDetails({
    super.key,
    required this.subjectName,
    required this.subjectDescription,
    required this.subjectId,
    this.teacherName,
  });

  // ---------------------------------------------------------------
  // Pieces
  // ---------------------------------------------------------------

  Widget _topBar(BuildContext context, SubjectsModel? subject) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: FadeSlideIn(
        child: Row(
          children: [
            RoundIconButton(
              icon: Icons.arrow_back_rounded,
              onTap: () => Navigator.pop(context),
            ),
            const Spacer(),
            if (subject != null) ...[
              RoundIconButton(
                icon: Icons.edit_rounded,
                color: AppColors.accent,
                onTap: () => SubjectSheets.show(context, subject: subject),
              ),
              const SizedBox(width: 10),
              RoundIconButton(
                icon: Icons.delete_outline_rounded,
                color: AppColors.danger,
                onTap: () => SubjectSheets.confirmDelete(
                  context,
                  subject,
                  onDeleted: () => Navigator.pop(context),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _heroCard({
    required String name,
    required String description,
    required String teacher,
  }) {
    return FadeSlideIn(
      index: 1,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [AppColors.accent, AppColors.accentDark],
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.32),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              children: [
                PositionedDirectional(
                  end: -30,
                  top: -40,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                ),
                PositionedDirectional(
                  start: -25,
                  bottom: -55,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Hero(
                            tag: 'subject-icon-$subjectId',
                            child: Container(
                              width: 62,
                              height: 62,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.menu_book_rounded,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              name,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                height: 1.25,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (description.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          description,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.88),
                            fontSize: 15,
                            height: 1.6,
                          ),
                        ),
                      ],
                      if (teacher.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.person_outline_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 7),
                              Flexible(
                                child: Text(
                                  teacher,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

  Widget _progressCard({required int total, required int done}) {
    final remaining = total - done;
    final progress = total == 0 ? 0.0 : done / total;
    final allDone = total > 0 && remaining == 0;

    final title = total == 0
        ? 'المادة لسه فاضية'
        : allDone
        ? 'عاش! خلصت كل الدروس'
        : 'خلصت $done من $total';
    final subtitle = total == 0
        ? 'ابدأ بإضافة أول درس ليك'
        : allDone
        ? 'كمّل بنفس الحماس'
        : 'فاضل $remaining ${remaining <= 10 ? 'دروس' : 'درس'}';

    return FadeSlideIn(
      index: 2,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.08),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              ProgressRing(
                progress: progress,
                size: 92,
                stroke: 9,
                color: allDone ? AppColors.success : AppColors.accent,
                track: AppColors.accent.withValues(alpha: 0.12),
                labelColor: AppColors.textPrimary,
                fontSize: 18,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        title,
                        key: ValueKey(title),
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    if (total > 0) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          InfoPill(
                            icon: Icons.check_circle_rounded,
                            text: 'خلصت $done',
                            color: AppColors.success,
                          ),
                          InfoPill(
                            icon: Icons.pending_rounded,
                            text: 'باقي $remaining',
                            color: AppColors.warm,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
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
    final subject = context
        .watch<SubjectsProvider>()
        .subjects
        .where((s) => s.id == subjectId)
        .firstOrNull;

    final name = subject?.subjectName ?? subjectName;
    final description = (subject?.subjectDescription ?? subjectDescription).trim();
    final teacher = (subject?.teacherName ?? teacherName ?? '').trim();

    final lessonsProvider = context.watch<LessonsProvider>();
    final lessons = lessonsProvider.lessons
        .where((l) => l.subjectId == subjectId)
        .toList();
    final done = lessons.where((l) => l.lessonCompleted).length;

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
              padding: const EdgeInsets.only(bottom: 130),
              children: [
                _topBar(context, subject),
                _heroCard(
                  name: name,
                  description: description,
                  teacher: teacher,
                ),
                _progressCard(total: lessons.length, done: done),
                SectionTitle(title: 'الدروس', count: lessons.length),
                if (lessons.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 14),
                    child: EmptyState(
                      icon: Icons.menu_book_outlined,
                      title: 'مفيش دروس',
                      subtitle: 'ابدأ بإضافة أول درس ليك في المادة دي',
                    ),
                  )
                else
                  for (var i = 0; i < lessons.length; i++)
                    LessonTile(
                      key: ObjectKey(lessons[i]),
                      index: i,
                      lessonId: lessons[i].id,
                      lessonName: lessons[i].lessonName,
                      lessonDescription: lessons[i].lessonDescription,
                      lessonCompleted: lessons[i].lessonCompleted,
                      onChanged: (_) {
                        final lesson = lessons[i];
                        lessonsProvider.toggleLesson(lesson: lesson);
                        if (lesson.lessonCompleted &&
                            lessons.every((l) => l.lessonCompleted)) {
                          Dialogs.success(
                            context: context,
                            title: 'عاش',
                            message:
                            'خلصت كل دروس "$name".\nاستمر كده، إنت أقرب لهدفك',
                          );
                        }
                      },
                      onTap: () {
                        final lesson = lessons[i];
                        Navigator.push<void>(
                          context,
                          fadeScaleRoute<void>(
                            NotesScreen(
                              lessonName: lesson.lessonName,
                              lessonDescription: lesson.lessonDescription,
                              lessonId: lesson.id,
                            ),
                          ),
                        );
                      },
                      onDelete: (_) =>
                          LessonSheets.confirmDelete(context, lessons[i]),
                      onEdit: (_) => LessonSheets.show(
                        context,
                        subjectId: subjectId,
                        lesson: lessons[i],
                      ),
                    ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: AddFab(
        onTap: () => LessonSheets.show(context, subjectId: subjectId),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}