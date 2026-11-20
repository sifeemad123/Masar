
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

  // Kept for backwards compatibility with the old API.
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<HabitsProvider>().resetCompletedHabits();
    });
  }

  // ---------------------------------------------------------------
  // Summary Card
  // ---------------------------------------------------------------

  Widget _summaryCard({
    required int done,
    required int total,
    required int bestStreak,
  }) {
    final progress = total == 0 ? 0.0 : done / total;
    final percentage = (progress * 100).round();
    final allDone = total > 0 && done == total;

    return FadeSlideIn(
      index: 1,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                AppColors.accent,
                AppColors.accentDark,
              ],
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
              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          allDone
                              ? "عاش! كملت عاداتك"
                              : "التزامك النهاردة",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          allDone
                              ? "أنجزت كل عاداتك النهاردة"
                              : "كل خطوة صغيرة بتفرق معاك",
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.82),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Best streak
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.local_fire_department_rounded,
                              color: Color(0xFFFFC857),
                              size: 21,
                            ),
                            const SizedBox(width: 4),
                            AnimatedCount(
                              value: bestStreak,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "أطول سلسلة",
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Progress information
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    "إنجاز اليوم",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    "$done",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    " / $total",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.17),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "$percentage%",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 11),

              // Animated progress bar
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progress),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) {
                  return Stack(
                    children: [
                      Container(
                        height: 11,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: math.max(value, 0.0001),
                        child: Container(
                          height: 11,
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
  // Habits Section Header
  // ---------------------------------------------------------------

  Widget _habitsSectionHeader(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 21,
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 9),
          const Text(
            "عاداتك اليومية",
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 11,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "$count عادة",
              style: const TextStyle(
                color: AppColors.accent,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
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
                // Page Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 22, 24, 0),
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
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          habits.isEmpty
                              ? "ابدأ بعادة صغيرة النهاردة"
                              : "خطواتك اليومية بتقربك من أهدافك",
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Summary
                if (habits.isNotEmpty)
                  _summaryCard(
                    done: done,
                    total: habits.length,
                    bestStreak: best,
                  ),

                // Habits List
                Expanded(
                  child: habits.isEmpty
                      ? const EmptyState(
                    icon: Icons.track_changes_rounded,
                    title: "مفيش عادات لسه",
                    subtitle: "ضيف عادة عاوز تلتزم بيها كل يوم",
                  )
                      : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _habitsSectionHeader(habits.length),

                      Expanded(
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics(),
                          ),
                          padding: const EdgeInsets.only(
                            top: 2,
                            bottom: 130,
                          ),
                          itemCount: habits.length,
                          itemBuilder: (context, index) {
                            final habit = habits[index];

                            final hasAlarm =
                                habit.alarmHour != null &&
                                    habit.alarmMinute != null;

                            return HabitTile(
                              key: ObjectKey(habit),
                              index: index,
                              habitName: habit.habitName,
                              habitDescription:
                              habit.habitDescription,
                              habitComplete: habit.habitCompleted,
                              streakCount: habit.streakCount,
                              protectionRemaining:
                              provider.remainingProtectionChances(
                                habit,
                              ),
                              protectionNeeded:
                              provider.canProtectStreak(habit),
                              alarmText: hasAlarm
                                  ? TimeOfDay(
                                hour: habit.alarmHour!,
                                minute: habit.alarmMinute!,
                              ).format(context)
                                  : null,
                              onChanged: (_) {
                                provider.habitCompleted(index: index);
                              },
                              deleteTask: (_) {
                                HabitSheets.confirmDelete(
                                  context,
                                  index,
                                );
                              },
                              updateTask: (_) {
                                HabitSheets.edit(context, index);
                              },
                            );
                          },
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
}
