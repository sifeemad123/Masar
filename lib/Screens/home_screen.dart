import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:masar/components/todo_tile.dart';
import 'package:masar/models/tasks_model.dart';
import 'package:masar/providers/user_data_provider.dart';
import 'package:masar/services/notifications_service.dart';
import 'package:masar/theme/AppColors.dart';
import 'package:provider/provider.dart';

import '../components/button.dart';
import '../components/dialogs.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final now = DateTime.now();

  String get greeting {
    if (now.hour < 12) {
      return 'صباح الخير';
    } else {
      return 'مساء الخير';
    }
  }

  String get arabicDate {
    return intl.DateFormat('EEEE، d MMMM', 'ar').format(now);
  }

  String get arabicTime {
    return intl.DateFormat('hh:mm a', 'ar').format(now);
  }

  @override
  void initState() {
    super.initState();
    context.read<UserDataProvider>().getUserName();
  }

  void _editTask(int index) {
    final task = Provider.of<UserDataProvider>(
      context,
      listen: false,
    ).tasks[index];

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

                        // Task Name
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
    final provider = Provider.of<UserDataProvider>(context);
    final tasks = provider.tasks;
    final today = DateTime.now();
    final todayTasks = tasks.where((task) {
      return task.taskDate.year == today.year &&
          task.taskDate.month == today.month &&
          task.taskDate.day == today.day;
    }).toList();
    final todayDoneTasks = todayTasks.where((task){
      return task.completed;
    }).toList();
    final overdueTasks = tasks.where((task) {
      return task.taskDate.isBefore(DateTime(now.year, now.month, now.day)) &&
          !task.completed;
    });
    final displayedTasks = [...overdueTasks, ...todayTasks];
    return Scaffold(
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 10,
                      children: [
                        Text(
                          arabicDate,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 22,
                          ),
                        ),
                        Text(
                          '$greeting ${context.watch<UserDataProvider>().userName}',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      Icons.access_time,
                      color: AppColors.textSecondary,
                      size: 50,
                    ),
                  ],
                ),
                SizedBox(height: 30),
                Container(
                  width: double.infinity,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border, width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if(todayDoneTasks.length != todayTasks.length)
                          Row(
                            children: [
                              Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    SizedBox(
                                      width: 50,
                                      height: 50,
                                      child: CircularProgressIndicator(
                                        value: todayDoneTasks.length.toDouble() / todayTasks.length.toDouble(),
                                        strokeWidth: 6,
                                        backgroundColor: AppColors.flameInactive,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          AppColors.accent,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      "${((todayDoneTasks.length / todayTasks.length) * 100).round()}%",
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ]
                              ),
                              SizedBox(width: 40),
                              Column(
                              children: [
                                Text(
                                  "خلصت ${todayDoneTasks.length} من ${todayTasks.length}",
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "كمّل يومك",
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 19,
                                  ),
                                ),
                              ],
                                                      ),
                            ],
                          ),
                        if(todayDoneTasks.length == todayTasks.length && todayTasks.isNotEmpty)
                          Row(
                            children: [
                              Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    SizedBox(
                                      width: 50,
                                      height: 50,
                                      child: CircularProgressIndicator(
                                        value: todayDoneTasks.length.toDouble() / todayTasks.length.toDouble(),
                                        strokeWidth: 6,
                                        backgroundColor: AppColors.flameInactive,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          AppColors.accent,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      "${((todayDoneTasks.length / todayTasks.length) * 100).round()}%",
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ]
                              ),
                              SizedBox(width: 40),
                              Text(
                                "عاش خلصت تاسكات انهارده",
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 19,
                                ),
                              ),
                            ],
                          ),
                        if(todayTasks.isEmpty && overdueTasks.isEmpty)
                          Text(
                            "معندكش اي تاسكات انهارده",
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 19,
                            ),
                          ),
                        if(todayTasks.isEmpty && overdueTasks.isNotEmpty)
                          Text(
                            "عليك تاسكات متأخره بس",
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 19,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (displayedTasks.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.today_outlined,
                            size: 70,
                            color: AppColors.textSecondary,
                          ),

                          const SizedBox(height: 15),

                          Text(
                            "مفيش مهام النهارده",
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            "يوم هادي.. استمتع بوقتك",
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    )
                  ),
                if (displayedTasks.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    itemCount: displayedTasks.length,
                    itemBuilder: (context, index) {
                      final task = displayedTasks[index];
                      return TodoTile(
                        taskName: task.taskName,
                        value: task.completed,
                        onChanged: (_) {
                          provider.toggleTask(task: task);
                        },
                        time: task.taskDate,
                        deleteTask: (_) {
                          confirmation(
                            context: context,
                            message: "هل تريد حذف المهمه ؟",
                            task: task,
                          );
                        },
                        updateTask: (_) {
                          _editTask(index);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
