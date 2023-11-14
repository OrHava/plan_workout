import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../blocs/workout_cubit.dart';
import '../helpers.dart';
import '../main.dart';
import 'calendar_page.dart';

class WorkoutPlannerPage extends StatelessWidget {
  const WorkoutPlannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const WorkoutPlannerForm();
  }
}

class WorkoutPlannerForm extends StatefulWidget {
  const WorkoutPlannerForm({super.key});

  @override
  WorkoutPlannerFormState createState() => WorkoutPlannerFormState();
}

class WorkoutPlannerFormState extends State<WorkoutPlannerForm> {
  String selectedPlace = 'Abs';
  String selectedLevel = 'Beginner';
  String selectedDuration = '7 days';
  List<String> selectedDays = [];
  List<WorkoutInfo> availableWorkoutInfos = [];

  @override
  void initState() {
    super.initState();
    _loadAvailableWorkoutTitles();
  }

  final List<String> places = [
    'Abs',
    'Glutes',
    'Arms',
    'Back',
    'Legs',
    'Chest'
  ];
  final List<String> levels = ['Beginner', 'Intermediate', 'Advanced'];
  final List<String> durations = ['7 days', '30 days', '90 days'];
  final List<String> days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  Future<void> _loadAvailableWorkoutTitles() async {
    final cubit = context.read<WorkoutCubit>();
    final List<WorkoutInfo> workoutInfos =
        await cubit.getAvailableWorkoutTitles();
    setState(() {
      availableWorkoutInfos = workoutInfos;
    });
  }

  Future<void> saveWorkout(WorkoutData workoutData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final workoutKey = 'workout_${workoutData.id}';
      await prefs.setString(
        workoutKey,
        '${workoutData.name} - ${workoutData.date.toString()} - ${workoutData.time}',
      );
    } catch (e) {
      // ignore: avoid_print
      print('Error saving workout: $e');
    }
  }

  String? getWorkoutTimeForTitle(String? title) {
    if (title == null) {
      return null; // Return null if title is null
    }

    // Find the WorkoutInfo with the matching title in the list
    final matchingWorkoutInfo = availableWorkoutInfos.firstWhere(
      (workoutInfo) => workoutInfo.title == title,
      // Return null if no match is found
    );

    return '${matchingWorkoutInfo.totalElapsedTime * 60}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 104, 66, 255),
        title: const Text('Workout Planner'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // Replace with the back icon
          onPressed: () {
            // Call your function here when the back button is pressed
            // For example, you can use Navigator.pop(context) to navigate back
            FocusScope.of(context).unfocus();
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select Workout Place',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 104, 66, 255),
                        ),
                      ),
                      DropdownButtonFormField<String>(
                        value: selectedPlace,
                        items: places.map((place) {
                          return DropdownMenuItem(
                            value: place,
                            child: Text(place),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedPlace = value!;
                          });
                        },
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.zero,
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromARGB(255, 104, 66,
                                    255)), // Change the color here
                          ),
                        ),
                        hint: const Text('Select Workout Place'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select Level',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 104, 66, 255)),
                      ),
                      DropdownButtonFormField<String>(
                        value: selectedLevel,
                        items: levels.map((level) {
                          return DropdownMenuItem(
                            value: level,
                            child: Text(level),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedLevel = value!;
                          });
                        },
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.zero,
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromARGB(255, 104, 66,
                                    255)), // Change the color here
                          ),
                        ),
                        hint: const Text('Select Level'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select Duration',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 104, 66, 255)),
                      ),
                      DropdownButtonFormField<String>(
                        value: selectedDuration,
                        items: durations.map((duration) {
                          return DropdownMenuItem(
                            value: duration,
                            child: Text(duration),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedDuration = value!;
                          });
                        },
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.zero,
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromARGB(255, 104, 66,
                                    255)), // Change the color here
                          ),
                        ),
                        hint: const Text('Select Duration'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select Workout Days:',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 104, 66, 255)),
                      ),
                      Wrap(
                        spacing: 8.0,
                        children: days.map((day) {
                          return ChoiceChip(
                            label: Text(day),
                            selected: selectedDays.contains(day),
                            selectedColor:
                                const Color.fromARGB(255, 104, 66, 255),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  selectedDays.add(day);
                                } else {
                                  selectedDays.remove(day);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                  onPressed: () {
                    if (selectedDuration == '7 days' ||
                        selectedDuration == '30 days' ||
                        selectedDuration == '90 days') {
                      final int duration = selectedDuration == '7 days'
                          ? 7
                          : selectedDuration == '30 days'
                              ? 30
                              : 90;

                      if (selectedDays.isEmpty) {
                        // Display a message if no days are selected
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Please select at least one day for the workout plan.'),
                          ),
                        );
                      } else {
                        for (int i = 0; i < duration; i++) {
                          final nextWorkoutDate =
                              DateTime.now().add(Duration(days: i));
                          // Check if the next workout date matches any of the selected days
                          if (selectedDays
                              .contains(days[nextWorkoutDate.weekday - 1])) {
                            final nextWorkoutData = WorkoutData(
                              id: generateRandomId(),
                              name:
                                  "${'Planned'} Workout: $selectedPlace $selectedLevel",
                              date: nextWorkoutDate,
                              time: getWorkoutTimeForTitle(
                                  "$selectedPlace $selectedLevel")!,
                            );

                            final now = DateTime.now();
                            final timeDifferenceInSeconds =
                                nextWorkoutDate.difference(now).inSeconds;

                            // Call the background task function with the calculated delay
                            startBackgroundTask2(timeDifferenceInSeconds,
                                "${'Planned'} Workout: $selectedPlace $selectedLevel");

                            saveWorkout(
                                nextWorkoutData); // Save the workout plan for the selected day
                          }
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Workouts added to calendar successfully.'),
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(
                        255, 104, 66, 255), // Use primary color for the button
                  ),
                  child: const Text('Generate Workout Plan')),
            ],
          ),
        ),
      ),
    );
  }
}
