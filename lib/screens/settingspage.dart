import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../background_task.dart';
import '../main.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  bool isSoundEnabled = true; // Initialize this from SharedPreferences
  String selectedSound = 'beep'; // Initialize with the default sound
  List<String> soundOptions = [
    'beep',
    'beep2',
    'female_voice_1',
    'female_voice_2',
    'male_voice_1',
    'male_voice_2',
  ]; // Define sound options

  @override
  void initState() {
    super.initState();
    loadSoundSetting();
  }

  void loadSoundSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isSoundEnabled = prefs.getBool('sound_enabled') ?? true;
      selectedSound = prefs.getString('selected_sound') ?? 'beep';
    });
  }

  void toggleSoundSetting(bool newValue) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('sound_enabled', newValue);
    await initializeBackgroundTasks();

    setState(() {
      isSoundEnabled = newValue;
    });
  }

  void changeSound(String? newSound) async {
    if (newSound != null) {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('selected_sound', newSound);

      await playAssetAudio(newSound);
      await initializeBackgroundTasks();

      setState(() {
        selectedSound = newSound;
      });
    }
  }

  Future<void> showAbout(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('About'),
          content: const SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Text(
                "Welcome to the future of fitness – introducing Workout Planner, an exceptional app meticulously curated by the visionary mind of Or Hava. This isn't merely an application; it's a testament to the extraordinary capabilities of a lone developer, where Or Hava's passion for health and well-being takes center stage.\n\n"
                "Workout Planner goes beyond the ordinary, offering a tailored fitness experience to elevate your physical prowess and sculpt the body of your dreams. Immerse yourself in a seamless fusion of cutting-edge technology and wellness expertise, where every feature is designed to make your fitness journey not only effective but exhilarating.\n\n"
                "What sets Workout Planner apart is not just its functionality but its commitment to perpetual enhancement. Or Hava's unwavering dedication ensures that the app is a dynamic entity, evolving with the latest advancements in the fitness world. Regular updates guarantee that your workout routine is always on the cutting edge, making every session an opportunity for progress and growth.\n\n"
                "However, the brilliance of Workout Planner extends beyond the solitary pursuit of fitness excellence. Or Hava envisions a community of like-minded individuals, united by their fitness goals. The app's unique Share Page becomes a collaborative space where users from around the globe come together to share their triumphs and insights. Workout plans aren't just logged; they become part of a collective tapestry of motivation, fostering a sense of connection and inspiration.\n\n"
                "Step into the future of fitness with Workout Planner – a groundbreaking app that seamlessly combines the expertise of Or Hava with the power of community. Join us on this extraordinary journey where every workout, every update, and every shared success brings us closer to a healthier, stronger, and more connected world. Workout Planner isn't just an app; it's a lifestyle revolution waiting to be experienced.",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Exit'),
            ),
          ],
        );
      },
    );
  }

  @pragma('vm:entry-point')
  Future<void> playAssetAudio(String theSound) async {
    String assetPath = 'assets/$theSound.mp3';

    try {
      final assetAudio = ConcatenatingAudioSource(children: [
        AudioSource.asset(assetPath), // Use AudioSource.asset here
      ]);
      await player.setAudioSource(assetAudio);

      player.play();
    } catch (e) {
      // ignore: avoid_print
      print("Error playing audio: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 104, 66, 255),
        title: const Text("Sound Settings"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0), // Add some padding
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Align text to the left
          children: [
            Row(
              children: [
                const Icon(
                  Icons.volume_up,
                  color: Colors.grey,
                ),
                const SizedBox(
                  width: 10,
                ),
                const Text(
                  "Enable sound for notifications",
                  style: TextStyle(
                    fontSize: 14, // Increase font size
                  ),
                ),
                Expanded(child: Container()),
                Switch(
                  value: isSoundEnabled,
                  onChanged: toggleSoundSetting,
                  activeColor:
                      Colors.blue, // Customize switch color when active
                ),
              ],
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (int i = 0; i < 400; i++)
                    i.isEven
                        ? Container(
                            width: 1,
                            height: 1,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          )
                        : Container(
                            width: 1,
                            height: 1,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          )
                ],
              ),
            ),
            const SizedBox(height: 10),
            // ignore: prefer_const_constructors
            Row(
              children: const [
                Icon(
                  Icons.music_note,
                  color: Colors.grey,
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  "Select notification sound",
                  style: TextStyle(
                    fontSize: 14, // Increase font size
                  ),
                ),
              ],
            ),

            Row(
              children: [
                const SizedBox(
                  width: 35,
                ),
                DropdownButton<String>(
                  value: selectedSound,
                  onChanged: changeSound,
                  items: soundOptions.map((sound) {
                    return DropdownMenuItem<String>(
                      value: sound,
                      child: Text(
                        sound,
                        style: const TextStyle(
                          fontSize: 14, // Customize dropdown item font size
                        ),
                      ),
                    );
                  }).toList(),
                  underline: Container(
                    height: 2, // Customize the underline's height
                    color: Colors.blue, // Customize the underline's color
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (int i = 0; i < 400; i++)
                    i.isEven
                        ? Container(
                            width: 1,
                            height: 1,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          )
                        : Container(
                            width: 1,
                            height: 1,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          )
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.info,
                  color: Colors.grey,
                ),
                const SizedBox(
                  width: 10,
                ),
                const Text(
                  "About",
                  style: TextStyle(
                    fontSize: 14, // Increase font size
                  ),
                ),
                Expanded(child: Container()),
                GestureDetector(
                  onTap: () {
                    showAbout(context);
                  },
                  child: const Icon(
                    Icons.file_open,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (int i = 0; i < 400; i++)
                    i.isEven
                        ? Container(
                            width: 1,
                            height: 1,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          )
                        : Container(
                            width: 1,
                            height: 1,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
