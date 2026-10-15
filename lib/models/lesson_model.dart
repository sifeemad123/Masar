import 'package:hive/hive.dart';

part 'lesson_model.g.dart';

@HiveType(typeId: 3)
class LessonModel extends HiveObject {
  @HiveField(0)
  late int id;
  @HiveField(1)
  late int subjectId;
  @HiveField(2)
  late String lessonName;
  @HiveField(3)
  late String lessonDescription;
  @HiveField(4)
  late bool lessonCompleted;
}