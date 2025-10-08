import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

class MeditationScreen extends StatefulWidget {
  const MeditationScreen({super.key});

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen> {
  int _selectedMinutes = 5; // User-selectable duration in minutes
  int _currentTime = 0;
  bool _isMeditationActive = false;
  late Timer _timer;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _currentTime = _selectedMinutes * 60; // Initialize with the selected duration
  }

  void playAlarm() async {
    await _audioPlayer.setSource(AssetSource('audio/music2.mp3'));
    await _audioPlayer.resume();
  }

  void startMeditation() {
    if (_currentTime == 0) {
      // Prevents starting a timer with 0 duration
      _currentTime = _selectedMinutes * 60;
    }
    setState(() {
      _isMeditationActive = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentTime > 0) {
        setState(() {
          _currentTime--;
        });
      } else {
        _timer.cancel();
        setState(() {
          _isMeditationActive = false;
        });
        playAlarm();
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Session Complete"),
              content: const Text("Congratulations! You've completed your meditation session."),
              actions: <Widget>[
                TextButton(
                  child: const Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                    resetMeditation();
                  },
                ),
              ],
            );
          },
        );
      }
    });
  }

  void pauseMeditation() {
    if (_timer.isActive) {
      _timer.cancel();
      setState(() {
        _isMeditationActive = false;
      });
    }
  }

  void resetMeditation() {
    if (_timer.isActive) {
      _timer.cancel();
    }
    setState(() {
      _currentTime = _selectedMinutes * 60; // Reset to the currently selected duration
      _isMeditationActive = false;
    });
  }

  String get timerText {
    final minutes = (_currentTime ~/ 60).toString().padLeft(2, '0');
    final seconds = (_currentTime % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    if (_timer.isActive) {
      _timer.cancel();
    }
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meditation Timer'),
        backgroundColor: Colors.lightBlueAccent,
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
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 250,
                    height: 250,
                    child: CircularProgressIndicator(
                      value: _currentTime / (_selectedMinutes * 60), // Use selected minutes for calculation
                      strokeWidth: 10,
                      backgroundColor: Colors.blue.shade100,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
                  Text(
                    timerText,
                    style: TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              // Slider to set meditation duration
              if (!_isMeditationActive) ...[
                Text(
                  "Set Duration: $_selectedMinutes minutes",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
                ),
                Slider(
                  value: _selectedMinutes.toDouble(),
                  min: 1, // Minimum 1 minute
                  max: 30, // Maximum 30 minutes
                  divisions: 29, // Number of intervals
                  label: _selectedMinutes.round().toString(),
                  onChanged: (double value) {
                    setState(() {
                      _selectedMinutes = value.round();
                      _currentTime = _selectedMinutes * 60;
                    });
                  },
                ),
              ],
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!_isMeditationActive)
                    ElevatedButton.icon(
                      onPressed: startMeditation,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Start'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                    ),
                  if (_isMeditationActive)
                    ElevatedButton.icon(
                      onPressed: pauseMeditation,
                      icon: const Icon(Icons.pause),
                      label: const Text('Pause'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                    ),
                  const SizedBox(width: 20),
                  ElevatedButton.icon(
                    onPressed: resetMeditation,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset'),
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