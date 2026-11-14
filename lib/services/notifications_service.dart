import 'dart:typed_data';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationsService {
  final FlutterLocalNotificationsPlugin plugin =
  FlutterLocalNotificationsPlugin();

  static const int _habitIdOffset = 1000000;

  static int deadlineId(int taskKey) => taskKey * 2;
  static int startId(int taskKey) => taskKey * 2 + 1;
  static int habitId(int habitKey) => _habitIdOffset + habitKey;

  static const AndroidNotificationDetails _taskAndroidDetails =
  AndroidNotificationDetails(
    'tasks_channel_v2',
    'Task Notifications',
    channelDescription: 'Notifications for tasks',
    importance: Importance.max,
    priority: Priority.max,
    playSound: true,
    enableVibration: true
  );

  Future<void> initNotification() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/launcher_icon',
    );

    const settings = InitializationSettings(
      android: androidSettings,
    );

    await plugin.initialize(
      settings: settings,
    );

    final androidPlugin = plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.requestExactAlarmsPermission();
  }

  // ============================================================
  // TASKS
  // ============================================================

  Future<void> deadLineScheduleTaskNotification({
    required int taskKey,
    required String taskName,
    required DateTime taskDate,
  }) async {
    final scheduledDate = tz.TZDateTime.from(taskDate, tz.local);

    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
      return;
    }

    await plugin.zonedSchedule(
      id: deadlineId(taskKey),
      title: 'خلصت التاسك؟',
      body: taskName,
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: _taskAndroidDetails,
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> startDateScheduleTaskNotification({
    required int taskKey,
    required String taskName,
    required DateTime startDate,
  }) async {
    final scheduledDate = tz.TZDateTime.from(startDate, tz.local);

    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
      return;
    }

    await plugin.zonedSchedule(
      id: startId(taskKey),
      title: 'ابدأ التاسك؟',
      body: taskName,
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: _taskAndroidDetails,
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> cancelTaskNotification(int taskKey) async {
    await plugin.cancel(id: deadlineId(taskKey));
    await plugin.cancel(id: startId(taskKey));
  }


  Future<void> scheduleHabitAlarm({
    required int habitKey,
    required String habitName,
    required int hour,
    required int minute,
  }) async {
    final now = DateTime.now();

    var firstRing = DateTime(now.year, now.month, now.day, hour, minute);
    if (!firstRing.isAfter(now)) {
      firstRing = firstRing.add(const Duration(days: 1));
    }

    final scheduled = tz.TZDateTime.from(firstRing, tz.local);

    await plugin.zonedSchedule(
      id: habitId(habitKey),
      title: 'وقت الالتزام',
      body: habitName,
      scheduledDate: scheduled,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'habits_alarm_channel',
          'Habit Alarms',
          channelDescription: 'Alarms for habits',
          importance: Importance.max,
          priority: Priority.max,
          category: AndroidNotificationCategory.alarm,
          fullScreenIntent: true,
          audioAttributesUsage: AudioAttributesUsage.alarm,
          playSound: true,
          enableVibration: true,
          autoCancel: false,
          additionalFlags: Int32List.fromList(<int>[4]),
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelHabitAlarm(int habitKey) async {
    await plugin.cancel(id: habitId(habitKey));
  }


  Future<void> cancelAllNotifications() async {
    await plugin.cancelAll();
  }
}