import 'package:flutter/material.dart';
import 'api_service.dart';
import 'affirmations.dart';
import 'breathingexercise.dart';
import 'grounding.dart';
import 'jouneralentry.dart';
import 'meditationscreen.dart';
import 'mind_games_screen.dart';
import 'mood_tracker.dart';
import 'music_therapy.dart';
import 'notification_service.dart';
import 'splashscreen.dart';
import 'schedule_screen.dart';
import 'voice_chatbot_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize notification service with the global navigator key
  await NotificationService().init(navigatorKey);
  await ApiService.init();
  runApp(const Manoveda());
}

class Manoveda extends StatelessWidget {
  const Manoveda({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
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
      routes: {
        '/scheduler': (context) => const ScheduleScreen(),
        '/chatbot': (context) => const VoiceChatbotScreen(),
        '/meditation': (context) => const MeditationScreen(),
        '/breathing_exercise': (context) => const BreathingExerciseScreen(),
        '/music_therapy': (context) => const MusicTherapyScreen(),
        '/reading_affirmation': (context) => const AffirmationsScreen(),
        '/mind_games': (context) => const MindGamesScreen(),
        '/writing_journal': (context) => const JournalEntryScreen(),
        '/grounding': (context) => const GroundingScreen(),
        '/mood_submit': (context) => const MoodTrackerScreen(),
        '/wellness_timeline': (context) => const ScheduleScreen(),
      },
    );
  }
}
