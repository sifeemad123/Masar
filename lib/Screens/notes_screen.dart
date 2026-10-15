import 'package:flutter/material.dart';
import 'package:masar/components/note_card.dart';
import 'package:masar/models/notes_model.dart';
import 'package:masar/providers/notes_provider.dart';
import 'package:provider/provider.dart';

import '../components/button.dart';
import '../components/dialogs.dart';
import '../theme/AppColors.dart';


class NotesScreen extends StatefulWidget {
  final String lessonName;
  final String lessonDescription;
  final int lessonId;
  const NotesScreen({super.key, required this.lessonName, required this.lessonDescription, required this.lessonId});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {



  void _createNewNote() {
    final noteNameController = TextEditingController();
    final noteDescriptionController = TextEditingController();
    final noteContentController = TextEditingController();
    final List<Color> noteColors = [
      Color(0xFFF1E9DF), // Paper
      Color(0xFFE4D5C3), // Sand
      Color(0xFFD2BFA8), // Beige
      Color(0xFFFFF3B0), // Lemon
      Color(0xFFFFD166), // Sunflower
      Color(0xFFFFB4A2), // Peach
      Color(0xFFE76F51), // Coral
      Color(0xFFF4A261), // Orange
      Color(0xFF83C5BE), // Seafoam
      Color(0xFF2A9D8F), // Teal
      Color(0xFF00A6A6), // Aqua
      Color(0xFF48CAE4), // Sky
      Color(0xFF5E9FB3), // Ocean Blue
      Color(0xFF9B5DE5), // Purple
      Color(0xFFE85D75),
      Color(0xFFD8A56A), // Amber
      Color(0xFFC98B72), // Terracotta
      Color(0xFFB85C50), // Brick
      Color(0xFFA3AD91), // Sage
      Color(0xFF7F9670), // Olive
      Color(0xFF8D9EAA), // Dusty Blue
      Color(0xFF9A8797), // Mauve
      Color(0xFF443C35), // Leather
      Color(0xFF353331), // Charcoal// Rose
    ];
    Color selectedColor = Color(0xFFF1E9DF);
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(30, 10, 30, 30),
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "نوت جديدة",
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 25,
                                fontWeight: FontWeight.w800,
                              ),
                            ),

                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.accent,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: Icon(
                                  Icons.close,
                                  color: AppColors.onAccent,
                                  size: 25,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        Row(
                          children: [
                            Text(
                              "عنوان النوت",
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),

                        TextFormField(
                          controller: noteNameController,
                          style: TextStyle(color: AppColors.textPrimary),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "يرجى إدخال عنوان النوت";
                            }

                            return null;
                          },
                          decoration: InputDecoration(
                            fillColor: AppColors.overlay,
                            filled: true,

                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppColors.border),
                            ),

                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppColors.border,
                                width: 2,
                              ),
                            ),

                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppColors.danger),
                            ),

                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppColors.danger,
                                width: 2,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),

                        Row(
                          children: [
                            Text(
                              "وصف النوت",
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),
                        TextFormField(
                          controller: noteDescriptionController,
                          style: TextStyle(color: AppColors.textPrimary),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "يرجى إدخال وصف النوت";
                            }

                            return null;
                          },
                          decoration: InputDecoration(
                            fillColor: AppColors.overlay,
                            filled: true,

                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppColors.border),
                            ),

                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppColors.border,
                                width: 2,
                              ),
                            ),

                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppColors.danger),
                            ),

                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppColors.danger,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            Text(
                              "محتوي النوت",
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: noteContentController,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.newline,

                          // Behaves like a textarea
                          minLines: 7,
                          maxLines: null,

                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 17,
                            height: 1.7,
                          ),

                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'مينفعش تسيب محتوي النوت فاضي';
                            }
                            return null;
                          },

                          decoration: InputDecoration(
                            hintText: 'اكتب محتوي النوت هنا',
                            hintStyle: const TextStyle(
                              color: AppColors.textMuted,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),

                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.border,
                                width: 2,
                              ),
                            ),

                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.danger),
                            ),

                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.danger,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 50,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: noteColors.length,
                            itemBuilder: (context, index) {
                              final color = noteColors[index];
                              final isSelected = color == selectedColor;

                              return GestureDetector(
                                onTap: () {
                                  setModalState(() {
                                    selectedColor = color;
                                  });
                                },
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  margin: const EdgeInsets.symmetric(horizontal: 6),
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.black
                                          : Colors.grey.shade300,
                                      width: isSelected ? 3 : 1,
                                    ),
                                  ),
                                  child: isSelected
                                      ? const Icon(
                                    Icons.check,
                                    size: 20,
                                  )
                                      : null,
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 30,),
                        Button(
                          text: "حفظ",
                          onPressed: () {
                            if (!formKey.currentState!.validate()) {
                              Dialogs.failed(
                                context: context,
                                message: "يرجى إدخال جميع البيانات المطلوبة",
                              );
                              return;
                            }
                            Provider.of<NotesProvider>(
                              context,
                              listen: false,
                            ).createNote(
                              noteName: noteNameController.text.trim(),
                              noteDescription: noteDescriptionController.text
                                  .trim(),
                              noteColor: selectedColor,
                              noteContent: noteContentController.text.trim(), lessonId: widget.lessonId
                            );
                            // Close Bottom Sheet
                            Navigator.pop(context);
                            Dialogs.success(
                              context: context,
                              message: "تمت إضافة النوت بنجاح",
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
  void _editNote(NotesModel note) {
    final noteNameController = TextEditingController(text: note.noteName);
    final noteDescriptionController = TextEditingController(text: note.noteDescription);
    final noteContentController = TextEditingController(text: note.noteContent);
    final List<Color> noteColors = [
      Color(0xFFF1E9DF), // Paper
      Color(0xFFE4D5C3), // Sand
      Color(0xFFD2BFA8), // Beige
      Color(0xFFFFF3B0), // Lemon
      Color(0xFFFFD166), // Sunflower
      Color(0xFFFFB4A2), // Peach
      Color(0xFFE76F51), // Coral
      Color(0xFFF4A261), // Orange
      Color(0xFF83C5BE), // Seafoam
      Color(0xFF2A9D8F), // Teal
      Color(0xFF00A6A6), // Aqua
      Color(0xFF48CAE4), // Sky
      Color(0xFF5E9FB3), // Ocean Blue
      Color(0xFF9B5DE5), // Purple
      Color(0xFFE85D75),
      Color(0xFFD8A56A), // Amber
      Color(0xFFC98B72), // Terracotta
      Color(0xFFB85C50), // Brick
      Color(0xFFA3AD91), // Sage
      Color(0xFF7F9670), // Olive
      Color(0xFF8D9EAA), // Dusty Blue
      Color(0xFF9A8797), // Mauve
      Color(0xFF443C35), // Leather
      Color(0xFF353331), // Charcoal// Rose
    ];
    Color selectedColor = note.noteColor;
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(30, 10, 30, 30),
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "تعديل الملاحظه",
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 25,
                                fontWeight: FontWeight.w800,
                              ),
                            ),

                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.accent,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: Icon(
                                  Icons.close,
                                  color: AppColors.onAccent,
                                  size: 25,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        Row(
                          children: [
                            Text(
                              "عنوان النوت",
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),

                        TextFormField(
                          controller: noteNameController,
                          style: TextStyle(color: AppColors.textPrimary),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "يرجى إدخال عنوان النوت";
                            }

                            return null;
                          },
                          decoration: InputDecoration(
                            fillColor: AppColors.overlay,
                            filled: true,

                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppColors.border),
                            ),

                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppColors.border,
                                width: 2,
                              ),
                            ),

                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppColors.danger),
                            ),

                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppColors.danger,
                                width: 2,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),

                        Row(
                          children: [
                            Text(
                              "وصف النوت",
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),
                        TextFormField(
                          controller: noteDescriptionController,
                          style: TextStyle(color: AppColors.textPrimary),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "يرجى إدخال وصف النوت";
                            }

                            return null;
                          },
                          decoration: InputDecoration(
                            fillColor: AppColors.overlay,
                            filled: true,

                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppColors.border),
                            ),

                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppColors.border,
                                width: 2,
                              ),
                            ),

                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppColors.danger),
                            ),

                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppColors.danger,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            Text(
                              "محتوي النوت",
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: noteContentController,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.newline,

                          // Behaves like a textarea
                          minLines: 7,
                          maxLines: null,

                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 17,
                            height: 1.7,
                          ),

                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'مينفعش تسيب محتوي النوت فاضي';
                            }
                            return null;
                          },

                          decoration: InputDecoration(
                            hintText: 'اكتب محتوي النوت هنا',
                            hintStyle: const TextStyle(
                              color: AppColors.textMuted,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),

                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.border,
                                width: 2,
                              ),
                            ),

                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.danger),
                            ),

                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.danger,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 50,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: noteColors.length,
                            itemBuilder: (context, index) {
                              final color = noteColors[index];
                              final isSelected = color == selectedColor;

                              return GestureDetector(
                                onTap: () {
                                  setModalState(() {
                                    selectedColor = color;
                                  });
                                },
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  margin: const EdgeInsets.symmetric(horizontal: 6),
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.black
                                          : Colors.grey.shade300,
                                      width: isSelected ? 3 : 1,
                                    ),
                                  ),
                                  child: isSelected
                                      ? const Icon(
                                    Icons.check,
                                    size: 20,
                                  )
                                      : null,
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 30,),
                        Button(
                          text: "حفظ",
                          onPressed: () {
                            if (!formKey.currentState!.validate()) {
                              Dialogs.failed(
                                context: context,
                                message: "يرجى إدخال جميع البيانات المطلوبة",
                              );
                              return;
                            }
                            Provider.of<NotesProvider>(
                              context,
                              listen: false,
                            ).editNote(
                                noteName: noteNameController.text.trim(),
                                noteDescription: noteDescriptionController.text
                                    .trim(),
                                noteColor: selectedColor,
                                noteContent: noteContentController.text.trim(),
                                note: note
                            );
                            // Close Bottom Sheet
                            Navigator.pop(context);
                            Dialogs.success(
                              context: context,
                              message: "تمت تعديل الملاحظه بنجاح",
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
  static void confirmation({
    required BuildContext context,
    required String message,
    required NotesModel note
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 350,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(15),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  color: AppColors.overlay,
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                  ),
                  child: Icon(
                    Icons.check,
                    size: 50,
                    color: AppColors.textPrimary,
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    " تأكيد ",
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    message,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 5),

                Row(
                  spacing: 20,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Provider.of<NotesProvider>(context , listen: false).deleteNote(note: note);
                        Dialogs.success(context: context, message: "تم حذف النوت بنجاح");
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.overlay,
                      ),
                      child: Text(
                        "تأكيد",
                        style: TextStyle(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.overlay,
                      ),
                      child: Text(
                        "إغلاق",
                        style: TextStyle(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    final notes = Provider.of<NotesProvider>(context).notes.where((note){
      return note.lessonId == widget.lessonId;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "تفاصيل الدرس",
          style: TextStyle(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
      ),

      body: SafeArea(child: Directionality(textDirection: TextDirection.rtl, child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                spacing: 20,
                children: [
                  Row(
                    spacing: 20,
                    children: [
                      Icon(
                        Icons.sticky_note_2_rounded,
                        color: AppColors.accentLight,
                        size: 35,
                      ),

                        Expanded(
                          child: Hero(
                            tag: "lesson-name-${widget.lessonId}",
                            child: Material(
                              color: Colors.transparent,
                              child: Text(
                                widget.lessonName,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                                textAlign: TextAlign.right,maxLines: 5,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  Hero(
                    tag: "lesson-desc-${widget.lessonId}",
                    child: Material(
                      color: Colors.transparent,
                      child: Text(
                        widget.lessonDescription,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: AppColors.textSecondary),textAlign: TextAlign.center,maxLines: 5,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "الملاحظات",
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${notes.length}",
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            if (notes.isEmpty)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.sticky_note_2_rounded,
                        size: 70,
                        color: AppColors.textSecondary,
                      ),

                      const SizedBox(height: 15),

                      Text(
                        "مفيش اي نوتس",
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        "ابدأ بأضافة اول نوت ليك في الدرس ده",
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),

            if (notes.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return NoteCard(noteName: note.noteName, noteDescription: note.noteDescription, noteContnet: note.noteContent, noteColor: note.noteColor, onDelete: (_) { confirmation(context: context, message: "متأكد عاوز تمسح الملاحظه دي؟", note: note); }, onEdit: (_) { _editNote(note); },);
                  },
                ),
          ],
        ),
      ))),

      floatingActionButton: SizedBox(
        width: 70,
        height: 70,
        child: FloatingActionButton(
          onPressed: () {
            _createNewNote();
          },
          backgroundColor: AppColors.accent,
          child: const Icon(Icons.add, color: AppColors.onAccent),
        ),
      ),

      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,

      floatingActionButtonLocation: CustomFabLocation(),

    );
  }
}


class CustomFabLocation extends FloatingActionButtonLocation {
  const CustomFabLocation();

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry geometry) {
    return Offset(30, geometry.scaffoldSize.height - 315);
  }
}
