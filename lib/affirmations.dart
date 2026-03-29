import 'package:flutter/material.dart';
import 'package:manoveda/widgets/app_scaffold.dart';

import 'wellness_repository.dart';

class AffirmationsScreen extends StatefulWidget {
  const AffirmationsScreen({super.key});

  @override
  State<AffirmationsScreen> createState() => _AffirmationsScreenState();
}

class _AffirmationsScreenState extends State<AffirmationsScreen> {
  final List<String> _affirmations = const [
    'I am strong and capable.',
    'Every day, I grow a little more.',
    'I am exactly where I need to be.',
    'My thoughts shape my reality.',
    'I release what no longer serves me.',
    'I am worthy of love and respect.',
    'Peace begins with my breath.',
    'I trust the journey of my life.',
    'Challenges help me grow.',
    'I am compassionate to myself.',
    'My mind is calm and clear.',
    'I choose hope over worry.',
    'I am resilient.',
    'Healing is possible for me.',
    'I celebrate small victories.',
  ];

  int _currentIndex = 0;

  Future<void> _logAffirmation(String action) async {
    await WellnessRepository.instance.logEvent(
      taskKey: 'reading_affirmation',
      title: 'Reading Affirmation',
      details: '$action: ${_affirmations[_currentIndex]}',
      score: 5,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: const Text('Daily Affirmations'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Icon(
                Icons.lightbulb_outline,
                size: 80,
                color: Colors.yellow,
              ),
              const SizedBox(height: 20),
              const Text(
                'Repeat after me:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(30),
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
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
                    Text(
                      _affirmations[_currentIndex],
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Say it 3 times slowly.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _currentIndex > 0
                            ? () {
                                setState(() => _currentIndex--);
                                _logAffirmation('Previous');
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.arrow_left),
                        label: const Text('Previous'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() => _currentIndex = (_currentIndex + 1) % _affirmations.length);
                          _logAffirmation('Next');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.arrow_right),
                        label: const Text('Next'),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: TextButton.icon(
                  onPressed: () {
                    setState(() => _currentIndex = DateTime.now().millisecondsSinceEpoch ~/ 86400000 % _affirmations.length);
                    _logAffirmation('Random');
                  },
                  icon: const Icon(Icons.shuffle),
                  label: const Text('Random'),
                  style: TextButton.styleFrom(foregroundColor: Colors.white),
                ),
              ),
            ],
          ),
        ),
    );
  }
}
