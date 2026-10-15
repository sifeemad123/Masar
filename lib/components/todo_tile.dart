import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:masar/theme/AppColors.dart';

class TodoTile extends StatelessWidget {
  final String taskName;
  final bool value;
  final DateTime time;
  Function(bool?)? onChanged;
  Function(BuildContext)? deleteTask;
  Function(BuildContext)? updateTask;
  TodoTile({
    super.key,
    required this.taskName,
    required this.value,
    required this.onChanged,
    required this.time,
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
                          Icons.task_alt_rounded,
                          color: AppColors.textPrimary,
                          size: 28,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Text(
                        "تفاصيل التاسك",
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "اسم التاسك",
                        style: TextStyle(
                          color: AppColors.textPrimary.withOpacity(.6),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        taskName,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 20),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.textPrimary.withOpacity(.06),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              color: AppColors.textPrimary,
                              size: 26,
                            ),

                            const SizedBox(width: 12),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "وقت التاسك",
                                  style: TextStyle(
                                    color: AppColors.textPrimary.withOpacity(.6),
                                    fontSize: 12,
                                  ),
                                ),

                                const SizedBox(height: 3),

                                Text(
                                  TimeOfDay.fromDateTime(time).format(context),
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: value
                              ? Colors.green.withOpacity(.1)
                              : Colors.orange.withOpacity(.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              value
                                  ? Icons.check_circle_rounded
                                  : Icons.pending_rounded,
                              color: value
                                  ? Colors.green
                                  : Colors.orange,
                              size: 26,
                            ),

                            const SizedBox(width: 12),

                            Text(
                              value ? "خلصت التاسك " : "لسه مخلصتش",
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                  color: value
                      ? AppColors.surfaceAlt
                      : time.isAfter(now.add(const Duration(days: 1)))
                      ? AppColors.overlay
                      : AppColors.surface,
                  border: Border.all(
                    color: time.isBefore(DateTime(now.year, now.month, now.day))
                        ? AppColors.onDanger
                        : AppColors.border,
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
                        //Task name and the check box
                        Row(
                          children: [
                            Transform.scale(
                              scale: 1.3,
                              child: Checkbox(
                                value: value,
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
                            Text(
                               taskName.length <= 15 ? taskName : "${taskName.substring(0, 15)} ...",
                              style: TextStyle(
                                color: value
                                    ? AppColors.textPrimary
                                    : AppColors.textPrimary,
                                fontWeight: FontWeight.w800,
                                decoration: value
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                                decorationThickness: 3,
                                decorationColor: AppColors.accent,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          DateUtils.isSameDay(time, DateTime.now())
                              ? TimeOfDay.fromDateTime(time).format(context)
                              : "${time.month}/${time.day} -- ${TimeOfDay.fromDateTime(time).format(context)}",
                          style: TextStyle(
                            color: value
                                ? AppColors.textPrimary
                                : AppColors.textPrimary,
                            fontSize: 15,
                            decoration: value
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            decorationThickness: 3,
                            decorationColor: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                    if (time.isBefore(DateTime(now.year, now.month, now.day)))
                      Text(
                        "تاسك متأخره",
                        style: TextStyle(
                          color: AppColors.danger,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
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
