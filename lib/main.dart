// cd plan_workout //flutter run to the start the app // dart fix to fix problems in the code
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:plan_workout/local_notifications.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import 'package:workmanager/workmanager.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) {
    final String nextExerciseName = inputData?['nextExerciseName'];
    LocalNotifications.initialize(flutterLocalNotificationsPlugin);
    LocalNotifications.showBigTextNotificationFemaleVoicePerformthenextset(
        title: "Workout",
        body: nextExerciseName,
        flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin);
    return Future.value(true);
  });
}

void callbackDispatcher2() {
  Workmanager().executeTask((task, inputData) {
    final String nextExerciseName = inputData?['nextExerciseName'];
    LocalNotifications.initialize(flutterLocalNotificationsPlugin);
    LocalNotifications.showBigTextNotificationMute(
        title: "Workout",
        body: nextExerciseName,
        flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin);
    return Future.value(true);
  });
}

void callbackDispatcher3() {
  Workmanager().executeTask((task, inputData) {
    final String nextExerciseName = inputData?['nextExerciseName'];
    LocalNotifications.initialize(flutterLocalNotificationsPlugin);
    LocalNotifications.showBigTextNotificationBeep(
        title: "Workout",
        body: nextExerciseName,
        flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin);
    return Future.value(true);
  });
}

void callbackDispatcher4() {
  Workmanager().executeTask((task, inputData) {
    final String nextExerciseName = inputData?['nextExerciseName'];
    LocalNotifications.initialize(flutterLocalNotificationsPlugin);
    LocalNotifications.showBigTextNotificationBeep2(
        title: "Workout",
        body: nextExerciseName,
        flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin);
    return Future.value(true);
  });
}

void callbackDispatcher5() {
  Workmanager().executeTask((task, inputData) {
    final String nextExerciseName = inputData?['nextExerciseName'];
    LocalNotifications.initialize(flutterLocalNotificationsPlugin);
    LocalNotifications.showBigTextNotificationFemale2VoicePerformthenextset(
        title: "Workout",
        body: nextExerciseName,
        flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin);
    return Future.value(true);
  });
}

void callbackDispatcher6() {
  Workmanager().executeTask((task, inputData) {
    final String nextExerciseName = inputData?['nextExerciseName'];
    LocalNotifications.initialize(flutterLocalNotificationsPlugin);
    LocalNotifications.showBigTextNotificationMaleVoicePerformthenextset(
        title: "Workout",
        body: nextExerciseName,
        flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin);
    return Future.value(true);
  });
}

void callbackDispatcher7() {
  Workmanager().executeTask((task, inputData) {
    final String nextExerciseName = inputData?['nextExerciseName'];
    LocalNotifications.initialize(flutterLocalNotificationsPlugin);
    LocalNotifications.showBigTextNotificationMale2VoicePerformthenextset(
        title: "Workout",
        body: nextExerciseName,
        flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin);
    return Future.value(true);
  });
}

void startBackgroundTask(int timerDurationInSeconds, String nextExerciseName) {
  // Calculate the delay time based on the timer duration
  final delayMilliseconds = timerDurationInSeconds * 1000;
  // print('Background task Start');
  Workmanager().registerOneOffTask(
    'notificationTask', // Task name
    'simpleTask', // Task tag
    initialDelay: Duration(milliseconds: delayMilliseconds),
    inputData: {'nextExerciseName': nextExerciseName},
  );
}

void startBackgroundTask2(int timerDurationInSeconds, String nextExerciseName) {
  // Calculate the delay time based on the timer duration
  final delayMilliseconds = timerDurationInSeconds * 1000;
  // print('Background task Start');
  Workmanager().registerOneOffTask(
    'notificationTask2', // Task name
    'CalendarAlert', // Task tag
    initialDelay: Duration(milliseconds: delayMilliseconds),
    inputData: {'nextExerciseName': nextExerciseName},
  );
}

Future<bool> loadSoundSetting() async {
  bool isSoundEnabled = true;
  final prefs = await SharedPreferences.getInstance();

  isSoundEnabled = prefs.getBool('sound_enabled') ?? true;
  return isSoundEnabled;
}

Future<String> loadSoundSetting2() async {
  String selectedSound = 'beep';
  final prefs = await SharedPreferences.getInstance();

  selectedSound = prefs.getString('selected_sound') ?? 'beep';
  return selectedSound;
}

void cancelBackgroundTask(String tag) {
  //Workmanager().cancelByTag('simpleTask');
  //Workmanager().cancelAll();
  Workmanager().cancelByUniqueName(tag);
  //print('Background task cancelled');
}

Future<void> initializeBackgroundTasks() async {
  bool isSoundEnabled = true;
  String soundOption = "beep";
  isSoundEnabled = await loadSoundSetting();
  soundOption = await loadSoundSetting2();

  if (isSoundEnabled) {
    if (soundOption == 'beep') {
      Workmanager().initialize(callbackDispatcher3);
    } else if (soundOption == 'female_voice_1') {
      Workmanager().initialize(callbackDispatcher);
    } else if (soundOption == 'beep2') {
      Workmanager().initialize(callbackDispatcher4);
    } else if (soundOption == 'female_voice_2') {
      Workmanager().initialize(callbackDispatcher5);
    } else if (soundOption == 'male_voice_1') {
      Workmanager().initialize(callbackDispatcher6);
    } else if (soundOption == 'male_voice_2') {
      Workmanager().initialize(callbackDispatcher7);
    }
  } else {
    Workmanager().initialize(callbackDispatcher2);
  }
}

bool myGlobalBool = true;
bool notificationDialogShown = false;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await Firebase.initializeApp();
  await initializeBackgroundTasks();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Plan Workout',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}
