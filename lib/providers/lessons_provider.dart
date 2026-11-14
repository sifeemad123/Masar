import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:masar/models/lesson_model.dart';
import 'package:masar/providers/notes_provider.dart';
import 'package:provider/provider.dart';

class LessonsProvider extends ChangeNotifier {
  static Box<LessonModel> lessonsBox() => Hive.box<LessonModel>("lessonsBox");

  List<LessonModel> get lessons => lessonsBox().values.toList();

  int generateLessonId() {
    final lessons = lessonsBox().values;

    if (lessons.isEmpty) {
      return 1;
    }

    return lessons.map((lesson) => lesson.id).reduce((a, b) => a > b ? a : b) +
        1;
  }

  void createLesson({
    required String lessonName,
    required String lessonDescription,
    required int subjectId,
  }) {
    final lesson = LessonModel()
      ..lessonCompleted = false
      ..lessonDescription = lessonDescription
      ..lessonName = lessonName
      ..subjectId = subjectId
      ..id = generateLessonId();
    lessonsBox().add(lesson);
    notifyListeners();
  }

  /// Kept for backwards compatibility: marks the lesson as done.
  void lessonCompleted({required LessonModel lesson}) {
    lesson.lessonCompleted = true;
    lesson.save();
    notifyListeners();
  }

  /// Done <-> not done (used by the new lesson tile).
  void toggleLesson({required LessonModel lesson}) {
    lesson.lessonCompleted = !lesson.lessonCompleted;
    lesson.save();
    notifyListeners();
  }

  void deleteLesson({
    required LessonModel lesson,
    required BuildContext context,
  }) {
    final notesProvider = Provider.of<NotesProvider>(context, listen: false);
    final notes = notesProvider.notes
        .where((note) => note.lessonId == lesson.id)
        .toList();
    for (final note in notes) {
      note.delete();
    }
    lesson.delete();
    notifyListeners();
  }

  void editLesson({
    required LessonModel lesson,
    required String lessonName,
    required String lessonDescription,
  }) {
    lesson.lessonName = lessonName;
    lesson.lessonDescription = lessonDescription;
    lesson.save();
    notifyListeners();
  }
}