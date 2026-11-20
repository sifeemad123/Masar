
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'package:masar/Screens/splash_screen.dart';

import 'package:masar/models/habits_model.dart';
import 'package:masar/models/lesson_model.dart';
import 'package:masar/models/notes_model.dart';
import 'package:masar/models/subjects_model.dart';
import 'package:masar/models/tasks_model.dart';

import 'package:masar/providers/habits_provider.dart';
import 'package:masar/providers/lessons_provider.dart';
import 'package:masar/providers/notes_provider.dart';
import 'package:masar/providers/subjects_provider.dart';
import 'package:masar/providers/user_data_provider.dart';

import 'package:masar/services/notifications_service.dart';
import 'package:masar/theme/AppColors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ========================= HIVE INITIALIZATION =========================

  await Hive.initFlutter();

  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(TasksModelAdapter());
  }

  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(HabitsModelAdapter());
  }

  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(SubjectsModelAdapter());
  }

  if (!Hive.isAdapterRegistered(3)) {
    Hive.registerAdapter(LessonModelAdapter());
  }

  if (!Hive.isAdapterRegistered(4)) {
    Hive.registerAdapter(NotesModelAdapter());
  }

  // ========================= OPEN HIVE BOXES =========================

  await Hive.openBox<TasksModel>('tasksBox');
  await Hive.openBox<HabitsModel>('habitsBox');
  await Hive.openBox<SubjectsModel>('subjectsBox');
  await Hive.openBox<LessonModel>('lessonsBox');
  await Hive.openBox<NotesModel>('notesBox');

  // ========================= PROVIDERS INITIALIZATION =========================

  final habitsProvider = HabitsProvider();

  // تحديث حالة العادات والـ Streak عند تشغيل التطبيق.
  await habitsProvider.resetCompletedHabits();

  final userDataProvider = UserDataProvider();

  await userDataProvider.deleteCompletedExpiredTasks();

  // ========================= NOTIFICATIONS INITIALIZATION =========================

  try {
    await NotificationsService().initNotification();
  } catch (e) {
    debugPrint('Notifications initialization error: $e');
  }

  // ========================= RUN APPLICATION =========================

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: userDataProvider,
        ),

        ChangeNotifierProvider.value(
          value: habitsProvider,
        ),

        ChangeNotifierProvider(
          create: (_) => SubjectsProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => LessonsProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => NotesProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationsService.openPendingAlarm();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: NotificationsService.navigatorKey,

      builder: (context, child) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: child,
      ),

      debugShowCheckedModeBanner: false,

      locale: const Locale('ar'),

      supportedLocales: const [
        Locale('ar'),
      ],

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'ReadexPro-Regular',

        textSelectionTheme: TextSelectionThemeData(
          cursorColor: AppColors.textSecondary,
          selectionColor: AppColors.textSecondary.withOpacity(0.3),
          selectionHandleColor: AppColors.textPrimary,
        ),
      ),

      home: const SplashScreen(),
    );
  }
}
