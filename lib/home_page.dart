import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_settings/open_settings.dart';
import 'package:path_provider/path_provider.dart';
import 'package:plan_workout/blocs/workout_cubit.dart';
import 'package:plan_workout/helpers.dart';
import 'package:plan_workout/main.dart';
import 'package:plan_workout/screens/all_build_video_players.dart';
import 'package:plan_workout/screens/all_workouts_page.dart';
import 'package:plan_workout/screens/bmi_calculator.dart';
import 'package:plan_workout/screens/calendar_page.dart';
import 'package:plan_workout/screens/edit_workout_screen.dart';
import 'package:plan_workout/screens/home_page_plan_workout.dart';
import 'package:plan_workout/screens/share_page.dart';
import 'package:plan_workout/screens/workout_in_progress.dart';
import 'package:plan_workout/states/workout_states.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'blocs/workouts_cubit.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'colors.dart' as color;
import 'models/workout.dart';

//api key
//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
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic>? info; // Make the 'info' list nullable
  List<WorkoutData> workouts = [];
  String selectedCategory = "Beginner";

  final List<WorkoutInfo> workoutInfos = [];
  List<WorkoutInfo> selectedWorkouts = [];

  List<WorkoutData> availableWorkouts = [];
  WorkoutData? closestWorkout;
  Future<List<dynamic>> _initDate() async {
    String jsonData =
        await DefaultAssetBundle.of(context).loadString("json/info.json");
    return json.decode(jsonData);
  }

  void changeCategory(String category) {
    setState(() {
      selectedCategory = category;
    });
  }

  int currentIndex = 0;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    loadWorkouts_2();

    getWorkout(saveToFile: true);

    _initData();
  }

  Future<bool> areLocalNotificationsEnabled() async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    final bool result = await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.areNotificationsEnabled() ??
        false;

    return result;
  }

  void navigateToCalendarPage() {
    // Navigate to the CalendarPage here

    Get.to(() => CalendarPage(refreshCallback: loadWorkouts));
  }

  void navigateToBMICalculatorPage() {
    Get.to(() => const BMICalculator());
  }

  void navigateToSharePage() {
    Get.to(() => const SharePage());
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Check the index and navigate accordingly
    if (index == 0) {
      // Navigate to the CalendarPage with any necessary arguments
      Get.to(() => const HomePage());
    } else if (index == 1) {
      // Navigate to another page if needed
      Get.to(() => CalendarPage(refreshCallback: loadWorkouts));
    } else if (index == 2) {
      // Navigate to yet another page if needed
      Get.to(() => const BMICalculator());
    } else if (index == 3) {
      Get.to(() => const SharePage());
    }
  }

  Future<void> _initData() async {
    // Load workouts and initialize other data here

    await loadWorkouts();
    if (context.mounted) {
      String jsonData =
          await DefaultAssetBundle.of(context).loadString("json/info.json");
      final data = json.decode(jsonData);
      setState(() {
        info = data;
      });
    }
  }

  Future<void> loadWorkouts_2() async {
    try {
      // Read the workout data from the JSON file
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/workouts.json');
      final jsonContent = await file.readAsString();
      final decodedJson = json.decode(jsonContent);

      workoutInfos.clear();

      for (final workoutData in decodedJson) {
        final String title = workoutData['title'];

        final double totalElapsedTime =
            calculateTotalElapsedTime2(workoutData) / 60.0;
        workoutInfos.add(WorkoutInfo(
            title: title, totalElapsedTime: totalElapsedTime.toInt()));
      }
    } catch (e) {
      // Handle file reading or decoding errors
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

  Future<void> loadWorkouts() async {
    workouts = [];
    final List<WorkoutData> loadedWorkouts = [];

    try {
      final prefs = await SharedPreferences.getInstance();
      final workoutKeys =
          prefs.getKeys().where((key) => key.startsWith('workout_')).toList();

      for (var key in workoutKeys) {
        final workoutData = prefs.getString(key);
        if (workoutData != null) {
          final parts = workoutData.split(' - ');
          if (parts.length == 3) {
            // Assuming time is the third part
            final workoutName = parts[0];
            final workoutDate = DateTime.tryParse(parts[1]);
            final workoutTime = parts[2]; // Extract the time

// Split the string by space
            List<String> words = workoutName.split(' ');

// Check if the first word is "Completed" or "Planned"
            if (words.isNotEmpty && (words[0] == "Planned")) {
              // The first word is "Planned".
              //print("Status: ${words.toString()}");
              if (workoutDate != null) {
                final id = key; // Use the key as the ID
                loadedWorkouts.add(
                  WorkoutData(
                      id: id,
                      name: workoutName,
                      date: workoutDate,
                      time: workoutTime), // Include time
                );
              }
            }
          }
        }
      }

      setState(() {
        workouts = loadedWorkouts; // Update the workouts list
        findClosestWorkout();
      });
    } catch (e) {
      // ignore: avoid_print
      print('Error loading workouts: $e');
    }
  }

  Future<void> findClosestWorkout() async {
    if (workouts.isEmpty) {
      setState(() {
        // print("mylife1");
        closestWorkout = WorkoutData(
            id: "id",
            name: "No upcoming workouts",
            date: DateTime.now(),
            time: "Add New Workout in Calendar");
      });
      return;
    }

    DateTime now = DateTime.now();
    workouts.sort((a, b) => a.date.compareTo(b.date));
    //print("mylife2");
    // Find the closest workout in the sorted list
    for (var workout in workouts) {
      if (workout.date.isAfter(now)) {
        setState(() {
          closestWorkout = workout;
        });
        break;
      }
    }
  }

  Future<void> saveSelectedWorkouts() async {
    final prefs = await SharedPreferences.getInstance();
    final workoutList =
        selectedWorkouts.map((workout) => workout.title).toList();
    await prefs.setStringList('selectedWorkouts', workoutList);
  }

  Future<List<WorkoutInfo>> loadSelectedWorkouts() async {
    await loadWorkouts_2();
    final prefs = await SharedPreferences.getInstance();
    final workoutList = prefs.getStringList('selectedWorkouts') ?? [];

    // Filter workoutInfos to find matching workouts by title
    final matchingWorkouts = workoutInfos.where((workout) {
      return workoutList.contains(workout.title);
    }).toList();

    return matchingWorkouts;
  }

  Future<List<WorkoutInfo>> loadSelectedWorkouts2() async {
    final prefs = await SharedPreferences.getInstance();
    final workoutList = prefs.getStringList('selectedWorkouts') ?? [];
    selectedWorkouts.clear();
    selectedWorkouts.addAll(
      workoutList.map((title) {
        return workoutInfos.firstWhere((workout) => workout.title == title);
      }),
    );
    return selectedWorkouts;
  }

  void showAddWorkoutDialog(
      BuildContext context, Function(List<WorkoutInfo>) updateUI) {
    loadSelectedWorkouts2();
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text("Select a Workout"),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                itemCount: workoutInfos.length,
                itemBuilder: (context, index) {
                  final workout = workoutInfos[index];
                  final title = workout.title;
                  final totalElapsedTime = workout.totalElapsedTime;
                  final isSelected = selectedWorkouts.contains(workout);

                  return ListTile(
                    title: Text(title),
                    subtitle: Text("$totalElapsedTime min"),
                    leading: Checkbox(
                      value: isSelected,
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            selectedWorkouts.add(workout);
                          } else {
                            selectedWorkouts.remove(workout);
                          }
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  saveSelectedWorkouts();
                  updateUI(
                      selectedWorkouts); // Notify the main widget of the changes
                  Navigator.of(context).pop();
                },
                child: const Text("Add"),
              ),
            ],
          );
        });
      },
    );
  }

  void updateSelectedWorkouts(List<WorkoutInfo> newSelectedWorkouts) {
    setState(() {
      selectedWorkouts = newSelectedWorkouts;
    });
  }

  // List of image file names
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
    // Check if Local Notifications are enabled at app startup
    Future<bool> checkAndShowNotificationDialog() async {
      final notificationsEnabled = await areLocalNotificationsEnabled();
      if (!notificationsEnabled &&
          context.mounted &&
          !notificationDialogShown) {
        notificationDialogShown = true; // Set it to false here

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const EnableNotificationsDialog();
          },
        );
      }
      return notificationsEnabled;
    }

    // Call the checkAndShowNotificationDialog function at the app startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkAndShowNotificationDialog();
    });

    return Scaffold(
        backgroundColor: color.AppColor.homePageBackground,
        bottomNavigationBar: PreferredSize(
          preferredSize:
              const Size.fromHeight(56), // Adjust the height as needed
          child: Container(
            color: Colors
                .blue, // Set the background color for the "top" navigation bar
            child: BottomNavigationBar(
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_today_outlined),
                  label: 'Calendar',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.auto_graph),
                  label: 'BMI calculater',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.manage_search),
                  label: 'Share',
                ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: const Color.fromARGB(255, 104, 66, 255),
              unselectedItemColor: Colors.grey,
              backgroundColor:
                  Colors.blueGrey, // Set the background color for the icons
              onTap: _onItemTapped,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.only(top: 40, left: 20, right: 20),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      "Home",
                      style: TextStyle(
                          fontSize: 30,
                          color: color.AppColor.homePageTitle,
                          fontWeight: FontWeight.w700),
                    ),
                    Expanded(child: Container()),
                    InkWell(
                      onTap: () {
                        Get.to(
                          () => MultiBlocProvider(
                            providers: [
                              BlocProvider<WorkoutsCubit>(
                                create: (BuildContext context) {
                                  WorkoutsCubit workoutsCubit = WorkoutsCubit();
                                  if (workoutsCubit.state.isEmpty) {
                                    workoutsCubit.getWorkout(
                                      saveToFile: true,
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
                                myGlobalBool = false;
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
                        Icons.edit,
                        size: 20, // Adjust the icon size
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                Row(
                  children: [
                    Text(
                      "Your Program",
                      style: TextStyle(
                          fontSize: 18,
                          color: color.AppColor.homePageSubtitle,
                          fontWeight: FontWeight.w700),
                    ),
                    Expanded(
                        child:
                            Container()), //take space between the text of "your program" and "details"
                    FutureBuilder<List<WorkoutInfo>>(
                      future: loadSelectedWorkouts(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator(); // Show a loading indicator
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          final selectedWorkouts = snapshot.data;

                          return InkWell(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    AllWorkoutsPage(selectedWorkouts!),
                              ));
                            },
                            child: const Text(
                              "See All",
                              style: TextStyle(
                                fontSize: 16,
                                color:
                                    Color(0xFF6842FF), // Use hexadecimal color
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(
                      //take space between the "details" and the arrow
                      width: 5,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 250),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Expanded(
                          child: FutureBuilder<List<WorkoutInfo>>(
                            future:
                                loadSelectedWorkouts(), // Use a Future that returns a List<WorkoutInfo>
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator(); // Show a loading indicator
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else {
                                final selectedWorkouts = snapshot.data;
                                // print(
                                //     "--------------------------selectedWorkouts--------------------------");
                                // print(selectedWorkouts);

                                return ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: <Widget>[
                                    planedContainerWidget(), // Place your "plannedContainerWidget" here
                                    const SizedBox(
                                      width: 15,
                                    ),
                                    ...selectedWorkouts!.map((workout) {
                                      final title = workout.title;
                                      final totalElapsedTime =
                                          workout.totalElapsedTime;
                                      // Get a random image file name
                                      final randomImageFileName =
                                          getRandomImageFileName();
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(right: 15.0),
                                        child: buildWorkoutContainer(
                                          AssetImage(
                                              "assets/$randomImageFileName"),
                                          WorkoutData(
                                            id: "id",
                                            name: title,
                                            date: DateTime.now(),
                                            time: "$totalElapsedTime min",
                                          ),
                                        ),
                                      );
                                    }).toList(),

                                    IconButton(
                                      icon: const Icon(Icons.add,
                                          size: 40,
                                          color: Color.fromARGB(255, 104, 66,
                                              255)), // Customize the icon as needed
                                      onPressed: () {
                                        showAddWorkoutDialog(
                                            context, updateSelectedWorkouts);
                                      },
                                    ),
                                  ],
                                );
                              }
                            },
                          ),
                        ),
                      ]),
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    Text(
                      "Workout Levels",
                      style: TextStyle(
                          fontSize: 18,
                          color: color.AppColor.homePageSubtitle,
                          fontWeight: FontWeight.w700),
                    ),
                    Expanded(
                        child:
                            Container()), //take space between the text of "your program" and "details"
                    InkWell(
                      onTap: () {
                        Get.to(() => const AllBuildBideoPlayers());
                      },
                      child: const Text(
                        "See All",
                        style: TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(255, 104, 66, 255),
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () => changeCategory("Beginner"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedCategory == "Beginner"
                            ? const Color.fromARGB(255, 104, 66, 255)
                            : Colors.white,
                        foregroundColor: selectedCategory == "Beginner"
                            ? Colors.white
                            : const Color.fromARGB(255, 104, 66, 255),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              20.0), // Adjust the value for the desired roundness
                          side: const BorderSide(
                            color: Color.fromARGB(255, 104, 66,
                                255), // Set the border color to purple
                            width: 2.0, // Adjust the border width as needed
                          ),
                        ),
                      ),
                      child: const Text("Beginner"),
                    ),
                    const SizedBox(
                      width: 2,
                    ),
                    ElevatedButton(
                      onPressed: () => changeCategory("Intermediate"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedCategory == "Intermediate"
                            ? const Color.fromARGB(255, 104, 66, 255)
                            : Colors.white,
                        foregroundColor: selectedCategory == "Intermediate"
                            ? Colors.white
                            : const Color.fromARGB(255, 104, 66, 255),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              20.0), // Adjust the value for the desired roundness
                          side: const BorderSide(
                            color: Color.fromARGB(255, 104, 66,
                                255), // Set the border color to purple
                            width: 2.0, // Adjust the border width as needed
                          ),
                        ),
                      ),
                      child: const Text("Intermediate"),
                    ),
                    const SizedBox(
                      width: 2,
                    ),
                    ElevatedButton(
                      onPressed: () => changeCategory("Advanced"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedCategory == "Advanced"
                            ? const Color.fromARGB(255, 104, 66, 255)
                            : Colors.white,
                        foregroundColor: selectedCategory == "Advanced"
                            ? Colors.white
                            : const Color.fromARGB(255, 104, 66, 255),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              20.0), // Adjust the value for the desired roundness
                          side: const BorderSide(
                            color: Color.fromARGB(255, 104, 66,
                                255), // Set the border color to purple
                            width: 2.0, // Adjust the border width as needed
                          ),
                        ),
                      ),
                      child: const Text("Advanced"),
                    ),
                  ],
                ),
                if (selectedCategory == "Beginner") ...[
                  buildVideoPlayer("workoutbackground1", "Arms Beginner", 1),
                  buildVideoPlayer("squatBackground2", "Glutes Beginner", 1),
                  buildVideoPlayer("ChestBackground", "Chest Beginner", 1),
                  buildVideoPlayer("LegsBackground", "Legs Beginner", 1),
                  buildVideoPlayer("absbackground", "Abs Beginner", 1),
                  buildVideoPlayer("backBackground", "Back Beginner", 1),
                ],
                if (selectedCategory == "Intermediate") ...[
                  buildVideoPlayer(
                      "workoutbackground1", "Arms Intermediate", 2),
                  buildVideoPlayer(
                      "squatBackground2", "Glutes Intermediate", 2),
                  buildVideoPlayer("ChestBackground", "Chest Intermediate", 2),
                  buildVideoPlayer("LegsBackground", "Legs Intermediate", 2),
                  buildVideoPlayer("absbackground", "Abs Intermediate", 2),
                  buildVideoPlayer("backBackground", "Back Intermediate", 2),
                ],
                if (selectedCategory == "Advanced") ...[
                  buildVideoPlayer("workoutbackground1", "Arms Advanced", 3),
                  buildVideoPlayer("squatBackground2", "Glutes Advanced", 3),
                  buildVideoPlayer("ChestBackground", "Chest Advanced", 3),
                  buildVideoPlayer("LegsBackground", "Legs Advanced", 3),
                  buildVideoPlayer("absbackground", "Abs Advanced", 3),
                  buildVideoPlayer("backBackground", "Back Advanced", 3),
                ],
                const SizedBox(
                  height: 20,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Area of focus",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 18,
                          color: color.AppColor.homePageSubtitle,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Expanded(
                        child: FutureBuilder<List<dynamic>>(
                          future: _initDate(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            } else if (snapshot.hasError) {
                              return const Center(
                                child: Text("Error loading data."),
                              );
                            } else {
                              List<dynamic> info = snapshot.data!;
                              return ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: info.length.toDouble() ~/ 2,
                                itemBuilder: (_, i) {
                                  int a = 2 * i;
                                  int b = 2 * i + 1;

                                  void navigateToWorkout(int index) {
                                    Get.to(
                                      () => MultiBlocProvider(
                                        providers: [
                                          BlocProvider<WorkoutsCubit>(
                                            create: (BuildContext context) {
                                              WorkoutsCubit workoutsCubit =
                                                  WorkoutsCubit();
                                              if (workoutsCubit.state.isEmpty) {
                                                workoutsCubit
                                                    .loadWorkoutsFromFile(
                                                        workoutType: info[index]
                                                            ["title"]);
                                              }
                                              return workoutsCubit;
                                            },
                                          ),
                                          BlocProvider<WorkoutCubit>(
                                            create: (BuildContext context) =>
                                                WorkoutCubit(),
                                          ),
                                        ],
                                        child: BlocBuilder<WorkoutCubit,
                                            WorkoutState>(
                                          builder: (context, state) {
                                            myGlobalBool = true;
                                            if (state is WorkoutIntial) {
                                              return const Home_Page_PlanWorkout();
                                            } else if (state
                                                is WorkoutEditing) {
                                              return EditWorkoutScreen();
                                            }
                                            return const WorkoutProgress();
                                          },
                                        ),
                                      ),
                                    );
                                  }

                                  return Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () => navigateToWorkout(a),
                                        child: _buildWorkoutContainer(info[a]),
                                      ),
                                      GestureDetector(
                                        onTap: () => navigateToWorkout(b),
                                        child: _buildWorkoutContainer(info[b]),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget planedContainerWidget() {
    return Container(
      width: 300,
      height: 250, // Adjust the height as needed
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/blur_gym_room.jpg"),
          fit: BoxFit.fill,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.only(
            left: 20, top: 15, right: 20), // Adjust padding as needed
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Next workout",
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
            closestWorkout != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        closestWorkout!.name,
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
                        "Date and Time: ${DateFormat('yyyy-MM-dd hh:mm a').format(closestWorkout!.date)}",
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
                  )
                : Text(
                    "No upcoming workouts",
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
                  closestWorkout != null
                      ? Text(
                          "${formatTime(parseWorkoutTime(closestWorkout!.time), true)} min",
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
                        )
                      : Text(
                          "Add New Workout in Calendar",
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
                        if (closestWorkout == null) {
                          // Notify the user that they need to add a planned workout.
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text("Please add a planned workout first."),
                            ),
                          );
                        } else {
                          // Split the string by space and take the second part (index 1)
                          List<String> parts = closestWorkout!.name.split(' ');
                          if (parts.length >= 2) {
                            String workoutName = parts.sublist(2).join(' ');

                            Get.to(
                              () => MultiBlocProvider(
                                providers: [
                                  BlocProvider<WorkoutsCubit>(
                                    create: (BuildContext context) {
                                      WorkoutsCubit workoutsCubit =
                                          WorkoutsCubit();
                                      if (workoutsCubit.state.isEmpty) {
                                        workoutsCubit
                                            .loadWorkoutsFromFileByTitle(
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
                          } else {
                            // ignore: avoid_print
                            print("Invalid input string");
                          }
                        }
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

  Widget _buildWorkoutContainer(dynamic info) {
    return Container(
      height: 140,
      width: (MediaQuery.of(context).size.width - 90) / 2,
      padding: const EdgeInsets.only(bottom: 5),
      margin: const EdgeInsets.only(left: 15, bottom: 15, top: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        image: DecorationImage(
          image: AssetImage(info["img"]),
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 3,
            offset: const Offset(5, 5),
            color: color.AppColor.gradientSecond.withOpacity(0.5),
          ),
          BoxShadow(
            blurRadius: 3,
            offset: const Offset(-5, -5),
            color: color.AppColor.gradientSecond.withOpacity(0.5),
          ),
        ],
      ),
      child: Center(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Text(
            info["title"],
            style: TextStyle(
              fontSize: 15,
              color: color.AppColor.homePageDetail,
            ),
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

  getWorkout({bool saveToFile = false}) async {
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
}

class EnableNotificationsDialog extends StatelessWidget {
  const EnableNotificationsDialog({super.key});

  // Function to open the device's notification settings
  void openDeviceNotificationSettings() {
    if (Platform.isAndroid) {
      // For Android, open the notification settings
      OpenSettings.openNotificationSetting();
    } else if (Platform.isIOS) {
      // For iOS, open the app settings
      OpenSettings.openAppSetting();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enable Notifications', style: TextStyle(fontSize: 20)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text(
            'Local Notifications are not enabled. Enable them to receive workout notifications.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  openDeviceNotificationSettings();
                },
                child: const Text('Enable', style: TextStyle(fontSize: 16)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();

                  // Close the dialog
                },
                child: const Text('Dismiss', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
