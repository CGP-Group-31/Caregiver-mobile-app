import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/session/session_manager.dart';
import 'features/splash/splash_screen.dart';
import 'core/notifications/fcm_manager.dart';
import 'core/notifications/caregiver_notification_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  //  init local notifications (background isolate)
  await CaregiverNotificationService.init();

  //  show appointment reminders (and future types later)
  await CaregiverNotificationService.showAppointmentNotification(message);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  //  register background handler early
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  //  init local notifications once
  await CaregiverNotificationService.init();

  // init token + permission
  await FCMManager.initAndGetToken();

  //  foreground listener
  FirebaseMessaging.onMessage.listen((message) async {
    await CaregiverNotificationService.showAppointmentNotification(message);
  });
  await SessionManager.debugPrintSession(tag: "APP STARTUP");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trustcare Caregiver',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SplashScreen(),
    );
  }
}