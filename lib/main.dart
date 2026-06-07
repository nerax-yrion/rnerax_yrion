import 'package:flutter/material.dart';

import 'partie connexion et inscription/connexion.dart';

void main() {
  runApp(const YrionApp());
}

class YrionApp extends StatelessWidget {
  const YrionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Yrion',

      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F172A),
          elevation: 0,
          centerTitle: true,
        ),
      ),

      home: const ConnexionPage(),
    );
  }
}