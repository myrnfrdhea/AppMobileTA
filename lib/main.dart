import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_home_app/screens/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Smart Home App',
      theme: ThemeData(
        textTheme: GoogleFonts.inriaSansTextTheme(
          Theme.of(context).textTheme.apply(
                bodyColor: Colors.white,
                displayColor: Colors.white,
              ),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1166AA),
          primary: const Color(0xFF1166AA),
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
