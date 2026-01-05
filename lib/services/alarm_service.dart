import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import '../models/alarm.dart';
import '../repositories/alarm_repository.dart';
import '../pages/alarm_ring_screen.dart';
import 'navigation_service.dart';

class AlarmService {
  static const platform = MethodChannel('com.example.healthsync/system_alarm');
  static final AlarmService _instance = AlarmService._internal();
  factory AlarmService() => _instance;
  AlarmService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final AlarmRepository _alarmRepository = AlarmRepository();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize timezone
    tz.initializeTimeZones();

    // Initialize notifications
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for alarms
    await _createAlarmNotificationChannel();

    // Request permissions
    await _requestPermissions();

    _isInitialized = true;
  }

  Future<void> _createAlarmNotificationChannel() async {
    const androidChannel = AndroidNotificationChannel(
      'alarm_channel',
      'Health Alarms',
      description: 'Notifications for health-related alarms',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('alarm'),
      enableVibration: true,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  Future<void> _requestPermissions() async {
    try {
      if (Platform.isAndroid) {
        // Request notification permission first
        final notificationStatus = await Permission.notification.request();
        if (kDebugMode) {
          print('Notification permission status: $notificationStatus');
        }

        // Request exact alarm permission (Android 12+)
        final exactAlarmStatus = await Permission.scheduleExactAlarm.status;
        if (kDebugMode) {
          print('Exact alarm permission status: $exactAlarmStatus');
        }

        if (exactAlarmStatus.isDenied) {
          final requestResult = await Permission.scheduleExactAlarm.request();
          if (kDebugMode) {
            print('Exact alarm permission request result: $requestResult');
          }
        }

        // Request system alert window permission for alarm overlay
        await Permission.systemAlertWindow.request();

        // Request ignore battery optimization
        await Permission.ignoreBatteryOptimizations.request();
      } else if (Platform.isIOS) {
        await _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );
      }
    } catch (e) {
      // On web platform, permission handling is different
      // Web notifications are handled by the browser
      if (kDebugMode) {
        print('Permission handling error: $e');
      }
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    if (kDebugMode) {
      print('🔔 Notification tapped: ${response.payload}');
      print('🔔 Response type: ${response.notificationResponseType}');
      print('🔔 Action ID: ${response.actionId}');
    }

    if (response.payload != null) {
      _handleAlarmNotification(response.payload!);
    }
  }

  Future<void> _handleAlarmNotification(String alarmId) async {
    try {
      if (kDebugMode) {
        print('🚨 Handling alarm notification for ID: $alarmId');
      }

      // Get the alarm from repository
      final alarm = await _alarmRepository.getAlarmById(alarmId);

      if (alarm != null) {
        if (kDebugMode) {
          print('🚨 Found alarm: ${alarm.title}');
          print(
              '🚨 Navigation context available: ${NavigationService.context != null}');
        }

        if (NavigationService.context != null) {
          // Navigate to alarm ring screen
          NavigationService.push(
            MaterialPageRoute(
              builder: (context) => AlarmRingScreen(alarm: alarm),
            ),
          );
        }
      } else {
        if (kDebugMode) {
          print('🚨 ERROR: Alarm not found for ID: $alarmId');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('🚨 ERROR handling alarm notification: $e');
      }
    }
  }

  Future<void> scheduleAlarm(Alarm alarm) async {
    await initialize();

    if (!alarm.isActive) {
      if (kDebugMode) {
        print('⏰ Skipping inactive alarm: ${alarm.title}');
      }
      return;
    }

    final nextAlarmTime = alarm.nextAlarmTime;
    if (nextAlarmTime == null) {
      if (kDebugMode) {
        print('⏰ No next alarm time for: ${alarm.title}');
      }
      return;
    }

    if (kDebugMode) {
      print(
          '⏰ Scheduling alarm: ${alarm.title} for ${nextAlarmTime.toString()}');
      print('⏰ Current time: ${DateTime.now().toString()}');
      print(
          '⏰ Time until alarm: ${nextAlarmTime.difference(DateTime.now()).toString()}');
    }

    // Check if exact alarms are available on Android
    if (Platform.isAndroid) {
      final exactAlarmStatus = await Permission.scheduleExactAlarm.status;
      if (exactAlarmStatus.isDenied || exactAlarmStatus.isPermanentlyDenied) {
        if (kDebugMode) {
          print(
              '⏰ Exact alarm permission not granted. Using inexact scheduling.');
        }
        // Fall back to inexact scheduling
        await _scheduleInexactAlarm(alarm);
        return;
      }
    }

    // Use system-level alarms on Android for better reliability
    if (Platform.isAndroid) {
      await _scheduleSystemAlarm(alarm, nextAlarmTime);
    } else {
      if (alarm.isRepeating) {
        await _scheduleRepeatingAlarm(alarm);
      } else {
        await _scheduleOneTimeAlarm(alarm);
      }
    }
  }

  Future<void> _scheduleSystemAlarm(Alarm alarm, DateTime triggerTime) async {
    try {
      await platform.invokeMethod('scheduleSystemAlarm', {
        'alarmId': alarm.id,
        'alarmTitle': '${alarm.type.icon} ${alarm.title}',
        'alarmDescription': alarm.description,
        'triggerTime': triggerTime.millisecondsSinceEpoch,
      });

      if (kDebugMode) {
        print(
            'System alarm scheduled for ${alarm.title} at ${triggerTime.toString()}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error scheduling system alarm: $e');
      }
      // Fallback to local notification
      if (alarm.isRepeating) {
        await _scheduleRepeatingAlarm(alarm);
      } else {
        await _scheduleOneTimeAlarm(alarm);
      }
    }
  }

  Future<void> _scheduleOneTimeAlarm(Alarm alarm) async {
    final nextAlarmTime = alarm.nextAlarmTime;
    if (nextAlarmTime == null) return;

    // Use system alarm for Android (this triggers AlarmService with sound)
    if (Platform.isAndroid) {
      try {
        await platform.invokeMethod('scheduleSystemAlarm', {
          'alarmId': alarm.id,
          'alarmTitle': '${alarm.type.icon} ${alarm.title}',
          'alarmDescription': alarm.description,
          'triggerTime': nextAlarmTime.millisecondsSinceEpoch,
        });

        if (kDebugMode) {
          print(
              '📱 System alarm scheduled for ${alarm.title} at ${nextAlarmTime.toString()}');
          print('📱 Alarm ID: ${alarm.id}');
        }
        return;
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ System alarm failed, falling back to notification: $e');
        }
      }
    }

    // Fallback to notification-based alarm (iOS or if system alarm fails)
    final androidDetails = AndroidNotificationDetails(
      'alarm_channel',
      'Health Alarms',
      channelDescription: 'Notifications for health-related alarms',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('alarm'),
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
      icon: '@mipmap/ic_launcher',
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      visibility: NotificationVisibility.public,
      autoCancel: false,
      ongoing: false,
      showWhen: true,
      when: DateTime.now().millisecondsSinceEpoch,
      usesChronometer: false,
      channelShowBadge: true,
      onlyAlertOnce: false,
      actions: const <AndroidNotificationAction>[
        AndroidNotificationAction(
          'DISMISS_ALARM',
          'Dismiss',
          showsUserInterface: true,
        ),
        AndroidNotificationAction(
          'SNOOZE_ALARM',
          'Snooze',
          showsUserInterface: true,
        ),
      ],
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.critical,
      categoryIdentifier: 'ALARM_CATEGORY',
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      alarm.id.hashCode,
      '${alarm.type.icon} ${alarm.title}',
      alarm.description,
      tz.TZDateTime.from(nextAlarmTime, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: alarm.id,
    );

    if (kDebugMode) {
      print(
          '📱 Notification fallback scheduled for ${alarm.title} at ${nextAlarmTime.toString()}');
      print('📱 Alarm ID: ${alarm.id}, Hash: ${alarm.id.hashCode}');
    }
  }

  Future<void> _scheduleRepeatingAlarm(Alarm alarm) async {
    // For repeating alarms, we schedule multiple one-time notifications
    // This is a workaround since flutter_local_notifications doesn't support
    // complex recurring patterns

    final now = DateTime.now();

    for (int i = 0; i < 30; i++) {
      // Schedule for next 30 days
      final checkDate = now.add(Duration(days: i));
      final weekday = checkDate.weekday;

      if (alarm.repeatDays.contains(weekday)) {
        final alarmDateTime = DateTime(
          checkDate.year,
          checkDate.month,
          checkDate.day,
          alarm.dateTime.hour,
          alarm.dateTime.minute,
        );

        if (alarmDateTime.isAfter(now)) {
          // Use system alarm for Android
          if (Platform.isAndroid) {
            try {
              await platform.invokeMethod('scheduleSystemAlarm', {
                'alarmId': '${alarm.id}_$i',
                'alarmTitle': '${alarm.type.icon} ${alarm.title}',
                'alarmDescription': alarm.description,
                'triggerTime': alarmDateTime.millisecondsSinceEpoch,
              });
            } catch (e) {
              // Fallback to notification
              await _scheduleNotificationForDateTime(alarm, alarmDateTime, i);
            }
          } else {
            await _scheduleNotificationForDateTime(alarm, alarmDateTime, i);
          }
        }
      }
    }
  }

  Future<void> _scheduleNotificationForDateTime(
      Alarm alarm, DateTime alarmDateTime, int index) async {
    const androidDetails = AndroidNotificationDetails(
      'alarm_channel',
      'Health Alarms',
      channelDescription: 'Notifications for health-related alarms',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      '${alarm.id}_$index'.hashCode,
      '${alarm.type.icon} ${alarm.title}',
      alarm.description,
      tz.TZDateTime.from(alarmDateTime, tz.local),
      notificationDetails,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: alarm.id,
    );
  }

  Future<void> cancelAlarm(String alarmId) async {
    await initialize();

    // Cancel system alarm on Android
    if (Platform.isAndroid) {
      try {
        await platform.invokeMethod('cancelSystemAlarm', {
          'alarmId': alarmId,
        });
      } catch (e) {
        if (kDebugMode) {
          print('Error cancelling system alarm: $e');
        }
      }
    }

    // Cancel the main alarm notification
    await _flutterLocalNotificationsPlugin.cancel(alarmId.hashCode);

    // Cancel any repeating instances
    for (int i = 0; i < 30; i++) {
      if (Platform.isAndroid) {
        try {
          await platform.invokeMethod('cancelSystemAlarm', {
            'alarmId': '${alarmId}_$i',
          });
        } catch (e) {
          // Continue with notification cancellation
        }
      }
      await _flutterLocalNotificationsPlugin.cancel('${alarmId}_$i'.hashCode);
    }
  }

  Future<void> cancelAllAlarms() async {
    await initialize();
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> stopAlarmService() async {
    try {
      if (Platform.isAndroid) {
        await platform.invokeMethod('stopAlarmService');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error stopping alarm service: $e');
      }
    }
  }

  Future<void> snoozeAlarm(String alarmId, int snoozeMinutes) async {
    try {
      // Stop current alarm
      await stopAlarmService();

      // Get alarm from repository
      final alarm = await _alarmRepository.getAlarmById(alarmId);
      if (alarm != null) {
        // Schedule snooze alarm
        final snoozeTime = DateTime.now().add(Duration(minutes: snoozeMinutes));

        if (Platform.isAndroid) {
          await platform.invokeMethod('scheduleSystemAlarm', {
            'alarmId': '${alarmId}_snooze',
            'alarmTitle': '${alarm.title} (Snoozed)',
            'alarmDescription': 'Health Alarm - Snooze',
            'triggerTime': snoozeTime.millisecondsSinceEpoch,
          });
        } else {
          // Fallback for other platforms
          await _scheduleOneTimeAlarmForDateTime(alarm, snoozeTime);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error snoozing alarm: $e');
      }
    }
  }

  Future<void> _scheduleOneTimeAlarmForDateTime(
      Alarm alarm, DateTime dateTime) async {
    const androidDetails = AndroidNotificationDetails(
      'alarm_channel',
      'Health Alarms',
      channelDescription: 'Notifications for health-related alarms',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      visibility: NotificationVisibility.public,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.critical,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      alarm.id.hashCode,
      '${alarm.type.icon} ${alarm.title}',
      alarm.description,
      tz.TZDateTime.from(dateTime, tz.local),
      notificationDetails,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: alarm.id,
    );
  }

  Future<List<PendingNotificationRequest>> getPendingAlarms() async {
    await initialize();
    return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  Future<void> updateAlarmStatus(Alarm alarm) async {
    // Cancel existing alarm
    await cancelAlarm(alarm.id);

    // Reschedule if active
    if (alarm.isActive) {
      await scheduleAlarm(alarm);
    }
  }

  Future<bool> hasExactAlarmPermission() async {
    if (!Platform.isAndroid) return true;

    try {
      final status = await Permission.scheduleExactAlarm.status;
      return status.isGranted;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking exact alarm permission: $e');
      }
      return false;
    }
  }

  Future<bool> requestExactAlarmPermission() async {
    if (!Platform.isAndroid) return true;

    try {
      final status = await Permission.scheduleExactAlarm.request();
      return status.isGranted;
    } catch (e) {
      if (kDebugMode) {
        print('Error requesting exact alarm permission: $e');
      }
      return false;
    }
  }

  Future<void> _scheduleInexactAlarm(Alarm alarm) async {
    final nextAlarmTime = alarm.nextAlarmTime;
    if (nextAlarmTime == null) return;

    const androidDetails = AndroidNotificationDetails(
      'alarm_channel',
      'Health Alarms',
      channelDescription:
          'Notifications for health-related alarms (inexact timing)',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      // Try to use zonedSchedule with matchDateTimeComponents for inexact alarms
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        alarm.id.hashCode,
        '${alarm.type.icon} ${alarm.title}',
        '${alarm.description}\n(Note: Inexact timing due to system restrictions)',
        tz.TZDateTime.from(nextAlarmTime, tz.local),
        notificationDetails,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: alarm.id,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Failed to schedule inexact alarm: $e');
      }
      // Last resort: show a notification with the scheduled time info
      await _flutterLocalNotificationsPlugin.show(
        alarm.id.hashCode,
        '${alarm.type.icon} ${alarm.title}',
        'Alarm created for ${nextAlarmTime.hour.toString().padLeft(2, '0')}:${nextAlarmTime.minute.toString().padLeft(2, '0')}. Please enable exact alarm permissions for precise timing.',
        notificationDetails,
        payload: alarm.id,
      );
    }
  }
}
