import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:plan_workout/blocs/workouts_cubit.dart';
import 'package:plan_workout/main.dart';
import 'package:plan_workout/models/workout.dart';
import 'package:plan_workout/states/workout_states.dart';
import 'package:wakelock/wakelock.dart';

class WorkoutCubit extends Cubit<WorkoutState> {
  WorkoutCubit() : super(const WorkoutIntial());
  Timer? _timer;
  bool _isActive = true;

  editWorkout(Workout workout, int index) =>
      emit(WorkoutEditing(workout, index, null));

  editExercise(int? exIndex) => emit(
      WorkoutEditing(state.workout, (state as WorkoutEditing).index, exIndex));
  pauseWorkout() => emit(WorkoutPaused(state.workout, state.elapsed));
  resumeWorkout() => emit(WorkoutInProgress(state.workout, state.elapsed));

  goHome(BuildContext context) {
    _timer?.cancel(); // Cancel the timer if it's active
    cancelBackgroundTask("notificationTask");
    if (context.mounted) {
      BlocProvider.of<WorkoutsCubit>(context).getWorkout(saveToFile: true);
    }
    emit(const WorkoutIntial());
  }

  onTick(Timer timer) {
    if (_isActive && state is WorkoutInProgress && !isClosed) {
      // Check if the cubit is still active
      WorkoutInProgress wip = state as WorkoutInProgress;

      if (wip.elapsed! < wip.workout!.getTotal()) {
        emit(WorkoutInProgress(wip.workout, wip.elapsed! + 1));
      } else {
        _timer!.cancel();
        Wakelock.disable();

        // Check if the cubit is still active before emitting a new state
        if (_isActive) {
          emit(WorkoutCompleted(wip.workout, wip.elapsed));
        }
      }
    }
  }

  void closeCubit() {
    _isActive = false;
    close(); // Close the cubit
  }

  void deleteWorkout(BuildContext context, int index) async {
    final currentState = state;
    if (currentState is WorkoutInProgress || currentState is WorkoutPaused) {
      // If a workout is in progress or paused, stop it before deleting
      goHome(context);
    }

    final workouts = BlocProvider.of<WorkoutsCubit>(context).state;
    if (index >= 0 && index < workouts.length) {
      // Remove the workout at the given index
      workouts.removeAt(index);

      // Update the JSON file with the updated list of workouts
      final updatedWorkoutsJson =
          jsonEncode(workouts.map((w) => w.toJson()).toList());
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/workouts.json');

      try {
        await file.writeAsString(updatedWorkoutsJson);
        if (context.mounted) {
          goHome(context);
        }
      } catch (e) {
        // Handle file writing error
      }

      // Update the GUI by emitting the updated list of workouts
      //BlocProvider.of<WorkoutsCubit>(context).emit(workouts);
      if (context.mounted) {
        Navigator.pop(context);
      } else {
        context.read<WorkoutsCubit>().emit(workouts);
      }
    }
  }

  Workout? findWorkoutByTitle(BuildContext context, String title) {
    final currentState = state;
    if (currentState is WorkoutInProgress || currentState is WorkoutPaused) {
      // If a workout is in progress or paused, stop it before starting a new one
      if (context.mounted) {
        goHome(context);
      }
    }

    final workouts = BlocProvider.of<WorkoutsCubit>(context).state;

    for (final workout in workouts) {
      if (workout.title == title) {
        return workout;
      }
    }

    return null; // Return null if the workout is not found
  }

  void startWorkoutByTitle(BuildContext context, String title) {
    final workout = findWorkoutByTitle(context, title);

    if (workout != null) {
      startWorkout(context, workout);
    } else {
      // Handle the case where the workout is not found
      // You can show a message or take appropriate action here.
    }
  }

  void startWorkout(BuildContext context, Workout workout, [int? index]) {
    _timer?.cancel();
    Wakelock.enable();

    if (workout.exercieses.isEmpty) {
      // Show a SnackBar with a creative style
      final snackBar = SnackBar(
        content: const Text(
          "This workout has no exercises. Add exercises to start!",
          style: TextStyle(fontSize: 16.0),
        ),
        backgroundColor: Colors.lightBlue, // Customize the background color
        behavior: SnackBarBehavior.floating, // Customize the behavior
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0), // Customize the shape
        ),
        elevation: 6.0, // Customize the elevation
        duration: const Duration(seconds: 4), // Customize the duration
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      return;
    } else {
      emit(WorkoutInProgress(workout, 0));
      _timer = Timer.periodic(const Duration(seconds: 1), onTick);
    }
  }

  void moveToNextExercise(int currentExerciseIndex, bool isPrelude) {
    if (state is WorkoutInProgress || state is WorkoutPaused) {
      final nextExerciseIndex = currentExerciseIndex + 1;

      if (nextExerciseIndex <= state.workout!.exercieses.length) {
        final currentExercise = state.workout!.exercieses[currentExerciseIndex];
        final totalElapsedTime = calculateTotalElapsedTime(currentExerciseIndex,
            isPrelude, currentExercise.prelude!, currentExercise.duration!);

        emit(WorkoutInProgress(
          state.workout,
          totalElapsedTime,
        ));
      } else {
        emit(WorkoutCompleted(state.workout, state.elapsed));
      }
    }
  }

  Future<List<WorkoutInfo>> getAvailableWorkoutTitles() async {
    final List<WorkoutInfo> workoutInfos = [];

    try {
      // Read the workout data from the JSON file
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/workouts.json');
      final jsonContent = await file.readAsString();
      final decodedJson = json.decode(jsonContent);

      for (final workoutData in decodedJson) {
        final String title = workoutData['title'];

        final double totalElapsedTime =
            calculateTotalElapsedTime2(workoutData) / 60.0;
        workoutInfos.add(WorkoutInfo(
            title: title, totalElapsedTime: totalElapsedTime.toInt()));
      }

      // You can now use workoutInfos as a list of WorkoutInfo objects
      return workoutInfos;
    } catch (e) {
      // Handle file reading or decoding errors
      return workoutInfos; // Return an empty list or handle the error as needed
    }
  }

  int calculateTotalElapsedTime2(Map<String, dynamic> workoutData) {
    int totalElapsedTime = 0;

    // Replace with your specific data structure
    // This assumes that 'exercises' is an array of exercise objects
    final List<dynamic> exercises = workoutData['exercises'];

    for (final exerciseData in exercises) {
      final int prelude = exerciseData['prelude'] ?? 0;
      final int duration = exerciseData['duration'] ?? 0;
      totalElapsedTime += prelude + duration;
    }

    return totalElapsedTime;
  }

  int calculateTotalElapsedTime(int currentExerciseIndex, bool isPrelude,
      int currentPrelude, int currentDuration) {
    int totalElapsedTime = 0;

    for (int i = 0; i < currentExerciseIndex; i++) {
      final exercise = state.workout!.exercieses[i];
      totalElapsedTime += exercise.prelude! + exercise.duration!;
    }

    if (isPrelude) {
      totalElapsedTime += currentPrelude;
    } else {
      totalElapsedTime += currentDuration + currentPrelude;
    }

    return totalElapsedTime;
  }

  void emitWorkoutState(int totalElapsedTime) {
    if (state is WorkoutInProgress) {
      emit(WorkoutInProgress(
        state.workout,
        totalElapsedTime,
      ));
    } else if (state is WorkoutPaused) {
      emit(WorkoutPaused(
        state.workout,
        totalElapsedTime,
      ));
    }
  }

  void createAndSaveNewWorkout(BuildContext context, Workout newWorkout) async {
    // Create a new Workout object with the updated title
    final updatedWorkout =
        newWorkout.copyWith(title: newWorkout.title, type: newWorkout.type);

    // Get the current list of workouts from the state
    final currentState = BlocProvider.of<WorkoutsCubit>(context).state;
    final updatedWorkouts = [...currentState, updatedWorkout];

    // Update the JSON file with the updated list of workouts
    final updatedWorkoutsJson =
        jsonEncode(updatedWorkouts.map((w) => w.toJson()).toList());

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/workouts.json');

    try {
      await file.writeAsString(updatedWorkoutsJson);
    } catch (e) {
      // Handle file writing error
    }

    // Update the GUI by emitting the updated list of workouts

    if (context.mounted) {
      BlocProvider.of<WorkoutsCubit>(context).emit(updatedWorkouts);

      BlocProvider.of<WorkoutsCubit>(context).getWorkout(saveToFile: true);
    }
  }

  updateAndSaveTitle(
      BuildContext context, String newTitle, int index, String newType) async {
    final currentState = state as WorkoutEditing;

    // Create a new Workout object with the updated title
    final updatedWorkout =
        currentState.workout!.copyWith(title: newTitle, type: newType);

    // Update the workout within the current state
    final updatedState = currentState.copyWith(workout: updatedWorkout);

    // Emit the updated state
    emit(updatedState);

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/workouts.json');

    try {
      // Read the JSON content from the file
      final jsonContent = await file.readAsString();
      final decodedJson = json.decode(jsonContent);

      // Update the workout title in the decoded JSON data
      decodedJson[index]['title'] = newTitle;
      decodedJson[index]['type'] = newType;
      // Convert the updated JSON data back to a string
      final updatedJsonContent = json.encode(decodedJson);

      // Write the updated JSON data to the file
      await file.writeAsString(updatedJsonContent);

// Update the workout title within WorkoutsCubit

      if (context.mounted) {
        BlocProvider.of<WorkoutsCubit>(context)
            .updateWorkoutTitle(index, newTitle, newType);
      }
    } catch (e) {
      // Handle file reading or writing error
    }
  }
}

class WorkoutInfo {
  final String title;
  final int totalElapsedTime;

  WorkoutInfo({required this.title, required this.totalElapsedTime});
}
