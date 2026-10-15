import 'dart:ui';

import 'package:hive/hive.dart';

part 'notes_model.g.dart';

@HiveType(typeId: 4)
class NotesModel extends HiveObject {
  @HiveField(0)
  late int lessonId;

  @HiveField(1)
  late String noteName;

  @HiveField(2)
  late String noteDescription;

  @HiveField(3)
  late String noteContent;

  @HiveField(4)
  late int noteColorValue;

  Color get noteColor => Color(noteColorValue);

  set noteColor(Color color) {
    noteColorValue = color.toARGB32();
  }
}