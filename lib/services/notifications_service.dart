
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:masar/models/tasks_model.dart';
import 'package:masar/models/habits_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationsService {
  final FlutterLocalNotificationsPlugin plugin =
  FlutterLocalNotificationsPlugin();

  static const int _habitIdOffset = 1000000;
  static const int _taskSnoozeOffset = 2000000;
  static const int _habitSnoozeOffset = 3000000;
  static const int _motivationOffset = 4000000;

  static int deadlineId(int key) => key * 2;
  static int startId(int key) => key * 2 + 1;

  static int habitId(int key) => _habitIdOffset + key;
  static int taskSnoozeId(int key) => _taskSnoozeOffset + key;
  static int habitSnoozeId(int key) => _habitSnoozeOffset + key;

  static const String _taskChannelId = 'tasks_channel_v3';
  static const String _habitChannelId = 'habits_channel_v3';
  static const String _motivationChannelId = 'motivation_channel_v1';

  static const String _taskDone = 'task_done';
  static const String _taskNotDone = 'task_not_done';
  static const String _taskSnooze = 'task_snooze';

  static const String _habitDone = 'habit_done';
  static const String _habitSnooze = 'habit_snooze';

  static const List<String> _motivationalMessages = [
    'خطوة صغيرة النهارده ممكن تعمل فرق كبير بكرة.',
    'خد دقيقة وارجع ركّز على اللي مهم بالنسبالك.',
    'مش لازم تنجز كل حاجة مرة واحدة، المهم تكمّل.',
    'كل مرة بتلتزم فيها، بتقرب من الشخص اللي عايز تكونه.',
    'ابدأ بالخطوة اللي قدامك، وسيب الباقي على وقته.',
  ];

  bool _initialized = false;

  static const AndroidNotificationAction _taskDoneAction =
  AndroidNotificationAction(
    _taskDone,
    'خلصت المهمة',
    showsUserInterface: false,
  );

  static const AndroidNotificationAction _taskNotDoneAction =
  AndroidNotificationAction(
    _taskNotDone,
    'لسه مخلصتش',
    showsUserInterface: false,
  );

  static const AndroidNotificationAction _taskSnoozeAction =
  AndroidNotificationAction(
    _taskSnooze,
    'ذكرني بعد 5 دقايق',
    showsUserInterface: false,
  );

  static const AndroidNotificationAction _habitDoneAction =
  AndroidNotificationAction(
    _habitDone,
    'أنجزت العادة',
    showsUserInterface: false,
  );

  static const AndroidNotificationAction _habitSnoozeAction =
  AndroidNotificationAction(
    _habitSnooze,
    'بعد 5 دقايق',
    showsUserInterface: false,
  );

  static const AndroidNotificationDetails _taskDetails =
  AndroidNotificationDetails(
    _taskChannelId,
    'تذكيرات المهام',
    channelDescription: 'تذكيرات بداية وانتهاء المهام',
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
    enableVibration: true,
    actions: [
      _taskDoneAction,
      _taskNotDoneAction,
      _taskSnoozeAction,
    ],
  );

  static const AndroidNotificationDetails _habitDetails =
  AndroidNotificationDetails(
    _habitChannelId,
    'تذكيرات العادات',
    channelDescription: 'تذكيرات العادات اليومية',
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
    enableVibration: true,
    actions: [
      _habitDoneAction,
      _habitSnoozeAction,
    ],
  );

  static const AndroidNotificationDetails _motivationDetails =
  AndroidNotificationDetails(
    _motivationChannelId,
    'رسائل مسار التحفيزية',
    channelDescription: 'رسائل خفيفة لتشجيعك على الاستمرار',
    importance: Importance.defaultImportance,
    priority: Priority.defaultPriority,
    playSound: false,
    enableVibration: false,
  );

  Future<void> initNotification() async {
    if (_initialized) return;

    WidgetsFlutterBinding.ensureInitialized();

    tz_data.initializeTimeZones();

    try {
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(
        tz.getLocation(timezoneInfo.identifier),
      );
    } catch (e) {
      // Keep the timezone package default if device timezone
      // cannot be retrieved.
    }

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/launcher_icon',
    );

    const settings = InitializationSettings(
      android: androidSettings,
    );

    await plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
      notificationTapBackground,
    );

    final androidPlugin = plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.requestExactAlarmsPermission();

    _initialized = true;

    final prefs = await SharedPreferences.getInstance();

    if (prefs.getBool('motivationRemindersEnabled') ?? false) {
      await scheduleMotivationalReminders();
    }
  }

  void _onNotificationResponse(NotificationResponse response) {
    if (response.actionId == null) return;

    unawaited(_handleAction(response));
  }

  // ============================================================
  // TASK NOTIFICATIONS
  // ============================================================

  Future<void> deadLineScheduleTaskNotification({
    required int taskKey,
    required String taskName,
    required DateTime taskDate,
  }) async {
    await _ensureInitialized();

    final scheduledDate = tz.TZDateTime.from(
      taskDate,
      tz.local,
    );

    if (!scheduledDate.isAfter(tz.TZDateTime.now(tz.local))) {
      return;
    }

    await plugin.zonedSchedule(
      id: deadlineId(taskKey),
      title: 'حان وقت مراجعة مهمتك',
      body: 'لسه قدامك مهمة "$taskName". تقدر تبدأ دلوقتي.',
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: _taskDetails,
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: 'task:$taskKey',
    );
  }

  Future<void> startDateScheduleTaskNotification({
    required int taskKey,
    required String taskName,
    required DateTime startDate,
  }) async {
    await _ensureInitialized();

    final scheduledDate = tz.TZDateTime.from(
      startDate,
      tz.local,
    );

    if (!scheduledDate.isAfter(tz.TZDateTime.now(tz.local))) {
      return;
    }

    await plugin.zonedSchedule(
      id: startId(taskKey),
      title: 'وقت البداية',
      body: 'جهّز نفسك وابدأ "$taskName".',
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: _taskDetails,
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: 'task:$taskKey',
    );
  }

  Future<void> cancelTaskNotification(int taskKey) async {
    await plugin.cancel(id: deadlineId(taskKey));
    await plugin.cancel(id: startId(taskKey));
    await plugin.cancel(id: taskSnoozeId(taskKey));
  }

  Future<void> _scheduleTaskSnooze(int taskKey) async {
    await _ensureInitialized();

    final scheduledDate = tz.TZDateTime.now(tz.local).add(
      const Duration(minutes: 5),
    );

    await plugin.zonedSchedule(
      id: taskSnoozeId(taskKey),
      title: 'رجعنا نفكرك بمهمتك',
      body: 'خد الخطوة اللي كنت مأجلها وابدأ بهدوء.',
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: _taskDetails,
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: 'task:$taskKey',
    );
  }

  // ============================================================
  // HABIT NOTIFICATIONS
  // ============================================================

  Future<void> scheduleHabitAlarm({
    required int habitKey,
    required String habitName,
    required int hour,
    required int minute,
  }) async {
    await _ensureInitialized();

    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      throw ArgumentError('Invalid habit alarm time');
    }

    final now = tz.TZDateTime.now(tz.local);

    var firstRing = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (!firstRing.isAfter(now)) {
      firstRing = firstRing.add(const Duration(days: 1));
    }

    await plugin.zonedSchedule(
      id: habitId(habitKey),
      title: 'وقت عادتك',
      body: 'خصص وقتك لـ "$habitName". كل خطوة صغيرة بتفرق.',
      scheduledDate: firstRing,
      notificationDetails: const NotificationDetails(
        android: _habitDetails,
      ),
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'habit:$habitKey',
    );
  }

  Future<void> cancelHabitAlarm(int habitKey) async {
    await plugin.cancel(id: habitId(habitKey));
    await plugin.cancel(id: habitSnoozeId(habitKey));
  }

  Future<void> _scheduleHabitSnooze(int habitKey) async {
    await _ensureInitialized();

    final scheduledDate = tz.TZDateTime.now(tz.local).add(
      const Duration(minutes: 5),
    );

    await plugin.zonedSchedule(
      id: habitSnoozeId(habitKey),
      title: 'لسه عندك وقت',
      body: 'تقدر ترجع لعادتك دلوقتي وتكمل يومك.',
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: _habitDetails,
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: 'habit:$habitKey',
    );
  }

  // ============================================================
  // MOTIVATIONAL NOTIFICATIONS
  // ============================================================

  Future<void> setMotivationalRemindersEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('motivationRemindersEnabled', enabled);

    if (enabled) {
      await scheduleMotivationalReminders();
    } else {
      await cancelMotivationalReminders();
    }
  }

  Future<void> scheduleMotivationalReminders() async {
    await _ensureInitialized();

    // 9 AM, 12 PM, 3 PM, 6 PM, 9 PM.
    // This keeps reminders away from typical sleeping hours.
    const hours = [9, 12, 15, 18, 21];

    final now = tz.TZDateTime.now(tz.local);

    for (int i = 0; i < hours.length; i++) {
      final hour = hours[i];

      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
      );

      if (!scheduledDate.isAfter(now)) {
        scheduledDate = scheduledDate.add(
          const Duration(days: 1),
        );
      }

      await plugin.zonedSchedule(
        id: _motivationOffset + i,
        title: 'رسالة من مسار',
        body: _motivationalMessages[i],
        scheduledDate: scheduledDate,
        notificationDetails: const NotificationDetails(
          android: _motivationDetails,
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  Future<void> cancelMotivationalReminders() async {
    for (int i = 0; i < 5; i++) {
      await plugin.cancel(id: _motivationOffset + i);
    }
  }

  // ============================================================
  // ACTION HANDLING
  // ============================================================

  Future<void> _handleAction(NotificationResponse response) async {
    final action = response.actionId;

    final payload = response.payload ?? '';
    final parts = payload.split(':');

    if (parts.length != 2) return;

    final type = parts[0];
    final key = int.tryParse(parts[1]);

    if (key == null) return;

    if (type == 'task') {
      await _handleTaskAction(key, action);
    } else if (type == 'habit') {
      await _handleHabitAction(key, action);
    }
  }

  Future<void> _handleTaskAction(int key, String? action) async {
    final box = Hive.box<TasksModel>('tasksBox');
    final task = box.get(key);

    if (task == null) return;

    switch (action) {
      case _taskDone:
        if (!task.completed) {
          task.completed = true;
          await task.save();
        }

        await cancelTaskNotification(key);
        break;

      case _taskNotDone:
      // The notification is dismissed.
      // The task remains incomplete.
        break;

      case _taskSnooze:
        await _scheduleTaskSnooze(key);
        break;
    }
  }

  Future<void> _handleHabitAction(int key, String? action) async {
    final box = Hive.box<HabitsModel>('habitsBox');
    final habit = box.get(key);

    if (habit == null) return;

    switch (action) {
      case _habitDone:
        if (!habit.habitCompleted) {
          habit
            ..habitCompleted = true
            ..streakCount += 1
            ..lastCompletedDate = DateTime.now();

          await habit.save();
        }

        await plugin.cancel(id: habitSnoozeId(key));
        break;

      case _habitSnooze:
        await _scheduleHabitSnooze(key);
        break;
    }
  }

  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await initNotification();
    }
  }

  Future<void> cancelAllNotifications() async {
    await plugin.cancelAll();
  }
}

// ============================================================
// BACKGROUND CALLBACK
// ============================================================

@pragma('vm:entry-point')
Future<void> notificationTapBackground(
    NotificationResponse response,
    ) async {
  WidgetsFlutterBinding.ensureInitialized();

  // This callback runs in a separate isolate.
  // Initialize Hive and register adapters in that isolate.
  await Hive.initFlutter();

  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(TasksModelAdapter());
  }

  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(HabitsModelAdapter());
  }

  if (!Hive.isBoxOpen('tasksBox')) {
    await Hive.openBox<TasksModel>('tasksBox');
  }

  if (!Hive.isBoxOpen('habitsBox')) {
    await Hive.openBox<HabitsModel>('habitsBox');
  }

  final service = NotificationsService();

  await service._handleAction(response);
}
