// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/welcome.dart';
import 'screens/main_page.dart';

void main() => runApp(const GachiRunApp());

class GachiRunApp extends StatelessWidget {
  const GachiRunApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '가치런 GachiRun',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
      home: const WelcomeScreen(),   // 처음엔 웰컴부터
      routes: {
        '/home': (_) => const MainPage(), // 필요하면 네임드 라우트도
      },
    );
  }
}