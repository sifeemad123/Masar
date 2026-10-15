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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(TasksModelAdapter());
  await Hive.openBox<TasksModel>('tasksBox');
  Hive.registerAdapter(HabitsModelAdapter());
  await Hive.openBox<HabitsModel>("habitsBox");
  Hive.registerAdapter(SubjectsModelAdapter());
  await Hive.openBox<SubjectsModel>("subjectsBox");
  Hive.registerAdapter(LessonModelAdapter());
  await Hive.openBox<LessonModel>("lessonsBox");
  Hive.registerAdapter(NotesModelAdapter());
  await Hive.openBox<NotesModel>("notesBox");
  await NotificationsService().initNotification();

  UserDataProvider().deleteCompletedExpiredTasks();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserDataProvider()),
        ChangeNotifierProvider(create: (_) => HabitsProvider()),
        ChangeNotifierProvider(create: (_) => SubjectsProvider()),
        ChangeNotifierProvider(create: (_) => LessonsProvider()),
        ChangeNotifierProvider(create: (_) => NotesProvider()),
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