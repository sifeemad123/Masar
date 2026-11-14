import 'package:flutter/material.dart';
import 'package:masar/components/empty_state.dart';
import 'package:masar/components/motion.dart';
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

class _TasksScreenState extends State<TasksScreen> {
  String selectedFilter = "all";

  // ---------------------------------------------------------------
  // Filter bar
  // ---------------------------------------------------------------

  Widget _filterPill({
    required String title,
    required String value,
    int count = 0,
  }) {
    final selected = selectedFilter == value;

    return Expanded(
      child: Pressable(
        haptic: true,
        pressedScale: 0.94,
        onTap: () => setState(() => selectedFilter = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
              colors: [AppColors.accent, AppColors.accentDark],
            )
                : null,
            borderRadius: BorderRadius.circular(16),
            boxShadow: selected
                ? [
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.28),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ]
                : const [],
          ),
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

  // ---------------------------------------------------------------
  // Empty state
  // ---------------------------------------------------------------

  Widget _emptyState() {
    switch (selectedFilter) {
      case "toDay":
        return const EmptyState(
          icon: Icons.today_rounded,
          title: "مفيش مهام النهاردة",
          subtitle: "يوم هادي.. استمتع بوقتك",
        );
      case "overdue":
        return const EmptyState(
          icon: Icons.task_alt_rounded,
          title: "مفيش مهام متأخرة",
          subtitle: "ممتاز! مخلص كل اللي عليك",
        );
      case "future":
        return const EmptyState(
          icon: Icons.event_available_rounded,
          title: "مفيش مهام جاية",
          subtitle: "لسه مفيش حاجة في جدولك",
        );
      default:
        return const EmptyState(
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
                  child: FadeSlideIn(
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

                // Filters
                FadeSlideIn(
                  index: 1,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(21),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          _filterPill(title: "الكل", value: "all"),
                          _filterPill(
                            title: "النهاردة",
                            value: "toDay",
                            count: todayTasks.length,
                          ),
                          _filterPill(
                            title: "متأخرة",
                            value: "overdue",
                            count: overdueTasks.length,
                          ),
                          _filterPill(
                            title: "الجاية",
                            value: "future",
                            count: futureTasks.length,
                          ),
                        ],
                      ),
                    ),
                  ),
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