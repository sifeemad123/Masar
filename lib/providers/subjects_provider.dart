import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:masar/models/lesson_model.dart';
import 'package:masar/models/notes_model.dart';
import 'package:masar/models/subjects_model.dart';

class SubjectsProvider extends ChangeNotifier {
  static Box<SubjectsModel> subjectsBox() =>
      Hive.box<SubjectsModel>("subjectsBox");

  List<SubjectsModel> get subjects => subjectsBox().values.toList();

  int generateSubjectId() {
    final subjects = subjectsBox().values;

    if (subjects.isEmpty) {
      return 1;
    }

    return subjects
        .map((subject) => subject.id)
        .reduce((a, b) => a > b ? a : b) +
        1;
  }

  void createSubject({
    required String subjectName,
    required String subjectDescription,
    String? teacherName,
  }) {
    final subject = SubjectsModel()
      ..subjectName = subjectName
      ..subjectDescription = subjectDescription
      ..teacherName = teacherName
      ..id = generateSubjectId();
    subjectsBox().add(subject);
    notifyListeners();
  }

  /// Deletes the subject, its lessons and every note inside those lessons.
  void deleteSubject({required SubjectsModel subject}) {
    final lessons = Hive.box<LessonModel>("lessonsBox")
        .values
        .where((lesson) => lesson.subjectId == subject.id)
        .toList();
    final lessonIds = lessons.map((l) => l.id).toSet();

    final notes = Hive.box<NotesModel>("notesBox")
        .values
        .where((note) => lessonIds.contains(note.lessonId))
        .toList();

    for (final note in notes) {
      note.delete();
    }
    for (final lesson in lessons) {
      lesson.delete();
    }
    subject.delete();
    notifyListeners();
  }

  void editSubject({
    required String subjectName,
    required String subjectDescription,
    required SubjectsModel subject,
    String? teacherName,
  }) {
    subject.subjectName = subjectName;
    subject.subjectDescription = subjectDescription;
    subject.teacherName = teacherName;
    subject.save();
    notifyListeners();
  }
}