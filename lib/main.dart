import 'package:flutter/material.dart';
import 'data/rest_preset_storage.dart';
import 'data/workout_storage.dart';
import 'data/schedule_storage.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await WorkoutStorage.instance.init();
  await RestPresetStorage.instance.init();
  await ScheduleStorage.instance.init();
  runApp(const NextRepApp());
}

class NextRepApp extends StatelessWidget {
  const NextRepApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NextRep',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D1B1E),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF2A9D8F),
          secondary: Color(0xFF2A9D8F),
          surface: Color(0xFF152126),
          onSurface: Colors.white,
          onPrimary: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0D1B1E),
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
