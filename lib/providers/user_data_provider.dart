import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:masar/components/dialogs.dart';
import 'package:masar/models/tasks_model.dart';
import 'package:masar/services/notifications_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserDataProvider extends ChangeNotifier {
  String _userName = '';

  String get userName => _userName;

  static Box<TasksModel> tasksBox() {
    return Hive.box<TasksModel>('tasksBox');
  }

  List<TasksModel> get tasks {
    return tasksBox().values.toList();
  }


  Future<void> _scheduleTaskNotifications({
    required int taskKey,
    required String taskName,
    required DateTime taskDate,
    required DateTime startDate,
  }) async {
    final service = NotificationsService();

    await service.deadLineScheduleTaskNotification(
      taskKey: taskKey,
      taskName: taskName,
      taskDate: taskDate,
    );

    await service.startDateScheduleTaskNotification(
      taskKey: taskKey,
      taskName: taskName,
      startDate: startDate,
    );
  }

  Future<void> addNewTask({
    required String taskName,
    required DateTime taskDate,
    required DateTime startDate,
  }) async {
    final task = TasksModel()
      ..taskName = taskName
      ..completed = false
      ..taskDate = taskDate
      ..startDate = startDate;

    final taskKey = await tasksBox().add(task);

    await _scheduleTaskNotifications(
      taskKey: taskKey,
      taskName: taskName,
      taskDate: taskDate,
      startDate: startDate,
    );

    notifyListeners();
  }


  Future<void> deleteTask({
    required TasksModel task,
  }) async {
    if (task.key is int) {
      await NotificationsService().cancelTaskNotification(
        task.key as int,
      );
    }

    await task.delete();

    notifyListeners();
  }


  Future<void> toggleTask({
    required TasksModel task,
  }) async {
    task.completed = !task.completed;

    await task.save();

    final taskKey = task.key;

    if (taskKey is int) {
      if (task.completed) {
        await NotificationsService().cancelTaskNotification(
          taskKey,
        );
      } else {
        await _scheduleTaskNotifications(
          taskKey: taskKey,
          taskName: task.taskName,
          taskDate: task.taskDate,
          startDate: task.startDate,
        );
      }
    }

    notifyListeners();
  }

  Future<void> updateTask(
      TasksModel task,
      String taskName,
      DateTime taskDate, {
        required DateTime startDate,
      }) async {
    final taskKey = task.key;

    if (taskKey is int) {
      await NotificationsService().cancelTaskNotification(
        taskKey,
      );
    }

    task.taskName = taskName;
    task.taskDate = taskDate;
    task.startDate = startDate;

    await task.save();

    if (!task.completed && taskKey is int) {
      await _scheduleTaskNotifications(
        taskKey: taskKey,
        taskName: taskName,
        taskDate: taskDate,
        startDate: startDate,
      );
    }

    notifyListeners();
  }


  Future<void> deleteCompletedExpiredTasks() async {
    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final expiredTasks = tasksBox().values.where((task) {
      final taskDay = DateTime(
        task.taskDate.year,
        task.taskDate.month,
        task.taskDate.day,
      );

      return task.completed && taskDay.isBefore(today);
    }).toList();

    for (final task in expiredTasks) {
      if (task.key is int) {
        await NotificationsService().cancelTaskNotification(
          task.key as int,
        );
      }

      await task.delete();
    }

    notifyListeners();
  }


  Future<void> getUserName() async {
    final pref = await SharedPreferences.getInstance();

    _userName = pref.getString('userName') ?? '';

    notifyListeners();
  }

  Future<void> editUserName({
    required String userName,
    required BuildContext context,
  }) async {
    final pref = await SharedPreferences.getInstance();

    await pref.setString(
      'userName',
      userName,
    );

    _userName = userName;

    notifyListeners();

    Dialogs.success(
      context: context,
      message: "تم تعديل الاسم بنجاح",
    );
  }

  // ============================================================
  // DELETE ALL DATA
  // ============================================================

  Future<void> deleteAllData() async {
    await NotificationsService().cancelAllNotifications();
    await Hive.deleteBoxFromDisk('tasksBox');
    await Hive.deleteBoxFromDisk('lessonsBox');
    await Hive.deleteBoxFromDisk('subjectsBox');
    await Hive.deleteBoxFromDisk('habitsBox');
    await Hive.deleteBoxFromDisk('notesBox');
    final pref = await SharedPreferences.getInstance();
    await pref.clear();

    notifyListeners();
  }
}