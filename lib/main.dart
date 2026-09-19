import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/routing/app_router.dart';

Future<void> main() async {
  // Ensure native code is initialized before calling Supabase
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the PostgreSQL backend connection
  await Supabase.initialize(
    url: 'https://hwujjjtqnambqfuxyyel.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh3dWpqanRxbmFtYnFmdXh5eWVsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODk2NTE2OTEsImV4cCI6MjEwNTIyNzY5MX0.sI953Ibh3lyEVctkTAfhf2xMMjTRcVNkMtjD9uD-B5Q',
  );

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
          seedColor: const Color(0xFFC0392B), 
          surface: const Color(0xFFFBF8F1), 
        ),
      ),
      routerConfig: appRouter,
    );
  }
}