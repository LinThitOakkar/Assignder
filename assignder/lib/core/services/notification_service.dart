import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/assignment_model.dart';
import '../constants/reminder_options.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Initialize timezone data and set a safe local timezone fallback.
    tz.initializeTimeZones();
    try {
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      defaultPresentAlert: true,
      defaultPresentBadge: true,
      defaultPresentSound: true,
      defaultPresentBanner: true,
      defaultPresentList: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _plugin.initialize(initSettings);

    const assignmentChannel = AndroidNotificationChannel(
      'assignment_reminders',
      'Assignment Reminders',
      description: 'Reminders for upcoming assignments',
      importance: Importance.high,
    );
    const testChannel = AndroidNotificationChannel(
      'test_channel',
      'Test Channel',
      description: 'Channel for testing notifications',
      importance: Importance.max,
    );
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.createNotificationChannel(assignmentChannel);
    await androidPlugin?.createNotificationChannel(testChannel);
  }

  Future<void> requestPermissions() async {
    final iosGranted = await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    final androidImplementation = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final androidNotificationsGranted =
        await androidImplementation?.requestNotificationsPermission();
    final exactAlarmGranted =
        await androidImplementation?.requestExactAlarmsPermission();

    debugPrint(
      'Notification permissions => '
      'iOS: $iosGranted, '
      'Android notifications: $androidNotificationsGranted, '
      'Android exact alarms: $exactAlarmGranted',
    );
  }

  // ✅ FIX 2: Test notification — call this first to verify plugin works
  Future<void> showTestNotification() async {
    await _plugin.show(
      999,
      '✅ Test Notification',
      'Notifications are working!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel',
          'Test Channel',
          channelDescription: 'Channel for testing notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  Future<void> showRemoteNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await _plugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'assignment_reminders',
          'Assignment Reminders',
          channelDescription: 'Reminders for upcoming assignments',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          presentBanner: true,
          presentList: true,
        ),
      ),
    );
  }

  // Schedule notifications for an assignment based on reminder offsets
  Future<void> scheduleAssignmentReminders(AssignmentModel assignment) async {
    // Cancel existing notifications for this assignment first
    await cancelAssignmentReminders(assignment.assignmentId);
    if (!assignment.reminder.enabled || assignment.reminder.offsets.isEmpty) {
      debugPrint(
        'Reminders disabled or empty for ${assignment.title}; '
        'existing notifications were cleared.',
      );
      return;
    }

    var scheduledCount = 0;
    for (final offset in assignment.reminder.offsets) {
      final duration = ReminderOptions.getDuration(offset);
      final scheduledTime = assignment.dueDate.subtract(duration);

      // ✅ FIX 3: Debug prints to see what's happening in terminal
      if (scheduledTime.isAfter(DateTime.now())) {
        debugPrint(
          'Scheduling notification for: $scheduledTime (offset: $offset)',
        );

        final notificationId = _generateNotificationId(
          assignment.assignmentId,
          offset,
        );

        await _plugin.zonedSchedule(
          notificationId,
          '📚 Assignment Due Soon!',
          '${assignment.title} is due in ${ReminderOptions.getLabel(offset)}',
          tz.TZDateTime.from(scheduledTime, tz.local),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'assignment_reminders',
              'Assignment Reminders',
              channelDescription: 'Reminders for upcoming assignments',
              importance: Importance.high,
              priority: Priority.high,
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
        scheduledCount++;
      } else {
        debugPrint(
          'Skipped notification because the reminder time already passed: '
          '$scheduledTime (offset: $offset)',
        );
      }
    }

    if (scheduledCount == 0) {
      debugPrint(
        'No reminders were scheduled for ${assignment.title}. '
        'All selected reminder times are in the past or no offsets were selected.',
      );
    }
  }

  // Rebuild scheduled reminders from the latest Firestore data for this device.
  Future<void> syncAssignmentReminders(List<AssignmentModel> assignments) async {
    await cancelAllNotifications();

    for (final assignment in assignments) {
      if (assignment.isSubmitted) continue;
      try {
        await scheduleAssignmentReminders(assignment);
      } catch (e) {
        debugPrint(
          'Failed to sync reminders for ${assignment.assignmentId}: $e',
        );
      }
    }
  }

  // Cancel all notifications for a specific assignment
  Future<void> cancelAssignmentReminders(String assignmentId) async {
    for (final offset in ReminderOptions.all) {
      final notificationId = _generateNotificationId(assignmentId, offset);
      await _plugin.cancel(notificationId);
    }
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }

  // Generate a unique int ID from assignmentId + offset
  int _generateNotificationId(String assignmentId, String offset) {
    return '${assignmentId}_$offset'.hashCode.abs() % 100000;
  }
}
