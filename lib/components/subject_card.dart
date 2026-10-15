import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:masar/Screens/subject_details.dart';
import 'package:masar/theme/AppColors.dart';

class SubjectCard extends StatelessWidget {
  final String subjectName;
  final String subjectDescription;
  final int subjectId;
  void Function(BuildContext)? deleteFunction;
  void Function(BuildContext)? editFunction;
  final String? teacherName;
  SubjectCard({
    super.key,
    required this.subjectName,
    required this.subjectDescription,
    required this.deleteFunction,
    required this.editFunction,
    required this.subjectId,
    this.teacherName
  });


  Widget _card({Widget? child, Color? color}) {
    Color color2 = color ?? AppColors.surface;
    return Container(
      width: double.infinity,
      height: 110,
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
    final teacher = teacherName;
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Slidable(
        endActionPane: ActionPane(motion: StretchMotion(), children: [
          SlidableAction(onPressed: deleteFunction, icon: Icons.delete_outline,backgroundColor: AppColors.danger, borderRadius: BorderRadius.circular(10),),
          SlidableAction(onPressed: editFunction, icon: Icons.edit_rounded,backgroundColor: AppColors.accent, borderRadius: BorderRadius.circular(10))
        ]),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SubjectDetails(
                subjectName: subjectName,
                subjectDescription: subjectDescription,
                subjectId: subjectId,
                teacherName:teacherName,
              )),
            );
          },
          child: Stack(
            children: [
              Transform.translate(
                offset: Offset(-3, -2),
                child: Transform.rotate(
                  angle: -0.030,
                  child: _card(color: AppColors.surfaceAlt),
                ),
              ),
              Transform.translate(
                offset: Offset(5, -5),
                child: Transform.rotate(
                  angle: 0.030,
                  child: _card(color: AppColors.surfaceAlt),
                ),
              ),
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppColors.border,
                        width: 1
                    )
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      spacing: 10,
                      children: [
                        Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                color: AppColors.accent,
                                borderRadius: BorderRadius.circular(5)
                            ) , child: Icon(Icons.menu_book_outlined, color: AppColors.onAccent, size: 30,)),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          spacing: 5,
                          children: [
                            Hero(
                              tag: "subject-name-$subjectName",
                              child: Material(
                                color: Colors.transparent,
                                child: Text(
                                    subjectName.length <= 15 ? subjectName : "${subjectName.substring(0, 15)}...",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ),

                            Hero(
                              tag: "subject-desc-$subjectName",
                              child: Material(
                                color: Colors.transparent,
                                child: Text(
                                    subjectDescription.length <= 25 ? subjectDescription : "${subjectDescription.substring(0, 25)}...",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
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
                      children: [
                        Hero(
                          tag: "teacherName-$subjectId",
                          child: Material(
                            color: Colors.transparent,
                            child: Text(
                              teacher == null
                                  ? "لا يوجد مدرس"
                                  : teacher.length <= 10
                                  ? teacher
                                  : "${teacher.substring(0, 10)}...",
                              style: TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_outlined,
                          color: AppColors.textPrimary,
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
