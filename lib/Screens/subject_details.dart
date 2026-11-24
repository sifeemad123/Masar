import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:masar/Screens/notes_screen.dart';
import 'package:masar/components/dialogs.dart';
import 'package:masar/components/lesson_sheets.dart';
import 'package:masar/components/lesson_tile.dart';
import 'package:masar/components/ocean_kit.dart';
import 'package:masar/components/subject_sheets.dart';
import 'package:masar/models/subjects_model.dart';
import 'package:masar/providers/lessons_provider.dart';
import 'package:masar/providers/subjects_provider.dart';
import 'package:masar/theme/AppColors.dart';
import 'package:provider/provider.dart';

enum _LessonFilter { all, pending, done }

class SubjectDetails extends StatefulWidget {
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

  @override
  State<SubjectDetails> createState() => _SubjectDetailsState();
}

class _SubjectDetailsState extends State<SubjectDetails>
    with TickerProviderStateMixin {
  _LessonFilter _filter = _LessonFilter.all;
  bool _descExpanded = false;

  /// حركة الموج (دورة كل 9 ثواني).
  late final AnimationController _ambient = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 9),
  )..repeat();

  /// نبض الأزرار والإضاءة.
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _ambient.dispose();
    _pulse.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------
  // Top bar
  // ---------------------------------------------------------------

  Widget _topBar(BuildContext context, SubjectsModel? subject) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Reveal(
        dy: -16,
        child: Row(
          children: [
            GlassIconButton(
              icon: Icons.arrow_back_rounded,
              onTap: () => Navigator.pop(context),
            ),
            const Spacer(),
            if (subject != null) ...[
              GlassIconButton(
                icon: Icons.edit_rounded,
                color: AppColors.accent,
                onTap: () => SubjectSheets.show(context, subject: subject),
              ),
              const SizedBox(width: 10),
              GlassIconButton(
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

  // ---------------------------------------------------------------
  // Hero — "خزان مية" مستواه بيمثّل نسبة إنجازك
  // ---------------------------------------------------------------

  Widget _heroPill(IconData icon, String text) {
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
          Flexible(
            child: Text(
              text,
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
    );
  }

  Widget _hero({
    required String name,
    required String description,
    required String teacher,
    required double progress,
    required bool allDone,
  }) {
    final isLong = description.length > 110;
    final glow = allDone ? AppColors.success : AppColors.accent;

    return Reveal(
      index: 1,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: glow.withValues(alpha: 0.3),
                blurRadius: 30,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Stack(
              children: [
                // الخلفية
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
                // المية
                Positioned.fill(
                  child: IgnorePointer(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: progress),
                      duration: const Duration(milliseconds: 1800),
                      curve: Curves.easeOutCubic,
                      builder: (context, v, _) {
                        return AnimatedBuilder(
                          animation: _ambient,
                          builder: (context, _) {
                            return CustomPaint(
                              painter: WavePainter(
                                level: 0.05 + 0.9 * v,
                                phase: _ambient.value * 3,
                                color: Colors.white.withValues(alpha: 0.15),
                                amplitude: 7,
                                layers: 3,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
                // لمعة
                PositionedDirectional(
                  end: -30,
                  top: -40,
                  child: IgnorePointer(
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                ),
                // المحتوى
                Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Hero(
                            tag: 'subject-icon-${widget.subjectId}',
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
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              name,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.w900,
                                height: 1.25,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            children: [
                              TweenAnimationBuilder<double>(
                                tween: Tween<double>(
                                  begin: 0,
                                  end: progress * 100,
                                ),
                                duration: const Duration(milliseconds: 1500),
                                curve: Curves.easeOutCubic,
                                builder: (context, v, _) => Text(
                                  '${v.round()}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w900,
                                    height: 1,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'إنجاز',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.75),
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (description.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: isLong
                              ? () => setState(
                                () => _descExpanded = !_descExpanded,
                          )
                              : null,
                          child: AnimatedSize(
                            duration: const Duration(milliseconds: 280),
                            curve: Curves.easeOutCubic,
                            alignment: Alignment.topCenter,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  description,
                                  maxLines: _descExpanded || !isLong ? null : 3,
                                  overflow: _descExpanded || !isLong
                                      ? TextOverflow.visible
                                      : TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.88),
                                    fontSize: 15,
                                    height: 1.6,
                                  ),
                                ),
                                if (isLong) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    _descExpanded ? 'أقل' : 'المزيد',
                                    style: const TextStyle(
                                      color: AppColors.secondaryLight,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                      if (teacher.isNotEmpty || allDone) ...[
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (teacher.isNotEmpty)
                              _heroPill(Icons.person_outline_rounded, teacher),
                            if (allDone)
                              _heroPill(
                                Icons.workspace_premium_rounded,
                                'مادة مكتملة',
                              ),
                          ],
                        ),
                      ],
                      // مساحة عشان المية تبان تحت النص
                      const SizedBox(height: 26),
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
  // Stats
  // ---------------------------------------------------------------

  Widget _stat({
    required IconData icon,
    required int value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.14),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 8),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: value.toDouble()),
            duration: const Duration(milliseconds: 1100),
            curve: Curves.easeOutCubic,
            builder: (context, v, _) => Text(
              '${v.round()}',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _stats({required int total, required int done}) {
    return Reveal(
      index: 2,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
        child: Row(
          children: [
            Expanded(
              child: _stat(
                icon: Icons.layers_rounded,
                value: total,
                label: 'الدروس',
                color: AppColors.accent,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _stat(
                icon: Icons.check_circle_rounded,
                value: done,
                label: 'خلصت',
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _stat(
                icon: Icons.pending_rounded,
                value: total - done,
                label: 'باقي',
                color: AppColors.warm,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // Continue card
  // ---------------------------------------------------------------

  Widget _continueCard({
    required String lessonName,
    required int number,
    required VoidCallback onTap,
  }) {
    return Reveal(
      index: 3,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
        child: OceanTap(
          pressedScale: 0.97,
          onTap: onTap,
          child: AnimatedBuilder(
            animation: _pulse,
            builder: (context, _) {
              final p = Curves.easeInOut.transform(_pulse.value);
              return Container(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [AppColors.accent, AppColors.accentDark],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.22 + 0.16 * p),
                      blurRadius: 18 + 14 * p,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Transform.translate(
                      offset: Offset(0, (p - 0.5) * 6),
                      child: Transform.rotate(
                        angle: (p - 0.5) * 0.12,
                        child: Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.18),
                          ),
                          child: const Icon(
                            Icons.sailing_rounded,
                            color: AppColors.onAccent,
                            size: 25,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'كمّل رحلتك • الدرس $number',
                            style: TextStyle(
                              color: AppColors.onAccent.withValues(alpha: 0.78),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            lessonName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.onAccent,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Transform.translate(
                      offset: Offset(-5 * p, 0),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: AppColors.onAccent,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // Section header + segmented filter
  // ---------------------------------------------------------------

  Widget _sectionHeader(int count) {
    return Reveal(
      index: 4,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 26, 24, 12),
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
            const Text(
              'الدروس',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
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
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _segmented({required int total, required int done}) {
    final items = <(String, int, _LessonFilter)>[
      ('الكل', total, _LessonFilter.all),
      ('الباقي', total - done, _LessonFilter.pending),
      ('المخلصة', done, _LessonFilter.done),
    ];
    final idx = _LessonFilter.values.indexOf(_filter);

    return Reveal(
      index: 5,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
        child: Container(
          height: 52,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppColors.surface,
            border: Border.all(color: AppColors.divider),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.06),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              AnimatedAlign(
                duration: const Duration(milliseconds: 380),
                curve: Curves.easeOutBack,
                alignment: AlignmentDirectional(idx - 1.0, 0),
                child: FractionallySizedBox(
                  widthFactor: 1 / 3,
                  heightFactor: 1,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [AppColors.accent, AppColors.accentDark],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  for (final e in items)
                    Expanded(
                      child: OceanTap(
                        pressedScale: 0.95,
                        onTap: () => setState(() => _filter = e.$3),
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 250),
                            style: TextStyle(
                              color: _filter == e.$3
                                  ? AppColors.onAccent
                                  : AppColors.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                            child: Text('${e.$1} ${e.$2}'),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filteredEmpty() {
    final pending = _filter == _LessonFilter.pending;
    return OceanEmpty(
      icon: pending ? Icons.celebration_rounded : Icons.flag_rounded,
      title: pending ? 'مفيش دروس باقية' : 'لسه مخلصتش أي درس',
      subtitle: pending
          ? 'خلصت كل حاجة، عاش عليك'
          : 'علّم أول درس تخلصه وهيظهر هنا',
    );
  }

  // ---------------------------------------------------------------
  // FAB
  // ---------------------------------------------------------------

  Widget _fab(VoidCallback onTap) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      curve: Curves.elasticOut,
      builder: (context, v, child) =>
          Transform.scale(scale: v.clamp(0.0, 1.2), child: child),
      child: OceanTap(
        pressedScale: 0.92,
        onTap: onTap,
        child: AnimatedBuilder(
          animation: _pulse,
          builder: (context, _) {
            final p = Curves.easeInOut.transform(_pulse.value);
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: const LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [AppColors.accent, AppColors.accentDark],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.28 + 0.16 * p),
                    blurRadius: 20 + 12 * p,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_rounded, color: AppColors.onAccent, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'درس جديد',
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
    final subject = context
        .watch<SubjectsProvider>()
        .subjects
        .where((s) => s.id == widget.subjectId)
        .firstOrNull;

    final name = subject?.subjectName ?? widget.subjectName;
    final description =
    (subject?.subjectDescription ?? widget.subjectDescription).trim();
    final teacher = (subject?.teacherName ?? widget.teacherName ?? '').trim();

    final lessonsProvider = context.watch<LessonsProvider>();
    final lessons = lessonsProvider.lessons
        .where((l) => l.subjectId == widget.subjectId)
        .toList();
    final done = lessons.where((l) => l.lessonCompleted).length;
    final total = lessons.length;
    final allDone = total > 0 && done == total;
    final progress = total == 0 ? 0.0 : done / total;

    final nextLesson = lessons.where((l) => !l.lessonCompleted).firstOrNull;

    void openLesson(dynamic lesson) {
      Navigator.push<void>(
        context,
        oceanRoute<void>(
          NotesScreen(
            lessonName: lesson.lessonName,
            lessonDescription: lesson.lessonDescription,
            lessonId: lesson.id,
          ),
        ),
      );
    }

    void onToggle(dynamic lesson) {
      lessonsProvider.toggleLesson(lesson: lesson);

      if (!lesson.lessonCompleted) return;

      if (lessons.every((l) => l.lessonCompleted)) {
        Dialogs.success(
          context: context,
          title: 'عاش',
          message: 'خلصت كل دروس "$name".\nاستمر كده، إنت أقرب لهدفك',
        );
      } else {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 96),
              duration: const Duration(seconds: 3),
              backgroundColor: AppColors.surface,
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(
                  color: AppColors.success.withValues(alpha: 0.4),
                ),
              ),
              content: Directionality(
                textDirection: TextDirection.rtl,
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.success,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'تم إنجاز "${lesson.lessonName}"',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              action: SnackBarAction(
                label: 'تراجع',
                textColor: AppColors.accent,
                onPressed: () => lessonsProvider.toggleLesson(lesson: lesson),
              ),
            ),
          );
      }
    }

    final visible = switch (_filter) {
      _LessonFilter.all => lessons,
      _LessonFilter.pending => lessons.where((l) => !l.lessonCompleted).toList(),
      _LessonFilter.done => lessons.where((l) => l.lessonCompleted).toList(),
    };

    return Scaffold(
      body: OceanBackground(
        child: SafeArea(
          bottom: false,
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: ListView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: const EdgeInsets.only(bottom: 140),
              children: [
                _topBar(context, subject),
                _hero(
                  name: name,
                  description: description,
                  teacher: teacher,
                  progress: progress,
                  allDone: allDone,
                ),
                if (total > 0) _stats(total: total, done: done),
                if (nextLesson != null)
                  _continueCard(
                    lessonName: nextLesson.lessonName,
                    number: lessons.indexOf(nextLesson) + 1,
                    onTap: () => openLesson(nextLesson),
                  ),
                _sectionHeader(total),
                if (total > 0) _segmented(total: total, done: done),
                if (total == 0)
                  const OceanEmpty(
                    icon: Icons.menu_book_rounded,
                    title: 'مفيش دروس',
                    subtitle: 'ابدأ بإضافة أول درس ليك في المادة دي',
                  )
                else
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    switchInCurve: Curves.easeOutCubic,
                    layoutBuilder: (current, previous) => Stack(
                      alignment: Alignment.topCenter,
                      children: [...previous, if (current != null) current],
                    ),
                    child: visible.isEmpty
                        ? KeyedSubtree(
                      key: ValueKey('empty-${_filter.name}'),
                      child: _filteredEmpty(),
                    )
                        : Column(
                      key: ValueKey('list-${_filter.name}'),
                      children: [
                        for (var i = 0; i < visible.length; i++)
                          LessonTile(
                            key: ObjectKey(visible[i]),
                            index: i,
                            lessonNumber:
                            lessons.indexOf(visible[i]) + 1,
                            isFirst: i == 0,
                            isLast: i == visible.length - 1,
                            isNext: identical(visible[i], nextLesson),
                            lessonId: visible[i].id,
                            lessonName: visible[i].lessonName,
                            lessonDescription:
                            visible[i].lessonDescription,
                            lessonCompleted: visible[i].lessonCompleted,
                            onChanged: (_) => onToggle(visible[i]),
                            onTap: () => openLesson(visible[i]),
                            onDelete: (_) => LessonSheets.confirmDelete(
                              context,
                              visible[i],
                            ),
                            onEdit: (_) => LessonSheets.show(
                              context,
                              subjectId: widget.subjectId,
                              lesson: visible[i],
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
      floatingActionButton: _fab(
            () => LessonSheets.show(context, subjectId: widget.subjectId),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}