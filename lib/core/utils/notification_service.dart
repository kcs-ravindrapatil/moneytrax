import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../core/utils/app_logger.dart';

class NotificationService {
  NotificationService();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const int _morningReminderId = 1001;
  static const int _eveningReminderId = 1002;
  static const int _expenseLoggedId = 2001;

  Future<void> initialize() async {
    if (_initialized) return;
    tz.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
    } catch (_) {
      // Fall back to device offset via local when named zone is unavailable.
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
    _initialized = true;
  }

  Future<bool> requestPermission() async {
    await initialize();
    if (Platform.isAndroid) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final granted = await android?.requestNotificationsPermission();
      return granted ?? false;
    }
    if (Platform.isIOS) {
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      final granted = await ios?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }
    return false;
  }

  /// Schedules daily reminders at 6:00 AM and 6:00 PM.
  Future<void> scheduleDailyReminders() async {
    await initialize();
    await cancelReminders();
    await _scheduleAt(
      id: _morningReminderId,
      hour: 6,
      minute: 0,
      title: 'Good morning · MoneyTrax',
      body: 'Add today’s expenses and keep your budget on track.',
    );
    await _scheduleAt(
      id: _eveningReminderId,
      hour: 18,
      minute: 0,
      title: 'Evening check-in · MoneyTrax',
      body: 'Don’t forget to log today’s expenses before you wrap up.',
    );
  }

  @Deprecated('Use scheduleDailyReminders()')
  Future<void> scheduleDailyReminder({int hour = 20, int minute = 0}) async {
    await scheduleDailyReminders();
  }

  Future<void> cancelReminders() async {
    await initialize();
    await _plugin.cancel(_morningReminderId);
    await _plugin.cancel(_eveningReminderId);
  }

  /// Immediate confirmation after saving an expense.
  Future<void> showExpenseLogged({
    required String amountLabel,
    String? categoryName,
  }) async {
    await initialize();
    final detail = categoryName == null || categoryName.isEmpty
        ? 'Expense of $amountLabel saved.'
        : 'Expense of $amountLabel for $categoryName saved.';
    try {
      await _plugin.show(
        _expenseLoggedId,
        'Expense logged',
        detail,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'moneytrax_activity',
            'Activity',
            channelDescription: 'Confirmations when you add expenses',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    } catch (e) {
      AppLogger.error('Failed to show expense notification', e);
    }
  }

  Future<void> _scheduleAt({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        _nextInstanceOfTime(hour, minute),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'moneytrax_reminders',
            'Daily reminders',
            channelDescription: 'Optional reminders to log expenses',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      AppLogger.error('Failed to schedule notification $id', e);
    }
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
