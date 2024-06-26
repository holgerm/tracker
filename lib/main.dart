import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'src/tracker.dart';

late SharedPreferences preferences;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  preferences = await SharedPreferences.getInstance();

  // Initialize Hive
  await Hive.initFlutter();

  // Register the adapters
  // Hive.registerAdapter(SettingsAdapter());

  if (!Hive.isBoxOpen('tracker')) {
    await Hive.openBox('tracker');
  }

  runApp(ChangeNotifierProvider(
      create: (context) => TasksManager(), child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const TasksGrid(),
      routes: {
        '/settings': (context) => const SettingsPage(),
        // Add more routes here
      },
    );
  }
}
