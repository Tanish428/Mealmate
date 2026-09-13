import 'package:flutter/material.dart';
import 'ui/auth/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MealMate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFC43A3A), // Rust/red primary color
          surface: const Color(0xFFFBF8F1), // Off-white/warm cream
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
