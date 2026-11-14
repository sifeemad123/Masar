import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:masar/components/empty_state.dart';
import 'package:masar/components/habit_tile.dart';
import 'package:masar/components/motion.dart';
import 'package:masar/providers/habits_provider.dart';
import 'package:masar/theme/AppColors.dart';
import 'package:provider/provider.dart';

import '../components/habits_sheets.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  /// Kept for backwards compatibility with any caller of the old API.
  static void confirmation({
    required BuildContext context,
    required String message,
    required int index,
  }) {
    HabitSheets.confirmDelete(context, index);
  }

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<HabitsProvider>(context, listen: false).resetCompletedHabits();
  }

  // ---------------------------------------------------------------
  // Summary card
  // ---------------------------------------------------------------

  Widget _summaryCard({
    required int done,
    required int total,
    required int bestStreak,
  }) {
    final progress = total == 0 ? 0.0 : done / total;
    final allDone = total > 0 && done == total;

    return FadeSlideIn(
      index: 1,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [AppColors.accent, AppColors.accentDark],
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.3),
                blurRadius: 26,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          allDone ? "عاش! كملت عاداتك" : "التزامك النهاردة",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "خلصت $done من $total",
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 14.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.local_fire_department_rounded,
                          color: Color(0xFFFFC857),
                          size: 22,
                        ),
                        const SizedBox(width: 5),
                        AnimatedCount(
                          value: bestStreak,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "أطول سلسلة",
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progress),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutCubic,
                builder: (context, v, _) {
                  return Stack(
                    children: [
                      Container(
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: math.max(v, 0.0001),
                        child: Container(
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.5),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
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
    final provider = context.watch<HabitsProvider>();
    final habits = provider.habits;

    final done = habits.where((h) => h.habitCompleted).length;
    final best = habits.isEmpty
        ? 0
        : habits.map((h) => h.streakCount).reduce(math.max);

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
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
                  child: FadeSlideIn(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "عاداتي",
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          habits.isEmpty
                              ? "ابدأ بعادة صغيرة النهاردة"
                              : "${habits.length} عادة بتبنيها",
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (habits.isNotEmpty)
                  _summaryCard(
                    done: done,
                    total: habits.length,
                    bestStreak: best,
                  ),
                Expanded(
                  child: habits.isEmpty
                      ? const EmptyState(
                    icon: Icons.track_changes_rounded,
                    title: "مفيش عادات لسه",
                    subtitle: "ضيف عادة عاوز تلتزم بيها كل يوم",
                  )
                      : ListView.builder(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    padding: const EdgeInsets.only(top: 4, bottom: 130),
                    itemCount: habits.length,
                    itemBuilder: (context, index) {
                      final habit = habits[index];
                      final hasAlarm = habit.alarmHour != null &&
                          habit.alarmMinute != null;
                      return HabitTile(
                        key: ObjectKey(habit),
                        index: index,
                        habitName: habit.habitName,
                        habitDescription: habit.habitDescription,
                        habitComplete: habit.habitCompleted,
                        streakCount: habit.streakCount,
                        alarmText: hasAlarm
                            ? TimeOfDay(
                          hour: habit.alarmHour!,
                          minute: habit.alarmMinute!,
                        ).format(context)
                            : null,
                        onChanged: (_) => provider.habitCompleted(
                          index: index,
                        ),
                        deleteTask: (_) =>
                            HabitSheets.confirmDelete(context, index),
                        updateTask: (_) =>
                            HabitSheets.edit(context, index),
                      );
                    },
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