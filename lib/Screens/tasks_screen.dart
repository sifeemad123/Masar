import 'package:flutter/material.dart';
import 'package:masar/components/button.dart';
import 'package:masar/components/dialogs.dart';
import 'package:masar/components/todo_tile.dart';
import 'package:masar/models/tasks_model.dart';
import 'package:masar/providers/user_data_provider.dart';
import 'package:masar/theme/AppColors.dart';
import 'package:provider/provider.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  String selectedFilter = "all";
  Widget _filtterButton({
    required String title,
    required String value,
    int? count,
  }) {
    final isSelected = selectedFilter == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedFilter = value;
          });
        },
        child: Column(
          spacing: 10,
          children: [
            Row(
              spacing: 5,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.accent,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                if (count != null && count > 0)
                  Text(
                    "($count)",
                    style: TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
            if (isSelected)
              Container(width: 30, height: 2, color: AppColors.accent),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    String title;
    String subtitle;
    IconData icon;

    switch (selectedFilter) {
      case "toDay":
        title = "مفيش مهام النهارده";
        subtitle = "يوم هادي.. استمتع بوقتك";
        icon = Icons.today_outlined;
        break;

      case "overdue":
        title = "مفيش مهام متأخرة";
        subtitle = "ممتاز! أنت مخلص كل اللي عليك ";
        icon = Icons.task_alt;
        break;

      case "upcoming":
        title = "مفيش مهام قادمة";
        subtitle = "لسه مفيش حاجة في جدولك";
        icon = Icons.event_available_outlined;
        break;

      default:
        title = "مفيش مهام لسه";
        subtitle = "ابدأ بإضافة أول مهمة ليك";
        icon = Icons.inbox_outlined;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 70, color: AppColors.textSecondary),

          const SizedBox(height: 15),

          Text(
            title,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            subtitle,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
          ),
        ],
      ),
    );
  }

  void _editTask(TasksModel task) {

    final taskNameController = TextEditingController(text: task.taskName);

    final formKey = GlobalKey<FormState>();

    DateTime selectedDateTime = task.taskDate;

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
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "تعديل المهمة",
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
                              "اسم المهمة",
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),

                        TextFormField(
                          controller: taskNameController,
                          style: TextStyle(color: AppColors.textPrimary),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "يرجى إدخال اسم المهمة";
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

                        const SizedBox(height: 30),

                        // Date & Time
                        Row(
                          children: [
                            // Time
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  final TimeOfDay?
                                  pickedTime = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.fromDateTime(
                                      selectedDateTime,
                                    ),
                                    builder: (context, child) {
                                      return Theme(
                                        data: Theme.of(context).copyWith(
                                          colorScheme: const ColorScheme.light(
                                            primary: AppColors.textPrimary,
                                            onPrimary: AppColors.surfaceAlt,
                                            surface: AppColors.surface,
                                            onSurface: AppColors.textSecondary,
                                          ),
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );

                                  if (pickedTime != null) {
                                    setModalState(() {
                                      selectedDateTime = DateTime(
                                        selectedDateTime.year,
                                        selectedDateTime.month,
                                        selectedDateTime.day,
                                        pickedTime.hour,
                                        pickedTime.minute,
                                      );
                                    });
                                  }
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  height: 60,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.border),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        TimeOfDay.fromDateTime(
                                          selectedDateTime,
                                        ).format(context),
                                        style: TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        Icons.access_time_outlined,
                                        color: AppColors.textSecondary,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 10),

                            // Date
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  final DateTime?
                                  pickedDate = await showDatePicker(
                                    context: context,
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime(2100),
                                    initialDate: selectedDateTime,
                                    builder: (context, child) {
                                      return Theme(
                                        data: Theme.of(context).copyWith(
                                          colorScheme: const ColorScheme.light(
                                            primary: AppColors.textPrimary,
                                            onPrimary: AppColors.surfaceAlt,
                                            surface: AppColors.surface,
                                            onSurface: AppColors.textSecondary,
                                          ),
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );

                                  if (pickedDate != null) {
                                    setModalState(() {
                                      selectedDateTime = DateTime(
                                        pickedDate.year,
                                        pickedDate.month,
                                        pickedDate.day,
                                        selectedDateTime.hour,
                                        selectedDateTime.minute,
                                      );
                                    });
                                  }
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  height: 60,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.border),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "${selectedDateTime.day} / "
                                        "${selectedDateTime.month} / "
                                        "${selectedDateTime.year}",
                                        style: TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        Icons.calendar_today_outlined,
                                        color: AppColors.textSecondary,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        // Update Button
                        Button(
                          text: "تعديل",
                          onPressed: () {
                            final isFormValid = formKey.currentState!
                                .validate();

                            if (!isFormValid) {
                              return;
                            }

                            Provider.of<UserDataProvider>(
                              context,
                              listen: false,
                            ).updateTask(
                              task,
                              taskNameController.text.trim(),
                              selectedDateTime,
                            );

                            Navigator.pop(context);

                            Dialogs.success(
                              context: context,
                              message: "تم تعديل المهمه بنجاح",
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
    required TasksModel task
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
                        Provider.of<UserDataProvider>(context , listen: false).deleteTask(task: task);
                        Dialogs.success(context: context, message: "تم حذف المهمه بنجاح");
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
    final provider = context.watch<UserDataProvider>();
    final tasks = provider.tasks;
    final today = DateTime.now();
    final todayTasks = tasks.where((task) {
      return task.taskDate.year == today.year &&
          task.taskDate.month == today.month &&
          task.taskDate.day == today.day;
    }).toList();
    final overdueTasks = tasks.where((task) {
      return task.taskDate.isBefore(
            DateTime(today.year, today.month, today.day),
          ) &&
          !task.completed;
    }).toList();
    final futureTasks = tasks.where((task) {
      return task.taskDate.isAfter(
        DateTime(
          today.year,
          today.month,
          today.day,
        ).add(const Duration(days: 1)),
      );
    }).toList();
    List<TasksModel> displayedTasks;
    if (selectedFilter == "toDay") {
      displayedTasks = todayTasks;
    } else if (selectedFilter == "overdue") {
      displayedTasks = overdueTasks;
    } else if (selectedFilter == "future") {
      displayedTasks = futureTasks;
    } else {
      displayedTasks = [...overdueTasks, ...todayTasks, ...futureTasks];
    }
    return Scaffold(
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =========================
              // Header
              // =========================
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 10,
                ),
                child: Text(
                  "تاسكاتي",
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Row(
                  children: [
                    _filtterButton(title: "الكل", value: "all"),
                    _filtterButton(title: "النهاردة", value: "toDay"),
                    _filtterButton(
                      title: "متأخره",
                      value: "overdue",
                      count: overdueTasks.length,
                    ),
                    _filtterButton(
                      title: "قادمه",
                      value: "future",
                      count: futureTasks.length,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Divider(color: AppColors.divider),
              ),
              if (displayedTasks.isEmpty) Expanded(child: _buildEmptyState()),

              if (displayedTasks.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    itemCount: displayedTasks.length,
                    itemBuilder: (context, index) {
                      final task = displayedTasks[index];
                      return TodoTile(
                        taskName: task.taskName,
                        value: task.completed,
                        time: task.taskDate,
                        onChanged: (_) {
                          provider.toggleTask(task: task);
                        },
                        deleteTask: (_) {
                          confirmation(
                            context: context,
                            message: "هل تريد حذف المهمه ؟",
                            task: task,
                          );
                        },
                        updateTask: (_) {
                          _editTask(task);
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
