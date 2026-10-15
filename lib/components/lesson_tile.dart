import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:masar/providers/notes_provider.dart';
import 'package:masar/theme/AppColors.dart';
import 'package:provider/provider.dart';

class LessonTile extends StatelessWidget {
  final String lessonName;
  final String lessonDescription;
  final bool lessonCompleted;
  final void Function(bool?) onChanged;
  final void Function() onTap;
  final int lessonId;
  final void Function(BuildContext) onDelete;
  final void Function(BuildContext) onEdit;
  const LessonTile({
    super.key,
    required this.lessonName,
    required this.lessonDescription,
    required this.lessonCompleted,
    required this.onChanged,
    required this.onTap,
    required this.lessonId,
    required this.onDelete,
    required this.onEdit,
  });

  Widget _card({Widget? child, Color? color}) {
    Color color2 = color ?? AppColors.surface;
    return Container(
      width: double.infinity,
      height: 100,
      decoration: BoxDecoration(
        color: color2,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notes = Provider.of<NotesProvider>(context).notes.where((note) {
      return note.lessonId == lessonId;
    }).toList();
    String truncateText(String text, int maxLength) {
      if (text.length <= maxLength) return text;
      return '${text.substring(0, maxLength)}...';
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Slidable(
        endActionPane: ActionPane(
          motion: StretchMotion(),
          children: [
            SlidableAction(
              onPressed: onDelete,
              icon: Icons.delete_outline,
              backgroundColor: AppColors.danger,
              borderRadius: BorderRadius.circular(5),
            ),
            SlidableAction(
              onPressed: onEdit,
              icon: Icons.edit_rounded,
              backgroundColor: AppColors.accentDark,
              borderRadius: BorderRadius.circular(5),
            ),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          child: Stack(
            children: [
              Transform.translate(
                offset: Offset(-3, -5),
                child: Transform.rotate(
                  angle: -0.030,
                  child: _card(color: AppColors.surfaceAlt),
                ),
              ),
              Transform.translate(
                offset: Offset(5, 0),
                child: Transform.rotate(
                  angle: 0.030,
                  child: _card(color: AppColors.surfaceAlt),
                ),
              ),
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Transform.scale(
                          scale: 1.2,
                          child: Checkbox(
                            value: lessonCompleted,
                            onChanged: onChanged,
                            activeColor: AppColors.overlay,
                            shape: CircleBorder(
                              side: BorderSide(width: 1, color: AppColors.border),
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Hero(
                              tag: "lesson-name-$lessonId",
                              child: Material(
                                color: Colors.transparent,
                                child: Text(
                                  truncateText(lessonName, 10),
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),

                            Hero(
                              tag: "lesson-desc-$lessonId",
                              child: Material(
                                color: Colors.transparent,
                                child: Text(
                                  truncateText(lessonDescription, 15),
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    Row(
                      spacing: 10,
                      children: [
                        if (notes.isEmpty)
                          Text(
                            "لا توجد ملاحظات",
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        if (notes.length == 1)
                          Text(
                            "ملاحظه واحده",
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        if (notes.length == 2)
                          Text(
                            "ملاحظتين",
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        if (notes.length >= 3)
                          Text(
                            "${notes.length} ملاحظات",
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        Icon(
                          Icons.arrow_forward_ios_outlined,
                          color: AppColors.textPrimary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ]
          ),
        ),
      ),
    );
  }
}
