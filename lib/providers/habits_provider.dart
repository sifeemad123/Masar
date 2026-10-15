import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:masar/models/habits_model.dart';

class HabitsProvider extends ChangeNotifier {
  static Box<HabitsModel> habitsBox() => Hive.box<HabitsModel>("habitsBox");
  List<HabitsModel> get habits => habitsBox().values.toList();

  void addHabit({required String habitName, required String habitDescription}) {
    final habit = HabitsModel()
      ..habitName = habitName
      ..habitDescription = habitDescription
      ..habitCompleted = false
      ..streakCount = 0
      ..lastCompletedDate = null;
    habitsBox().add(habit);
    notifyListeners();
  }

  void deleteHabit({required int index}){
    habits[index].delete();
    notifyListeners();
  }

  void habitCompleted({required int index}){
    final habit = habits[index];
    if(habit.habitCompleted){
      return;
    }
    habit.habitCompleted = true;
    habit.streakCount += 1;
    habit.lastCompletedDate = DateTime.now();
    habit.save();
    notifyListeners();
  }

  void editHabit({required String habitName, required String habitDescription, required int index}){
    habits[index].habitName = habitName;
    habits[index].habitDescription = habitDescription;
    habits[index].save();
    notifyListeners();
  }

  void resetCompletedHabits() {
    final now = DateTime.now();
    bool hasChanges = false;

    for (final habit in habits) {
      final lastCompleted = habit.lastCompletedDate;

      if (lastCompleted == null) continue;

      final today = DateTime(now.year, now.month, now.day);

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

    if (hasChanges) {
      notifyListeners();
    }
  }

}
