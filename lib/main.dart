import 'dart:developer';
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'utils/notification_helper.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> requestNotificationPermission() async {
  final nStatus = await Permission.notification.status;
  final aStatus = await Permission.scheduleExactAlarm.status;

  if (!nStatus.isGranted || !aStatus.isGranted) {
    await Permission.notification.request();
    await Permission.scheduleExactAlarm.request();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await requestNotificationPermission();
  await NotificationHelper.init();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    log('FLUTTER ERROR: ${details.exception}');
  };
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Islamic Utility App',
      theme: ThemeData(
        primarySwatch: Colors.green,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.green,
      ),
      home: const HomeScreen(),
    );
  }
}
