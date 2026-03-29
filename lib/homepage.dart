import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:manoveda/widgets/app_scaffold.dart';

import 'aboutus.dart';
import 'affirmations.dart';
import 'breathingexercise.dart';
import 'grounding.dart';
import 'jouneralentry.dart';
import 'meditationscreen.dart';
import 'mind_games_screen.dart';
import 'mood_detection_screen.dart';
import 'mood_tracker.dart';
import 'music_therapy.dart';
import 'schedule_screen.dart';
import 'voice_chatbot_screen.dart';
import 'wellness_repository.dart';
import 'yoga_screen.dart';

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
  bool _loadingDashboard = true;
  DashboardSummary? _summary;

  @override
  void initState() {
    super.initState();
    _refreshDashboard();
    _fetchQuote();
  }

  Future<void> _refreshDashboard() async {
    setState(() => _loadingDashboard = true);
    final summary = await WellnessRepository.instance.buildDashboardSummary();
    if (!mounted) {
      return;
    }
    setState(() {
      _summary = summary;
      _loadingDashboard = false;
    });
  }

  Future<void> _fetchQuote() async {
    if (mounted) {
      setState(() => _loadingQuote = true);
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
        final item =
            data.isNotEmpty ? data.first as Map<String, dynamic> : null;
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

  Future<void> _open(Widget page) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    if (mounted) {
      _refreshDashboard();
    }
  }

  Widget _buildDrawer() {
    final items = [
      _DrawerItem(Icons.home, 'Home', null),
      _DrawerItem(Icons.self_improvement, 'Meditation',
          () => _open(const MeditationScreen())),
      _DrawerItem(Icons.air, 'Breathing Exercises',
          () => _open(const BreathingExerciseScreen())),
      _DrawerItem(Icons.music_note, 'Music Therapy',
          () => _open(const MusicTherapyScreen())),
      _DrawerItem(Icons.edit_note, 'My Journal',
          () => _open(const JournalEntryScreen())),
      _DrawerItem(
          Icons.fitness_center, 'Yoga', () => _open(const YogaScreen())),
      _DrawerItem(Icons.psychology_alt_rounded, 'Mind Games',
          () => _open(const MindGamesScreen())),
      _DrawerItem(Icons.mood, 'Mood Tracker',
          () => _open(const MoodTrackerScreen())),
      _DrawerItem(Icons.auto_awesome, 'Affirmations',
          () => _open(const AffirmationsScreen())),
      _DrawerItem(Icons.park_outlined, 'Grounding',
          () => _open(const GroundingScreen())),
      _DrawerItem(Icons.face_retouching_natural, 'Mood Detection',
          () => _open(const MoodDetectionScreen())),
      _DrawerItem(Icons.smart_toy_outlined, 'AI Voice Assistant',
          () => _open(const VoiceChatbotScreen())),
      _DrawerItem(Icons.history_toggle_off, 'Wellness Timeline',
          () => _open(const ScheduleScreen())),
      _DrawerItem(Icons.account_circle_rounded, 'About Us',
          () => _open(const AboutUsScreen())),
    ];

    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF4338CA), Color(0xFF0F172A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.favorite_rounded, color: Colors.white, size: 32),
                SizedBox(height: 14),
                Text(
                  'ManoVeda',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Your wellness dashboard and routine space',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: items.length,
              itemBuilder: (_, i) {
                final item = items[i];
                return ListTile(
                  leading: Icon(item.icon, color: const Color(0xFF3B82F6)),
                  title: Text(item.label),
                  onTap: item.onTap == null
                      ? () => Navigator.pop(context)
                      : () {
                          Navigator.pop(context);
                          item.onTap!();
                        },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero(DashboardSummary summary) {
    final monthChangeText = summary.monthlyImprovement >= 0
        ? '+${summary.monthlyImprovement.toStringAsFixed(0)}%'
        : '${summary.monthlyImprovement.toStringAsFixed(0)}%';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E40AF), Color(0xFF3B82F6), Color(0xFF06B6D4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Text(
                  DateFormat('MMM dd').format(DateTime.now()),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Text(
                  monthChangeText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            summary.greeting,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            summary.message,
            style: TextStyle(
              color: Colors.white.withOpacity(0.82),
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _heroStat(
                  label: 'Today score',
                  value: '${summary.todayScore}',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _heroStat(
                  label: 'Mindful min',
                  value: '${summary.totalMindfulMinutes}',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _heroStat(
                  label: 'Tasks done',
                  value: '${summary.completedToday}/${summary.scheduledToday}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroStat({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.76),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightStrip(DashboardSummary summary) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _smallMetricCard(
              'Monthly growth',
              summary.monthlyImprovement.isFinite
                  ? '${summary.monthlyImprovement.toStringAsFixed(0)}%'
                  : '0%',
              'vs last month',
              const Color(0xFF60A5FA),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _smallMetricCard(
              'Mood average',
              summary.moodAverage > 0
                  ? '${summary.moodAverage.toStringAsFixed(1)}/10'
                  : '--',
              'tracked this month',
              const Color(0xFF38BDF8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallMetricCard(
    String title,
    String value,
    String caption,
    Color accent,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.insights_rounded, color: accent, size: 18),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            caption,
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildQuoteCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withOpacity(0.76),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.16),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.format_quote_rounded,
              color: Color(0xFF60A5FA), size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _quote,
                  style: const TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '- $_author',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF93C5FD),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _loadingQuote ? null : _fetchQuote,
            icon: _loadingQuote
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, {String? action, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          if (action != null && onTap != null)
            TextButton(
              onPressed: onTap,
              child: Text(action),
            ),
        ],
      ),
    );
  }

  Widget _buildWeeklyGraph(DashboardSummary summary) {
    final maxScore = summary.weeklyBars.fold<double>(
      10,
      (maxValue, item) => item.score > maxValue ? item.score : maxValue,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Wellness growth graph',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'This graph reflects the last 7 days of your stored wellness interactions.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 180,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: summary.weeklyBars.map((bar) {
                final ratio = (bar.score / maxScore).clamp(0.08, 1.0);
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          bar.score.toStringAsFixed(0),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.65),
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 8),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          height: 110 * ratio,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: bar.isToday
                                  ? const [Color(0xFF38BDF8), Color(0xFF1D4ED8)]
                                  : const [Color(0xFF60A5FA), Color(0xFF06B6D4)],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          bar.label,
                          style: TextStyle(
                            color: bar.isToday ? Colors.white : Colors.white70,
                            fontWeight:
                                bar.isToday ? FontWeight.bold : FontWeight.w500,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineProgress(DashboardSummary summary) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          if (summary.scheduledTasks.isEmpty)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  const Text(
                    'Your timeline is empty.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Set daily reminder times so the dashboard can compare scheduled tasks with completed tasks.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _open(const ScheduleScreen()),
                    icon: const Icon(Icons.history_toggle_off),
                    label: const Text('Create wellness timeline'),
                  ),
                ],
              ),
            )
          else
            ...summary.scheduledTasks.map((task) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: task.completedToday
                        ? task.task.color.withOpacity(0.45)
                        : Colors.white10,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: task.task.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(task.task.icon, color: task.task.color),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.task.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Reminder at ${task.time.format(context)}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          task.completedToday ? 'Done today' : 'Pending',
                          style: TextStyle(
                            color: task.completedToday
                                ? const Color(0xFF86EFAC)
                                : const Color(0xFFFDE68A),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${task.streakCount} day streak',
                          style:
                              const TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildNotices(DashboardSummary summary) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: summary.notices.map((notice) {
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              notice,
              style: const TextStyle(
                color: Colors.white,
                height: 1.45,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.favorite_rounded, size: 20, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'ManoVeda Dashboard',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _refreshDashboard,
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: RefreshIndicator(
        onRefresh: _refreshDashboard,
        child: _loadingDashboard
            ? _buildLoadingState()
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_summary != null) ...[
                      _buildHero(_summary!),
                      _buildInsightStrip(_summary!),
                      _buildQuoteCard(),
                      _sectionHeader('Growth Graph'),
                      _buildWeeklyGraph(_summary!),
                      _sectionHeader(
                        'Daily Wellness Timeline',
                        action: 'Edit',
                        onTap: () => _open(const ScheduleScreen()),
                      ),
                      _buildTimelineProgress(_summary!),
                      _sectionHeader('What To Notice'),
                      _buildNotices(_summary!),
                    ],
                  ],
                ),
              ),
      ),
    );
  }
}

class _DrawerItem {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _DrawerItem(this.icon, this.label, this.onTap);
}
