import 'package:hive/hive.dart';
part 'subjects_model.g.dart';

@HiveType(typeId: 2)
class SubjectsModel extends HiveObject {
  @HiveField(0)
  late String subjectName;
  @HiveField(1)
  late String subjectDescription;
  @HiveField(2)
  late String? teacherName;
  @HiveField(3)
  late int id;
}