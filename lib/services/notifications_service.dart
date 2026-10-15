import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationsService {
  final FlutterLocalNotificationsPlugin plugin =
  FlutterLocalNotificationsPlugin();

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

    final androidPlugin =
    plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.requestNotificationsPermission();
  }

  Future<void> scheduleTaskNotification({
    required int id,
    required String taskName,
    required DateTime taskDate,
  }) async {
    final scheduledDate = tz.TZDateTime.from(
      taskDate,
      tz.local,
    );

    if (scheduledDate.isBefore(
      tz.TZDateTime.now(tz.local),
    )) {
      return;
    }

    await plugin.zonedSchedule(
      id: id,
      title: 'خلصت التاسك؟',
      body: taskName,
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'tasks_channel',
          'Task Notifications',
          channelDescription: 'Notifications for tasks',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode:
      AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> cancelTaskNotification(int id) async {
    await plugin.cancel(id: id);
  }

  Future<void> cancelAllNotifications() async {
    await plugin.cancelAll();
  }
}