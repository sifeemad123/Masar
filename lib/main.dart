import 'package:flutter/material.dart';
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
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'package:hive_flutter/hive_flutter.dart';

import 'components/dialogs.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

  await Hive.openBox<TasksModel>('tasksBox');
  await Hive.openBox<HabitsModel>('habitsBox');
  await Hive.openBox<SubjectsModel>('subjectsBox');
  await Hive.openBox<LessonModel>('lessonsBox');
  await Hive.openBox<NotesModel>('notesBox');

  await NotificationsService().initNotification();

  final userDataProvider = UserDataProvider();
  await userDataProvider.deleteCompletedExpiredTasks();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: userDataProvider,
        ),
        ChangeNotifierProvider(
          create: (_) => HabitsProvider(),
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
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: Dialogs.navigatorKey,
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