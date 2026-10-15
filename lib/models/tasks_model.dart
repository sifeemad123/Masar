import 'package:hive/hive.dart';
part 'tasks_model.g.dart';

@HiveType(typeId: 0)
class TasksModel extends HiveObject {
  @HiveField(0)
  late String taskName;
  @HiveField(1)
  late bool completed;
  @HiveField(2)
  late DateTime taskDate;
}