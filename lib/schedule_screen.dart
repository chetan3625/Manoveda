import 'package:flutter/material.dart';
import 'package:manoveda/widgets/app_scaffold.dart';
import 'notification_service.dart';

import 'wellness_repository.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final Map<String, TimeOfDay> _schedules = {};
  int _pendingCount = 0;
  bool _exactAlarmAvailable = true;

  @override
  void initState() {
    super.initState();
    _loadSchedules();
    _loadNotificationDebugState();
  }

  Future<void> _loadSchedules() async {
    final saved = await WellnessRepository.instance.getSchedules();
    if (!mounted) {
      return;
    }

    setState(() {
      for (final schedule in saved) {
        _schedules[schedule.title] = schedule.time;
      }
    });
  }

  Future<void> _loadNotificationDebugState() async {
    final pending = await NotificationService().getPendingRequests();
    final exact = await NotificationService().canScheduleExactNotifications();
    if (!mounted) {
      return;
    }
    setState(() {
      _pendingCount = pending.length;
      _exactAlarmAvailable = exact;
    });
  }

  Future<void> _pickTime(String task) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _schedules[task] ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) {
      setState(() => _schedules[task] = picked);
    }
  }

  void _submitSchedules() async {
    // 1. Request permissions first (crucial for Android 13/14)
    final permissionsGranted = await NotificationService().requestPermissions();
    if (!permissionsGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Notification or exact alarm permission is blocked. Please allow it in system settings and try again.',
            ),
          ),
        );
      }
      return;
    }
    await NotificationService().cancelAllReminders();

    // 2. Proceed with scheduling
    int id = 100;
    final schedulesToSave = <WellnessSchedule>[];
    for (var entry in _schedules.entries) {
      final task = WellnessRepository.tasks.firstWhere(
        (item) => item.title == entry.key,
      );
      id++;
      await NotificationService().scheduleDailyReminder(
        id,
        "Time for ${entry.key}",
        "Your scheduled ${entry.key} session is starting now!",
        entry.value.hour,
        entry.value.minute,
        task.key,
      );
      schedulesToSave.add(
        WellnessSchedule(
          taskKey: task.key,
          title: task.title,
          hour: entry.value.hour,
          minute: entry.value.minute,
        ),
      );
    }
    await WellnessRepository.instance.saveSchedules(schedulesToSave);
    await _loadNotificationDebugState();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Timeline scheduled successfully. Pending reminders: $_pendingCount',
          ),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: const Text('Daily Wellness Timeline', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active, color: Colors.cyanAccent),
            onPressed: () => NotificationService().showTestNotification(),
            tooltip: 'Send Test Notification',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pending reminders: $_pendingCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _exactAlarmAvailable
                      ? 'Exact alarm is available on this device.'
                      : 'Exact alarm is blocked, so reminders use Android inexact scheduling.',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () async {
                    await NotificationService().requestPermissions();
                    await NotificationService().scheduleTestReminderInSeconds();
                    await _loadNotificationDebugState();
                    if (!context.mounted) {
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Scheduled a test notification for about 10 seconds from now.',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.timer_outlined, color: Colors.white),
                  label: const Text(
                    'Schedule test in 10 sec',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white24),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: WellnessRepository.tasks.length,
              itemBuilder: (context, index) {
                final task = WellnessRepository.tasks[index].title;
                final time = _schedules[task];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: time != null ? Colors.cyanAccent : Colors.grey,
                      radius: 5,
                    ),
                    title: Text(task, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      time != null ? 'Remind at ${time.format(context)}' : 'Tap clock to schedule',
                      style: TextStyle(color: Colors.white.withOpacity(0.5)),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.history_toggle_off, color: Colors.cyanAccent),
                      onPressed: () => _pickTime(task),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyanAccent,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: _schedules.isEmpty ? null : _submitSchedules,
              child: const Text('Save My Timeline', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
