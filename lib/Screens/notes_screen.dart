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

  Widget _topBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: FadeSlideIn(
        child: Row(
          children: [
            RoundIconButton(
              icon: Icons.arrow_back_rounded,
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

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
                          Container(
                            width: 62,
                            height: 62,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.sticky_note_2_rounded,
                              color: Colors.white,
                              size: 32,
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
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _heroChip(
                            Icons.sticky_note_2_outlined,
                            notesCountText(notesCount),
                          ),
                          _heroChip(
                            hasSummary
                                ? Icons.auto_stories_rounded
                                : Icons.auto_stories_outlined,
                            hasSummary ? 'فيه ملخص' : 'مفيش ملخص',
                          ),
                          _heroChip(
                            completed
                                ? Icons.check_circle_rounded
                                : Icons.pending_rounded,
                            completed ? 'الدرس خلصان' : 'الدرس لسه',
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

  Widget _heroChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 7),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  /// عنوان قسم الملخص + زرار إضافة ملخص
  Widget _summaryHeader(BuildContext context, int count) {
    return Row(
      children: [
        Expanded(
          child: SectionTitle(title: 'ملخص الدرس', count: count, index: 2),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 8),
          child: Pressable(
            haptic: true,
            onTap: () => NoteSheets.show(
              context,
              lessonId: lessonId,
              isSummary: true,
            ),
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.25),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_rounded, size: 18, color: AppColors.accent),
                  SizedBox(width: 4),
                  Text(
                    'ملخص',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// كارت يشجعك تكتب ملخص لو مفيش
  Widget _summaryCta(BuildContext context) {
    return FadeSlideIn(
      index: 3,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
        child: Pressable(
          haptic: true,
          onTap: () => NoteSheets.show(
            context,
            lessonId: lessonId,
            isSummary: true,
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.accent.withValues(alpha: 0.35),
                width: 1.4,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [AppColors.accent, AppColors.accentDark],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.auto_stories_rounded,
                    color: AppColors.onAccent,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'لسه مكتبتش ملخص للدرس ده',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'لخّص أهم النقاط بأسلوبك عشان تراجعها بسرعة',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12.5,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.add_circle_rounded,
                  color: AppColors.accent,
                  size: 28,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
              padding: const EdgeInsets.only(bottom: 130),
              children: [
                _topBar(context),
                _heroCard(
                  name: name,
                  description: description,
                  notesCount: notes.length,
                  hasSummary: summaries.isNotEmpty,
                  completed: completed,
                ),

                // ===== ملخص الدرس =====
                _summaryHeader(context, summaries.length),
                if (summaries.isEmpty)
                  _summaryCta(context)
                else
                  for (var i = 0; i < summaries.length; i++)
                    _noteCard(context, summaries[i], i),

                // ===== الملاحظات =====
                SectionTitle(title: 'الملاحظات', count: notes.length, index: 4),
                if (notes.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 14),
                    child: EmptyState(
                      icon: Icons.sticky_note_2_rounded,
                      title: 'مفيش ملاحظات',
                      subtitle: 'ابدأ بإضافة أول ملاحظة ليك في الدرس ده',
                    ),
                  )
                else
                  for (var i = 0; i < notes.length; i++)
                    _noteCard(context, notes[i], i),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: AddFab(
        onTap: () => NoteSheets.show(context, lessonId: lessonId),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}