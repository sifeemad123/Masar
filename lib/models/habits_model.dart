import 'package:hive/hive.dart';

part 'habits_model.g.dart';

@HiveType(typeId: 1)
class HabitsModel extends HiveObject {
  @HiveField(0)
  late String habitName;

  @HiveField(1)
  late String habitDescription;

  @HiveField(2)
  late bool habitCompleted;

  @HiveField(3)
  late int streakCount;

  @HiveField(4)
  late DateTime? lastCompletedDate;

  @HiveField(5)
  late int? alarmHour;

  @HiveField(6)
  late int? alarmMinute;

  @HiveField(7)
  int protectionUsesThisMonth = 0;

  @HiveField(8)
  String? protectionMonthKey;
}