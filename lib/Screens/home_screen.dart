import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:masar/components/ocean_kit.dart';
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
    with TickerProviderStateMixin {
  /// حركة الموج والشمس (دورة كل 9 ثواني).
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
    context.read<UserDataProvider>().getUserName();
  }

  @override
  void dispose() {
    _ambient.dispose();
    _pulse.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------
  // Header
  // ---------------------------------------------------------------

  Widget _header(DateTime now, String userName) {
    final greeting = now.hour < 12 ? 'صباح الخير' : 'مساء الخير';
    final isDay = now.hour >= 5 && now.hour < 18;
    final date = intl.DateFormat('EEEE، d MMMM', 'ar').format(now);
    final tint = isDay ? AppColors.warm : AppColors.accent;

    return Reveal(
      index: 0,
      dy: 20,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    date,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    userName.isEmpty ? greeting : '$greeting $userName',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 27,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ابدأ يومك بخطوة جديدة',
                    style: TextStyle(
                      color: AppColors.textMuted.withValues(alpha: 0.95),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            // شمس بتلف / قمر بيتهز + هالة بتنبض
            AnimatedBuilder(
              animation: Listenable.merge([_ambient, _pulse]),
              builder: (context, _) {
                final p = Curves.easeInOut.transform(_pulse.value);
                return SizedBox(
                  width: 70,
                  height: 70,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 58 + 12 * p,
                        height: 58 + 12 * p,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20 + 6 * p),
                          color: tint.withValues(alpha: 0.16 * (1 - p)),
                        ),
                      ),
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: isDay
                                ? [
                              AppColors.warm,
                              AppColors.warm.withValues(alpha: 0.75),
                            ]
                                : [AppColors.accent, AppColors.accentDark],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: tint.withValues(alpha: 0.22 + 0.1 * p),
                              blurRadius: 18,
                              offset: const Offset(0, 7),
                            ),
                          ],
                        ),
                        child: Transform.translate(
                          offset: Offset(0, isDay ? 0 : (p - 0.5) * 4),
                          child: Transform.rotate(
                            angle: isDay
                                ? _ambient.value * 2 * math.pi
                                : (p - 0.5) * 0.3,
                            child: Icon(
                              isDay
                                  ? Icons.wb_sunny_rounded
                                  : Icons.nights_stay_rounded,
                              color: Colors.white,
                              size: 29,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // Progress card — فيها مية بموج مستواها بيمثّل إنجازك
  // ---------------------------------------------------------------

  Widget _statChip(IconData icon, String text) {
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

  Widget _progressCard({
    required int done,
    required int total,
    required int overdue,
  }) {
    final allDone = total > 0 && done == total;
    final progress = total == 0 ? 0.0 : done / total;

    late final String title;
    late final String subtitle;
    IconData? icon;

    if (total == 0 && overdue == 0) {
      title = 'يومك فاضي';
      subtitle = 'معندكش مهام النهاردة';
      icon = Icons.wb_sunny_rounded;
    } else if (total == 0) {
      title = 'عندك مهام متأخرة';
      subtitle = '$overdue مهام محتاجة اهتمامك';
      icon = Icons.error_outline_rounded;
    } else if (allDone) {
      title = 'عاش! خلصت كل مهام النهاردة';
      subtitle = 'أنجزت كل اللي خططتله.. كمّل بنفس الروح';
    } else {
      title = 'خلصت $done من $total';
      subtitle = overdue > 0
          ? 'لسه عندك $overdue مهام متأخرة'
          : 'كمّل، أنت ماشي بشكل كويس';
    }

    final glow = allDone ? AppColors.success : AppColors.accent;
    final showChips = total > 0 || overdue > 0;

    return Reveal(
      index: 1,
      dy: 24,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 25, 20, 8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: glow.withValues(alpha: 0.28),
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
                // المية
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
                  end: -35,
                  top: -45,
                  child: IgnorePointer(
                    child: _decorativeCircle(140, 0.075),
                  ),
                ),
                PositionedDirectional(
                  start: -25,
                  bottom: -55,
                  child: IgnorePointer(
                    child: _decorativeCircle(120, 0.055),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(21),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 78,
                            height: 78,
                            child: icon != null
                                ? AnimatedBuilder(
                              animation: _pulse,
                              builder: (context, child) =>
                                  Transform.scale(
                                    scale: 1 +
                                        0.06 *
                                            Curves.easeInOut
                                                .transform(_pulse.value),
                                    child: child,
                                  ),
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white
                                      .withValues(alpha: 0.15),
                                  border: Border.all(
                                    color: Colors.white
                                        .withValues(alpha: 0.15),
                                  ),
                                ),
                                child: Icon(
                                  icon,
                                  color: Colors.white,
                                  size: 35,
                                ),
                              ),
                            )
                                : TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: progress),
                              duration:
                              const Duration(milliseconds: 900),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, _) {
                                return Stack(
                                  fit: StackFit.expand,
                                  alignment: Alignment.center,
                                  children: [
                                    CircularProgressIndicator(
                                      value: value,
                                      strokeWidth: 7,
                                      strokeCap: StrokeCap.round,
                                      backgroundColor: Colors.white
                                          .withValues(alpha: 0.19),
                                      valueColor:
                                      const AlwaysStoppedAnimation<
                                          Color>(Colors.white),
                                    ),
                                    Center(
                                      child: Text(
                                        '${(value * 100).round()}%',
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
                          const SizedBox(width: 18),
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
                                      fontSize: 19,
                                      fontWeight: FontWeight.w900,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 7),
                                Text(
                                  subtitle,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (showChips) ...[
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (total > 0)
                              _statChip(
                                Icons.check_circle_rounded,
                                'خلصت $done',
                              ),
                            if (total > 0 && total - done > 0)
                              _statChip(
                                Icons.pending_rounded,
                                'باقي ${total - done}',
                              ),
                            if (overdue > 0)
                              _statChip(
                                Icons.warning_amber_rounded,
                                'متأخرة $overdue',
                              ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 14),
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

  Widget _decorativeCircle(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }

  // ---------------------------------------------------------------
  // Section title + mini labels
  // ---------------------------------------------------------------

  Widget _sectionTitle(int count) {
    return Reveal(
      index: 2,
      dy: 18,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 25, 24, 10),
        child: Row(
          children: [
            Container(
              width: 5,
              height: 25,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.accent, AppColors.secondary],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'مهام النهاردة',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 10),
            if (count > 0)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(
                    color: AppColors.accentDark,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            const Spacer(),
            Icon(
              Icons.checklist_rounded,
              color: AppColors.accent.withValues(alpha: 0.65),
              size: 23,
            ),
          ],
        ),
      ),
    );
  }

  /// عنوان صغير بيفصل بين "المتأخرة" و"النهاردة".
  Widget _miniLabel({
    required String text,
    required int count,
    required Color color,
    required IconData icon,
    required int index,
  }) {
    return Reveal(
      index: index,
      dy: 14,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(26, 12, 26, 2),
        child: Row(
          children: [
            Icon(icon, size: 17, color: color),
            const SizedBox(width: 7),
            Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: color,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                height: 1.5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withValues(alpha: 0.35),
                      color.withValues(alpha: 0),
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
  // Background (static — الصفحة دي جوه PageView ومش عايزينها تتحرك طول الوقت)
  // ---------------------------------------------------------------

  Widget _background({required Widget child}) {
    return Container(
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
      child: Stack(
        children: [
          PositionedDirectional(
            top: -100,
            end: -90,
            child: _backgroundGlow(230, AppColors.secondary, 0.09),
          ),
          PositionedDirectional(
            top: 390,
            start: -125,
            child: _backgroundGlow(220, AppColors.accentLight, 0.07),
          ),
          child,
        ],
      ),
    );
  }

  Widget _backgroundGlow(double size, Color color, double opacity) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: opacity),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // Tile
  // ---------------------------------------------------------------

  Widget _tile(UserDataProvider provider, TasksModel task, int index) {
    return TodoTile(
      key: ObjectKey(task),
      index: index,
      taskName: task.taskName,
      value: task.completed,
      time: task.taskDate,
      onChanged: (_) {
        provider.toggleTask(task: task);
      },
      deleteTask: (_) {
        TaskSheets.confirmDelete(context, task);
      },
      updateTask: (_) {
        TaskSheets.edit(context, task);
      },
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

    // Collect today's and overdue tasks in one pass.
    final todayTasks = <TasksModel>[];
    final overdueTasks = <TasksModel>[];

    var todayDone = 0;

    for (final task in tasks) {
      if (DateUtils.isSameDay(task.taskDate, now)) {
        todayTasks.add(task);

        if (task.completed) {
          todayDone++;
        }
      } else if (task.taskDate.isBefore(todayStart) && !task.completed) {
        overdueTasks.add(task);
      }
    }

    final displayedCount = overdueTasks.length + todayTasks.length;

    final children = <Widget>[
      _header(now, (provider.userName as String?) ?? ''),
      _progressCard(
        done: todayDone,
        total: todayTasks.length,
        overdue: overdueTasks.length,
      ),
      _sectionTitle(displayedCount),
    ];

    if (displayedCount == 0) {
      children.add(
        const Padding(
          padding: EdgeInsets.only(top: 20),
          child: OceanEmpty(
            icon: Icons.today_rounded,
            title: 'مفيش مهام النهاردة',
            subtitle: 'يوم هادي.. استمتع بوقتك',
          ),
        ),
      );
    } else {
      var idx = 0;

      if (overdueTasks.isNotEmpty) {
        children.add(
          _miniLabel(
            text: 'متأخرة',
            count: overdueTasks.length,
            color: AppColors.danger,
            icon: Icons.warning_amber_rounded,
            index: 3,
          ),
        );
        for (final t in overdueTasks) {
          children.add(_tile(provider, t, idx++));
        }
      }

      if (todayTasks.isNotEmpty) {
        if (overdueTasks.isNotEmpty) {
          children.add(
            _miniLabel(
              text: 'النهاردة',
              count: todayTasks.length,
              color: AppColors.accent,
              icon: Icons.today_rounded,
              index: 4,
            ),
          );
        }
        for (final t in todayTasks) {
          children.add(_tile(provider, t, idx++));
        }
      }
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _background(
        child: SafeArea(
          bottom: false,
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: ListView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: const EdgeInsets.only(bottom: 130),
              children: children,
            ),
          ),
        ),
      ),
    );
  }
}