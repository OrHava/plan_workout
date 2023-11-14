// all_workouts_page.dart

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:plan_workout/screens/home_page_plan_workout.dart';
import 'package:plan_workout/blocs/workout_cubit.dart';
import 'package:plan_workout/screens/workout_in_progress.dart';
import '../blocs/workouts_cubit.dart';
import '../main.dart';
import 'package:get/get.dart';

import '../states/workout_states.dart';
import '../colors.dart' as color;
import 'calendar_page.dart';
import 'edit_workout_screen.dart';

// ignore: must_be_immutable
class AllWorkoutsPage extends StatelessWidget {
  final List<WorkoutInfo> selectedWorkouts;

  AllWorkoutsPage(this.selectedWorkouts, {super.key});

  List<String> imageFileNames =
      List.generate(14, (index) => 'random_${index + 1}.jpg');

// Function to randomly select an image file name
  String getRandomImageFileName() {
    final random = Random();
    final index = random.nextInt(imageFileNames.length);
    return imageFileNames[index];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: color.AppColor.homePageBackground,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 104, 66, 255),
        title: const Text("Selected Workouts"),
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Display two items in each row
        ),
        itemCount: selectedWorkouts.length,
        itemBuilder: (context, index) {
          final workout = selectedWorkouts[index];
          final title = workout.title;
          final totalElapsedTime = workout.totalElapsedTime;
          final randomImageFileName = getRandomImageFileName();

          return Padding(
            padding: const EdgeInsets.all(8.0), // Adjust padding as needed
            child: buildWorkoutContainer(
              AssetImage("assets/$randomImageFileName"),
              WorkoutData(
                id: "id",
                name: title,
                date: DateTime.now(),
                time: "$totalElapsedTime min",
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildWorkoutContainer(ImageProvider image, WorkoutData workoutData) {
    return Container(
      width: 300,
      height: 250, // Adjust the height as needed
      decoration: BoxDecoration(
        image: DecorationImage(
          image: image,
          fit: BoxFit.fill,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.only(
          left: 20,
          top: 15,
          right: 20,
        ), // Adjust padding as needed
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Workout",
              style: TextStyle(
                fontSize: 20, // Adjust the font size
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 3.0,
                    color: Colors.black.withOpacity(0.5),
                    offset: const Offset(2.0, 2.0),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workoutData.name,
                  style: TextStyle(
                    fontSize: 16, // Adjust the font size
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 3.0,
                        color: Colors.black.withOpacity(0.5),
                        offset: const Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 8, // Adjust the spacing
                ),
                Text(
                  "Date and Time: ${DateFormat('yyyy-MM-dd hh:mm a').format(workoutData.date)}",
                  style: TextStyle(
                    fontSize: 14, // Adjust the font size
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 3.0,
                        color: Colors.black.withOpacity(0.5),
                        offset: const Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 8, // Adjust the spacing
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(
                    Icons.timer,
                    size: 18, // Adjust the icon size
                    color: color.AppColor.homePageContainerTextSmall,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    workoutData.time,
                    style: TextStyle(
                      fontSize: 12, // Adjust the font size
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 3.0,
                          color: Colors.black.withOpacity(0.5),
                          offset: const Offset(2.0, 2.0),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(60),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 3.0,
                          color: Colors.black.withOpacity(0.5),
                          offset: const Offset(2.0, 2.0),
                        ),
                      ],
                    ),
                    child: InkWell(
                      onTap: () {
                        String workoutName = workoutData.name;

                        Get.to(
                          () => MultiBlocProvider(
                            providers: [
                              BlocProvider<WorkoutsCubit>(
                                create: (BuildContext context) {
                                  WorkoutsCubit workoutsCubit = WorkoutsCubit();
                                  if (workoutsCubit.state.isEmpty) {
                                    workoutsCubit.loadWorkoutsFromFileByTitle(
                                      workoutName,
                                    );
                                  } else {
                                    // print("...not loading json");
                                  }
                                  return workoutsCubit;
                                },
                              ),
                              BlocProvider<WorkoutCubit>(
                                create: (BuildContext context) =>
                                    WorkoutCubit(),
                              ),
                            ],
                            child: BlocBuilder<WorkoutCubit, WorkoutState>(
                              builder: (context, state) {
                                myGlobalBool = true;
                                if (state is WorkoutIntial) {
                                  return const Home_Page_PlanWorkout();
                                } else if (state is WorkoutEditing) {
                                  return EditWorkoutScreen();
                                }
                                return const WorkoutProgress();
                              },
                            ),
                          ),
                        );
                      },
                      child: const Icon(
                        Icons.play_circle_fill,
                        size: 40, // Adjust the icon size
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
