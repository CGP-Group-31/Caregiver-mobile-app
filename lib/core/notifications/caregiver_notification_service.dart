import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class CaregiverNotificationService {
  CaregiverNotificationService._();

  static final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();
  static bool _inited = false;

  static Future<void> init() async {
    if (_inited) return;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_trust');
    const initSettings = InitializationSettings(android: androidInit);

    await _local.initialize(initSettings);

    const AndroidNotificationChannel apptChannel = AndroidNotificationChannel(
      "appt_reminders",
      "Appointment Reminders",
      description: "Doctor appointment reminders",
      importance: Importance.high,
    );

    await _local
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(apptChannel);

    _inited = true;
  }

  static Future<void> showAppointmentNotification(RemoteMessage message) async {
    await init();

    final d = message.data;
    if ((d["type"] ?? "") != "APPT_REMINDER") return;

    final elderId = d["elderId"]?.toString() ?? "";
    final reminderType = d["reminderType"]?.toString() ?? "";

    final title = d["title"]?.toString() ?? "Doctor Appointment";
    final doctorName = d["doctorName"]?.toString() ?? "-";
    final location = d["location"]?.toString() ?? "-";
    final date = d["appointmentDate"]?.toString() ?? "";
    final time = (d["appointmentTime"]?.toString() ?? "").substring(0, 5);

    final whenText = reminderType == "24H" ? "Tomorrow" : "In 6 hours";

    final notifTitle = "Appointment Reminder";
    final notifBody =
        "$whenText • $date $time\n"
        "Doctor: $doctorName\n"
        "Place: $location\n"
        "Title: $title";

    final payload = jsonEncode({
      "type": "APPT_REMINDER",
      "elderId": elderId,
      "appointmentId": d["appointmentId"]?.toString() ?? "",
    });

    final androidDetails = AndroidNotificationDetails(
      "appt_reminders",
      "Appointment Reminders",
      channelDescription: "Doctor appointment reminders",
      importance: Importance.high,
      priority: Priority.high,
    );

    await _local.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      notifTitle,
      notifBody,
      NotificationDetails(android: androidDetails),
      payload: payload,
    );
  }
}