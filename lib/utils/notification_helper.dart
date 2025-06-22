import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String channelId = 'prayer_channel';
  static const String channelName = 'Prayer Notifications';
  static const String channelDescription = 'Notifications for prayer times';

  static Future<void> _requestExactAlarmPermissionIfNeeded() async {
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;

      if (androidInfo.version.sdkInt >= 31) {
        final status = await Permission.scheduleExactAlarm.status;
        if (!status.isGranted) {
          final granted = await Permission.scheduleExactAlarm.request();
          if (!granted.isGranted) {
            openAppSettings();
          }
        }
      }
    }
  }

  static Future<void> init() async {
    await _requestExactAlarmPermissionIfNeeded();

    tz.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    final initSettings = InitializationSettings(android: androidInit);
    await flutterLocalNotificationsPlugin.initialize(initSettings);

    const androidChannel = AndroidNotificationChannel(
      channelId,
      channelName,
      description: channelDescription,
      importance: Importance.max,
      playSound: true,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(androidChannel);
  }

  static Future<String> _getSelectedAzanSound() async {
    final prefs = await SharedPreferences.getInstance();
    final sound = prefs.getString('azan_sound');
    final validSounds = ['azan1', 'azan2', 'azan3'];
    return validSounds.contains(sound) ? sound! : 'azan1';
  }

  /// Show daily prayer notification using the selected azan sound
  static Future<void> showPrayerNotification(
    String prayerName,
    DateTime scheduledTime,
  ) async {
    final soundName = await _getSelectedAzanSound();

    final androidSound = RawResourceAndroidNotificationSound(soundName);
    await flutterLocalNotificationsPlugin.zonedSchedule(
      prayerName.hashCode,
      'Prayer Time',
      'It\'s time for $prayerName prayer.',
      _nextInstanceOfTime(scheduledTime),
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: channelDescription,
          importance: Importance.max,
          priority: Priority.high,
          sound: androidSound,
          playSound: true,
          enableVibration: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  static tz.TZDateTime _nextInstanceOfTime(DateTime scheduledTime) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      scheduledTime.hour,
      scheduledTime.minute,
      scheduledTime.second,
    );

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }
}
