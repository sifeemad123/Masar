import 'package:flutter/material.dart';
import 'package:masar/components/ocean_kit.dart';
import 'package:masar/components/task_sheets.dart';
import 'package:masar/components/todo_tile.dart';
import 'package:masar/models/tasks_model.dart';
import 'package:masar/providers/user_data_provider.dart';
import 'package:masar/theme/AppColors.dart';
import 'package:provider/provider.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  /// Kept for backwards compatibility with any caller of the old API.
  static void confirmation({
    required BuildContext context,
    required String message,
    required TasksModel task,
  }) {
    TaskSheets.confirmDelete(context, task);
  }

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen>
    with SingleTickerProviderStateMixin {
  String selectedFilter = "all";

  /// حركة الموج (دورة كل 9 ثواني).
  late final AnimationController _ambient = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 9),
  )..repeat();

  @override
  void dispose() {
    _ambient.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------
  // Overview card — مية بموج مستواها نسبة إنجاز كل مهامك
  // ---------------------------------------------------------------

  Widget _chip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 15),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _overviewCard({
    required int done,
    required int total,
    required int overdue,
  }) {
    final progress = total == 0 ? 0.0 : done / total;
    final allDone = total > 0 && done == total;
    final glow = allDone ? AppColors.success : AppColors.accent;

    return Reveal(
      index: 1,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: glow.withValues(alpha: 0.26),
                blurRadius: 24,
                offset: const Offset(0, 11),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
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
                            amplitude: 6,
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
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.07),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'نسبة إنجازك الكلية',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 7,
                              runSpacing: 7,
                              children: [
                                _chip(
                                  Icons.check_circle_rounded,
                                  'خلصت $done',
                                ),
                                _chip(
                                  Icons.pending_rounded,
                                  'باقي ${total - done}',
                                ),
                                if (overdue > 0)
                                  _chip(
                                    Icons.warning_amber_rounded,
                                    'متأخرة $overdue',
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: progress * 100),
                        duration: const Duration(milliseconds: 1400),
                        curve: Curves.easeOutCubic,
                        builder: (context, v, _) => Text(
                          '${v.round()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            height: 1,
                          ),
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
  // Filter bar — مؤشر بينزلق بين الاختيارات
  // ---------------------------------------------------------------

  Widget _filterPill({
    required String title,
    required String value,
    int count = 0,
  }) {
    final selected = selectedFilter == value;

    return Expanded(
      child: OceanTap(
        pressedScale: 0.94,
        onTap: () => setState(() => selectedFilter = value),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 250),
                    style: TextStyle(
                      color: selected
                          ? AppColors.onAccent
                          : AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    ),
                    child: Text(title),
                  ),
                  if (count > 0) ...[
                    const SizedBox(width: 5),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? Colors.white.withValues(alpha: 0.25)
                            : (value == "overdue"
                            ? AppColors.danger.withValues(alpha: 0.14)
                            : AppColors.accent.withValues(alpha: 0.12)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "$count",
                        style: TextStyle(
                          color: selected
                              ? AppColors.onAccent
                              : (value == "overdue"
                              ? AppColors.danger
                              : AppColors.accent),
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _filters({
    required int todayCount,
    required int overdueCount,
    required int futureCount,
  }) {
    const values = ["all", "toDay", "overdue", "future"];
    final idx = values.indexOf(selectedFilter).clamp(0, 3);

    return Reveal(
      index: 2,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(21),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.06),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: SizedBox(
            height: 44,
            child: Stack(
              children: [
                AnimatedAlign(
                  duration: const Duration(milliseconds: 380),
                  curve: Curves.easeOutBack,
                  alignment: AlignmentDirectional(-1 + idx * 2 / 3, 0),
                  child: FractionallySizedBox(
                    widthFactor: 1 / 4,
                    heightFactor: 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          begin: Alignment.centerRight,
                          end: Alignment.centerLeft,
                          colors: [AppColors.accent, AppColors.accentDark],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.28),
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
                    _filterPill(title: "الكل", value: "all"),
                    _filterPill(
                      title: "النهاردة",
                      value: "toDay",
                      count: todayCount,
                    ),
                    _filterPill(
                      title: "متأخرة",
                      value: "overdue",
                      count: overdueCount,
                    ),
                    _filterPill(
                      title: "الجاية",
                      value: "future",
                      count: futureCount,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // Empty state
  // ---------------------------------------------------------------

  Widget _emptyState() {
    switch (selectedFilter) {
      case "toDay":
        return const OceanEmpty(
          icon: Icons.today_rounded,
          title: "مفيش مهام النهاردة",
          subtitle: "يوم هادي.. استمتع بوقتك",
        );
      case "overdue":
        return const OceanEmpty(
          icon: Icons.task_alt_rounded,
          title: "مفيش مهام متأخرة",
          subtitle: "ممتاز! مخلص كل اللي عليك",
        );
      case "future":
        return const OceanEmpty(
          icon: Icons.event_available_rounded,
          title: "مفيش مهام جاية",
          subtitle: "لسه مفيش حاجة في جدولك",
        );
      default:
        return const OceanEmpty(
          icon: Icons.inbox_rounded,
          title: "مفيش مهام لسه",
          subtitle: "ابدأ بإضافة أول مهمة ليك",
        );
    }
  }

  // ---------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserDataProvider>();
    final tasks = provider.tasks;
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    final todayTasks = tasks
        .where((t) => DateUtils.isSameDay(t.taskDate, now))
        .toList();
    final overdueTasks = tasks
        .where((t) => t.taskDate.isBefore(todayStart) && !t.completed)
        .toList();
    final futureTasks = tasks
        .where(
          (t) => t.taskDate.isAfter(todayStart.add(const Duration(days: 1))),
    )
        .toList();

    final List<TasksModel> displayed;
    switch (selectedFilter) {
      case "toDay":
        displayed = todayTasks;
        break;
      case "overdue":
        displayed = overdueTasks;
        break;
      case "future":
        displayed = futureTasks;
        break;
      default:
        displayed = [...overdueTasks, ...todayTasks, ...futureTasks];
    }

    final remaining = tasks.where((t) => !t.completed).length;
    final doneCount = tasks.length - remaining;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.pearlLight,
              AppColors.background,
              AppColors.pearlDark,
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
                  child: Reveal(
                    dy: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "مهامي",
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            remaining == 0
                                ? "كل مهامك خلصت"
                                : "$remaining مهمة لسه مخلصتش",
                            key: ValueKey(remaining),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (tasks.isNotEmpty)
                  _overviewCard(
                    done: doneCount,
                    total: tasks.length,
                    overdue: overdueTasks.length,
                  ),

                _filters(
                  todayCount: todayTasks.length,
                  overdueCount: overdueTasks.length,
                  futureCount: futureTasks.length,
                ),

                // List
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    switchInCurve: Curves.easeOutCubic,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.03),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: displayed.isEmpty
                        ? KeyedSubtree(
                      key: ValueKey('empty-$selectedFilter'),
                      child: _emptyState(),
                    )
                        : ListView.builder(
                      key: ValueKey('list-$selectedFilter'),
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      padding: const EdgeInsets.only(top: 4, bottom: 130),
                      itemCount: displayed.length,
                      itemBuilder: (context, index) {
                        final task = displayed[index];
                        return TodoTile(
                          key: ObjectKey(task),
                          index: index,
                          taskName: task.taskName,
                          value: task.completed,
                          time: task.taskDate,
                          onChanged: (_) =>
                              provider.toggleTask(task: task),
                          deleteTask: (_) =>
                              TaskSheets.confirmDelete(context, task),
                          updateTask: (_) =>
                              TaskSheets.edit(context, task),
                        );
                      },
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