import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {

  static final FlutterLocalNotificationsPlugin notifications =
  FlutterLocalNotificationsPlugin();

  static Future init() async {

    const AndroidInitializationSettings android =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
    InitializationSettings(android: android);

    await notifications.initialize(settings);
  }

  static Future scheduleWeeklyReminder() async {

    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'weekly_questionnaire',
      'Weekly Questionnaire',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails details =
    NotificationDetails(android: androidDetails);

    await notifications.periodicallyShow(
      0,
      "Weekly Questionnaire",
      "Please fill the elder weekly questionnaire.",
      RepeatInterval.weekly,
      details,
    );
  }
}