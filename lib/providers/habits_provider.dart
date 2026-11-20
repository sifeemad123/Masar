
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:masar/models/habits_model.dart';
import 'package:masar/services/notifications_service.dart';

class HabitsProvider extends ChangeNotifier {
  static Box<HabitsModel> habitsBox() =>
      Hive.box<HabitsModel>("habitsBox");

  List<HabitsModel> get habits => habitsBox().values.toList();

  static const int monthlyProtectionLimit = 3;

  String get _currentMonthKey {
    final now = DateTime.now();

    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  int _daysPassed(DateTime lastDate) {
    final now = DateTime.now();

    final today = DateTime.utc(
      now.year,
      now.month,
      now.day,
    );

    final lastDay = DateTime.utc(
      lastDate.year,
      lastDate.month,
      lastDate.day,
    );

    return today.difference(lastDay).inDays;
  }

  int remainingProtectionChances(HabitsModel habit) {
    if (habit.protectionMonthKey != _currentMonthKey) {
      return monthlyProtectionLimit;
    }

    return (monthlyProtectionLimit - habit.protectionUsesThisMonth)
        .clamp(0, monthlyProtectionLimit)
        .toInt();
  }

  bool canProtectStreak(HabitsModel habit) {
    final lastCompleted = habit.lastCompletedDate;

    if (lastCompleted == null || habit.habitCompleted) {
      return false;
    }

    return _daysPassed(lastCompleted) == 2 &&
        habit.streakCount > 0 &&
        remainingProtectionChances(habit) > 0;
  }

  Future<bool> _resetMonthlyProtectionIfNeeded(
      HabitsModel habit,
      ) async {
    if (habit.protectionMonthKey == _currentMonthKey) {
      return false;
    }

    habit
      ..protectionMonthKey = _currentMonthKey
      ..protectionUsesThisMonth = 0;

    await habit.save();

    return true;
  }

  Future<bool> _resetHabitIfNeeded(
      HabitsModel habit, {
        bool preserveProtectableStreak = true,
      }) async {
    final lastCompleted = habit.lastCompletedDate;

    if (lastCompleted == null) return false;

    final daysPassed = _daysPassed(lastCompleted);

    bool changed = false;

    if (daysPassed >= 1 && habit.habitCompleted) {
      habit.habitCompleted = false;
      changed = true;
    }

    if (daysPassed >= 2 && habit.streakCount != 0) {
      final canKeepStreak =
          preserveProtectableStreak &&
              daysPassed == 2 &&
              remainingProtectionChances(habit) > 0;

      if (!canKeepStreak) {
        habit.streakCount = 0;
        changed = true;
      }
    }

    if (changed) {
      await habit.save();
    }

    return changed;
  }

  Future<void> addHabit({
    required String habitName,
    required String habitDescription,
  }) async {
    final habit = HabitsModel()
      ..habitName = habitName
      ..habitDescription = habitDescription
      ..habitCompleted = false
      ..streakCount = 0
      ..lastCompletedDate = null
      ..alarmHour = null
      ..alarmMinute = null
      ..protectionUsesThisMonth = 0
      ..protectionMonthKey = _currentMonthKey;

    await habitsBox().add(habit);

    notifyListeners();
  }

  Future<void> deleteHabit({required int index}) async {
    final habit = habits[index];
    final key = habit.key;

    if (key is int) {
      await NotificationsService().cancelHabitAlarm(key);
    }

    await habit.delete();

    notifyListeners();
  }

  // ---------------------------------------------------------------
  // Complete habit + automatic streak protection
  // ---------------------------------------------------------------

  Future<bool> habitCompleted({required int index}) async {
    final currentHabits = habits;

    if (index < 0 || index >= currentHabits.length) {
      return false;
    }

    final habit = currentHabits[index];

    // Prevent completing the same habit more than once per day.
    if (habit.habitCompleted) {
      return false;
    }

    await _resetMonthlyProtectionIfNeeded(habit);

    // Check protection BEFORE resetting the streak.
    final shouldUseProtection = canProtectStreak(habit);

    // Keep the streak only if this completion can protect it.
    await _resetHabitIfNeeded(
      habit,
      preserveProtectableStreak: shouldUseProtection,
    );

    // Consume exactly one chance when protection is actually needed.
    if (shouldUseProtection) {
      habit
        ..protectionUsesThisMonth += 1
        ..protectionMonthKey = _currentMonthKey;
    }

    // Complete today's habit.
    habit
      ..habitCompleted = true
      ..streakCount += 1
      ..lastCompletedDate = DateTime.now();

    await habit.save();

    notifyListeners();

    // Returns true if a protection chance was consumed.
    return shouldUseProtection;
  }

  // ---------------------------------------------------------------
  // Edit habit
  // ---------------------------------------------------------------

  Future<void> editHabit({
    required String habitName,
    required String habitDescription,
    required int index,
  }) async {
    final habit = habits[index];

    habit
      ..habitName = habitName
      ..habitDescription = habitDescription;

    await habit.save();

    notifyListeners();
  }

  // ---------------------------------------------------------------
  // Habit alarm
  // ---------------------------------------------------------------

  Future<void> setHabitAlarm({
    required int index,
    required int hour,
    required int minute,
  }) async {
    final habit = habits[index];
    final key = habit.key;

    if (key is! int) return;

    await NotificationsService().cancelHabitAlarm(key);

    habit
      ..alarmHour = hour
      ..alarmMinute = minute;

    await habit.save();

    await NotificationsService().scheduleHabitAlarm(
      habitKey: key,
      habitName: habit.habitName,
      hour: hour,
      minute: minute,
    );

    notifyListeners();
  }

  Future<void> removeHabitAlarm({required int index}) async {
    final habit = habits[index];
    final key = habit.key;

    if (key is int) {
      await NotificationsService().cancelHabitAlarm(key);
    }

    habit
      ..alarmHour = null
      ..alarmMinute = null;

    await habit.save();

    notifyListeners();
  }

  // ---------------------------------------------------------------
  // Daily reset
  // ---------------------------------------------------------------

  Future<void> resetCompletedHabits() async {
    bool hasChanges = false;

    for (final habit in habits) {
      final monthlyReset =
      await _resetMonthlyProtectionIfNeeded(habit);

      final habitReset = await _resetHabitIfNeeded(
        habit,
        preserveProtectableStreak: true,
      );

      if (monthlyReset || habitReset) {
        hasChanges = true;
      }
    }

    if (hasChanges) {
      notifyListeners();
    }
  }
}
