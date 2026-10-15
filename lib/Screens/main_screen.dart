import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:masar/Screens/habits_screen.dart';
import 'package:masar/Screens/home_screen.dart';
import 'package:masar/Screens/subjects_screen.dart';
import 'package:masar/Screens/settings_screen.dart';
import 'package:masar/Screens/tasks_screen.dart';
import 'package:masar/components/button.dart';
import 'package:masar/components/dialogs.dart';
import 'package:masar/providers/habits_provider.dart';
import 'package:masar/providers/subjects_provider.dart';
import 'package:masar/providers/user_data_provider.dart';
import 'package:masar/theme/AppColors.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentScreen = 0;

  final PageController pageController = PageController();

  final List<Widget> screens = [
    HomeScreen(),
    TasksScreen(),
    HabitsScreen(),
    SubjectsScreen(),
    SettingsScreen(),
  ];

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void createNewTask() {
    final taskNameController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    DateTime? selectedDateTime;

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
                              "مهمة جديدة",
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

                        // =========================
                        // Task Name
                        // =========================
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

                        // =========================
                        // Date & Time
                        // =========================
                        Row(
                          children: [
                            // =========================
                            // Time Button
                            // =========================
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  final TimeOfDay?
                                  pickedTime = await showTimePicker(
                                    context: context,
                                    initialTime: selectedDateTime != null
                                        ? TimeOfDay.fromDateTime(
                                            selectedDateTime!,
                                          )
                                        : TimeOfDay.now(),
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
                                      final currentDate =
                                          selectedDateTime ?? DateTime.now();

                                      selectedDateTime = DateTime(
                                        currentDate.year,
                                        currentDate.month,
                                        currentDate.day,
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
                                    border: Border.all(
                                      color: AppColors.border,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),

                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        selectedDateTime == null
                                            ? "إضافة وقت"
                                            : TimeOfDay.fromDateTime(
                                                selectedDateTime!,
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

                            // =========================
                            // Date Button
                            // =========================
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  final DateTime?
                                  pickedDate = await showDatePicker(
                                    context: context,
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime(2100),
                                    initialDate:
                                        selectedDateTime ?? DateTime.now(),
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
                                      final currentDate =
                                          selectedDateTime ?? DateTime.now();

                                      selectedDateTime = DateTime(
                                        pickedDate.year,
                                        pickedDate.month,
                                        pickedDate.day,
                                        currentDate.hour,
                                        currentDate.minute,
                                      );
                                    });
                                  }
                                },

                                borderRadius: BorderRadius.circular(12),

                                child: Container(
                                  height: 60,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: AppColors.border,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),

                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        selectedDateTime == null
                                            ? "إضافة تاريخ"
                                            : "${selectedDateTime!.day} / "
                                                  "${selectedDateTime!.month} / "
                                                  "${selectedDateTime!.year}",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: AppColors.textPrimary,
                                          fontFamily: 'Tajawal',
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

                        // =========================
                        // Save Button
                        // =========================
                        Button(
                          text: "حفظ",
                          onPressed: () {
                            final isFormValid = formKey.currentState!
                                .validate();

                            final isDateTimeSelected = selectedDateTime != null;

                            // =========================
                            // Validation
                            // =========================
                            if (!isFormValid || !isDateTimeSelected) {
                              Dialogs.failed(
                                context: context,
                                message: "يرجى إدخال جميع البيانات المطلوبة",
                              );
                              return;
                            }

                            // =========================
                            // Add Task
                            // =========================
                            Provider.of<UserDataProvider>(
                              context,
                              listen: false,
                            ).addNewTask(
                              taskName: taskNameController.text.trim(),
                              taskDate: selectedDateTime!,
                            );

                            // Close Bottom Sheet
                            Navigator.pop(context);
                            Dialogs.success(
                              context: context,
                              message: "تمت إضافة المهمة بنجاح",
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

  void createNewHabit() {
    final habitNameController = TextEditingController();
    final habitDescriptionController = TextEditingController();
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
                              "عاده جديدة",
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

                        // =========================
                        // Task Name
                        // =========================
                        Row(
                          children: [
                            Text(
                              "اسم العاده",
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),

                        TextFormField(
                          controller: habitNameController,
                          style: TextStyle(color: AppColors.textPrimary),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "يرجى إدخال اسم العاده";
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
                              "وصف العاده",
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),
                        TextFormField(
                          controller: habitDescriptionController,
                          style: TextStyle(color: AppColors.textPrimary),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "يرجى إدخال وصف العاده";
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
                        // =========================
                        // Save Button
                        // =========================
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
                            // =========================
                            // Add Task
                            // =========================
                            Provider.of<HabitsProvider>(
                              context,
                              listen: false,
                            ).addHabit(
                              habitName: habitNameController.text.trim(),
                              habitDescription: habitDescriptionController.text
                                  .trim(),
                            );
                            // Close Bottom Sheet
                            Navigator.pop(context);
                            Dialogs.success(
                              context: context,
                              message: "تمت إضافة العاده بنجاح",
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

  void createNewSubject() {
    final subjectNameController = TextEditingController();
    final subjectDescriptionController = TextEditingController();
    final teacherNameController = TextEditingController();
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
                              "ماده جديدة",
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
                              "اسم الماده",
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),

                        TextFormField(
                          controller: subjectNameController,
                          style: TextStyle(color: AppColors.textPrimary),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "يرجى إدخال اسم الماده";
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
                              "وصف الماده",
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),
                        TextFormField(
                          controller: subjectDescriptionController,
                          style: TextStyle(color: AppColors.textPrimary),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "يرجى إدخال وصف الماده";
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
                              "اسم مدرس الماده (اختياري)",
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: teacherNameController,
                          style: TextStyle(color: AppColors.textPrimary),
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

                            Provider.of<SubjectsProvider>(
                              context,
                              listen: false,
                            ).createSubject(
                              subjectName: subjectNameController.text.trim(),
                              subjectDescription: subjectDescriptionController
                                  .text
                                  .trim(),
                              teacherName: teacherNameController.text.trim(),
                            );
                            // Close Bottom Sheet
                            Navigator.pop(context);
                            Dialogs.success(
                              context: context,
                              message: "تمت إضافة الماده بنجاح",
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

  void create() {
    showModalBottomSheet(
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(30, 10, 30, 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Button(
                      text: "تاسك جديدة",
                      onPressed: () {
                        Navigator.pop(context);
                        createNewTask();
                      },
                    ),
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: Button(
                      text: "عادة جديدة",
                      onPressed: () {
                        Navigator.pop(context);
                        createNewHabit();
                      },
                    ),
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: Button(
                      text: "مادة جديدة",
                      onPressed: () {
                        Navigator.pop(context);
                        createNewSubject();
                      },
                    ),
                  ),

                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final NotchBottomBarController _notchController =
    NotchBottomBarController(index: 0);
    return Scaffold(
      body: PageView.builder(
        controller: pageController,
        itemCount: screens.length,

        onPageChanged: (index) {
          setState(() {
            currentScreen = index;
          });
        },

        itemBuilder: (context, index) {
          return screens[index];
        },
      ),

      floatingActionButton: SizedBox(
        width: 70,
        height: 70,
        child: FloatingActionButton(
          onPressed: () {
            create();
          },
          backgroundColor: AppColors.accent,
          child: const Icon(Icons.add, color: AppColors.onAccent),
        ),
      ),

      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,

      floatingActionButtonLocation: CustomFabLocation(),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),

        child: Container(
          height: 90,

          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: AppColors.border, width: 1),
          ),

          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),

            child: BottomNavigationBar(
              backgroundColor: Colors.transparent,

              selectedItemColor: AppColors.accent,

              unselectedItemColor: AppColors.textSecondary,

              selectedFontSize: 13,

              unselectedFontSize: 13,

              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),

              type: BottomNavigationBarType.fixed,

              currentIndex: currentScreen,

              onTap: (index) {
                pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },

              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_today_outlined),
                  label: 'اليوم',
                ),

                BottomNavigationBarItem(
                  icon: Icon(Icons.menu_rounded),
                  label: 'مهام',
                ),

                BottomNavigationBarItem(
                  icon: Icon(Icons.water_drop_outlined),
                  label: 'عادات',
                ),

                BottomNavigationBarItem(
                  icon: Icon(Icons.menu_book_outlined),
                  label: 'المواد',
                ),

                BottomNavigationBarItem(
                  icon: Icon(Icons.settings_outlined),
                  label: 'إعدادات',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =========================
// Custom FAB Location
// =========================

class CustomFabLocation extends FloatingActionButtonLocation {
  const CustomFabLocation();

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry geometry) {
    return Offset(30, geometry.scaffoldSize.height - 315);
  }
}
