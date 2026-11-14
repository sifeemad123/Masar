import 'package:flutter/material.dart';
import 'package:masar/components/empty_state.dart';
import 'package:masar/components/motion.dart';
import 'package:masar/components/sheet_kit.dart';
import 'package:masar/components/study_kit.dart';
import 'package:masar/components/subject_card.dart';
import 'package:masar/components/subject_sheets.dart';
import 'package:masar/models/subjects_model.dart';
import 'package:masar/providers/lessons_provider.dart';
import 'package:masar/providers/subjects_provider.dart';
import 'package:masar/theme/AppColors.dart';
import 'package:provider/provider.dart';

class SubjectsScreen extends StatefulWidget {
  const SubjectsScreen({super.key});

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<SubjectsModel> _filter(List<SubjectsModel> subjects) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return subjects;
    return subjects.where((s) {
      return s.subjectName.toLowerCase().contains(q) ||
          s.subjectDescription.toLowerCase().contains(q) ||
          (s.teacherName ?? '').toLowerCase().contains(q);
    }).toList();
  }

  // ---------------------------------------------------------------
  // Header
  // ---------------------------------------------------------------

  Widget _header(int total) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
      child: FadeSlideIn(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'موادي',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    total == 0
                        ? 'ابدأ بإضافة أول مادة'
                        : 'كل موادك الدراسية في مكان واحد',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [AppColors.accent, AppColors.accentDark],
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_stories_rounded,
                color: AppColors.onAccent,
                size: 26,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // Summary card
  // ---------------------------------------------------------------

  Widget _summaryCard({
    required int subjects,
    required int lessons,
    required int done,
  }) {
    final hasLessons = lessons > 0;
    final progress = hasLessons ? done / lessons : 0.0;
    final allDone = hasLessons && done == lessons;

    final title = allDone
        ? 'عاش! خلصت كل دروسك'
        : subjects == 1
        ? 'عندك مادة واحدة'
        : subjects == 2
        ? 'عندك مادتين'
        : 'عندك $subjects ${subjects <= 10 ? 'مواد' : 'مادة'}';
    final subtitle = hasLessons
        ? 'خلصت $done من $lessons ${lessons <= 10 ? 'دروس' : 'درس'}'
        : 'ضيف دروس جوه موادك وابدأ تتابع';

    return FadeSlideIn(
      index: 1,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 6),
        child: Container(
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
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                ),
                PositionedDirectional(
                  start: -20,
                  bottom: -50,
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(22),
                  child: Row(
                    children: [
                      if (hasLessons)
                        ProgressRing(
                          progress: progress,
                          size: 78,
                          stroke: 8,
                          color: Colors.white,
                          track: Colors.white.withValues(alpha: 0.22),
                          labelColor: Colors.white,
                        )
                      else
                        Container(
                          width: 78,
                          height: 78,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.18),
                          ),
                          child: const Icon(
                            Icons.library_books_rounded,
                            color: AppColors.onAccent,
                            size: 36,
                          ),
                        ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 21,
                                fontWeight: FontWeight.w900,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              subtitle,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 15,
                              ),
                            ),
                          ],
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
    );
  }

  // ---------------------------------------------------------------
  // Search
  // ---------------------------------------------------------------

  Widget _search() {
    return FadeSlideIn(
      index: 2,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
        child: TextField(
          controller: _searchController,
          onChanged: (v) => setState(() => _query = v),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: 'ابحث عن مادة أو مدرس...',
            hintStyle: const TextStyle(color: AppColors.textMuted),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: AppColors.accent,
            ),
            suffixIcon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _query.isEmpty
                  ? const SizedBox.shrink(key: ValueKey('empty'))
                  : IconButton(
                key: const ValueKey('clear'),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _query = '');
                },
                icon: const Icon(
                  Icons.close_rounded,
                  color: AppColors.textMuted,
                ),
              ),
            ),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: AppColors.accent, width: 2),
            ),
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
    final subjects = context.watch<SubjectsProvider>().subjects;
    final allLessons = context.watch<LessonsProvider>().lessons;

    final ids = subjects.map((s) => s.id).toSet();
    final lessons = allLessons.where((l) => ids.contains(l.subjectId)).toList();
    final done = lessons.where((l) => l.lessonCompleted).length;

    final filtered = _filter(subjects);
    final searching = _query.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PageBackground(
        child: SafeArea(
          bottom: false,
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              keyboardDismissBehavior:
              ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                SliverToBoxAdapter(child: _header(subjects.length)),
                if (subjects.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _summaryCard(
                      subjects: subjects.length,
                      lessons: lessons.length,
                      done: done,
                    ),
                  ),
                SliverToBoxAdapter(child: _search()),
                if (filtered.isNotEmpty)
                  SliverToBoxAdapter(
                    child: SectionTitle(
                      title: searching ? 'نتايج البحث' : 'قائمة المواد',
                      count: filtered.length,
                    ),
                  ),
                if (filtered.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 24, bottom: 130),
                      child: Column(
                        children: [
                          EmptyState(
                            icon: searching
                                ? Icons.search_off_rounded
                                : Icons.menu_book_outlined,
                            title: searching
                                ? 'مش لاقيين المادة دي'
                                : 'لسه مفيش مواد',
                            subtitle: searching
                                ? 'جرّب تبحث باسم مختلف أو بكلمة تانية'
                                : 'ضيف موادك واجمع دروسك وملاحظاتك في مكان واحد',
                          ),
                          if (!searching)
                            Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 50),
                              child: GradientButton(
                                text: 'أضف أول مادة',
                                onTap: () => SubjectSheets.show(context),
                              ),
                            ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.only(top: 4, bottom: 130),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          final subject = filtered[index];
                          return SubjectCard(
                            key: ValueKey('subject-card-${subject.id}'),
                            index: index,
                            subjectName: subject.subjectName,
                            subjectDescription: subject.subjectDescription,
                            subjectId: subject.id,
                            teacherName: subject.teacherName,
                            deleteFunction: (_) =>
                                SubjectSheets.confirmDelete(context, subject),
                            editFunction: (_) =>
                                SubjectSheets.show(context, subject: subject),
                          );
                        },
                        childCount: filtered.length,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}