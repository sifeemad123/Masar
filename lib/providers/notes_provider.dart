import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:masar/models/notes_model.dart';

class NotesProvider extends ChangeNotifier {
  static Box<NotesModel> notesBox() => Hive.box("notesBox");
  List<NotesModel> get notes => notesBox().values.toList();

  void createNote({
    required int lessonId,
    required String noteName,
    required String noteDescription,
    required String noteContent,
    required Color noteColor,
  }) {
    final note = NotesModel()
        ..lessonId = lessonId
        ..noteColor = noteColor
        ..noteContent = noteContent
        ..noteName = noteName
        ..noteDescription = noteDescription;
    notesBox().add(note);
    notifyListeners();
  }
  void deleteNote({required NotesModel note}){
    note.delete();
    notifyListeners();
  }
  void editNote({required NotesModel note, required String noteName, required String noteDescription, required String noteContent, required Color noteColor,}){
    note.noteName = noteName;
    note.noteDescription = noteDescription;
    note.noteContent = noteContent;
    note.noteColor = noteColor;
    note.save();
    notifyListeners();
  }
}
