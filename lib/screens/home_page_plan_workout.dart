// ignore_for_file: prefer_const_literals_to_create_immutables

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

import 'package:plan_workout/blocs/workout_cubit.dart';
import 'package:plan_workout/blocs/workouts_cubit.dart';
import 'package:plan_workout/helpers.dart';
import 'package:plan_workout/models/workout.dart';
import 'package:plan_workout/screens/settingspage.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../main.dart';

// ignore: camel_case_types
class Home_Page_PlanWorkout extends StatefulWidget {
  const Home_Page_PlanWorkout({super.key});

  @override
  State<Home_Page_PlanWorkout> createState() => _MyWidgetState();
}

class ExpansionPanelRadioItem {
  final int index;
  final Workout workout;

  ExpansionPanelRadioItem(this.index, this.workout);
}

class _MyWidgetState extends State<Home_Page_PlanWorkout> {
  bool isSoundEnabled = true; // Initialize this from SharedPreferences
  int expandedWorkoutIndex =
      -1; // Initialize to -1, indicating no workout is expanded
  Workout? selectedWorkout;
  @override
  void initState() {
    super.initState();

    // Load the workouts from the file when the page is first opened
    //BlocProvider.of<WorkoutsCubit>(context).loadWorkoutsFromFile();
  }

  @override
  void dispose() {
    for (final videoAssetPath in _thumbnailCache.keys.toList()) {
      closeCachedThumbnail(videoAssetPath);
    }
    super.dispose();
  }

// Create a cache manager for thumbnails
  final Map<String, File> _thumbnailCache = {};

// Function to close cached File objects
  void closeCachedThumbnail(String videoAssetPath) {
    if (_thumbnailCache.containsKey(videoAssetPath)) {
      final cachedThumbnail = _thumbnailCache[videoAssetPath];
      if (cachedThumbnail!.existsSync()) {
        cachedThumbnail.delete();
      }
      _thumbnailCache.remove(videoAssetPath);
    }
  }

  Future<Uint8List?> generateThumbnail(
    String videoAssetPath,
    int positionInSeconds,
  ) async {
    try {
      if (_thumbnailCache.containsKey(videoAssetPath)) {
        final cachedThumbnail = _thumbnailCache[videoAssetPath]!;
        final bytes = await cachedThumbnail.readAsBytes();
        return Uint8List.fromList(bytes);
      } else {
        final ByteData byteData = await rootBundle.load(videoAssetPath);
        final List<int> videoBytes = byteData.buffer.asUint8List();

        final Directory tempDir = await getTemporaryDirectory();
        final String tempVideoPath = "${tempDir.path}/$videoAssetPath";
        final File tempVideo = File(tempVideoPath);

        if (!tempVideo.existsSync()) {
          // Check if the video file exists before writing to it
          await tempVideo.create(recursive: true);
          await tempVideo.writeAsBytes(videoBytes);
          if (!tempVideo.existsSync()) {
            // If it still doesn't exist, return null
            return null;
          }
        }

        final thumbnail = await VideoThumbnail.thumbnailData(
          video: tempVideo.path,
          imageFormat: ImageFormat.PNG,
          timeMs: positionInSeconds * 1000,
          quality: 100,
        );

        if (thumbnail != null) {
          // Cache the generated thumbnail and close the temp video file
          _thumbnailCache[videoAssetPath] = tempVideo;
          closeCachedThumbnail(videoAssetPath);
        }

        return thumbnail;
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error generating thumbnail: $e');
      return null;
    }
  }

  Widget yourThumbnailWidget(String videoAssetPath, int positionInSeconds) {
    return FutureBuilder<Uint8List?>(
      future: generateThumbnail(videoAssetPath, positionInSeconds),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          return SizedBox(
            width: 60.0,
            height: 60.0,
            child: Image.memory(snapshot.data!),
          );
        } else {
          // You can display a loading indicator or a placeholder image here
          return Container(
            width: 60.0,
            height: 60.0,
            color: Colors.white, // Placeholder background color
            child: const Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 104, 66, 255),
          title: const Text("Workout Time!"),
          actions: [
            // IconButton(
            //   onPressed: printsomething,
            //   icon: const Icon(Icons.event_available), // Wrap with Icon widget
            // ),
            IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SettingsPage(),
                  ),
                );
              },
              icon: const Icon(Icons.settings),
            ),
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                  'assets/background_main_gym.jpg'), // Replace with your image asset path
              fit: BoxFit.cover, // You can adjust the fit as needed
            ),
          ),
          child: BlocBuilder<WorkoutsCubit, List<Workout>>(
            builder: (context, workouts) => ListView.builder(
              itemCount: workouts.length,
              itemBuilder: (BuildContext context, int index) {
                final workout = workouts[index];
                selectedWorkout = workout;
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: myGlobalBool
                          ? Colors.transparent
                          : Colors.black, // Border color
                      width: 2.0, // Border width
                    ),
                  ),
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        //tileColor: Colors.blue[50],
                        iconColor: Colors.blue[700],
                        textColor: Colors.blue[900],
                        focusColor: Colors.blue[200],
                        hoverColor: Colors.blue[100],
                        splashColor: Colors.blue[700],
                        selectedColor: Colors.blue[200],
                        selectedTileColor: Colors.blue[50],
                        visualDensity: const VisualDensity(
                          horizontal: 0,
                          vertical: VisualDensity.maximumDensity,
                        ),
                        leading: IconButton(
                          onPressed: myGlobalBool
                              ? null
                              : () {
                                  BlocProvider.of<WorkoutCubit>(context)
                                      .editWorkout(workout, index);
                                },
                          icon: Icon(
                            Icons.edit,
                            color: myGlobalBool
                                ? Colors.transparent
                                : Colors.white,
                          ),
                        ),
                        title: Text(
                          workout.title!,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold),
                        ),
                        trailing: Text(
                          "${formatTime(workout.getTotal(), true)} min",
                          style: const TextStyle(
                              color: Color.fromRGBO(102, 103, 107, 1),
                              fontSize: 13,
                              fontWeight: FontWeight.w900),
                        ),

                        subtitle: Column(
                          children: [
                            Container(
                              height: 10,
                            ),
                            Row(
                              children: [
                                Text(
                                  "${workout.exercieses.length} Exercises",
                                  style: const TextStyle(
                                    color: Color.fromRGBO(102, 103, 107, 1),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        blurRadius: 3.0,
                                        color: Colors.black,
                                        offset: Offset(2.0, 2.0),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              height: 10,
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 150, // Set the width you desire
                                  height: 30,
                                  child: Container(
                                    padding: const EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.rectangle,
                                      borderRadius: BorderRadius.circular(10),
                                      color: const Color.fromRGBO(
                                          104, 66, 255, 0.5),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Workout Type: ${workout.type!}",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        onTap: () => BlocProvider.of<WorkoutCubit>(context)
                            .startWorkout(context, workout),
                      ),
                      ListTile(
                        visualDensity: const VisualDensity(
                          horizontal: 0,
                          vertical: VisualDensity.maximumDensity,
                        ),
                        leading: IconButton(
                          onPressed: () {
                            _thumbnailCache.clear();
                            selectedWorkout = workout;
                            setState(() {
                              expandedWorkoutIndex =
                                  expandedWorkoutIndex == index ? -1 : index;
                            });
                          },
                          icon: Icon(
                            expandedWorkoutIndex == index
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: const Color.fromRGBO(104, 66, 255, 2),
                          ),
                        ),
                        title: const Text(
                          "Exercises",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (expandedWorkoutIndex == index || myGlobalBool)

                        //const Color.fromRGBO(244, 244, 246, 1),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: const BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(25.0),
                              topRight: Radius.circular(25.0),
                            ), // This can be customized based on your needs
                            color: Color.fromRGBO(244, 244, 246, 1),
                          ),
                          child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 80),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: workout.exercieses.length,
                            itemBuilder:
                                (BuildContext context, int exerciseIndex) {
                              final exerciseTitle =
                                  workout.exercieses[exerciseIndex].title;
                              final hasThumbnail =
                                  savedWorkouts.contains(exerciseTitle);

                              return Padding(
                                padding: const EdgeInsets.only(
                                    left: 14, right: 14, top: 8),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: ListTile(
                                    // tileColor: Colors.blue[50],
                                    iconColor: Colors.blue[700],
                                    textColor: Colors.blue[900],
                                    focusColor: Colors.blue[200],
                                    hoverColor: Colors.blue[100],
                                    splashColor: Colors.blue[700],
                                    selectedColor: Colors.blue[200],
                                    selectedTileColor: Colors.blue[50],
                                    onTap: null,
                                    visualDensity: const VisualDensity(
                                      horizontal: 0,
                                      vertical: VisualDensity.maximumDensity,
                                    ),
                                    leading: hasThumbnail
                                        ? Column(
                                            children: [
                                              yourThumbnailWidget(
                                                  'assets/workouts_videos/$exerciseTitle.mp4',
                                                  1),
                                            ],
                                          )
                                        : Column(
                                            children: [
                                              SizedBox(
                                                height: 40,
                                                width: 40,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 5),
                                                  child: Image.asset(
                                                      'assets/abs.png'),
                                                ),
                                              ),
                                            ],
                                          ), // Use a placeholder image
                                    title: Text(
                                      replaceUnderscoresWithSpaces(
                                          exerciseTitle!),
                                      style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    ),

                                    trailing: Text(
                                      "${workout.exercieses[exerciseIndex].sets.toString()} reps",
                                      style: const TextStyle(
                                          color:
                                              Color.fromRGBO(102, 103, 107, 1)),
                                    ),
                                    subtitle: Text(
                                      "${workout.exercieses[exerciseIndex].prelude!} sec rest\n${workout.exercieses[exerciseIndex].duration!} sec duration",
                                      style: const TextStyle(
                                          color:
                                              Color.fromRGBO(102, 103, 107, 1),
                                          fontSize: 13),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),

        // Add a floating action button at the bottom right corner
        floatingActionButton: myGlobalBool
            ? FloatingActionButton.extended(
                onPressed: () {
                  BlocProvider.of<WorkoutCubit>(context)
                      .startWorkout(context, selectedWorkout!);
                },
                backgroundColor: const Color.fromARGB(255, 104, 66, 255),
                label: const Row(
                  children: <Widget>[
                    Text(
                      'Start Workout',
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(width: 8), // Adjust the spacing as needed
                    Icon(Icons.play_arrow),
                  ],
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              )
            : FloatingActionButton(
                backgroundColor: const Color.fromRGBO(104, 66, 255, 2),
                onPressed: () {
                  _addNewWorkout(
                      context); // Call a function to show the "Add Workout" dialog
                },
                child: const Icon(Icons.add),
              ),
        floatingActionButtonLocation: myGlobalBool
            ? FloatingActionButtonLocation.centerFloat
            : FloatingActionButtonLocation.endFloat);
  }

  Future<void> saveToJsonFile(String content) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/json_output.txt');
      await file.writeAsString(content);

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("JSON content saved to app's internal storage")),
      );

      // Open the saved file using the default application
      await OpenFile.open(file.path);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error saving JSON content: "),
        ),
      );
    }
  }

  Future<void> printsomething() async {
    final directory = await getApplicationDocumentsDirectory();
    final file2 = File('${directory.path}/workouts.json');
    final jsonContent2 = await file2.readAsString();
    //print("after 2");

    //print(jsonContent2);
    await saveToJsonFile(jsonContent2); // Save JSON content to a file
  }

  // Function to show the "Add Workout" dialog
  void _addNewWorkout(BuildContext context) {
    TextEditingController newWorkoutController = TextEditingController();

    String selectedWorkoutType = 'General';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add New Workout"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: newWorkoutController,
              decoration: const InputDecoration(
                labelText: "New Workout Name",
              ),
              keyboardType: TextInputType.text,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.singleLineFormatter,
              ],
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: selectedWorkoutType,
              items: ["General", "Abs", "Legs", "Arms", "Back", "Glutes"]
                  .map((type) => DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      ))
                  .toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedWorkoutType = newValue!;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              String newWorkoutName = newWorkoutController.text;
              if (newWorkoutName.isNotEmpty) {
                // Create a new workout object with the new name
                final newWorkout =
                    // ignore: prefer_const_literals_to_create_immutables beacuse it might create a problem when add new exercises
                    Workout(
                        title: newWorkoutName,
                        type: selectedWorkoutType,
                        exercieses: []);

                // Dispatch an event to add the new workout in WorkoutsCubit
                BlocProvider.of<WorkoutCubit>(context)
                    .createAndSaveNewWorkout(context, newWorkout);

                Navigator.pop(context); // Close the dialog
              }
            },
            child: const Text("Save"),
          ),
          TextButton(
            onPressed: () {
              // Close the dialog without saving
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }
}
