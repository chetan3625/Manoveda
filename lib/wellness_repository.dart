import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import 'dbhelper.dart';

class WellnessTask {
  final String key;
  final String title;
  final IconData icon;
  final Color color;

  const WellnessTask({
    required this.key,
    required this.title,
    required this.icon,
    required this.color,
  });
}

class WellnessSchedule {
  final String taskKey;
  final String title;
  final int hour;
  final int minute;

  const WellnessSchedule({
    required this.taskKey,
    required this.title,
    required this.hour,
    required this.minute,
  });

  TimeOfDay get time => TimeOfDay(hour: hour, minute: minute);

  Map<String, dynamic> toMap() {
    return {
      'task_key': taskKey,
      'title': title,
      'hour': hour,
      'minute': minute,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    };
  }

  factory WellnessSchedule.fromMap(Map<String, dynamic> map) {
    return WellnessSchedule(
      taskKey: map['task_key'] as String,
      title: map['title'] as String,
      hour: map['hour'] as int,
      minute: map['minute'] as int,
    );
  }
}

class DashboardBarPoint {
  final String label;
  final double score;
  final bool isToday;

  const DashboardBarPoint({
    required this.label,
    required this.score,
    required this.isToday,
  });
}

class ScheduledTaskProgress {
  final WellnessTask task;
  final TimeOfDay time;
  final bool completedToday;
  final int streakCount;

  const ScheduledTaskProgress({
    required this.task,
    required this.time,
    required this.completedToday,
    required this.streakCount,
  });
}

class DashboardSummary {
  final String greeting;
  final String message;
  final int todayScore;
  final int monthScore;
  final int previousMonthScore;
  final int totalMindfulMinutes;
  final int scheduledToday;
  final int completedToday;
  final double moodAverage;
  final double monthlyImprovement;
  final List<DashboardBarPoint> weeklyBars;
  final List<ScheduledTaskProgress> scheduledTasks;
  final List<String> notices;

  const DashboardSummary({
    required this.greeting,
    required this.message,
    required this.todayScore,
    required this.monthScore,
    required this.previousMonthScore,
    required this.totalMindfulMinutes,
    required this.scheduledToday,
    required this.completedToday,
    required this.moodAverage,
    required this.monthlyImprovement,
    required this.weeklyBars,
    required this.scheduledTasks,
    required this.notices,
  });
}

class WellnessRepository {
  WellnessRepository._();

  static final WellnessRepository instance = WellnessRepository._();

  static const List<WellnessTask> tasks = [
    WellnessTask(
      key: 'meditation',
      title: 'Meditation',
      icon: Icons.self_improvement,
      color: Color(0xFF0D9488),
    ),
    WellnessTask(
      key: 'breathing_exercise',
      title: 'Breathing Exercise',
      icon: Icons.air,
      color: Color(0xFF059669),
    ),
    WellnessTask(
      key: 'yoga',
      title: 'Yoga',
      icon: Icons.fitness_center,
      color: Color(0xFFD97706),
    ),
    WellnessTask(
      key: 'mood_submit',
      title: 'Mood Submit',
      icon: Icons.mood,
      color: Color(0xFFDB2777),
    ),
    WellnessTask(
      key: 'music_therapy',
      title: 'Music Therapy',
      icon: Icons.music_note,
      color: Color(0xFF4338CA),
    ),
    WellnessTask(
      key: 'reading_affirmation',
      title: 'Reading Affirmation',
      icon: Icons.lightbulb_outline,
      color: Color(0xFF7C3AED),
    ),
    WellnessTask(
      key: 'mind_games',
      title: 'Mind Games',
      icon: Icons.psychology_alt_rounded,
      color: Color(0xFF6D28D9),
    ),
    WellnessTask(
      key: 'writing_journal',
      title: 'Writing Journal',
      icon: Icons.edit_note,
      color: Color(0xFFB45309),
    ),
    WellnessTask(
      key: 'grounding',
      title: 'Grounding',
      icon: Icons.nature,
      color: Color(0xFF16A34A),
    ),
  ];

  static WellnessTask? findTask(String key) {
    for (final task in tasks) {
      if (task.key == key) {
        return task;
      }
    }
    return null;
  }

  Future<void> saveSchedules(List<WellnessSchedule> schedules) async {
    final db = await DatabaseHelper().database;
    final batch = db.batch();

    batch.delete('schedules');
    for (final schedule in schedules) {
      batch.insert(
        'schedules',
        schedule.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<WellnessSchedule>> getSchedules() async {
    final db = await DatabaseHelper().database;
    final rows = await db.query('schedules', orderBy: 'hour ASC, minute ASC');
    return rows.map(WellnessSchedule.fromMap).toList();
  }

  Future<void> logEvent({
    required String taskKey,
    required String title,
    int durationMinutes = 0,
    double? score,
    String? details,
    DateTime? createdAt,
  }) async {
    final db = await DatabaseHelper().database;
    final resolvedScore = score ?? _defaultScore(taskKey, durationMinutes);

    await db.insert('wellness_events', {
      'task_key': taskKey,
      'title': title,
      'duration_minutes': durationMinutes,
      'score': resolvedScore,
      'details': details,
      'created_at': (createdAt ?? DateTime.now()).millisecondsSinceEpoch,
    });
  }

  Future<void> saveMood({
    required int mood,
    String? note,
  }) async {
    final db = await DatabaseHelper().database;
    final now = DateTime.now();

    await db.insert('moods', {
      'date': now.millisecondsSinceEpoch,
      'mood': mood,
      'note': note,
    });

    await logEvent(
      taskKey: 'mood_submit',
      title: 'Mood Submit',
      durationMinutes: 0,
      score: (mood * 2.0).clamp(2.0, 20.0),
      details: note,
      createdAt: now,
    );
  }

  Future<List<Map<String, dynamic>>> getMoodHistory({int limit = 30}) async {
    final db = await DatabaseHelper().database;
    return db.query('moods', orderBy: 'date DESC', limit: limit);
  }

  Future<DashboardSummary> buildDashboardSummary() async {
    final db = await DatabaseHelper().database;
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final startOfTomorrow = startOfToday.add(const Duration(days: 1));
    final startOfMonth = DateTime(now.year, now.month, 1);
    final startOfPreviousMonth = DateTime(now.year, now.month - 1, 1);

    final todayEvents = await db.query(
      'wellness_events',
      where: 'created_at >= ? AND created_at < ?',
      whereArgs: [
        startOfToday.millisecondsSinceEpoch,
        startOfTomorrow.millisecondsSinceEpoch,
      ],
    );

    final monthEvents = await db.query(
      'wellness_events',
      where: 'created_at >= ?',
      whereArgs: [startOfMonth.millisecondsSinceEpoch],
    );

    final previousMonthEvents = await db.query(
      'wellness_events',
      where: 'created_at >= ? AND created_at < ?',
      whereArgs: [
        startOfPreviousMonth.millisecondsSinceEpoch,
        startOfMonth.millisecondsSinceEpoch,
      ],
    );

    final moodRows = await db.query(
      'moods',
      where: 'date >= ?',
      whereArgs: [startOfMonth.millisecondsSinceEpoch],
      orderBy: 'date DESC',
    );

    final schedules = await getSchedules();
    final scheduledProgress = <ScheduledTaskProgress>[];

    for (final schedule in schedules) {
      final matchingTask = findTask(schedule.taskKey);
      if (matchingTask == null) {
        continue;
      }

      final completed = todayEvents.any(
        (event) => event['task_key'] == schedule.taskKey,
      );

      final streak = await _countRecentDaysWithTask(
        db,
        taskKey: schedule.taskKey,
        startOfToday: startOfToday,
      );

      scheduledProgress.add(
        ScheduledTaskProgress(
          task: matchingTask,
          time: schedule.time,
          completedToday: completed,
          streakCount: streak,
        ),
      );
    }

    final weeklyBars = await _buildWeeklyBars(db, startOfToday);
    final todayScore = _sumScores(todayEvents).round();
    final monthScore = _sumScores(monthEvents).round();
    final previousMonthScore = _sumScores(previousMonthEvents).round();
    final totalMindfulMinutes = monthEvents.fold<int>(
      0,
      (sum, row) => sum + ((row['duration_minutes'] as int?) ?? 0),
    );
    final completedToday = scheduledProgress.where((task) => task.completedToday).length;
    final moodAverage = moodRows.isEmpty
        ? 0.0
        : moodRows
                .map((row) => (row['mood'] as int).toDouble())
                .reduce((a, b) => a + b) /
            moodRows.length;
    final monthlyImprovement = previousMonthScore <= 0
        ? (monthScore > 0 ? 100.0 : 0.0)
        : ((monthScore - previousMonthScore) / previousMonthScore) * 100;
    final notices = _buildNotices(
      todayScore: todayScore,
      moodAverage: moodAverage,
      completedToday: completedToday,
      scheduledToday: schedules.length,
      totalMindfulMinutes: totalMindfulMinutes,
    );

    return DashboardSummary(
      greeting: _buildGreeting(todayScore, completedToday, schedules.length),
      message: _buildMessage(todayScore, moodAverage),
      todayScore: todayScore,
      monthScore: monthScore,
      previousMonthScore: previousMonthScore,
      totalMindfulMinutes: totalMindfulMinutes,
      scheduledToday: schedules.length,
      completedToday: completedToday,
      moodAverage: moodAverage,
      monthlyImprovement: monthlyImprovement,
      weeklyBars: weeklyBars,
      scheduledTasks: scheduledProgress,
      notices: notices,
    );
  }

  Future<List<DashboardBarPoint>> _buildWeeklyBars(
    Database db,
    DateTime startOfToday,
  ) async {
    final points = <DashboardBarPoint>[];

    for (int offset = 6; offset >= 0; offset--) {
      final dayStart = startOfToday.subtract(Duration(days: offset));
      final nextDay = dayStart.add(const Duration(days: 1));
      final rows = await db.query(
        'wellness_events',
        where: 'created_at >= ? AND created_at < ?',
        whereArgs: [
          dayStart.millisecondsSinceEpoch,
          nextDay.millisecondsSinceEpoch,
        ],
      );
      points.add(
        DashboardBarPoint(
          label: _weekdayShort(dayStart.weekday),
          score: _sumScores(rows),
          isToday: offset == 0,
        ),
      );
    }

    return points;
  }

  Future<int> _countRecentDaysWithTask(
    Database db, {
    required String taskKey,
    required DateTime startOfToday,
  }) async {
    int streak = 0;
    for (int offset = 0; offset < 7; offset++) {
      final dayStart = startOfToday.subtract(Duration(days: offset));
      final nextDay = dayStart.add(const Duration(days: 1));
      final rows = await db.query(
        'wellness_events',
        where: 'task_key = ? AND created_at >= ? AND created_at < ?',
        whereArgs: [
          taskKey,
          dayStart.millisecondsSinceEpoch,
          nextDay.millisecondsSinceEpoch,
        ],
        limit: 1,
      );
      if (rows.isEmpty) {
        break;
      }
      streak++;
    }
    return streak;
  }

  double _sumScores(List<Map<String, dynamic>> rows) {
    return rows.fold<double>(
      0,
      (sum, row) => sum + ((row['score'] as num?)?.toDouble() ?? 0),
    );
  }

  double _defaultScore(String taskKey, int durationMinutes) {
    switch (taskKey) {
      case 'breathing_exercise':
        return 4 + (durationMinutes * 1.5);
      case 'meditation':
        return 5 + (durationMinutes * 1.8);
      case 'music_therapy':
        return 3 + (durationMinutes * 1.2);
      case 'mind_games':
        return 8 + (durationMinutes * 0.8);
      case 'writing_journal':
        return 10;
      case 'grounding':
        return 9;
      case 'reading_affirmation':
        return 5;
      case 'yoga':
        return 12;
      default:
        return durationMinutes > 0 ? durationMinutes.toDouble() : 6;
    }
  }

  String _buildGreeting(int todayScore, int completedToday, int scheduledToday) {
    if (todayScore >= 45 || (scheduledToday > 0 && completedToday == scheduledToday)) {
      return 'You are doing great today';
    }
    if (todayScore >= 20) {
      return 'A steady day for your mind';
    }
    return 'Let us build calm one step at a time';
  }

  String _buildMessage(int todayScore, double moodAverage) {
    if (todayScore >= 45) {
      return 'Your routine looks strong. Keep the momentum gentle and consistent.';
    }
    if (moodAverage > 0 && moodAverage < 5) {
      return 'Your dashboard suggests a softer day. Try one grounding or breathing task first.';
    }
    if (todayScore >= 20) {
      return 'You have already invested in yourself today. One more mindful task can lift the trend.';
    }
    return 'Start with the smallest win. Even a few mindful minutes count.';
  }

  List<String> _buildNotices({
    required int todayScore,
    required double moodAverage,
    required int completedToday,
    required int scheduledToday,
    required int totalMindfulMinutes,
  }) {
    final notices = <String>[];

    if (scheduledToday > 0 && completedToday < scheduledToday) {
      notices.add(
        'Notice: $completedToday of $scheduledToday scheduled wellness tasks are complete today.',
      );
    } else if (scheduledToday > 0) {
      notices.add('Notice: You completed every scheduled wellness task today.');
    }

    if (moodAverage > 0) {
      if (moodAverage >= 7) {
        notices.add('Mood trend: Your average mood this month is ${moodAverage.toStringAsFixed(1)}/10.');
      } else {
        notices.add('Mood trend: Your average mood is ${moodAverage.toStringAsFixed(1)}/10, so calmer routines may help this week.');
      }
    } else {
      notices.add('Mood trend: Add a few mood check-ins so the dashboard can learn your pattern.');
    }

    if (totalMindfulMinutes >= 120) {
      notices.add('Keep doing: You already built $totalMindfulMinutes mindful minutes this month.');
    } else {
      notices.add('Keep doing: Short daily sessions will make your monthly graph more stable.');
    }

    if (todayScore < 15) {
      notices.add('Do not ignore: low activity days can be a signal to nudge yourself with one small routine.');
    }

    return notices;
  }

  String _weekdayShort(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Mon';
      case DateTime.tuesday:
        return 'Tue';
      case DateTime.wednesday:
        return 'Wed';
      case DateTime.thursday:
        return 'Thu';
      case DateTime.friday:
        return 'Fri';
      case DateTime.saturday:
        return 'Sat';
      default:
        return 'Sun';
    }
  }
}
