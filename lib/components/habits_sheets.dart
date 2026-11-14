import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:masar/components/dialogs.dart';
import 'package:masar/components/motion.dart';
import 'package:masar/components/sheet_kit.dart';
import 'package:masar/providers/habits_provider.dart';
import 'package:masar/theme/AppColors.dart';
import 'package:provider/provider.dart';

/// Edit sheet + delete confirmation for habits.
class HabitSheets {
  HabitSheets._();

  static void edit(BuildContext context, int index) {
    final provider = Provider.of<HabitsProvider>(context, listen: false);
    final habit = provider.habits[index];

    final nameController = TextEditingController(text: habit.habitName);
    final descController = TextEditingController(text: habit.habitDescription);
    final formKey = GlobalKey<FormState>();

    TimeOfDay? alarm = habit.alarmHour != null && habit.alarmMinute != null
        ? TimeOfDay(hour: habit.alarmHour!, minute: habit.alarmMinute!)
        : null;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      shape: sheetShape,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (ctx, setSheet) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 4, 24, 28),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        sheetHeader(
                          icon: Icons.edit_rounded,
                          title: "تعديل العادة",
                          onClose: () => Navigator.pop(sheetContext),
                        ),
                        const SizedBox(height: 26),
                        sheetLabel("اسم العادة"),
                        TextFormField(
                          controller: nameController,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? "اكتب اسم العادة"
                              : null,
                          decoration: sheetInputDecoration(),
                        ),
                        const SizedBox(height: 22),
                        sheetLabel("وصف العادة"),
                        TextFormField(
                          controller: descController,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? "اكتب وصف العادة"
                              : null,
                          decoration: sheetInputDecoration(),
                        ),
                        const SizedBox(height: 22),
                        sheetLabel("وقت التنبيه (اختياري)"),
                        Row(
                          children: [
                            Expanded(
                              child: PickerField(
                                icon: Icons.alarm_rounded,
                                label: alarm == null
                                    ? "بدون تنبيه"
                                    : alarm!.format(ctx),
                                onTap: () async {
                                  final picked = await showTimePicker(
                                    context: ctx,
                                    initialTime: alarm ?? TimeOfDay.now(),
                                    builder: sheetPickerTheme,
                                  );
                                  if (picked != null) {
                                    setSheet(() => alarm = picked);
                                  }
                                },
                              ),
                            ),
                            if (alarm != null) ...[
                              const SizedBox(width: 10),
                              Pressable(
                                onTap: () => setSheet(() => alarm = null),
                                child: Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: AppColors.danger
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    Icons.alarm_off_rounded,
                                    color: AppColors.danger,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 30),
                        GradientButton(
                          text: "حفظ التعديل",
                          onTap: () async {
                            if (!formKey.currentState!.validate()) {
                              HapticFeedback.lightImpact();
                              return;
                            }

                            provider.editHabit(
                              habitName: nameController.text.trim(),
                              habitDescription: descController.text.trim(),
                              index: index,
                            );

                            if (alarm != null) {
                              await provider.setHabitAlarm(
                                index: index,
                                hour: alarm!.hour,
                                minute: alarm!.minute,
                              );
                            } else {
                              await provider.removeHabitAlarm(index: index);
                            }

                            if (sheetContext.mounted) {
                              Navigator.pop(sheetContext);
                            }
                            if (context.mounted) {
                              Dialogs.success(
                                context: context,
                                message: "تم تعديل العادة بنجاح",
                              );
                            }
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

  static Future<void> confirmDelete(BuildContext context, int index) {
    final provider = Provider.of<HabitsProvider>(context, listen: false);
    final name = provider.habits[index].habitName;

    return Dialogs.confirm(
      context: context,
      title: "حذف العادة",
      message: "هتحذف \"$name\" وكل السلسلة بتاعتها، ومش هتقدر ترجعها.",
      confirmText: "حذف",
      danger: true,
      onConfirm: () {
        provider.deleteHabit(index: index);
        Dialogs.success(context: context, message: "تم حذف العادة بنجاح");
      },
    );
  }
}