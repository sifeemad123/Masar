
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:masar/models/habits_model.dart';
import 'package:masar/services/notifications_service.dart';

class HabitsProvider extends ChangeNotifier {
  static Box<HabitsModel> habitsBox() =>
      Hive.box<HabitsModel>("habitsBox");

  List<HabitsModel> get habits => habitsBox().values.toList();

  void addHabit({
    required String habitName,
    required String habitDescription,
  }) {
    final habit = HabitsModel()
      ..habitName = habitName
      ..habitDescription = habitDescription
      ..habitCompleted = false
      ..streakCount = 0
      ..lastCompletedDate = null
      ..alarmHour = null
      ..alarmMinute = null;

    habitsBox().add(habit);
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

  void habitCompleted({required int index}) {
    final habit = habits[index];

    if (habit.habitCompleted) return;

    habit.habitCompleted = true;
    habit.streakCount += 1;
    habit.lastCompletedDate = DateTime.now();

    habit.save();
    notifyListeners();
  }

  void editHabit({
    required String habitName,
    required String habitDescription,
    required int index,
  }) {
    final habit = habits[index];

    habit.habitName = habitName;
    habit.habitDescription = habitDescription;

    habit.save();
    notifyListeners();
  }

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

  void resetCompletedHabits() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    bool hasChanges = false;

    for (final habit in habits) {
      final lastCompleted = habit.lastCompletedDate;

      if (lastCompleted == null) continue;

      final lastDay = DateTime(
        lastCompleted.year,
        lastCompleted.month,
        lastCompleted.day,
      );

      final daysPassed = today.difference(lastDay).inDays;

      if (daysPassed >= 1 && habit.habitCompleted) {
        habit.habitCompleted = false;
        habit.save();
        hasChanges = true;
      }

      if (daysPassed >= 2 && habit.streakCount != 0) {
        habit.streakCount = 0;
        habit.save();
        hasChanges = true;
      }
    }

    if (hasChanges) notifyListeners();
  }
}
