import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:plan_workout/screens/workout_in_progress.dart';
import '../colors.dart' as color;
import '../blocs/workout_cubit.dart';
import '../blocs/workouts_cubit.dart';
import '../main.dart';
import '../states/workout_states.dart';
import 'edit_workout_screen.dart';
import 'home_page_plan_workout.dart';

class AllBuildBideoPlayers extends StatefulWidget {
  const AllBuildBideoPlayers({Key? key}) : super(key: key);

  @override
  AllBuildBideoPlayersState createState() => AllBuildBideoPlayersState();
}

class AllBuildBideoPlayersState extends State<AllBuildBideoPlayers> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 104, 66, 255),
        title: const Text('All Levels'),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                children: [
                  Text(
                    "Workout Levels",
                    style: TextStyle(
                        fontSize: 18,
                        color: color.AppColor.homePageSubtitle,
                        fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              buildVideoPlayer("workoutbackground1", "Arms Beginner", 1),
              buildVideoPlayer("squatBackground2", "Glutes Beginner", 1),
              buildVideoPlayer("ChestBackground", "Chest Beginner", 1),
              buildVideoPlayer("LegsBackground", "Legs Beginner", 1),
              buildVideoPlayer("absbackground", "Abs Beginner", 1),
              buildVideoPlayer("backBackground", "Back Beginner", 1),
              const SizedBox(
                height: 30, // Adjust the spacing
              ),
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
              buildVideoPlayer("workoutbackground1", "Arms Intermediate", 2),
              buildVideoPlayer("squatBackground2", "Glutes Intermediate", 2),
              buildVideoPlayer("ChestBackground", "Chest Intermediate", 2),
              buildVideoPlayer("LegsBackground", "Legs Intermediate", 2),
              buildVideoPlayer("absbackground", "Abs Intermediate", 2),
              buildVideoPlayer("backBackground", "Back Intermediate", 2),
              const SizedBox(
                height: 30, // Adjust the spacing
              ),
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
              buildVideoPlayer("workoutbackground1", "Arms Advanced", 3),
              buildVideoPlayer("squatBackground2", "Glutes Advanced", 3),
              buildVideoPlayer("ChestBackground", "Chest Advanced", 3),
              buildVideoPlayer("LegsBackground", "Legs Advanced", 3),
              buildVideoPlayer("absbackground", "Abs Advanced", 3),
              buildVideoPlayer("backBackground", "Back Advanced", 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildVideoPlayer(
      String? photoFileName, String? nameWorkout, int? stars) {
    if (photoFileName != null) {
      return Container(
        width: MediaQuery.of(context).size.width,
        height: 120, // Adjust the height as needed
        margin: const EdgeInsets.only(top: 30),
        child: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: 150, // Adjust the height as needed
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image: AssetImage(
                      "assets/workouts_background_pictures/$photoFileName.jpg"),
                  fit: BoxFit.fill,
                ),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 40,
                    offset: const Offset(8, 10),
                    color: color.AppColor.gradientSecond.withOpacity(0.3),
                  ),
                  BoxShadow(
                    blurRadius: 10,
                    offset: const Offset(-1, -5),
                    color: color.AppColor.gradientSecond.withOpacity(0.3),
                  ),
                ],
              ),
            ),
            Container(
              width: double.maxFinite,
              height: 100, // Adjust the height as needed
              margin: const EdgeInsets.only(left: 20, top: 5),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nameWorkout!,
                      style: TextStyle(
                        fontSize: 24, // Increase the font size for emphasis
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
                    const SizedBox(height: 40), // Adjust the spacing
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star,
                            size: 20, // Adjust the icon size
                            color: Color.fromARGB(255, 104, 66, 255),
                          ),
                          const SizedBox(width: 2),
                          Icon(
                            Icons.star,
                            size: 20, // Adjust the icon size
                            color: stars! >= 2
                                ? const Color.fromARGB(255, 104, 66, 255)
                                : Colors.grey,
                          ),
                          const SizedBox(width: 2),
                          Icon(
                            Icons.star,
                            size: 20, // Adjust the icon size
                            color: stars >= 3
                                ? const Color.fromARGB(255, 104, 66, 255)
                                : Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 20,
              bottom: 10,
              child: InkWell(
                onTap: () {
                  Get.to(
                    () => MultiBlocProvider(
                      providers: [
                        BlocProvider<WorkoutsCubit>(
                          create: (BuildContext context) {
                            WorkoutsCubit workoutsCubit = WorkoutsCubit();
                            if (workoutsCubit.state.isEmpty) {
                              workoutsCubit.loadWorkoutsFromFileByTitle(
                                nameWorkout,
                              );
                            } else {
                              // print("...not loading json");
                            }
                            return workoutsCubit;
                          },
                        ),
                        BlocProvider<WorkoutCubit>(
                          create: (BuildContext context) => WorkoutCubit(),
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
      );
    } else {
      return Container();
    }
  }
}
