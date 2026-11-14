import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:masar/components/empty_state.dart';
import 'package:masar/components/motion.dart';
import 'package:masar/components/task_sheets.dart';
import 'package:masar/components/todo_tile.dart';
import 'package:masar/models/tasks_model.dart';
import 'package:masar/providers/user_data_provider.dart';
import 'package:masar/theme/AppColors.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  /// Kept for backwards compatibility with any caller of the old API.
  static void confirmation({
    required BuildContext context,
    required String message,
    required TasksModel task,
  }) {
    TaskSheets.confirmDelete(context, task);
  }

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _float;

  @override
  void initState() {
    super.initState();
    _float = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);
    context.read<UserDataProvider>().getUserName();
  }

  @override
  void dispose() {
    _float.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------
  // Header
  // ---------------------------------------------------------------

  Widget _header(DateTime now, String userName) {
    final greeting = now.hour < 12 ? 'صباح الخير' : 'مساء الخير';
    final isDay = now.hour >= 5 && now.hour < 18;
    final date = intl.DateFormat('EEEE، d MMMM', 'ar').format(now);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeSlideIn(
                  child: Text(
                    date,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                FadeSlideIn(
                  index: 1,
                  child: Text(
                    userName.isEmpty ? greeting : '$greeting $userName',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          AnimatedBuilder(
            animation: _float,
            builder: (context, child) {
              final t = Curves.easeInOut.transform(_float.value);
              return Transform.translate(
                offset: Offset(0, (t - 0.5) * 8),
                child: Transform.rotate(angle: (t - 0.5) * 0.18, child: child),
              );
            },
            child: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: isDay
                      ? [AppColors.warm, AppColors.warm.withValues(alpha: 0.7)]
                      : [AppColors.accent, AppColors.accentDark],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: (isDay ? AppColors.warm : AppColors.accent)
                        .withValues(alpha: 0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                isDay ? Icons.wb_sunny_rounded : Icons.nights_stay_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // Progress card
  // ---------------------------------------------------------------

  Widget _progressCard({
    required int done,
    required int total,
    required int overdue,
  }) {
    final allDone = total > 0 && done == total;

    String title;
    String subtitle;
    IconData? icon;

    if (total == 0 && overdue == 0) {
      title = "يومك فاضي";
      subtitle = "معندكش مهام النهاردة";
      icon = Icons.wb_sunny_rounded;
    } else if (total == 0) {
      title = "عندك مهام متأخرة";
      subtitle = "$overdue محتاجة تخلصها";
      icon = Icons.error_outline_rounded;
    } else if (allDone) {
      title = "عاش! خلصت كل مهام النهاردة";
      subtitle = "كمّل بنفس الحماس";
    } else {
      title = "خلصت $done من $total";
      subtitle = overdue > 0 ? "ومعاك $overdue متأخرة" : "كمّل يومك";
    }

    final progress = total == 0 ? 0.0 : done / total;

    return FadeSlideIn(
      index: 2,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 26, 20, 8),
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
                      SizedBox(
                        width: 78,
                        height: 78,
                        child: icon != null
                            ? Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.18),
                          ),
                          child: Icon(
                            icon,
                            color: AppColors.onAccent,
                            size: 38,
                          ),
                        )
                            : TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: progress),
                          duration: const Duration(milliseconds: 1100),
                          curve: Curves.easeOutCubic,
                          builder: (context, v, _) {
                            return Stack(
                              alignment: Alignment.center,
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
                                    "${(v * 100).round()}%",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
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
  // Section title
  // ---------------------------------------------------------------

  Widget _sectionTitle(int count) {
    return FadeSlideIn(
      index: 3,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 22, 24, 8),
        child: Row(
          children: [
            const Text(
              "مهام النهاردة",
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 10),
            if (count > 0)
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "$count",
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
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
    final provider = context.watch<UserDataProvider>();
    final tasks = provider.tasks;
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    final todayTasks = tasks
        .where((t) => DateUtils.isSameDay(t.taskDate, now))
        .toList();
    final todayDone = todayTasks.where((t) => t.completed).length;
    final overdueTasks = tasks
        .where((t) => t.taskDate.isBefore(todayStart) && !t.completed)
        .toList();
    final displayed = [...overdueTasks, ...todayTasks];

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
            child: ListView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: const EdgeInsets.only(bottom: 130),
              children: [
                _header(now, (provider.userName as String?) ?? ''),
                _progressCard(
                  done: todayDone,
                  total: todayTasks.length,
                  overdue: overdueTasks.length,
                ),
                _sectionTitle(displayed.length),
                if (displayed.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 30),
                    child: EmptyState(
                      icon: Icons.today_rounded,
                      title: "مفيش مهام النهاردة",
                      subtitle: "يوم هادي.. استمتع بوقتك",
                    ),
                  )
                else
                  for (var i = 0; i < displayed.length; i++)
                    TodoTile(
                      key: ObjectKey(displayed[i]),
                      index: i,
                      taskName: displayed[i].taskName,
                      value: displayed[i].completed,
                      time: displayed[i].taskDate,
                      onChanged: (_) =>
                          provider.toggleTask(task: displayed[i]),
                      deleteTask: (_) =>
                          TaskSheets.confirmDelete(context, displayed[i]),
                      updateTask: (_) =>
                          TaskSheets.edit(context, displayed[i]),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}