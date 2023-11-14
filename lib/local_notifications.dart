import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotifications {
  static Future initialize(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    AndroidInitializationSettings androidInitializationSettings =
        const AndroidInitializationSettings('ic_launcher');

    DarwinInitializationSettings iosInitializationSettings =
        const DarwinInitializationSettings();

    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: androidInitializationSettings,
            iOS: iosInitializationSettings);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> showBigTextNotificationFemaleVoicePerformthenextset({
    var id = 0,
    required String title,
    required String body,
    var payload,
    required FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
  }) async {
    AndroidNotificationDetails androidNotificationDetails =
        const AndroidNotificationDetails(
      "GiseleHava11",
      'channelName',
      playSound: true,
      icon: 'ic_launcher',
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound("female_voice_1"),
    );
    const DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(presentSound: false);
    var not = NotificationDetails(
        android: androidNotificationDetails, iOS: darwinNotificationDetails);
    await flutterLocalNotificationsPlugin.show(0, title, body, not);
  }

  static Future<void> showBigTextNotificationMute({
    var id = 0,
    required String title,
    required String body,
    var payload,
    required FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
  }) async {
    AndroidNotificationDetails androidNotificationDetails =
        const AndroidNotificationDetails(
      'GiseleHava12',
      'Channel Name 1',
      playSound: false,
      icon: 'ic_launcher',
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound("female_voice_1"),
    );
    const DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(presentSound: false);
    var not = NotificationDetails(
        android: androidNotificationDetails, iOS: darwinNotificationDetails);
    await flutterLocalNotificationsPlugin.show(0, title, body, not);
  }

  static Future<void> showBigTextNotificationBeep({
    var id = 0,
    required String title,
    required String body,
    var payload,
    required FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
  }) async {
    AndroidNotificationDetails androidNotificationDetails =
        const AndroidNotificationDetails(
      'GiseleHava13',
      'Channel Name 2',
      playSound: true,
      icon: 'ic_launcher',
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound("beep"),
    );
    const DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(presentSound: false);
    var not = NotificationDetails(
        android: androidNotificationDetails, iOS: darwinNotificationDetails);
    await flutterLocalNotificationsPlugin.show(0, title, body, not);
  }

  static Future<void> showBigTextNotificationBeep2({
    var id = 0,
    required String title,
    required String body,
    var payload,
    required FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
  }) async {
    AndroidNotificationDetails androidNotificationDetails =
        const AndroidNotificationDetails(
      'GiseleHava14',
      'Channel Name 2',
      playSound: true,
      icon: 'ic_launcher',
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound("beep2"),
    );
    const DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(presentSound: false);
    var not = NotificationDetails(
        android: androidNotificationDetails, iOS: darwinNotificationDetails);
    await flutterLocalNotificationsPlugin.show(0, title, body, not);
  }

  static Future<void> showBigTextNotificationFemale2VoicePerformthenextset({
    var id = 0,
    required String title,
    required String body,
    var payload,
    required FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
  }) async {
    AndroidNotificationDetails androidNotificationDetails =
        const AndroidNotificationDetails(
      'GiseleHava15',
      'Channel Name 3',
      playSound: true,
      icon: 'ic_launcher',
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound("female_voice_2"),
    );
    const DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(presentSound: false);
    var not = NotificationDetails(
        android: androidNotificationDetails, iOS: darwinNotificationDetails);
    await flutterLocalNotificationsPlugin.show(0, title, body, not);
  }

  static Future<void> showBigTextNotificationMaleVoicePerformthenextset({
    var id = 0,
    required String title,
    required String body,
    var payload,
    required FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
  }) async {
    AndroidNotificationDetails androidNotificationDetails =
        const AndroidNotificationDetails(
      'GiseleHava16',
      'Channel Name 4',
      playSound: true,
      icon: 'ic_launcher',
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound("male_voice_1"),
    );
    const DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(presentSound: false);
    var not = NotificationDetails(
        android: androidNotificationDetails, iOS: darwinNotificationDetails);
    await flutterLocalNotificationsPlugin.show(0, title, body, not);
  }

  static Future<void> showBigTextNotificationMale2VoicePerformthenextset({
    var id = 0,
    required String title,
    required String body,
    var payload,
    required FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
  }) async {
    AndroidNotificationDetails androidNotificationDetails =
        const AndroidNotificationDetails(
      'GiseleHava17',
      'Channel Name 5',
      playSound: true,
      icon: 'ic_launcher',
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound("male_voice_2"),
    );
    const DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(presentSound: false);
    var not = NotificationDetails(
        android: androidNotificationDetails, iOS: darwinNotificationDetails);
    await flutterLocalNotificationsPlugin.show(0, title, body, not);
  }
}
