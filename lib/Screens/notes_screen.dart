import 'package:flutter/material.dart';
import 'package:masar/components/empty_state.dart';
import 'package:masar/components/motion.dart';
import 'package:masar/components/note_card.dart';
import 'package:masar/components/note_sheets.dart';
import 'package:masar/components/study_kit.dart';
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

    final notes = context
        .watch<NotesProvider>()
        .notes
        .where((n) => n.lessonId == lessonId)
        .toList();

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
                  completed: completed,
                ),
                SectionTitle(title: 'الملاحظات', count: notes.length, index: 2),
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
                    NoteCard(
                      key: ObjectKey(notes[i]),
                      index: i,
                      noteName: notes[i].noteName,
                      noteDescription: notes[i].noteDescription,
                      noteContent: notes[i].noteContent,
                      noteColor: notes[i].noteColor,
                      onTap: () => NoteSheets.details(
                        context,
                        notes[i],
                        onEdit: () => NoteSheets.show(
                          context,
                          lessonId: lessonId,
                          note: notes[i],
                        ),
                      ),
                      onDelete: (_) =>
                          NoteSheets.confirmDelete(context, notes[i]),
                      onEdit: (_) => NoteSheets.show(
                        context,
                        lessonId: lessonId,
                        note: notes[i],
                      ),
                    ),
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