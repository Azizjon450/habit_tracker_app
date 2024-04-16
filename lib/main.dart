import 'package:flutter/material.dart';
import 'package:habit_tracker_app/database/habit_database.dart';
import 'package:provider/provider.dart';

import '../theme/theme_provider.dart';
import '../pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // initialize database
  await HabitDatabse.initialize();
  await HabitDatabse().saveFirstLaunchDate();

  runApp(
    MultiProvider(
      providers: [
        // habit provider
        ChangeNotifierProvider(create: (context) => HabitDatabse()),

        // theme provider
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
      theme: Provider.of<ThemeProvider>(context).themeData,
    );
  }
}
