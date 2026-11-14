import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:masar/components/dialogs.dart';
import 'package:masar/components/sheet_kit.dart';
import 'package:masar/models/tasks_model.dart';
import 'package:masar/providers/user_data_provider.dart';
import 'package:masar/theme/AppColors.dart';
import 'package:provider/provider.dart';

/// Edit sheet + delete dialog for tasks, shared by Home and Tasks screens.
class TaskSheets {
  TaskSheets._();

  // ---------------------------------------------------------------
  // Edit
  // ---------------------------------------------------------------

  static void edit(BuildContext context, TasksModel task) {
    final nameController = TextEditingController(text: task.taskName);
    final formKey = GlobalKey<FormState>();
    DateTime startDate = task.startDate!;
    DateTime endDate = task.taskDate;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (ctx, setSheet) {
            Future<void> pickTime(bool isStart) async {
              final current = isStart ? startDate : endDate;
              final picked = await showTimePicker(
                context: ctx,
                initialTime: TimeOfDay.fromDateTime(current),
                builder: sheetPickerTheme,
              );
              if (picked == null) return;
              setSheet(() {
                final updated = DateTime(
                  current.year,
                  current.month,
                  current.day,
                  picked.hour,
                  picked.minute,
                );
                if (isStart) {
                  startDate = updated;
                } else {
                  endDate = updated;
                }
              });
            }

            Future<void> pickDate(bool isStart) async {
              final current = isStart ? startDate : endDate;
              final today = DateUtils.dateOnly(DateTime.now());
              // never crash when editing a task whose date is already past
              final first =
              current.isBefore(today) ? DateUtils.dateOnly(current) : today;
              final picked = await showDatePicker(
                context: ctx,
                firstDate: first,
                lastDate: DateTime(2100),
                initialDate: current,
                builder: sheetPickerTheme,
              );
              if (picked == null) return;
              setSheet(() {
                final updated = DateTime(
                  picked.year,
                  picked.month,
                  picked.day,
                  current.hour,
                  current.minute,
                );
                if (isStart) {
                  startDate = updated;
                } else {
                  endDate = updated;
                }
              });
            }

            Widget pickerRow(bool isStart) {
              final value = isStart ? startDate : endDate;
              return Row(
                children: [
                  Expanded(
                    child: PickerField(
                      icon: Icons.access_time_rounded,
                      label: TimeOfDay.fromDateTime(value).format(ctx),
                      onTap: () => pickTime(isStart),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PickerField(
                      icon: Icons.calendar_today_rounded,
                      label: "${value.day} / ${value.month} / ${value.year}",
                      onTap: () => pickDate(isStart),
                    ),
                  ),
                ],
              );
            }

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
                        Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topRight,
                                  end: Alignment.bottomLeft,
                                  colors: [
                                    AppColors.accent,
                                    AppColors.accentDark,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.edit_rounded,
                                color: AppColors.onAccent,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Text(
                                "تعديل المهمة",
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(sheetContext),
                              style: IconButton.styleFrom(
                                backgroundColor: AppColors.overlay,
                              ),
                              icon: const Icon(
                                Icons.close_rounded,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 26),
                        sheetLabel("اسم المهمة"),
                        TextFormField(
                          controller: nameController,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? "اكتب اسم المهمة"
                              : null,
                          decoration: sheetInputDecoration(),
                        ),
                        const SizedBox(height: 22),
                        sheetLabel("وقت البداية"),
                        pickerRow(true),
                        const SizedBox(height: 22),
                        sheetLabel("الموعد النهائي"),
                        pickerRow(false),
                        const SizedBox(height: 30),
                        GradientButton(
                          text: "حفظ التعديل",
                          onTap: () {
                            if (!formKey.currentState!.validate()) {
                              HapticFeedback.lightImpact();
                              return;
                            }
                            if (endDate.isBefore(startDate)) {
                              Dialogs.failed(
                                context: ctx,
                                message:
                                "الموعد النهائي لازم يكون بعد وقت البداية",
                              );
                              return;
                            }

                            Provider.of<UserDataProvider>(
                              ctx,
                              listen: false,
                            ).updateTask(
                              task,
                              nameController.text.trim(),
                              endDate,
                              startDate: startDate,
                            );

                            Navigator.pop(sheetContext);
                            Dialogs.success(
                              context: context,
                              message: "تم تعديل المهمة بنجاح",
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

  // ---------------------------------------------------------------
  // Delete
  // ---------------------------------------------------------------

  static Future<void> confirmDelete(BuildContext context, TasksModel task) {
    return Dialogs.confirm(
      context: context,
      title: "حذف المهمة",
      message: "هتحذف \"${task.taskName}\" ومش هتقدر ترجعها تاني.",
      confirmText: "حذف",
      danger: true,
      onConfirm: () {
        Provider.of<UserDataProvider>(
          context,
          listen: false,
        ).deleteTask(task: task);
        Dialogs.success(context: context, message: "تم حذف المهمة بنجاح");
      },
    );
  }
}