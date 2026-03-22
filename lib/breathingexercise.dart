import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BreathingExerciseScreen extends StatefulWidget {
  const BreathingExerciseScreen({super.key});

  @override
  State<BreathingExerciseScreen> createState() => _BreathingExerciseScreenState();
}

class _BreathingExerciseScreenState extends State<BreathingExerciseScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  String _instruction = "Ready?";
  String _selectedLanguage = "English";
  bool _languageDialogShown = false;
  int _lastPhase = -1;

  // Exact asset paths provided by user.
  final Map<String, Map<String, String>> _languageSounds = {
    "English": {
      "inhale": "assets/audio/Breathe/english/inhale.mp3",
      "exhale": "assets/audio/Breathe/english/exhale.mp3",
    },
    "Hindi": {
      "inhale": "assets/audio/Breathe/hindi/inhale.mp3",
      "exhale": "assets/audio/Breathe/hindi/exhale.mp3",
    },
    "Marathi": {
      "inhale": "assets/audio/Breathe/marathi/inhale.mp3",
      "exhale": "assets/audio/Breathe/marathi/exhale.mp3",
    },
  };

  final AudioPlayer _voicePlayer = AudioPlayer();
  final Map<String, Map<String, Uint8List>> _resolvedAudio = {};

  @override
  void initState() {
    super.initState();
    _voicePlayer.setAudioContext(
      AudioContext(
        android: AudioContextAndroid(
          isSpeakerphoneOn: true,
          stayAwake: false,
          contentType: AndroidContentType.sonification,
          usageType: AndroidUsageType.assistanceSonification,
          audioFocus: AndroidAudioFocus.gainTransient,
        ),
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: <AVAudioSessionOptions>{},
        ),
      ),
    );
    _voicePlayer.setReleaseMode(ReleaseMode.stop);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16), // 4 seconds per phase x 4 phases
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() {
        final phase = _controller.duration!.inSeconds * _animation.value;
        final int currentPhase = phase ~/ 4; // 0: inhale,1: hold1,2: exhale,3: hold2

        if (currentPhase != _lastPhase) {
          _lastPhase = currentPhase;
          _handlePhaseChange(currentPhase);
        }
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.repeat();
        }
      });
  }

  Future<bool> _ensureAudioForLanguage(String lang) async {
    if (_resolvedAudio.containsKey(lang)) return true;
    final inhaleBytes = await _resolveBytes(lang, "inhale");
    final exhaleBytes = await _resolveBytes(lang, "exhale");

    if (inhaleBytes == null || exhaleBytes == null) {
      return false;
    }
    _resolvedAudio[lang] = {
      "inhale": inhaleBytes,
      "exhale": exhaleBytes,
    };
    return true;
  }

  @override
  void dispose() {
    _voicePlayer.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handlePhaseChange(int phase) async {
    switch (phase) {
      case 0:
        setState(() {
          _instruction = "Inhale...";
        });
        await _playInhale();
        break;
      case 1:
        setState(() {
          _instruction = "Hold...";
        });
        break;
      case 2:
        setState(() {
          _instruction = "Exhale...";
        });
        await _playExhale();
        break;
      case 3:
        setState(() {
          _instruction = "Hold...";
        });
        break;
      default:
        setState(() {
          _instruction = "Ready?";
        });
    }
  }

  Future<void> _playInhale() async {
    await _playCue(_selectedLanguage, "inhale");
  }

  Future<void> _playExhale() async {
    await _playCue(_selectedLanguage, "exhale");
  }

  Future<void> _playCue(String lang, String phase) async {
    try {
      final ready = await _ensureAudioForLanguage(lang);
      if (!ready || !_resolvedAudio.containsKey(lang) || !_resolvedAudio[lang]!.containsKey(phase)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Audio missing for $lang $phase')),
          );
        }
        return;
      }
      final bytes = _resolvedAudio[lang]![phase]!;
      await _voicePlayer.stop();
      await _voicePlayer.play(BytesSource(bytes));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Audio error: $e')),
        );
      }
    }
  }

  Future<Uint8List?> _resolveBytes(String lang, String phase) async {
    final key = _languageSounds[lang]?[phase];
    if (key == null) return null;
    try {
      final data = await rootBundle.load(key);
      return data.buffer.asUint8List();
    } catch (_) {}
    return null;
  }

  void _startBreathing() {
    setState(() {
      _lastPhase = -1;
      _instruction = "Ready?";
    });
    _ensureAudioForLanguage(_selectedLanguage);
    // Trigger first inhale immediately so the cue is heard as soon as user starts.
    _handlePhaseChange(0);
    _controller.repeat();
  }

  void _stopBreathing() {
    _controller.stop();
    _voicePlayer.stop();
    setState(() {
      _instruction = "Ready?";
      _lastPhase = -1;
    });
  }

  Future<void> _showLanguageDialog() async {
    final chosen = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        String tempSelection = _selectedLanguage;
        return AlertDialog(
          title: const Text("Select breathing language"),
          content: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: _languageSounds.keys.map((lang) {
                  return RadioListTile<String>(
                    title: Text(lang),
                    value: lang,
                    groupValue: tempSelection,
                    onChanged: (value) {
                      setModalState(() {
                        tempSelection = value!;
                      });
                    },
                  );
                }).toList(),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(tempSelection),
              child: const Text("Continue"),
            ),
          ],
        );
      },
    );

    if (chosen != null) {
      setState(() {
        _selectedLanguage = chosen;
        _lastPhase = -1;
        _instruction = "Ready?";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_languageDialogShown) {
      _languageDialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showLanguageDialog();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Guided Breathing'),
        backgroundColor: Colors.lightBlueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.translate),
            tooltip: "Change language",
            onPressed: () async {
              await _showLanguageDialog();
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlue.shade100, Colors.blue.shade300],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Container(
                    width: 100.0 + (_animation.value * 150.0),
                    height: 100.0 + (_animation.value * 150.0),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade700,
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 50),
              Text(
                _instruction,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black45,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Language: $_selectedLanguage",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _startBreathing,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton.icon(
                    onPressed: _stopBreathing,
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
