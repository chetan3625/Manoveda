import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  AndroidFlutterLocalNotificationsPlugin? get _androidImplementation =>
      _notificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  Future<void> init(GlobalKey<NavigatorState> navigatorKey) async {
    // 1. Initialize Timezones and detect local timezone
    tz.initializeTimeZones();
    final timezoneInfo = await FlutterTimezone.getLocalTimezone();
    try {
      tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));
    } catch (e) {
      // Fallback to UTC if the timezone identifier is not found in the database
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    // 2. Android Settings
    const AndroidInitializationSettings androidSettings = 
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // 3. iOS Settings
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        if (details.payload != null && details.payload!.isNotEmpty) {
          // Automatically navigate to the task route when notification is tapped
          navigatorKey.currentState?.pushNamed('/${details.payload}');
        }
      },
    );

    // Handle notification tap if the app was closed
    final NotificationAppLaunchDetails? launchDetails = 
        await _notificationsPlugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      final payload = launchDetails?.notificationResponse?.payload;
      if (payload != null && payload.isNotEmpty) {
        Future.delayed(const Duration(seconds: 1), () {
          navigatorKey.currentState?.pushNamed('/$payload');
        });
      }
    }
  }

  /// Requests necessary permissions for Android 13+ and Android 14+
  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      // Request notification permission (Android 13+)
      final notificationsGranted =
          await _androidImplementation?.requestNotificationsPermission() ?? true;
      // Request exact alarm permission (Android 14+)
      await _androidImplementation?.requestExactAlarmsPermission();
      final exactAlarmGranted =
          await _androidImplementation?.canScheduleExactNotifications() ?? true;

      return notificationsGranted && exactAlarmGranted;
    }

    return true;
  }

  Future<bool> canScheduleExactNotifications() async {
    if (!Platform.isAndroid) {
      return true;
    }
    return await _androidImplementation?.canScheduleExactNotifications() ?? true;
  }

  /// Schedules a notification at a specific time (e.g., every day at 9:00 AM)
  Future<void> scheduleDailyReminder(int id, String title, String body, int hour, int minute, String payload) async {
    final canScheduleExact = await canScheduleExactNotifications();
    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder_channel',
          'Daily Reminders',
          channelDescription: 'Fixed time wellness reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: canScheduleExact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // This makes it repeat daily at the same time
      payload: payload,
    );
  }

  Future<void> cancelAllReminders() async {
    await _notificationsPlugin.cancelAll();
  }

  Future<void> scheduleTestReminderInSeconds({
    int seconds = 10,
  }) async {
    final canScheduleExact = await canScheduleExactNotifications();
    await _notificationsPlugin.zonedSchedule(
      998,
      'ManoVeda test reminder',
      'This is a scheduled test notification.',
      tz.TZDateTime.now(tz.local).add(Duration(seconds: seconds)),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel',
          'Test Notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: canScheduleExact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'scheduler',
    );
  }

  Future<List<PendingNotificationRequest>> getPendingRequests() async {
    return _notificationsPlugin.pendingNotificationRequests();
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  /// Test method to verify notifications work immediately
  Future<void> showTestNotification() async {
    const NotificationDetails details = NotificationDetails(
      android: AndroidNotificationDetails(
        'test_channel',
        'Test Notifications',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );
    await _notificationsPlugin.show(
      999,
      "Test Success!",
      "Your notification system is working fine.",
      details,
      payload: 'chatbot',
    );
  }
}
