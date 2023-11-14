// ignore_for_file: prefer_const_literals_to_create_immutables

import 'dart:convert';
import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plan_workout/models/exercise.dart';
import 'package:plan_workout/models/workout.dart';

class LoadWorkoutsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AddWorkoutEvent extends Equatable {
  final int workoutIndex;
  final Exercise newExercise;

  const AddWorkoutEvent(this.workoutIndex, this.newExercise);

  @override
  List<Object?> get props => [workoutIndex, newExercise];
}

class WorkoutsCubit extends Cubit<List<Workout>> {
  WorkoutsCubit() : super([]);

  getWorkout({bool saveToFile = false}) async {
    loadWorkoutsFromFile();
    final workoutsJson = await rootBundle.loadString("assets/workouts.json");
    final decodedJson = jsonDecode(workoutsJson);
    final List<Workout> defaultWorkouts =
        List.from(decodedJson).map((el) => Workout.fromJson(el)).toList();
    // Print the merged workouts to the console

    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/workouts.json';
    final file = File(filePath);

    List<Workout> existingWorkouts = [];

    try {
      if (await file.exists()) {
        final existingContent = await file.readAsString();

        final List<dynamic> decodedExistingJson = jsonDecode(existingContent);
        existingWorkouts =
            decodedExistingJson.map((map) => Workout.fromJson(map)).toList();

        if (saveToFile) {
          // Save the merged workouts to the file
          final updatedWorkoutsJson =
              jsonEncode(existingWorkouts.map((w) => w.toJson()).toList());

          try {
            await file.writeAsString(updatedWorkoutsJson);
          } catch (e) {
            // Handle file writing error
          }
        }
      } else {
        // Merge the default workouts and the workouts from the file
        final List<Workout> allWorkouts = [
          ...defaultWorkouts,
          ...existingWorkouts
        ];

        if (saveToFile) {
          // Save the merged workouts to the file
          final updatedWorkoutsJson =
              jsonEncode(allWorkouts.map((w) => w.toJson()).toList());

          try {
            await file.writeAsString(updatedWorkoutsJson);
          } catch (e) {
            // Handle file writing error
          }
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print("Error reading file: $e");
      // Handle file reading error
    }
  }

  void addExerciseToWorkout(
      int workoutIndex, Exercise newExercise, BuildContext context) {
    final updatedWorkouts = List<Workout>.from(state); // Create a copy
    updatedWorkouts[workoutIndex]
        .exercieses
        .add(newExercise); // Add the exercise

    _saveWorkoutsToFile(updatedWorkouts); // Save the updated workouts to file

    emit(updatedWorkouts); // Emit the updated state, to update the gui

    //getWorkout(saveToFile: true);
  }

  Future<void> _saveWorkoutsToFile(List<Workout> updatedWorkouts) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/workouts.json');

    try {
      final updatedWorkoutsJson =
          jsonEncode(updatedWorkouts.map((w) => w.toJson()).toList());
      await file.writeAsString(updatedWorkoutsJson);
    } catch (e) {
      // Handle file writing error
    }
  }

  void deleteExercise(int workoutIndex, int exerciseIndex) {
    final updatedWorkouts = List<Workout>.from(state); // Create a copy
    final updatedWorkout = updatedWorkouts[workoutIndex];

    updatedWorkout.exercieses.removeAt(exerciseIndex); // Remove the exercise

    _saveWorkoutsToFile(updatedWorkouts); // Save the updated workouts to file

    emit(updatedWorkouts); // Emit the updated state
  }

  updateWorkoutTitle(int index, String newTitle, String newType) {
    // Update the title of the specific workout within the state
    state[index] = state[index].copyWith(title: newTitle, type: newType);
    emit([...state]);
  }

  Future<void> loadWorkoutsFromFile({String? workoutType}) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/workouts.json');

    try {
      // Read the JSON content from the file
      final jsonContent = await file.readAsString();
      final decodedJson = jsonDecode(jsonContent);

      // Convert JSON data to List<Workout>
      final List<Workout> allWorkouts =
          List.from(decodedJson).map((el) => Workout.fromJson(el)).toList();

      if (workoutType != null) {
        // Filter workouts by the specified workout type
        final filteredWorkouts = allWorkouts
            .where((workout) => workout.type == workoutType)
            .toList();
        emit(filteredWorkouts);
      } else {
        // If no type is specified, emit all workouts
        emit(allWorkouts);
      }
    } catch (e) {
      // Handle file reading error
    }
  }

  Future<void> loadWorkoutsFromFileByTitle(String name) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/workouts.json');

    try {
      // Read the JSON content from the file
      final jsonContent = await file.readAsString();
      final decodedJson = jsonDecode(jsonContent);

      // Convert JSON data to List<Workout>
      final List<Workout> allWorkouts =
          List.from(decodedJson).map((el) => Workout.fromJson(el)).toList();

      // Filter workouts by the specified workout type
      final filteredWorkouts =
          allWorkouts.where((workout) => workout.title == name).toList();
      emit(filteredWorkouts);
    } catch (e) {
      // Handle file reading error
    }
  }

  Future<void> saveWorkout(Workout workout, int index) async {
    final newWorkout = Workout(
        title: workout.title,
        type: workout.type,
        exercieses: []); //dont make it const beacuse then it wont be able to edit the execise in real time

    int exIndex = 0;
    int startTime = 0;
    for (var ex in workout.exercieses) {
      newWorkout.exercieses.add(
        Exercise(
          title: ex.title,
          prelude: ex.prelude,
          sets: ex.sets,
          duration: ex.duration,
          index: exIndex,
          startTime: startTime,
        ),
      );
      exIndex++;
      startTime += ex.prelude! + ex.duration!;
    }

    // Update the exercise data within the original workout instance
    state[index].exercieses.clear();
    for (var ex in newWorkout.exercieses) {
      state[index].exercieses.add(ex);
    }

    // Update the JSON file with the updated data
    final updatedWorkoutsJson =
        jsonEncode(state.map((workout) => workout.toJson()).toList());

    // Get the application's documents directory
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/workouts.json');

    // Write the updated JSON data to the file
    await file.writeAsString(updatedWorkoutsJson);

    // Emit the updated state
    emit([...state]);
  }

  void createAndSaveNewExercise(
      BuildContext context, Workout newWorkout) async {
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
    }
  }
}
