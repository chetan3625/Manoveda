import 'package:flutter/material.dart';
import 'package:manoveda/widgets/app_scaffold.dart';
import 'package:intl/intl.dart';

import 'wellness_repository.dart';

class MoodEntry {
  final int id;
  final DateTime date;
  final int mood;
  final String? note;

  MoodEntry({
    required this.id,
    required this.date,
    required this.mood,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.millisecondsSinceEpoch,
      'mood': mood,
      'note': note,
    };
  }

  factory MoodEntry.fromMap(Map<String, dynamic> map) {
    return MoodEntry(
      id: map['id'] as int,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      mood: map['mood'] as int,
      note: map['note'] as String?,
    );
  }
}

class MoodTrackerScreen extends StatefulWidget {
  const MoodTrackerScreen({super.key});

  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen> {
  int _currentMood = 5;
  final TextEditingController _noteController = TextEditingController();
  List<MoodEntry> _history = [];

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final maps = await WellnessRepository.instance.getMoodHistory(limit: 30);
      if (mounted) {
        setState(() {
          _history = maps.map((map) => MoodEntry.fromMap(map)).toList();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Load history error: $e')),
        );
      }
    }
  }

  Future<void> _saveMood() async {
    try {
      await WellnessRepository.instance.saveMood(
        mood: _currentMood,
        note: _noteController.text.isEmpty ? null : _noteController.text,
      );
      _noteController.clear();
      await _loadHistory();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mood saved!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save error: $e')),
        );
      }
    }
  }

  Color _moodColor(int mood) {
    if (mood <= 2) return Colors.red;
    if (mood <= 4) return Colors.orange;
    if (mood <= 6) return Colors.yellow;
    if (mood <= 8) return Colors.lightGreen;
    return Colors.green;
  }

  String _moodEmoji(int mood) {
    if (mood <= 2) return '😢';
    if (mood <= 4) return '😐';
    if (mood <= 6) return '🙂';
    if (mood <= 8) return '😊';
    return '🥰';
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: const Text('Mood Tracker'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
          children: [
            // Current Mood Entry
            Container(
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'How are you feeling today?',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Text(_moodEmoji(_currentMood)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Slider(
                          value: _currentMood.toDouble(),
                          min: 1,
                          max: 10,
                          divisions: 9,
                          activeColor: _moodColor(_currentMood),
                          onChanged: (value) {
                            setState(() {
                              _currentMood = value.round();
                            });
                          },
                        ),
                      ),
                      Text('$_currentMood', style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _noteController,
                    maxLines: 2,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: r"Whats on your mind? (optional)",
                      hintStyle: const TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveMood,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Save Todays Mood'),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadHistory,
                child: _history.isEmpty
                    ? const Center(
                        child: Text(
                          'No mood entries yet.\nStart tracking your feelings!',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, color: Colors.white70),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _history.length,
                        itemBuilder: (context, index) {
                          final entry = _history[index];
                          final dateStr = DateFormat('MMM dd').format(entry.date);
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _moodColor(entry.mood),
                                child: Text(_moodEmoji(entry.mood)),
                              ),
                              title: Text('$dateStr - Mood ${_moodEmoji(entry.mood)}'),
                              subtitle: Text(entry.note ?? 'No note'),
                              trailing: Text('${entry.mood}/10'),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }
}
