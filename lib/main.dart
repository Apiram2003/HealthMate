import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';

/// The main entry point of the Flutter application.
void main() {
  runApp(const HealthMateApp());
}

/// The root widget of the entire HealthMate application.
/// It configures the app title, Material 3 teal theme, and sets
/// the initial screen to DashboardScreen.
class HealthMateApp extends StatelessWidget {
  const HealthMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HealthMate',
      debugShowCheckedModeBanner: false,
      // Material 3 theme configuration with Teal as the primary color
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}
