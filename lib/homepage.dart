import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'Chatbot.dart';
import 'aboutus.dart';
import 'breathingexercise.dart';
import 'jouneralentry.dart';
import 'meditationscreen.dart';
import 'mind_games_screen.dart';
import 'music_therapy.dart';
import 'yoga_screen.dart';
import 'affirmations.dart';
import 'mood_tracker.dart';
import 'grounding.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  static const String _fallbackQuote =
      'Take one calm step at a time. Progress still counts.';
  static const String _fallbackAuthor = 'Mindful reminder';

  String _quote = _fallbackQuote;
  String _author = _fallbackAuthor;
  bool _loadingQuote = false;

  @override
  void initState() {
    super.initState();
    _fetchQuote();
  }

  Future<void> _fetchQuote() async {
    if (mounted) {
      setState(() {
        _loadingQuote = true;
      });
    }

    try {
      final response = await http
          .get(
            Uri.parse('https://api.api-ninjas.com/v1/quotes'),
            headers: const {
              'X-Api-Key': 'jA774RYMHWSVHd+w2I0Eyg==3mYvpCdfzwHeWXCd',
            },
          )
          .timeout(const Duration(seconds: 8));

      if (!mounted) {
        return;
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        final item = data.isNotEmpty
            ? data.first as Map<String, dynamic>
            : null;
        setState(() {
          _quote = (item?['quote'] as String?) ?? _fallbackQuote;
          _author = (item?['author'] as String?) ?? _fallbackAuthor;
          _loadingQuote = false;
        });
      } else {
        _setFallbackQuote();
      }
    } catch (_) {
      if (mounted) {
        _setFallbackQuote();
      }
    }
  }

  void _setFallbackQuote() {
    setState(() {
      _quote = _fallbackQuote;
      _author = _fallbackAuthor;
      _loadingQuote = false;
    });
  }

  void _open(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade500, Colors.indigo.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.favorite, color: Colors.white, size: 34),
                SizedBox(height: 16),
                Text(
                  'ManoVeda',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Calm tools for body, breath, and mind.',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.self_improvement),
            title: const Text('Meditation'),
            onTap: () {
              Navigator.pop(context);
              _open(const MeditationScreen());
            },
          ),
          ListTile(
            leading: const Icon(Icons.air),
            title: const Text('Breathing Exercises'),
            onTap: () {
              Navigator.pop(context);
              _open(const BreathingExerciseScreen());
            },
          ),
          ListTile(
            leading: const Icon(Icons.music_note),
            title: const Text('Music Therapy'),
            onTap: () {
              Navigator.pop(context);
              _open(const MusicTherapyScreen());
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit_note),
            title: const Text('My Journal'),
            onTap: () {
              Navigator.pop(context);
              _open(const JournalEntryScreen());
            },
          ),
          ListTile(
            leading: const Icon(Icons.fitness_center),
            title: const Text('Yoga'),
            onTap: () {
              Navigator.pop(context);
              _open(const YogaScreen());
            },
          ),
          ListTile(
            leading: const Icon(Icons.psychology_alt_rounded),
            title: const Text('Mind Games'),
            onTap: () {
              Navigator.pop(context);
              _open(const MindGamesScreen());
            },
          ),
          ListTile(
            leading: const Icon(Icons.smart_toy_outlined),
            title: const Text('AI Chatbot'),
            onTap: () {
              Navigator.pop(context);
              _open(const WebViewExample());
            },
          ),
          ListTile(
            leading: const Icon(Icons.account_circle_rounded),
            title: const Text('About Us'),
            onTap: () {
              Navigator.pop(context);
              _open(const AboutUsScreen());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.lightBlue.shade100, Colors.blue.shade300],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            children: [
              _featureTile(
                title: 'Meditation',
                subtitle: 'Find your inner peace with a guided timer.',
                icon: Icons.self_improvement,
                colors: [Colors.teal.shade400, Colors.teal.shade700],
                onTap: () => _open(const MeditationScreen()),
              ),
              _featureTile(
                title: 'Breathing Exercises',
                subtitle: 'Breathe in slowly and let stress settle.',
                icon: Icons.air,
                colors: [Colors.green.shade400, Colors.green.shade700],
                onTap: () => _open(const BreathingExerciseScreen()),
              ),
              _featureTile(
                title: 'Music Therapy',
                subtitle: 'Listen to calming tracks during a mental reset.',
                icon: Icons.music_note,
                colors: [Colors.indigo.shade400, Colors.indigo.shade700],
                onTap: () => _open(const MusicTherapyScreen()),
              ),
_featureTile(
                title: 'Yoga',
                subtitle: 'Practice gentle asanas with animated guidance.',
                icon: Icons.fitness_center,
                colors: [Colors.orange.shade400, Colors.orange.shade700],
                onTap: () => _open(const YogaScreen()),
              ),
              _featureTile(
                title: 'Affirmations',
                subtitle: 'Daily positive statements for self-care.',
                icon: Icons.lightbulb_outline,
                colors: [Colors.purple.shade400, Colors.purple.shade700],
                onTap: () => _open(const AffirmationsScreen()),
              ),
              _featureTile(
                title: 'Mood Tracker',
                subtitle: 'Log daily moods and see your patterns.',
                icon: Icons.mood,
                colors: [Colors.pink.shade400, Colors.pink.shade600],
                onTap: () => _open(const MoodTrackerScreen()),
              ),
              _featureTile(
                title: 'Grounding',
                subtitle: '5-4-3-2-1 exercise for anxiety moments.',
                icon: Icons.nature,
                colors: [Colors.green.shade400, Colors.green.shade700],
                onTap: () => _open(const GroundingScreen()),
              ),
              _featureTile(
                title: 'My Journal',
                subtitle: 'Capture feelings, thoughts, and daily reflection.',
                icon: Icons.edit_note,
                colors: [Colors.amber.shade400, Colors.amber.shade700],
                onTap: () => _open(const JournalEntryScreen()),
              ),
              _featureTile(
                title: 'Yoga',
                subtitle: 'Practice gentle asanas with animated guidance.',
                icon: Icons.fitness_center,
                colors: [Colors.orange.shade400, Colors.orange.shade700],
                onTap: () => _open(const YogaScreen()),
              ),
              _featureTile(
                title: 'Mind Games',
                subtitle: 'Two simple 2D games for memory and concentration.',
                icon: Icons.psychology_alt_rounded,
                colors: [Colors.deepPurple.shade400, Colors.indigo.shade700],
                onTap: () => _open(const MindGamesScreen()),
              ),
              _featureTile(
                title: 'AI Chatbot',
                subtitle: 'Talk with our AI companion when you need support.',
                icon: Icons.smart_toy_outlined,
                colors: [Colors.purple.shade400, Colors.purple.shade700],
                onTap: () => _open(const WebViewExample()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.lightBlue.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.wb_sunny_outlined, color: Colors.indigo),
                SizedBox(width: 8),
                Text(
                  'Daily wellbeing space',
                  style: TextStyle(
                    color: Colors.indigo,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Calm body, clear mind, gentle routines.',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'This app already uses soft blue gradients, rounded cards, and supportive language. The new mind games keep that same calm psychology-friendly feel.',
            style: TextStyle(
              fontSize: 15,
              color: Colors.blueGrey.shade700,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuoteCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.blue.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(3, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.format_quote_rounded,
            size: 30,
            color: Colors.white.withValues(alpha: 0.9),
          ),
          const SizedBox(height: 10),
          Text(
            '"$_quote"',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontStyle: FontStyle.italic,
              color: Colors.white,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '- $_author',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.yellow.shade200,
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: _loadingQuote ? null : _fetchQuote,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue.shade700,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: _loadingQuote
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh, size: 18),
            label: Text(_loadingQuote ? 'Refreshing...' : 'New Quote'),
          ),
        ],
      ),
    );
  }

  Widget _featureTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(3, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.84),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Icon(icon, size: 50, color: Colors.white.withValues(alpha: 0.92)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        title: const Text('ManoVeda'),
      ),
      drawer: _buildDrawer(),
      body: _buildBody(),
    );
  }
}
