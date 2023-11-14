import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:just_audio/just_audio.dart';
import 'local_notifications.dart';
import 'main.dart'; // Import necessary dependencies

final AudioPlayer player = AudioPlayer();

bool audioPlayedForCurrentPrelude = false; // Flag to track audio playback
String assetPath = 'assets/beep.mp3';

@pragma('vm:entry-point')
void backgroundTask() async {
  try {
    final assetAudio = ConcatenatingAudioSource(children: [
      AudioSource.asset(assetPath), // Use AudioSource.asset here
    ]);
    await player.setAudioSource(assetAudio);
    player.play();
    LocalNotifications.showBigTextNotificationFemaleVoicePerformthenextset(
        title: "Workout",
        body: "Time is Up go to the next workout",
        flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin);
    audioPlayedForCurrentPrelude = true;
  } catch (e) {
    // print("Error playing audio: $e");
  }
}

void scheduleBackgroundTask() {
  const int helloAlarmID = 0;
  AndroidAlarmManager.periodic(
    const Duration(seconds: 1),
    helloAlarmID,
    backgroundTask,
    wakeup: true,
  );
}
