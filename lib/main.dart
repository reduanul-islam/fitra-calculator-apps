import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const FitraCalculatorApp());
}

class FitraCalculatorApp extends StatelessWidget {
  const FitraCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fitra Calculator',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF6F6F2),
        fontFamily: 'Arial',
      ),
      home: const HomeScreen(),
    );
  }
}
