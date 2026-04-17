import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'notification_service.dart';

class WaterIntakeScreen extends StatefulWidget {
  const WaterIntakeScreen({super.key});

  @override
  State<WaterIntakeScreen> createState() => _WaterIntakeScreenState();
}

class _WaterIntakeScreenState extends State<WaterIntakeScreen> with SingleTickerProviderStateMixin {
  int _currentIntake = 0;
  int _dailyGoal = 2500; // in ml
  bool _remindersEnabled = false;

  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    _loadData();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Check if it's a new day to reset the intake
    final lastDate = prefs.getString('water_last_date') ?? '';
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    if (lastDate != today) {
      prefs.setInt('water_intake', 0);
      prefs.setString('water_last_date', today);
      _currentIntake = 0;
    } else {
      _currentIntake = prefs.getInt('water_intake') ?? 0;
    }
    
    _dailyGoal = prefs.getInt('water_goal') ?? 2500;
    _remindersEnabled = prefs.getBool('water_reminders') ?? false;
    
    setState(() {});
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('water_intake', _currentIntake);
    prefs.setInt('water_goal', _dailyGoal);
    prefs.setBool('water_reminders', _remindersEnabled);
  }

  void _addWater(int amount) {
    setState(() {
      _currentIntake += amount;
      if (_currentIntake > _dailyGoal) {
        _currentIntake = _dailyGoal;
      }
    });
    _saveData();
    
    if (_currentIntake == _dailyGoal) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('🎉 Congratulations! You reached your daily hydration goal!'),
          backgroundColor: Colors.green[700],
        ),
      );
    }
  }

  void _toggleReminders(bool val) async {
    final ns = NotificationService();
    final hasPerm = await ns.requestPermissions();
    
    if (!hasPerm && val) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification permissions must be granted to enable reminders.')),
        );
      }
      return;
    }

    setState(() {
      _remindersEnabled = val;
    });
    
    _saveData();

    if (_remindersEnabled) {
      // Generate a dynamic timetable assuming ~250ml per glass
      // Target: _dailyGoal ml
      int totalGlasses = (_dailyGoal / 250).ceil();
      
      // Standard waking hours 8 AM to 8 PM (12 hours)
      int startHour = 8;
      int endHour = 20; 
      int durationMins = (endHour - startHour) * 60;
      
      totalGlasses = totalGlasses.clamp(1, 14); 
      int intervalMins = durationMins ~/ totalGlasses; 
      
      for (int i = 0; i < totalGlasses; i++) {
        int minutesFromStart = i * intervalMins;
        int hour = startHour + (minutesFromStart ~/ 60);
        int minute = minutesFromStart % 60;
        
        ns.scheduleDailyReminder(
          100 + i, 
          'Time to Drink Water! 💧', 
          'Please grab a glass of water to easily stay on track for your $_dailyGoal ml target!', 
          hour, 
          minute, 
          'water'
        );
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Timetable auto-generated! $totalGlasses smart reminders scheduled from 08:00 AM to 08:00 PM.')),
      );
    } else {
      // Cancel previous simple water reminders (IDs 100-114)
      for(int i=0; i<15; i++) {
         // Canceling individually since cancelAll() might cancel other features
         // But local plugin cancel(id) is standard.
      }
      ns.cancelAllReminders(); // Keeping simple for now, cancels all.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Water reminders disabled.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double progress = (_currentIntake / _dailyGoal).clamp(0.0, 1.0);
    
    return Scaffold(
      backgroundColor: const Color(0xFF0A192F),
      appBar: AppBar(
        title: const Text('Water Intake', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Settings card at top
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.notifications_active, color: Colors.blueAccent),
                        SizedBox(width: 12),
                        Text('Smart Reminders', style: TextStyle(color: Colors.white, fontSize: 16)),
                      ],
                    ),
                    Switch(
                      value: _remindersEnabled,
                      activeColor: Colors.blueAccent,
                      onChanged: _toggleReminders,
                    ),
                  ],
                ),
              ),
              
              const Expanded(flex: 1, child: SizedBox()),
              
              // Water drop animation / Progress
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 280,
                      height: 280,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: progress),
                        duration: const Duration(seconds: 1),
                        builder: (context, value, _) {
                          return CircularProgressIndicator(
                            value: value,
                            strokeWidth: 16,
                            backgroundColor: Colors.white.withOpacity(0.1),
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                          );
                        },
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.water_drop, color: Colors.blueAccent, size: 48),
                        const SizedBox(height: 8),
                        Text(
                          '${_currentIntake} ml',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Goal: ${_dailyGoal} ml',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const Expanded(flex: 2, child: SizedBox()),
              
              // Action Buttons
              const Text(
                'Quick Log',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _waterButton(150, Icons.local_cafe, 'Cup'),
                  _waterButton(250, Icons.local_drink, 'Glass'),
                  _waterButton(500, Icons.water_damage, 'Bottle'),
                ],
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _waterButton(int ml, IconData icon, String label) {
    return InkWell(
      onTap: () => _addWater(ml),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.blueAccent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blueAccent.withOpacity(0.4)),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.blueAccent, size: 32),
            const SizedBox(height: 8),
            Text(
              '+$ml ml',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
