import 'package:flutter/material.dart';
import 'package:masar/Screens/notes_screen.dart';
import 'package:masar/components/lesson_tile.dart';
import 'package:masar/models/lesson_model.dart';
import 'package:masar/providers/lessons_provider.dart';
import 'package:provider/provider.dart';

import '../components/button.dart';
import '../components/dialogs.dart';
import '../theme/AppColors.dart';

class SubjectDetails extends StatefulWidget {
  final String subjectName;
  final String subjectDescription;
  final int subjectId;
  final String? teacherName;
  const SubjectDetails({
    super.key,
    required this.subjectName,
    required this.subjectDescription,
    required this.subjectId,
    this.teacherName,
  });

  @override
  State<SubjectDetails> createState() => _SubjectDetailsState();
}

class _SubjectDetailsState extends State<SubjectDetails> {
  void _createNewLesson() {
    final lessonNameController = TextEditingController();
    final lessonDescriptionController = TextEditingController();
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
                        // =========================
                        // Header
                        // =========================
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "درس جديد",
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
                              "اسم الدرس",
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),

                        TextFormField(
                          controller: lessonNameController,
                          style: TextStyle(color: AppColors.textPrimary),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "يرجى إدخال اسم الدرس";
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
                              "وصف الدرس",
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),
                        TextFormField(
                          controller: lessonDescriptionController,
                          style: TextStyle(color: AppColors.textPrimary),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "يرجى إدخال وصف الدرس";
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
                        const SizedBox(height: 20),
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

                            Provider.of<LessonsProvider>(
                              context,
                              listen: false,
                            ).createLesson(
                              lessonName: lessonNameController.text.trim(),
                              lessonDescription: lessonDescriptionController
                                  .text
                                  .trim(),
                              subjectId: widget.subjectId,
                            );
                            Navigator.pop(context);
                            Dialogs.success(
                              context: context,
                              message: "تمت إضافة الدرس بنجاح",
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

  void _editLesson(LessonModel lesson) {
    final lessonNameController = TextEditingController(text: lesson.lessonName);
    final lessonDescriptionController = TextEditingController(
      text: lesson.lessonDescription,
    );
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
                        // =========================
                        // Header
                        // =========================
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "تعديل درس ${lesson.lessonName}",
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
                              "اسم الدرس",
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),

                        TextFormField(
                          controller: lessonNameController,
                          style: TextStyle(color: AppColors.textPrimary),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "يرجى إدخال اسم الدرس";
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
                              "وصف الدرس",
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),
                        TextFormField(
                          controller: lessonDescriptionController,
                          style: TextStyle(color: AppColors.textPrimary),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "يرجى إدخال وصف الدرس";
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
                        const SizedBox(height: 20),
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

                            Provider.of<LessonsProvider>(
                              context,
                              listen: false,
                            ).editLesson(
                              lesson: lesson,
                              lessonName: lessonNameController.text.trim(),
                              lessonDescription: lessonDescriptionController
                                  .text
                                  .trim(),
                            );
                            Navigator.pop(context);
                            Dialogs.success(
                              context: context,
                              message: "تمت تعديل الدرس بنجاح",
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
    required LessonModel lesson,
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
                  padding: const EdgeInsets.symmetric(vertical: 20),
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
                        Provider.of<LessonsProvider>(
                          context,
                          listen: false,
                        ).deleteLesson(lesson: lesson, context: context);
                        Dialogs.success(
                          context: context,
                          message: "تم حذف الدرس بنجاح",
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.overlay,
                      ),
                      child: Text(
                        "تأكيد",
                        style: TextStyle(color: AppColors.textPrimary),
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
                        style: TextStyle(color: AppColors.textPrimary),
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
    final lessons = Provider.of<LessonsProvider>(
      context,
    ).lessons.where((lesson) => lesson.subjectId == widget.subjectId).toList();

    final lessonsDone = lessons
        .where((lesson) => lesson.lessonCompleted)
        .length;

    final lessonsNotDone = lessons
        .where((lesson) => !lesson.lessonCompleted)
        .length;

    final progress = lessons.isEmpty
        ? 0.0
        : lessonsDone / lessons.length;
    String teacher = widget.teacherName!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "تفاصيل المادة",
          style: TextStyle(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Column(
                    spacing: 20,
                    children: [
                      Row(
                        spacing: 20,
                        children: [
                          Icon(
                            Icons.menu_book_outlined,
                            color: AppColors.accentLight,
                            size: 35,
                          ),
              
                          Expanded(
                            child: Hero(
                              tag: "subject-name-${widget.subjectName}",
                              child: Material(
                                color: Colors.transparent,
                                child: Text(
                                  widget.subjectName,
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
                        tag: "subject-desc-${widget.subjectName}",
                        child: Material(
                          color: Colors.transparent,
                          child: Text(
                            widget.subjectDescription,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: AppColors.textSecondary), textAlign: TextAlign.center,maxLines: 5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (widget.teacherName != null &&
                      widget.teacherName!.trim().isNotEmpty)
                    Column(
                      spacing: 20,
                      children: [
                        Row(
                          spacing: 20,
                          children: [
                            Icon(
                              Icons.person_2_outlined,
                              color: AppColors.accentLight,
                              size: 35,
                            ),
                            Text(
                              "المدرس",
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        Hero(
                          tag: "teacherName-${widget.subjectId}",
                          child: Material(
                            color: Colors.transparent,
                            child: Text(
                              teacher,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                              ),textAlign: TextAlign.center,maxLines: 5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.border,
                        width: 2
                      )
                    ),
                    padding: EdgeInsets.all(20),
                    child: Column(
                      spacing: 25,
                      children: [
                        Row(
                          spacing: 10,
                          children: [
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(5)
                              ),
                                child: Icon(Icons.gps_not_fixed_outlined, color: AppColors.accentDark,)),
                            Column(
                              spacing: 5,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("تقدم الدروس", style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold
                                ),),Text("تابع الدروس الخلصانه و المتبقيه", style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 15
                                ),),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              spacing: 10,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  spacing: 10,
                                  children: [
                                    Container(
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                            color: AppColors.success,
                                            borderRadius: BorderRadius.circular(100)
                                        ),
                                        child: Icon(Icons.done, color: AppColors.onSuccess,)),
                                    Text(
                                      "خلصت : $lessonsDone",
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  spacing: 10,
                                  children: [
                                    Container(
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                            color: AppColors.danger,
                                            borderRadius: BorderRadius.circular(100)
                                        ),
                                        child: Icon(Icons.close, color: AppColors.onDanger,)),
                                    Text(
                                      "باقي : $lessonsNotDone",
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 100,
                                  height: 100,
                                  child: CircularProgressIndicator(
                                    value: progress,
                                    strokeWidth: 8,
                                    backgroundColor: AppColors.surface,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.accent
                                    ),
                                  ),
                                ),
                                Text(
                                  "${(progress * 100).round()}%",
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (lessons.isNotEmpty && lessonsNotDone == 0)
                          Text(
                            "عاش خلصت كل الدروس اللي عليك",
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        if(lessons.isEmpty)
                          Column(
                            spacing: 10,
                            children: [
                              Text(
                                "المادة لسه فاضية",
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "ابدأ بإضافة أول درس ليك في المادة",
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "الدروس",
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${lessons.length}",
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  if (lessons.isEmpty)
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.menu_book_outlined,
                              size: 70,
                              color: AppColors.textSecondary,
                            ),
              
                            const SizedBox(height: 15),
              
                            Text(
                              "مفيش دروس",
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
              
                            const SizedBox(height: 8),
              
                            Text(
                              "ابدأ بأضافة اول درس ليك في الماده",
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),

                  if (lessons.isNotEmpty)
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: lessons.length,
                        itemBuilder: (context, index) {
                          final lesson = lessons[index];
                          return LessonTile(
                            lessonName: lesson.lessonName,
                            lessonDescription: lesson.lessonDescription,
                            lessonCompleted: lesson.lessonCompleted,
                            onChanged: (_) {
                              if (!lesson.lessonCompleted) {
                                Provider.of<LessonsProvider>(
                                  context,
                                  listen: false,
                                ).lessonCompleted(lesson: lesson);
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      backgroundColor: AppColors.surface,
                                      icon: Icon(
                                        Icons.check_circle_outline_rounded,
                                        color: AppColors.accentLight,
                                        size: 40,
                                      ),
                                      title: Text(
                                        "عاش",
                                        style: TextStyle(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 25,
                                        ),
                                      ),
                                      content: Text(
                                        "خلصت درس ${lesson.lessonName} بنجاح\nاستمر كده، خطوة كمان وأنت أقرب لهدفك",
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      contentPadding:
                                          EdgeInsetsGeometry.symmetric(
                                            horizontal: 50,
                                            vertical: 20,
                                          ),
                                    );
                                  },
                                );
                              }
                            },
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => NotesScreen(
                                    lessonName: lesson.lessonName,
                                    lessonDescription: lesson.lessonDescription,
                                    lessonId: lesson.id,
                                  ),
                                ),
                              );
                            },
                            lessonId: lesson.id,
                            onDelete: (_) {
                              confirmation(
                                context: context,
                                message:
                                    "متأكد عاوز تمسح درس ${lesson.lessonName}",
                                lesson: lesson,
                              );
                            },
                            onEdit: (_) {
                              _editLesson(lesson);
                            },
                          );
                        },
                      ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: SizedBox(
        width: 70,
        height: 70,
        child: FloatingActionButton(
          onPressed: () {
            _createNewLesson();
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
