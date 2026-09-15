import 'package:flutter/material.dart';
import 'core/routing/app_router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MealMate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFC0392B), // Warm rust / deep terracotta red
          surface: const Color(0xFFFBF8F1), // Off-white/warm cream
        ),
      ),
      routerConfig: appRouter,
    );
  }
}
