import 'package:crystal_navigation_bar/crystal_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:masar/Screens/habits_screen.dart';
import 'package:masar/Screens/home_screen.dart';
import 'package:masar/Screens/settings_screen.dart';
import 'package:masar/Screens/subjects_screen.dart';
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
  static const int _settingsIndex = 4;

  /// Space reserved at the bottom so the (existing) screens never hide
  /// content behind the floating navigation bar.
  static const double _navInset = 96;

  int currentScreen = 0;

  final PageController pageController = PageController();

  final List<Widget> screens = const [
    _KeepAlive(child: HomeScreen()),
    _KeepAlive(child: TasksScreen()),
    _KeepAlive(child: HabitsScreen()),
    _KeepAlive(child: SubjectsScreen()),
    _KeepAlive(child: SettingsScreen()),
  ];

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void _goTo(int index) {
    HapticFeedback.selectionClick();
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeInOutCubic,
    );
  }

  // ---------------------------------------------------------------
  // Shared sheet building blocks
  // ---------------------------------------------------------------

  OutlineInputBorder _border(Color color, [double width = 1]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  InputDecoration _decoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textMuted),
      filled: true,
      fillColor: AppColors.surfaceAlt,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      enabledBorder: _border(AppColors.divider),
      focusedBorder: _border(AppColors.accent, 2),
      errorBorder: _border(AppColors.danger),
      focusedErrorBorder: _border(AppColors.danger, 2),
      errorStyle: const TextStyle(
        color: AppColors.danger,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          text,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      textInputAction: TextInputAction.next,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 17,
        fontWeight: FontWeight.w600,
      ),
      decoration: _decoration(hint: hint),
    );
  }

  String? _required(String? value, String message) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
  }

  Widget _sheetHeader(BuildContext sheetContext, String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: AppColors.accent, size: 26),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Material(
          color: AppColors.surfaceAlt,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => Navigator.pop(sheetContext),
            child: const Padding(
              padding: EdgeInsets.all(10),
              child: Icon(
                Icons.close_rounded,
                color: AppColors.textPrimary,
                size: 22,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _openSheet({
    required String title,
    required IconData icon,
    required Widget Function(BuildContext sheetContext, StateSetter setSheet)
    builder,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheet) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 4, 24, 28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _sheetHeader(sheetContext, title, icon),
                      const SizedBox(height: 26),
                      builder(sheetContext, setSheet),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _pickerButton({
    required IconData icon,
    required String text,
    required bool active,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        height: 58,
        decoration: BoxDecoration(
          color: active ? AppColors.surfaceAlt : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: active ? AppColors.accent : AppColors.border,
            width: active ? 1.6 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: active ? AppColors.accent : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: active ? AppColors.textPrimary : AppColors.textSecondary,
                fontSize: 15,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickChip({
    required String text,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected ? AppColors.onAccent : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _pickerTheme(BuildContext ctx, Widget? child) {
    return Theme(
      data: Theme.of(ctx).copyWith(
        colorScheme: const ColorScheme.light(
          primary: AppColors.accent,
          onPrimary: AppColors.onAccent,
          surface: AppColors.surface,
          onSurface: AppColors.textPrimary,
        ),
      ),
      child: child!,
    );
  }

  void _showMissingData() {
    Dialogs.failed(
      context: context,
      message: "اكمل البيانات المطلوبة الأول",
    );
  }

  // ---------------------------------------------------------------
  // New task
  // ---------------------------------------------------------------

  void createNewTask() {
    final taskNameController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    DateTime? startDate;
    DateTime? endDate;

    _openSheet(
      title: "مهمة جديدة",
      icon: Icons.task_alt_rounded,
      builder: (sheetContext, setSheet) {
        DateTime merge(DateTime? base, {DateTime? date, TimeOfDay? time}) {
          final b = base ?? DateTime.now();
          return DateTime(
            date?.year ?? b.year,
            date?.month ?? b.month,
            date?.day ?? b.day,
            time?.hour ?? b.hour,
            time?.minute ?? b.minute,
          );
        }

        Future<void> pickTime(bool isStart) async {
          final current = isStart ? startDate : endDate;
          final picked = await showTimePicker(
            context: sheetContext,
            initialTime: current != null
                ? TimeOfDay.fromDateTime(current)
                : TimeOfDay.now(),
            builder: _pickerTheme,
          );
          if (picked == null) return;
          setSheet(() {
            if (isStart) {
              startDate = merge(startDate, time: picked);
            } else {
              endDate = merge(endDate, time: picked);
            }
          });
        }

        Future<void> pickDate(bool isStart) async {
          final today = DateUtils.dateOnly(DateTime.now());
          final current = isStart ? startDate : endDate;
          final picked = await showDatePicker(
            context: sheetContext,
            firstDate: today,
            lastDate: DateTime(2100),
            initialDate: current != null && !current.isBefore(today)
                ? current
                : today,
            builder: _pickerTheme,
          );
          if (picked == null) return;
          setSheet(() {
            if (isStart) {
              startDate = merge(startDate, date: picked);
            } else {
              endDate = merge(endDate, date: picked);
            }
          });
        }

        void setQuickStart(int daysFromToday) {
          final target = DateTime.now().add(Duration(days: daysFromToday));
          setSheet(() => startDate = merge(startDate, date: target));
        }

        Widget dateRow(bool isStart) {
          final value = isStart ? startDate : endDate;
          return Row(
            children: [
              Expanded(
                child: _pickerButton(
                  icon: Icons.access_time_rounded,
                  text: value == null
                      ? "إضافة وقت"
                      : TimeOfDay.fromDateTime(value).format(sheetContext),
                  active: value != null,
                  onTap: () => pickTime(isStart),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _pickerButton(
                  icon: Icons.calendar_today_rounded,
                  text: value == null
                      ? "إضافة تاريخ"
                      : "${value.day} / ${value.month} / ${value.year}",
                  active: value != null,
                  onTap: () => pickDate(isStart),
                ),
              ),
            ],
          );
        }

        final isToday = startDate != null &&
            DateUtils.isSameDay(startDate, DateTime.now());
        final isTomorrow = startDate != null &&
            DateUtils.isSameDay(
              startDate,
              DateTime.now().add(const Duration(days: 1)),
            );

        return Form(
          key: formKey,
          child: Column(
            children: [
              _fieldLabel("اسم المهمة"),
              _textField(
                controller: taskNameController,
                hint: "مثلاً: مراجعة درس الفيزياء",
                validator: (v) => _required(v, "اكتب اسم المهمة"),
              ),
              const SizedBox(height: 22),
              _fieldLabel("وقت البداية"),
              dateRow(true),
              const SizedBox(height: 14),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Wrap(
                  spacing: 10,
                  children: [
                    _quickChip(
                      text: "النهاردة",
                      selected: isToday,
                      onTap: () => setQuickStart(0),
                    ),
                    _quickChip(
                      text: "بكرة",
                      selected: isTomorrow,
                      onTap: () => setQuickStart(1),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              _fieldLabel("الموعد النهائي"),
              dateRow(false),
              const SizedBox(height: 28),
              Button(
                text: "حفظ",
                onPressed: () {
                  final isFormValid = formKey.currentState!.validate();
                  if (!isFormValid) return;

                  if (startDate == null || endDate == null) {
                    _showMissingData();
                    return;
                  }

                  if (endDate!.isBefore(startDate!)) {
                    Dialogs.failed(
                      context: context,
                      message: "الموعد النهائي لازم يكون بعد وقت البداية",
                    );
                    return;
                  }

                  Provider.of<UserDataProvider>(
                    context,
                    listen: false,
                  ).addNewTask(
                    taskName: taskNameController.text.trim(),
                    taskDate: endDate!,
                    startDate: startDate!,
                  );

                  Navigator.pop(sheetContext);
                  Dialogs.success(
                    context: context,
                    message: "تمت إضافة المهمة بنجاح",
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------
  // New habit
  // ---------------------------------------------------------------

  void createNewHabit() {
    final habitNameController = TextEditingController();
    final habitDescriptionController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    TimeOfDay? alarmTime;

    _openSheet(
      title: "عادة جديدة",
      icon: Icons.water_drop_rounded,
      builder: (sheetContext, setSheet) {
        return Form(
          key: formKey,
          child: Column(
            children: [
              _fieldLabel("اسم العادة"),
              _textField(
                controller: habitNameController,
                hint: "مثلاً: قراءة قبل النوم",
                validator: (v) => _required(v, "اكتب اسم العادة"),
              ),
              const SizedBox(height: 20),
              _fieldLabel("وصف العادة"),
              _textField(
                controller: habitDescriptionController,
                hint: "مثلاً: ١٠ صفحات كل ليلة",
                validator: (v) => _required(v, "اكتب وصف العادة"),
              ),
              const SizedBox(height: 22),
              _fieldLabel("وقت التنبيه (اختياري)"),
              _pickerButton(
                icon: Icons.alarm_rounded,
                text: alarmTime == null
                    ? "بدون تنبيه"
                    : alarmTime!.format(sheetContext),
                active: alarmTime != null,
                onTap: () async {
                  final picked = await showTimePicker(
                    context: sheetContext,
                    initialTime: alarmTime ?? TimeOfDay.now(),
                    builder: _pickerTheme,
                  );
                  if (picked != null) setSheet(() => alarmTime = picked);
                },
              ),
              const SizedBox(height: 28),
              Button(
                text: "حفظ",
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;

                  final provider = Provider.of<HabitsProvider>(
                    context,
                    listen: false,
                  );

                  provider.addHabit(
                    habitName: habitNameController.text.trim(),
                    habitDescription: habitDescriptionController.text.trim(),
                  );

                  if (alarmTime != null) {
                    await provider.setHabitAlarm(
                      index: provider.habits.length - 1,
                      hour: alarmTime!.hour,
                      minute: alarmTime!.minute,
                    );
                  }

                  if (!context.mounted || !sheetContext.mounted) return;

                  Navigator.pop(sheetContext);
                  Dialogs.success(
                    context: context,
                    message: "تمت إضافة العادة بنجاح",
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------
  // New subject
  // ---------------------------------------------------------------

  void createNewSubject() {
    final subjectNameController = TextEditingController();
    final subjectDescriptionController = TextEditingController();
    final teacherNameController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    _openSheet(
      title: "مادة جديدة",
      icon: Icons.menu_book_rounded,
      builder: (sheetContext, setSheet) {
        return Form(
          key: formKey,
          child: Column(
            children: [
              _fieldLabel("اسم المادة"),
              _textField(
                controller: subjectNameController,
                hint: "مثلاً: الفيزياء",
                validator: (v) => _required(v, "اكتب اسم المادة"),
              ),
              const SizedBox(height: 20),
              _fieldLabel("وصف المادة"),
              _textField(
                controller: subjectDescriptionController,
                hint: "مثلاً: الفصل الأول والتاني",
                validator: (v) => _required(v, "اكتب وصف المادة"),
              ),
              const SizedBox(height: 20),
              _fieldLabel("اسم مدرس المادة (اختياري)"),
              _textField(
                controller: teacherNameController,
                hint: "اسم المدرس",
              ),
              const SizedBox(height: 28),
              Button(
                text: "حفظ",
                onPressed: () {
                  if (!formKey.currentState!.validate()) return;

                  Provider.of<SubjectsProvider>(
                    context,
                    listen: false,
                  ).createSubject(
                    subjectName: subjectNameController.text.trim(),
                    subjectDescription:
                    subjectDescriptionController.text.trim(),
                    teacherName: teacherNameController.text.trim(),
                  );

                  Navigator.pop(sheetContext);
                  Dialogs.success(
                    context: context,
                    message: "تمت إضافة المادة بنجاح",
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------
  // "What do you want to add?" sheet
  // ---------------------------------------------------------------

  void create() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (sheetContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    "عاوز تضيف إيه؟",
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                _CreateTile(
                  index: 0,
                  icon: Icons.task_alt_rounded,
                  title: "مهمة جديدة",
                  subtitle: "بموعد وتذكير",
                  onTap: () {
                    Navigator.pop(sheetContext);
                    createNewTask();
                  },
                ),
                _CreateTile(
                  index: 1,
                  icon: Icons.water_drop_rounded,
                  title: "عادة جديدة",
                  subtitle: "وابدأ سلسلتك من النهاردة",
                  onTap: () {
                    Navigator.pop(sheetContext);
                    createNewHabit();
                  },
                ),
                _CreateTile(
                  index: 2,
                  icon: Icons.menu_book_rounded,
                  title: "مادة جديدة",
                  subtitle: "بدروسها وملاحظاتها",
                  onTap: () {
                    Navigator.pop(sheetContext);
                    createNewSubject();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------

  Widget _addButton() {
    final hidden = currentScreen == _settingsIndex;
    return AnimatedScale(
      scale: hidden ? 0 : 1,
      duration: const Duration(milliseconds: 260),
      curve: hidden ? Curves.easeInBack : Curves.easeOutBack,
      child: IgnorePointer(
        ignoring: hidden,
        child: Container(
          width: 66,
          height: 66,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [AppColors.accent, AppColors.accentDark],
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.38),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: create,
              child: const Icon(
                Icons.add_rounded,
                color: AppColors.onAccent,
                size: 34,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);

    return PopScope(
      canPop: currentScreen == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goTo(0);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        extendBody: true,
        body: MediaQuery(
          data: mq.copyWith(
            padding: mq.padding.copyWith(bottom: mq.padding.bottom + _navInset),
          ),
          child: PageView(
            controller: pageController,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (index) {
              FocusManager.instance.primaryFocus?.unfocus();
              setState(() => currentScreen = index);
            },
            children: screens,
          ),
        ),
        floatingActionButton: _addButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        bottomNavigationBar: CrystalNavigationBar(
          currentIndex: currentScreen,
          onTap: _goTo,
          enableFloatingNavBar: true,
          showLabels: true,
          blurSigma: 18,
          borderWidth: 1,
          outlineBorderColor: AppColors.border,
          backgroundColor: AppColors.surface.withValues(alpha: 0.78),
          indicatorColor: AppColors.accent.withValues(alpha: 0.12),
          selectedItemColor: AppColors.accent,
          unselectedItemColor: AppColors.textMuted,
          duration: const Duration(milliseconds: 380),
          curve: Curves.easeOutCubic,
          items: [
            CrystalNavigationBarItem(
              icon: Icons.today_rounded,
              unselectedIcon: Icons.today_outlined,
              selectedColor: AppColors.accent,
              label: "اليوم",
            ),
            CrystalNavigationBarItem(
              icon: Icons.checklist_rounded,
              unselectedIcon: Icons.checklist_outlined,
              selectedColor: AppColors.accent,
              label: "المهام",
            ),
            CrystalNavigationBarItem(
              icon: Icons.water_drop_rounded,
              unselectedIcon: Icons.water_drop_outlined,
              selectedColor: AppColors.accent,
              label: "العادات",
            ),
            CrystalNavigationBarItem(
              icon: Icons.menu_book_rounded,
              unselectedIcon: Icons.menu_book_outlined,
              selectedColor: AppColors.accent,
              label: "المواد",
            ),
            CrystalNavigationBarItem(
              icon: Icons.settings_rounded,
              unselectedIcon: Icons.settings_outlined,
              selectedColor: AppColors.accent,
              label: "الإعدادات",
            ),
          ],
        ),
      ),
    );
  }
}

// =========================
// Option tile in the "add" sheet
// =========================

class _CreateTile extends StatelessWidget {
  final int index;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _CreateTile({
    required this.index,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 380 + index * 90),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 24),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Material(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [AppColors.accent, AppColors.accentDark],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, color: AppColors.onAccent, size: 26),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =========================
// Keeps each tab's state (filters, scroll) alive while swiping
// =========================

class _KeepAlive extends StatefulWidget {
  final Widget child;
  const _KeepAlive({required this.child});

  @override
  State<_KeepAlive> createState() => _KeepAliveState();
}

class _KeepAliveState extends State<_KeepAlive>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}