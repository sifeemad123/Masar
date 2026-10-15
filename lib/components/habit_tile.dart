import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:masar/theme/AppColors.dart';

class HabitTile extends StatelessWidget {
  final String habitName;
  final String habitDescription;
  final bool habitComplete;
  final int streakCount;
  Function(bool?)? onChanged;
  Function(BuildContext)? deleteTask;
  Function(BuildContext)? updateTask;
  HabitTile({
    super.key,
    required this.habitName,
    required this.habitDescription,
    required this.habitComplete,
    required this.onChanged,
    required this.streakCount,
    required this.deleteTask,
    required this.updateTask,
  });

  Widget _card({Widget? child, Color? color}) {
    Color color2 = color ?? AppColors.surface;
    return Container(
      width: double.infinity,
      height: 90,
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
    final now = DateTime.now();
    return Padding(
      padding: const EdgeInsets.only(left: 25, right: 25, top: 25),
      child: Slidable(
        endActionPane: ActionPane(
          motion: StretchMotion(),
          children: [
            SlidableAction(
              onPressed: deleteTask,
              icon: Icons.delete_outline,
              backgroundColor: AppColors.danger,
              borderRadius: BorderRadius.circular(12),
            ),
            SlidableAction(
              onPressed: updateTask,
              icon: Icons.edit_rounded,
              backgroundColor: AppColors.accent,
              borderRadius: BorderRadius.circular(12),
            ),
          ],
        ),
        child: InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  backgroundColor: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                  contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
                  actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),

                  title: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.textPrimary.withOpacity(.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.info_outline_rounded,
                          color: AppColors.textPrimary,
                          size: 28,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Text(
                        "تفاصيل العادة",
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  content: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        _InfoSection(
                          title: "اسم العادة",
                          value: habitName,
                        ),

                        const SizedBox(height: 18),

                        _InfoSection(
                          title: "وصف العادة",
                          value: habitDescription,
                        ),

                        const SizedBox(height: 20),

                        // Streak
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 18,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            color: AppColors.textPrimary.withOpacity(.08),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.local_fire_department_rounded,
                                color: AppColors.flameActive,
                                size: 34,
                              ),

                              const SizedBox(height: 6),

                              Text(
                                streakCount == 0
                                    ? "لسه البداية"
                                    : "$streakCount يوم مستمر",
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                streakCount == 0
                                    ? "ابدأ النهارده وخليها عادة"
                                    : "استمر، أنت ماشي كويس",
                                style: TextStyle(
                                  color: AppColors.textPrimary.withOpacity(.65),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  actions: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("تمام", style: TextStyle(
                            color: AppColors.onAccent
                        ),),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
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
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: habitComplete
                      ? AppColors.surfaceAlt
                      : AppColors.surface,
                  border: Border.all(
                    color: AppColors.border,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Transform.scale(
                              scale: 1.3,
                              child: Checkbox(
                                value: habitComplete,
                                onChanged: onChanged,
                                activeColor: AppColors.overlay,
                                shape: CircleBorder(
                                  side: BorderSide(
                                    width: 1,
                                    color: AppColors.border,
                                  ),
                                ),
                              ),
                            ),
                            Column(
                              children: [
                                Text(
                                  habitName.length <= 15 ? habitName : "${habitName.substring(0, 15)}...",
                                  style: TextStyle(
                                    color: habitComplete
                                        ? AppColors.textPrimary
                                        : AppColors.textPrimary,
                                    fontWeight: FontWeight.w800,
                                    decoration: habitComplete
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                    decorationThickness: 3,
                                    decorationColor: AppColors.accent,
                                  ),
                                ),
                                Text(
                                  habitDescription.length <= 25 ? habitDescription : "${habitDescription.substring(0, 25)}...",
                                  style: TextStyle(
                                    color: habitComplete
                                        ? AppColors.textPrimary
                                        : AppColors.textPrimary,
                                    fontSize: 15,
                                    decoration: habitComplete
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                    decorationThickness: 3,
                                    decorationColor: AppColors.accent,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          spacing: 7,
                          children: [
                            Text(
                              "$streakCount",
                              style: TextStyle(
                                color: habitComplete
                                    ? AppColors.textPrimary
                                    : AppColors.textPrimary,
                                fontSize: 15,
                                decorationThickness: 3,
                                decorationColor: AppColors.accent,
                              ),
                            ),
                            Icon(Icons.water_drop, color: habitComplete ? AppColors.flameActive : AppColors.flameInactive ,size: 17,)
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _InfoSection extends StatelessWidget {
  final String title;
  final String value;

  const _InfoSection({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.textPrimary.withOpacity(.6),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          value.isEmpty ? "لا يوجد" : value,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}