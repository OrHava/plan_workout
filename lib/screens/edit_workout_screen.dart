import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plan_workout/blocs/workout_cubit.dart';
import 'package:plan_workout/blocs/workouts_cubit.dart';

import 'package:plan_workout/helpers.dart';
import 'package:plan_workout/models/exercise.dart';

import 'package:plan_workout/screens/edit_exercise_screen.dart';
import 'package:plan_workout/states/workout_states.dart';
import 'package:video_player/video_player.dart';

class EditWorkoutScreen extends StatelessWidget {
  EditWorkoutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child:
            BlocBuilder<WorkoutCubit, WorkoutState>(builder: (context, state) {
          WorkoutEditing we = state as WorkoutEditing;
          final workoutsCubit = context.watch<WorkoutsCubit>(); // Add this line
          String? selectedWorkoutType = we.workout!.type;

          return Scaffold(
            backgroundColor: const Color.fromARGB(255, 173, 180, 184),
            appBar: AppBar(
                backgroundColor: const Color.fromARGB(255, 104, 66, 255),
                leading: BackButton(
                  onPressed: () =>
                      BlocProvider.of<WorkoutCubit>(context).goHome(context),
                ),
                actions: [
                  Builder(builder: (context) {
                    final workoutCubitContext = context; // Capture the context

                    return IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext dialogContext) {
                            // Use a different context here
                            return AlertDialog(
                              title: const Text("Confirm Delete"),
                              content: const Text(
                                  "Are you sure you want to delete this workout?"),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(
                                        dialogContext); // Close the dialog
                                    BlocProvider.of<WorkoutCubit>(
                                            workoutCubitContext) // Use the captured context
                                        .deleteWorkout(context, we.index);
                                  },
                                  child: const Text("Delete"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(
                                        dialogContext); // Close the dialog
                                  },
                                  child: const Text("Cancel"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      icon: const Icon(Icons.delete),
                    );
                  }),
                ],
                title: InkWell(
                  child: Text(we.workout!.title!),
                  onTap: () => showDialog(
                      context: context,
                      builder: (_) {
                        final controller =
                            TextEditingController(text: we.workout!.title);
                        return AlertDialog(
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: controller,
                                decoration: const InputDecoration(
                                    labelText: "Workout title"),
                              ),
                              const SizedBox(height: 20),
                              DropdownButtonFormField<String>(
                                value: selectedWorkoutType,
                                items: [
                                  "General",
                                  "Abs",
                                  "Legs",
                                  "Arms",
                                  "Back",
                                  "Glutes"
                                ]
                                    .map((type) => DropdownMenuItem<String>(
                                          value: type,
                                          child: Text(type),
                                        ))
                                    .toList(),
                                onChanged: (newValue) {
                                  selectedWorkoutType = newValue!;
                                },
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  if (controller.text.isNotEmpty) {
                                    Navigator.pop(context);
                                    BlocProvider.of<WorkoutCubit>(context)
                                        .updateAndSaveTitle(
                                            context,
                                            controller.text,
                                            we.index,
                                            selectedWorkoutType!);
                                  }
                                },
                                child: const Text("Rename"))
                          ],
                        );
                      }),
                )),
            body: ListView.builder(
                key: const PageStorageKey(0),
                itemCount: we.workout!.exercieses.length,
                itemBuilder: (context, index) {
                  Exercise exercise = we.workout!.exercieses[index];
                  if (we.exIndex == index) {
                    return EditExerciseScreen(
                        workout: we.workout!,
                        index: we.index,
                        exIndex: we.exIndex!);
                  } else {
                    return Padding(
                      padding:
                          const EdgeInsets.only(left: 14, right: 14, top: 8),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ), // Add vertical spacing here

                        child: ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          iconColor: Colors.blue[700],
                          tileColor: const Color.fromRGBO(244, 244, 246, 1),
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
                          leading: const Icon(
                            Icons.edit,
                            size: 20,
                            color: Color.fromRGBO(104, 66, 255, 0.5),
                          ),
                          title: Text(
                            replaceUnderscoresWithSpaces(exercise.title!),
                            style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          ),
                          trailing: Text(
                            "${exercise.sets!.toString()} reps",
                            style: const TextStyle(
                                color: Color.fromRGBO(102, 103, 107, 1)),
                          ),
                          subtitle: Text(
                            "${exercise.prelude!} sec rest\n${exercise.duration!} sec duration",
                            style: const TextStyle(
                                color: Color.fromRGBO(102, 103, 107, 1),
                                fontSize: 13),
                          ),
                          onTap: () => BlocProvider.of<WorkoutCubit>(context)
                              .editExercise(index),
                        ),
                      ),
                    );
                  }
                }),

            // Add a floating action button at the bottom right corner
            floatingActionButton: FloatingActionButton(
              backgroundColor: const Color.fromRGBO(104, 66, 255, 2),
              onPressed: () {
                _addNewExercise2(context, we,
                    workoutsCubit); // Call a function to show the "Add Workout" dialog
              },
              child: const Icon(Icons.add),
            ),
          );
        }),
        onWillPop: () =>
            BlocProvider.of<WorkoutCubit>(context).goHome(context));
  }

  void _addNewExercise2(
    BuildContext context,
    WorkoutEditing we,
    WorkoutsCubit workoutsCubit,
  ) {
    TextEditingController newExerciseController = TextEditingController();
    TextEditingController preludeController = TextEditingController(text: '10');
    TextEditingController durationController =
        TextEditingController(text: '30');
    TextEditingController setsController = TextEditingController(text: '30');

    String selectedExerciseName = savedWorkouts[0];
    TextEditingController searchController = TextEditingController();
    int selectedIndex = -1;
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          final query = searchController.text.toLowerCase();

          // Filter the workouts based on the search query
          final filteredWorkouts = savedWorkouts
              .where((workout) => workout.toLowerCase().contains(query))
              .toList();

          return SingleChildScrollView(
            child: AlertDialog(
              title: const Text("Add New Exercise"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      labelText: "Search Exercise",
                    ),
                    onChanged: (_) {
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    width: 250,
                    child: ListView.builder(
                      itemCount: filteredWorkouts.length,
                      itemBuilder: (BuildContext context, int index) {
                        final value = filteredWorkouts[index];
                        final isSelected = index == selectedIndex;
                        return ListTile(
                          tileColor: isSelected
                              ? const Color.fromRGBO(104, 66, 255, 0.5)
                              : null,
                          leading: IconButton(
                            icon: Icon(
                              savedWorkouts.contains(value) && value != "Custom"
                                  ? Icons.play_circle_outline
                                  : Icons.edit_document,
                              color: const Color.fromARGB(255, 104, 66, 255),
                            ),
                            onPressed: () {
                              if (savedWorkouts.contains(value) &&
                                  value != "Custom") {
                                openVideoPopup(value, context);
                              } else {
                                selectedIndex =
                                    index; // Update the selected index.
                                selectedExerciseName = "Custom";
                              }
                              setState(
                                  () {}); // Trigger a rebuild to reflect the changes.
                            },
                          ),
                          title: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  replaceUnderscoresWithSpaces(value),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            setState(() {
                              selectedIndex = index;
                              selectedExerciseName = value;
                            });
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (selectedExerciseName == "Custom")
                    TextField(
                      controller: newExerciseController,
                      decoration: const InputDecoration(
                        labelText: "New Exercise Name",
                      ),
                      keyboardType: TextInputType.text,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.singleLineFormatter,
                      ],
                    ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: preludeController,
                          decoration: const InputDecoration(
                            labelText: "Prelude (seconds)",
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: durationController,
                          decoration: const InputDecoration(
                            labelText: "Duration (seconds)",
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: setsController,
                          decoration: const InputDecoration(
                            labelText: "Reps (Amount)",
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    String newExerciseName = selectedExerciseName == "Custom"
                        ? newExerciseController.text
                        : selectedExerciseName;
                    int prelude = int.parse(preludeController.text);
                    int duration = int.parse(durationController.text);
                    int sets = int.parse(setsController.text);
                    if (newExerciseName.isNotEmpty &&
                        prelude > 0 &&
                        duration > 0 &&
                        sets > 0) {
                      final newExercise = Exercise(
                        title: newExerciseName,
                        prelude: prelude,
                        duration: duration,
                        sets: sets,
                      );

                      // Add the new exercise to the specific workout
                      workoutsCubit.addExerciseToWorkout(
                          we.index, newExercise, context);

                      Navigator.pop(context); // Close the dialog
                    }
                  },
                  child: const Text(
                    "Save",
                    style: TextStyle(color: Color.fromARGB(255, 104, 66, 255)),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog without saving
                  },
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: Color.fromARGB(255, 104, 66, 255)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  final Map<String, VideoPlayerController> exerciseVideoControllers = {};

  // Function to open the video pop-up
  Future<void> openVideoPopup(String exerciseName, BuildContext context) async {
    // Initialize the video controller before showing the dialog
    FocusScope.of(context).unfocus();
    await initializeVideoController(exerciseName);
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          // Use your video pop-up logic here
          // You can use your `_exerciseVideoControllers` to play the video
          // for the selected exercise.
          return AlertDialog(
            title: const Text("Exercise Video"),
            content: buildVideoWorkout(exerciseName),
            actions: [
              TextButton(
                onPressed: () {
                  closeVideoPopup(dialogContext); // Close the dialog
                },
                child: const Text("Close"),
              ),
            ],
          );
        },
      ).then((_) {
        // When the dialog is dismissed, ensure that video controllers are disposed.
        disposeVideoControllers();
      });
    }
  }

  Future<void> initializeVideoController(String videoFileName) async {
    if (!exerciseVideoControllers.containsKey(videoFileName)) {
      final videoPath = 'assets/workouts_videos/$videoFileName.mp4';
      final controller = VideoPlayerController.asset(videoPath);

      try {
        await controller.initialize();
        controller.setLooping(true);
        controller.play();
        exerciseVideoControllers[videoFileName] = controller;
      } catch (e) {
        // ignore: avoid_print
        print('Error initializing video controller for: $videoFileName');
        // Handle the error as needed (e.g., show an error message).
      }
    }
  }

  Widget buildVideoWorkout(String exerciseName) {
    if (exerciseVideoControllers.containsKey(exerciseName)) {
      return buildVideoPlayer(exerciseVideoControllers[exerciseName]!);
    } else {
      // Handle the case when the video controller is not found
      // ignore: avoid_print
      print("problem in like 11888888");
      return Container();
    }
  }

  Widget buildVideoPlayer(VideoPlayerController controller) {
    controller.play();
    return SizedBox(
      height: 300, // Adjust the height and width as needed
      width: 300,
      child: VideoPlayer(controller),
    );
  }

  void disposeVideoControllers() {
    exerciseVideoControllers.forEach((_, controller) {
      controller.dispose();
    });
    exerciseVideoControllers.clear();
  }

  void closeVideoPopup(BuildContext dialogContext) {
    disposeVideoControllers(); // Dispose of video controllers
    Navigator.pop(dialogContext); // Close the dialog
  }
}
