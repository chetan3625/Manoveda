import 'package:flutter/material.dart';
import 'Loginpage.dart';


void main() {
  runApp(const Manoveda());
}

class Manoveda extends StatelessWidget {
  const Manoveda({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Manoveda',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF63B6E7),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF2FAFF),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.lightBlueAccent,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
        ),
      ),
      home: const Loginpage(),
    );
  }
}
