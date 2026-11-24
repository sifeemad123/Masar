import 'package:flutter/material.dart';
import 'package:masar/components/ocean_kit.dart';
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

class _SubjectsScreenState extends State<SubjectsScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  String _query = '';

  /// حركة الموج (دورة كل 9 ثواني).
  late final AnimationController _ambient = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 9),
  )..repeat();

  /// نبض خفيف.
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat(reverse: true);

  @override
  void initState() {
    super.initState();
    _searchFocus.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    _ambient.dispose();
    _pulse.dispose();
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
      child: Reveal(
        dy: 20,
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
            AnimatedBuilder(
              animation: _pulse,
              builder: (context, child) {
                final p = Curves.easeInOut.transform(_pulse.value);
                return SizedBox(
                  width: 66,
                  height: 66,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 52 + 12 * p,
                        height: 52 + 12 * p,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18 + 6 * p),
                          color: AppColors.accent
                              .withValues(alpha: 0.14 * (1 - p)),
                        ),
                      ),
                      Transform.translate(
                        offset: Offset(0, (p - 0.5) * 4),
                        child: Transform.rotate(
                          angle: (p - 0.5) * 0.12,
                          child: child,
                        ),
                      ),
                    ],
                  ),
                );
              },
              child: Container(
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
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // Summary card — مية بموج مستواها بيمثّل نسبة إنجاز كل دروسك
  // ---------------------------------------------------------------

  Widget _chip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard({
    required int subjects,
    required int lessons,
    required int done,
  }) {
    final hasLessons = lessons > 0;
    final progress = hasLessons ? done / lessons : 0.0;
    final allDone = hasLessons && done == lessons;
    final glow = allDone ? AppColors.success : AppColors.accent;

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

    return Reveal(
      index: 1,
      dy: 24,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 6),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: glow.withValues(alpha: 0.3),
                blurRadius: 28,
                offset: const Offset(0, 13),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Stack(
              children: [
                Positioned.fill(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: allDone
                            ? const [
                          Color(0xFF2F6F5E),
                          AppColors.success,
                          Color(0xFF5FA58C),
                        ]
                            : const [
                          AppColors.accentDark,
                          AppColors.accent,
                          Color(0xFF187F83),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: progress),
                      duration: const Duration(milliseconds: 1600),
                      curve: Curves.easeOutCubic,
                      builder: (context, v, _) => AnimatedBuilder(
                        animation: _ambient,
                        builder: (context, _) => CustomPaint(
                          painter: WavePainter(
                            level: 0.06 + 0.88 * v,
                            phase: _ambient.value * 3,
                            color: Colors.white.withValues(alpha: 0.14),
                            amplitude: 7,
                            layers: 3,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                PositionedDirectional(
                  end: -30,
                  top: -40,
                  child: IgnorePointer(
                    child: Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
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
                          if (hasLessons)
                            SizedBox(
                              width: 78,
                              height: 78,
                              child: TweenAnimationBuilder<double>(
                                tween: Tween<double>(begin: 0, end: progress),
                                duration: const Duration(milliseconds: 1200),
                                curve: Curves.easeOutCubic,
                                builder: (context, v, _) => Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    CircularProgressIndicator(
                                      value: v,
                                      strokeWidth: 8,
                                      strokeCap: StrokeCap.round,
                                      backgroundColor:
                                      Colors.white.withValues(alpha: 0.22),
                                      valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                    Center(
                                      child: Text(
                                        '${(v * 100).round()}%',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  child: Text(
                                    title,
                                    key: ValueKey(title),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 21,
                                      fontWeight: FontWeight.w900,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  subtitle,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.88),
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (hasLessons) ...[
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _chip(Icons.menu_book_rounded, '$subjects مواد'),
                            _chip(Icons.layers_rounded, '$lessons دروس'),
                            _chip(Icons.check_circle_rounded, 'خلصت $done'),
                          ],
                        ),
                      ],
                      const SizedBox(height: 10),
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
    final focused = _searchFocus.hasFocus;

    return Reveal(
      index: 2,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withValues(alpha: focused ? 0.22 : 0.06),
                blurRadius: focused ? 20 : 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocus,
            textInputAction: TextInputAction.search,
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            onSubmitted: (_) => FocusManager.instance.primaryFocus?.unfocus(),
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
      ),
    );
  }

  // ---------------------------------------------------------------
  // Section title
  // ---------------------------------------------------------------

  Widget _sectionTitle(String title, int count) {
    return Reveal(
      index: 3,
      dy: 16,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 22, 24, 10),
        child: Row(
          children: [
            Container(
              width: 5,
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.accent, AppColors.secondary],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  color: AppColors.accent,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // Add-first button
  // ---------------------------------------------------------------

  Widget _addFirstButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: OceanTap(
        pressedScale: 0.95,
        onTap: () => SubjectSheets.show(context),
        child: AnimatedBuilder(
          animation: _pulse,
          builder: (context, _) {
            final p = Curves.easeInOut.transform(_pulse.value);
            return Container(
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [AppColors.accent, AppColors.accentDark],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.26 + 0.16 * p),
                    blurRadius: 18 + 10 * p,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_rounded, color: AppColors.onAccent, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'أضف أول مادة',
                    style: TextStyle(
                      color: AppColors.onAccent,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
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
    final subjects = context.watch<SubjectsProvider>().subjects;
    final allLessons = context.watch<LessonsProvider>().lessons;

    final ids = subjects.map((s) => s.id).toSet();
    final lessons = allLessons.where((l) => ids.contains(l.subjectId)).toList();
    final done = lessons.where((l) => l.lessonCompleted).length;

    final filtered = _filter(subjects);
    final searching = _query.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: OceanBackground(
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
                    child: _sectionTitle(
                      searching ? 'نتايج البحث' : 'قائمة المواد',
                      filtered.length,
                    ),
                  ),
                if (filtered.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 24, bottom: 130),
                      child: Column(
                        children: [
                          OceanEmpty(
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
                          if (!searching) _addFirstButton(),
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