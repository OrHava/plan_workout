import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:plan_workout/blocs/workout_cubit.dart';
import 'package:plan_workout/helpers.dart';
import 'package:plan_workout/main.dart';
import 'package:plan_workout/models/exercise.dart';
import 'package:plan_workout/models/workout.dart';
import 'package:plan_workout/screens/workout_result_page.dart';
import 'package:plan_workout/states/workout_states.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:math';
import 'package:video_player/video_player.dart';
import 'package:plan_workout/screens/calendar_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class AppInfo {
  final String name;
  final String urlScheme;
  final String imagePath;

  AppInfo(this.name, this.urlScheme, this.imagePath);
}

class WorkoutProgress extends StatefulWidget {
  const WorkoutProgress({super.key});

  @override
  WorkoutProgressState createState() => WorkoutProgressState();
}

class WorkoutProgressState extends State<WorkoutProgress>
    with WidgetsBindingObserver {
  int elapsedDuration = 0;
  Timer? timer;
  bool isSoundEnabled = true; // Initialize this from SharedPreferences
  String selectedSound = 'beep'; // Initialize with the default sound
  DateTime workoutStartTime = DateTime.now();
  bool isVideoEnabled = true;
  final List<AppInfo> musicApps = [
    AppInfo('Spotify', 'spotify:',
        'assets/spotify_icon.png'), // Replace with the actual URL scheme
    AppInfo('Apple Music', 'music:',
        'assets/applemusic_icon.png'), // Replace with the actual URL scheme
    AppInfo('Google Play Music', 'music:', 'assets/googleplay_icon.png'),
    AppInfo('Amazon Music', 'music:', 'assets/amazonmusic_icon.png'),
  ];

  @override
  void initState() {
    super.initState();
    // Register this class as an observer for app lifecycle events
    loadSoundSetting();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // Remove this class as an observer when the widget is disposed
    WidgetsBinding.instance.removeObserver(this);
    // Other cleanup code...
    for (final controller in _exerciseVideoControllers.values) {
      controller.dispose();
    }
    super.dispose();
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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Handle app lifecycle changes here
    if (state == AppLifecycleState.paused) {
      // The app is going to the background, save the elapsed time
      saveElapsedTime();
    } else if (state == AppLifecycleState.resumed) {
      // The app is coming back to the foreground, reload the elapsed time
      reloadElapsedTime();
    }
  }

  void saveElapsedTime() {
    // Save the elapsed duration to a storage mechanism (e.g., SharedPreferences)
    SharedPreferences.getInstance().then((prefs) {
      prefs.setInt('elapsedTime', elapsedDuration);
    });
  }

  void reloadElapsedTime() {
    // Reload the elapsed duration from storage (e.g., SharedPreferences)
    SharedPreferences.getInstance().then((prefs) {
      final savedElapsedTime = prefs.getInt('elapsedTime') ?? 0;
      setState(() {
        elapsedDuration = savedElapsedTime;
      });
    });
  }

  Future<void> _launchApp(String urlScheme) async {
    if (await canLaunchUrl(Uri.parse(urlScheme))) {
      await launchUrl(Uri.parse(urlScheme));
    } else {
      // Handle if the app cannot be launched
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not launch the Spotify app'),
          ),
        );
      }
    }
  }

  Future<void> showMusicAppsList(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Music Apps'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: musicApps.length,
              itemBuilder: (context, index) {
                final appInfo = musicApps[index];

                return ListTile(
                  leading: SizedBox(
                      width: 30,
                      height: 30,
                      child: Image.asset(appInfo.imagePath)),
                  title: Text(appInfo.name),
                  onTap: () {
                    _launchApp(appInfo.urlScheme);

                    Navigator.of(context).pop(); // Close the dialog
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Widget randomTipWidget() {
    // Generate a random index to select a tip
    Random random = Random();
    int randomIndex = random.nextInt(tips.length);

    // The selected tip
    String selectedTip = tips[randomIndex];

    // Your UI code with the selected tip and image
    // Make sure to adjust the image path and dimensions as needed
    return SizedBox(
      height: 300, // Adjust the height as needed
      width: MediaQuery.of(context).size.width, // Adjust the width as needed
      child: Stack(
        alignment: Alignment.center, // Center the children
        children: <Widget>[
          Image.asset(
            'assets/blur_gym_room.jpg', // Replace with your image asset
            height: 300, // Adjust the image height
            width: MediaQuery.of(context).size.width, // Adjust the image width
            fit: BoxFit.fill, // Adjust this to control image scaling
          ),
          Container(
            color: Colors.black.withOpacity(0.6), // Background color for text
            padding: const EdgeInsets.all(10), // Adjust text padding
            child: Text(
              selectedTip,
              textAlign: TextAlign.center, // Center-align the text
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ), // Text style with white letters in bold
            ),
          ),
        ],
      ),
    );
  }

  final Map<String, VideoPlayerController> _exerciseVideoControllers = {};

  Future<void> initializeVideoController(String videoFileName) async {
    if (_exerciseVideoControllers.containsKey(videoFileName)) {
      return; // Video already loaded, no need to initialize again
    }

    // You can load videos asynchronously using compute or another isolate.
    await _loadVideoInBackground(videoFileName);
  }

  Future<void> _loadVideoInBackground(String videoFileName) async {
    final videoPath = 'assets/workouts_videos/$videoFileName.mp4';

    final tempDir = await getTemporaryDirectory();
    final tempVideoFile = File('${tempDir.path}/$videoFileName.mp4');

    // Check if the video is already cached, if not, load it from assets
    if (!tempVideoFile.existsSync()) {
      final assetData = await rootBundle.load(videoPath);
      final bytes = assetData.buffer.asUint8List();
      await tempVideoFile.writeAsBytes(bytes);
    }

    final controller = VideoPlayerController.file(tempVideoFile,
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true,
        ));

    try {
      await controller.initialize();
      controller.setLooping(true);
      _exerciseVideoControllers[videoFileName] = controller;
    } catch (e) {
      // Handle the error as needed (e.g., show an error message).
      // ignore: avoid_print
      print('Error initializing video controller for: $videoFileName');
    }
  }

  void disposeUnusedControllers(String currentExerciseName) {
    _exerciseVideoControllers.forEach((key, controller) {
      if (key != currentExerciseName) {
        controller.dispose();
      }
    });
    _exerciseVideoControllers
        .removeWhere((key, value) => key != currentExerciseName);
  }

  Widget buildVideoWorkout(String exerciseName, WorkoutState state) {
    if (savedWorkouts.contains(exerciseName)) {
      initializeVideoController(exerciseName);
      // disposeUnusedControllers(exerciseName);
      if (_exerciseVideoControllers.containsKey(exerciseName)) {
        // ignore: avoid_print
        //print("Problem in like 1");
        return buildVideoPlayer(
            _exerciseVideoControllers[exerciseName]!, state);
      } else {
        // ignore: avoid_print
        print("Problem in like 2");
        return randomTipWidget();
      }
    } else {
      // ignore: avoid_print
      print("Problem in like 3");
      return randomTipWidget();
    }
  }

  Widget buildVideoPlayer(
    VideoPlayerController controller,
    WorkoutState state,
  ) {
    if (controller.value.isInitialized) {
      isVideoEnabled = false;
      if (state is WorkoutPaused) {
        controller.pause();
      } else {
        controller.play();
      }
      return SizedBox(
        height: 300, // Adjust the height and width as needed
        width: 150,
        child: VideoPlayer(controller),
      );
    } else {
      // Display a placeholder image while the video is loading
      return randomTipWidget();
    }
  }

  WorkoutTips? findWorkoutByName(String targetWorkoutName) {
    for (var workout in savedWorkoutsTips) {
      if (workout.name == targetWorkoutName) {
        return workout;
      }
    }
    return null; // Workout not found
  }

  String? previousExerciseName;
  Widget? videoPlayer;
  int consecutiveChangeCount = 0;
  @override
  Widget build(BuildContext context) {
    int? previousExerciseIndex;
    // Initialize AudioPlayer for background audio playback
    final AudioPlayer player = AudioPlayer();

    bool isBackgroundTaskActive = false; // Flag to track audio playback

    timer ??= Timer.periodic(const Duration(seconds: 1), (timer) {
      elapsedDuration++;
    });

    // ignore: no_leading_underscores_for_local_identifiers
    Map<String, dynamic> _getStats(Workout workout, int workoutElapsed) {
      int workoutTotal = workout.getTotal();
      Exercise exercise = workout.getCurrentExercise(workoutElapsed);
      int exerciseElapsed = workoutElapsed - exercise.startTime!;
      int exerciseRemaining = exercise.prelude! - exerciseElapsed;
      bool isPrelude = exerciseElapsed < exercise.prelude!;
      int exerciseTotal = isPrelude ? exercise.prelude! : exercise.duration!;
      int currentExerciseSets = exercise.sets!;
      String currentExerciseName = exercise.title!;
      String nextExerciseName = "";

      if (exercise.index! + 1 < workout.exercieses.length) {
        nextExerciseName = workout.exercieses[exercise.index! + 1].title!;
      } else {
        nextExerciseName =
            "No next exercise"; // Handle case when there's no next exercise
      }

      // Reset the flag when the exercise changes
      if (exercise.index != previousExerciseIndex) {
        isBackgroundTaskActive = false;
        previousExerciseIndex = exercise.index;
      }

      if (!isPrelude) {
        exerciseElapsed -= exercise.prelude!;

        exerciseRemaining += exercise.duration!;
      }
      return {
        "workoutTile": workout.title,
        "workoutProgress": workoutElapsed / workoutTotal,
        "workoutElasped": workoutElapsed,
        "totalExercises": workout.exercieses.length,
        "currentExerciseIndex": exercise.index!.toDouble().toInt(),
        "workoutRemaining": workoutTotal - workoutElapsed,
        "exerciseRemaining": exerciseRemaining,
        "isPrelude": isPrelude,
        "exerciseProgress": exerciseElapsed / exerciseTotal,
        "currentExerciseName": currentExerciseName,
        "nextExerciseName": nextExerciseName,
        "currentExerciseSets": currentExerciseSets,
      };
    }

    return BlocConsumer<WorkoutCubit, WorkoutState>(builder: (context, state) {
      final stats = _getStats(state.workout!, state.elapsed!);

      if (savedWorkouts.contains(stats['currentExerciseName'])) {
        if (isVideoEnabled) {
          videoPlayer = buildVideoWorkout(stats['currentExerciseName'], state);
          disposeUnusedControllers(stats['currentExerciseName']);
        }
      } else {
        if (stats['currentExerciseName'] != previousExerciseName) {
          videoPlayer = buildVideoWorkout(stats['currentExerciseName'], state);
          previousExerciseName =
              stats['currentExerciseName']; // Update the previousExerciseName
        }
      }

      if (stats['isPrelude']) {
        if (!isBackgroundTaskActive && state is WorkoutInProgress) {
          startBackgroundTask(
            stats['exerciseRemaining'] - 3,
            "Time is up. Go to the next workout: ${replaceUnderscoresWithSpaces(stats['currentExerciseName'])}.",
          );

          isBackgroundTaskActive = true; // Set the flag to indicate active task
          //print("its true");
        }
      } else {
        cancelBackgroundTask("notificationTask");
      }

      if (state is WorkoutPaused) {
        cancelBackgroundTask("notificationTask");
        isBackgroundTaskActive = false; // Task is canceled, reset the flag
      }

      // Create a list of Dot widgets for the DotsIndicator.
      List<Widget> dots = List.generate(
        stats['totalExercises'],
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 2.0),
          width: 8.0,
          height: 8.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index == stats['currentExerciseIndex']
                ? const Color.fromARGB(255, 104, 66, 255)
                : Colors.grey,
          ),
        ),
      );

      // Create a Wrap widget to handle wrapping of dots to new lines.
      Widget dotsWrap = Wrap(
        direction: Axis.horizontal,
        alignment: WrapAlignment.start,
        spacing: 4.0,
        children: dots,
      );

      return WillPopScope(
        onWillPop: () async {
          // Show a confirmation dialog when the back button is pressed
          return await showDialog(
            context: context,
            builder: (context) {
              timer?.cancel();

              return leaveWorkout(context);
            },
          );
        },
        child: Scaffold(
          backgroundColor: const Color.fromARGB(255, 48, 46, 48),
          appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 104, 66, 255),
            title: Text(state.workout!.title.toString()),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () async {
                final leaveConfirmed = await showDialog(
                  context: context,
                  builder: (context) {
                    return leaveWorkout(context);
                  },
                );
                if (leaveConfirmed == true) {
                  timer?.cancel();
                  // Check if the state is WorkoutInProgress and pause it if needed
                  if (state is WorkoutInProgress && context.mounted) {
                    BlocProvider.of<WorkoutCubit>(context).pauseWorkout();
                  }

                  if (context.mounted) {
                    Navigator.of(context).pop(); // Close the current screen
                  }
                }
              },
            ),
          ),
          body: ListView(
            children: [
              LinearProgressIndicator(
                color: const Color.fromARGB(255, 104, 66, 255),
                backgroundColor: Colors.blue[100],
                minHeight: 10,
                value: stats['workoutProgress'],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5, right: 5, left: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatTime(stats["workoutElasped"], true),
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text('-${formatTime(stats["workoutRemaining"], true)}',
                        style: const TextStyle(color: Colors.white))
                  ],
                ),
              ),
              Center(child: dotsWrap),
              const SizedBox(
                height: 2,
              ),
              videoPlayer!,
              const SizedBox(
                height: 2,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          showMusicAppsList(context);
                        },
                        child: Container(
                          width: 40.0,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.library_music,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 0.0),
                      child: Stack(
                        alignment: const Alignment(0, 0),
                        children: [
                          Center(
                            child: SizedBox(
                              height: 55,
                              width: 55,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    stats['isPrelude']
                                        ? Colors.red
                                        : const Color.fromARGB(
                                            255, 104, 66, 255)),
                                strokeWidth: 6,
                                value: stats['exerciseProgress'],
                              ),
                            ),
                          ),
                          Center(
                            child: SizedBox(
                              height: 75,
                              width: 75,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 5),
                                child: Image.asset("assets/stopwatch.png"),
                              ),
                            ),
                          ),
                          Center(
                            child: Column(
                              children: [
                                Text(
                                  formatTime(stats['exerciseRemaining'], true),
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          toggleSoundSetting(!isSoundEnabled);
                        },
                        child: Container(
                          width: 40.0,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            isSoundEnabled ? Icons.volume_up : Icons.volume_off,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
              Column(
                children: [
                  Wrap(
                    children: [
                      Text(
                        "    ${stats['currentExerciseSets']} ",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(
                        width: 320,
                        child: Text(
                          replaceUnderscoresWithSpaces(
                              stats['currentExerciseName']),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow
                              .ellipsis, // Add ellipsis for long text
                          maxLines: 1, // Limit to a single line
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 20.0),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {
                              if (context.mounted) {
                                WorkoutTips? matchingWorkout =
                                    findWorkoutByName(
                                        stats['currentExerciseName']);

                                if (matchingWorkout != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Name: ${replaceUnderscoresWithSpaces(matchingWorkout.name)}\n\n'
                                        'Description: ${matchingWorkout.howTo}\n\n'
                                        'Tips: ${matchingWorkout.tips}\n\n',
                                        style: const TextStyle(
                                          fontSize: 16, // Adjust the font size
                                          fontWeight: FontWeight
                                              .normal, // Adjust the font weight
                                          color: Colors
                                              .white, // Change the text color
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                            child: Container(
                              width: 25.0,
                              height: 25,
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.info,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          onPressed: () {
                            if (stats['currentExerciseIndex'] > 0) {
                              BlocProvider.of<WorkoutCubit>(context)
                                  .moveToNextExercise(
                                stats['currentExerciseIndex'] - 1,
                                stats['isPrelude'],
                              );
                              isVideoEnabled = true;
                            }
                          },
                          child: Container(
                            width: 150.0,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.arrow_back,
                                  size: 30,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            if (state is WorkoutInProgress) {
                              // Your code to pause the workout
                              BlocProvider.of<WorkoutCubit>(context)
                                  .pauseWorkout();

                              if (_exerciseVideoControllers
                                  .containsKey(stats['currentExerciseName'])) {
                                if (_exerciseVideoControllers[
                                        stats['currentExerciseName']]!
                                    .value
                                    .isInitialized) {
                                  _exerciseVideoControllers[
                                          stats['currentExerciseName']]!
                                      .pause();
                                }
                              }

                              cancelBackgroundTask("notificationTask");
                            } else if (state is WorkoutPaused) {
                              // Your code to resume the workout
                              BlocProvider.of<WorkoutCubit>(context)
                                  .resumeWorkout();

                              if (_exerciseVideoControllers
                                  .containsKey(stats['currentExerciseName'])) {
                                if (_exerciseVideoControllers[
                                        stats['currentExerciseName']]!
                                    .value
                                    .isInitialized) {
                                  _exerciseVideoControllers[
                                          stats['currentExerciseName']]!
                                      .play();
                                }
                              }
                            }
                          },
                          child: Container(
                            width: 150.0,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Visibility(
                                  visible: state is WorkoutInProgress ||
                                      state is WorkoutPaused,
                                  child: Icon(
                                    state is WorkoutInProgress
                                        ? Icons.pause
                                        : Icons.play_arrow,
                                    size: 30,
                                    color: Colors.white,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 250,
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 13),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: SizedBox(
                          height: 60,
                          width: 350,
                          child: ElevatedButton(
                            onPressed: () {
                              isVideoEnabled = true;

                              BlocProvider.of<WorkoutCubit>(context)
                                  .moveToNextExercise(
                                stats['currentExerciseIndex'],
                                stats['isPrelude'],
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 104, 66, 255),
                              foregroundColor: Colors.white,
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment
                                    .center, // Center the contents
                                children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: SizedBox(
                                      width: 40,
                                      height:
                                          30, // Reduce height to match the icon size
                                      child: Stack(
                                        children: [
                                          Container(
                                            width: 30,
                                            height: 30,
                                            decoration: BoxDecoration(
                                              color: Colors.black45,
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                            ),
                                          ),
                                          Image.asset(
                                            stats['isPrelude']
                                                ? "assets/go.png"
                                                : "assets/rest.png",
                                            width: 30,
                                            height: 30,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Next:",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 200,
                                        child: Text(
                                          stats['isPrelude']
                                              ? replaceUnderscoresWithSpaces(
                                                  stats['nextExerciseName'])
                                              : "Rest Time",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow
                                              .ellipsis, // Add ellipsis for long text
                                          maxLines: 1, // Limit to a single line
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Expanded(
                                    child: SizedBox(),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward,
                                    size: 30,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }, listener: (context, state) async {
      // Listen for state changes here
      if (state is WorkoutCompleted) {
        // The workout is completed, navigate to the result page
        timer?.cancel();
        player.dispose();
        cancelBackgroundTask("notificationTask");

        // Save workout information to SharedPreferences
        DateTime workoutFinishTime = DateTime.now();
        Duration workoutDuration =
            workoutFinishTime.difference(workoutStartTime);

        final workoutName = "Completed Workout: ${state.workout!.title}";

        // Use a unique key to store each workout's data
        // final workoutKey = 'workout_${workoutDate.millisecondsSinceEpoch}';
        CalendarPageState calendarPageState = CalendarPageState();

        // Create a workout data object
        WorkoutData workoutData = WorkoutData(
            id: generateRandomId(),
            name: workoutName,
            date: DateTime.now(),
            time: workoutDuration.inSeconds.toString());

        // Call the saveWorkout function
        calendarPageState.saveWorkout(workoutData);

        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => WorkoutResultPage(
                totalTime: elapsedDuration,
              ),
            ),
          );
        }
      }
    });
  }

  AlertDialog leaveWorkout(BuildContext context) {
    return AlertDialog(
      title: const Text("Leave Workout?"),
      content: const Text("Are you sure you want to leave the workout?"),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(true); // User confirms, allow navigation
            cancelBackgroundTask("notificationTask");
          },
          child: const Text("Yes"),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context)
                .pop(false); // User cancels, prevent navigation
          },
          child: const Text("No"),
        ),
      ],
    );
  }
}
