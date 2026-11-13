import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() => runApp(const FunnyAgeApp());

class FunnyAgeApp extends StatelessWidget {
  const FunnyAgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Funny Age Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C4DFF),
          secondary: const Color(0xFFFFC400),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
