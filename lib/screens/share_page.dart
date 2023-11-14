import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:share_plus/share_plus.dart';
import '../helpers.dart';
import '../home_page.dart';
import '../models/exercise.dart';
import '../models/workout.dart';
import 'bmi_calculator.dart';
import 'calendar_page.dart';

class SharePage extends StatefulWidget {
  const SharePage({Key? key}) : super(key: key);

  @override
  SharePageState createState() => SharePageState();
}

enum SearchType {
  // ignore: constant_identifier_names
  UserId,
  // ignore: constant_identifier_names
  Title,
  // ignore: constant_identifier_names
  Type,
}

class SharePageState extends State<SharePage> {
  List<Workout> workouts = [];
  String selectedUsername = '';
  String? selectedWorkoutName;
  List<Map<String, dynamic>> workoutPosts = [];
  TextEditingController usernameController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  static String deviceIdentifier = '';
  final uuid = const Uuid();
  String searchQuery = ''; // To store the user's search query
  List<Map<String, dynamic>> originalWorkoutPosts =
      []; // Store the original data

  SearchType selectedSearchType = SearchType.UserId; // Default search type
  bool isWorkoutsLoaded = false;
  GlobalKey<RefreshIndicatorState> refreshKey =
      GlobalKey<RefreshIndicatorState>();
  TextEditingController searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    loadWorkoutsFromJsonFile();
    readAllData();
    loadDeviceIdentifier(); // Load the device identifier from local storage
    updateSearchQuery('');
  }

  @override
  void dispose() {
    usernameController.dispose();
    searchController.dispose();
    super.dispose();
  }

  int _selectedIndex = 3;

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
      Get.to(() => CalendarPage(
            refreshCallback: () {},
          ));
    } else if (index == 2) {
      // Navigate to yet another page if needed
      Get.to(() => const BMICalculator());
    } else if (index == 3) {
      Get.to(() => const SharePage());
    }
  }

  void updateSearchQuery(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
      // Filter the original data based on the search query
      workoutPosts = filterWorkoutPosts(originalWorkoutPosts, searchQuery);
    });
  }

  void updateSearchType(SearchType type) {
    setState(() {
      selectedSearchType = type;
    });
  }

  // Function to filter the workout posts
  List<Map<String, dynamic>> filterWorkoutPosts(
      List<Map<String, dynamic>> posts, String query) {
    if (query.isEmpty) {
      // If the search query is empty, return all workout posts
      return posts;
    }

    return posts.where((workoutData) {
      final userId = workoutData['userId'].toString().toLowerCase();
      final title = workoutData['title'].toString().toLowerCase();
      final type = workoutData['type'].toString().toLowerCase();

      switch (selectedSearchType) {
        case SearchType.UserId:
          return userId.contains(query);
        case SearchType.Title:
          return title.contains(query);
        case SearchType.Type:
          return type.contains(query);
        default:
          return false;
      }
    }).toList();
  }

  Future<void> loadDeviceIdentifier() async {
    // Load the device identifier from local storage
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedIdentifier = prefs.getString('deviceIdentifier');

    if (savedIdentifier == null) {
      // Generate a new device identifier if it doesn't exist
      deviceIdentifier = uuid.v4(); // Use Uuid to generate a UUID
      await prefs.setString('deviceIdentifier', deviceIdentifier);
    } else {
      // Use the existing device identifier
      deviceIdentifier = savedIdentifier;
    }
  }

  void goUp() {
    _scrollController.animateTo(
      0.0, // Scroll to the top
      duration: const Duration(milliseconds: 500), // Animation duration
      curve: Curves.easeInOut, // Animation curve
    );
  }

  void createRecord() {
    DatabaseReference databaseReference =
        FirebaseDatabase.instance.ref().child('users');

    databaseReference.push().set({
      'name': 'John Doe',
      'email': 'johndoe@example.com',
      'age': 30,
    });
  }

  void readAllData() {
    DatabaseReference databaseReference =
        FirebaseDatabase.instance.ref().child('users');

    databaseReference.onValue.listen((event) async {
      DataSnapshot dataSnapshot = event.snapshot;

      if (dataSnapshot.value != null && mounted) {
        Map<dynamic, dynamic> values = dataSnapshot.value
            as Map<dynamic, dynamic>; // Cast to the correct type

        List<Map<String, dynamic>> updatedWorkoutPosts = [];

        for (var userId in values.keys) {
          var userData = values[userId];
          var workoutsData = userData['workouts'] as Map<dynamic, dynamic>;

          for (var workoutKey in workoutsData.keys) {
            var workoutValue = workoutsData[workoutKey];
            Map<String, dynamic> workoutMap = {
              'userId': userId,
              'workoutKey': workoutKey,
              'title': workoutValue['title'],
              'type': workoutValue['type'],
              'exercises': workoutValue['exercises'],
              'timestamp': workoutValue['timestamp'],
            };

            updatedWorkoutPosts.add(workoutMap);
          }
        }
        // Retrieve like counts for each workout
        for (var workoutData in updatedWorkoutPosts) {
          int likeCount = await getLikeCount(workoutData['workoutKey']);
          workoutData['likeCount'] = likeCount;
        }

        // Sort the workoutPosts list by the number of likes in descending order
        updatedWorkoutPosts.sort((a, b) {
          int likesA = a['likeCount'] as int;
          int likesB = b['likeCount'] as int;
          return likesB.compareTo(likesA);
        });

        if (!mounted) return;

        // Store the original data
        originalWorkoutPosts = updatedWorkoutPosts;

        // Filter the data based on the search query
        workoutPosts = filterWorkoutPosts(originalWorkoutPosts, searchQuery);

        // Update the workoutPosts list with the new data
        setState(() {
          // workoutPosts is already filtered
        });
      }
    });
  }

  Future<int> getLikeCount(String workoutKey) async {
    final databaseReference = FirebaseDatabase.instance.ref();
    final likesRef =
        databaseReference.child('workouts').child(workoutKey).child('likes');

    final StreamController<int> controller = StreamController<int>();

    final StreamSubscription<DatabaseEvent> subscription =
        likesRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value;
      if (data != null) {
        Map<dynamic, dynamic> likesMap = data as Map<dynamic, dynamic>;
        controller.add(likesMap.length);
      } else {
        controller.add(0);
      }
    });

    try {
      final int likeCount = await controller.stream.first;
      await subscription.cancel(); // Cancel the subscription when done

      return likeCount;
    } catch (e) {
      //print('Error getting like count: $e');
      await subscription.cancel(); // Cancel the subscription in case of error
      return 0;
    }
  }

  void createWorkout(String userId, Workout? workout) {
    DatabaseReference databaseReference =
        FirebaseDatabase.instance.ref().child('users/$userId/workouts');

    databaseReference.push().set({
      'title': workout?.title,
      'type': workout?.type,
      'timestamp': ServerValue.timestamp,
      'exercises': workout?.exercieses.map((exercise) {
        return {
          'title': exercise.title,
          'prelude': exercise.prelude,
          'duration': exercise.duration,
          'sets': exercise.sets,
        };
      }).toList(),
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Workout Uploaded!'),
      ),
    );
  }

  Future<void> loadWorkoutsFromJsonFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/workouts.json');

      if (!file.existsSync()) {
        workouts = [];
        return; // Return if the file does not exist
      }

      final jsonContent = await file.readAsString();
      final decodedJson = json.decode(jsonContent);

      workouts = List<Workout>.from(decodedJson.map((workoutData) {
        // Assuming Workout.fromJson is a factory constructor in your Workout class
        return Workout.fromJson(workoutData);
      }));
    } catch (e) {
      // Handle file reading or decoding errors
      workouts = []; // Return an empty list or handle the error as needed
    }
  }

  void createAndSaveNewWorkout(
      List<Workout> workouts, Workout newWorkout) async {
    // Update the list of workouts with the updated workout
    workouts.add(newWorkout);

    // Update the JSON file with the updated list of workouts
    final updatedWorkoutsJson =
        jsonEncode(workouts.map((w) => w.toJson()).toList());

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/workouts.json');

    try {
      await file.writeAsString(updatedWorkoutsJson);
    } catch (e) {
      // Handle file writing error
    }

    // You can choose to emit an event or notify the UI about the updated list of workouts here.
  }

  Future<Workout?> getWorkoutByName(String name) async {
    await loadWorkoutsFromJsonFile();
    // Find the workout with the specified name
    return workouts.firstWhere(
      (workout) => workout.title == name,
    );
  }

  void updateData(String recordKey) {
    DatabaseReference databaseReference =
        FirebaseDatabase.instance.ref().child('users');

    databaseReference.child(recordKey).update({
      'name': 'Jane Doe',
      'age': 25,
    });
  }

  void deleteData(String recordKey) {
    DatabaseReference databaseReference =
        FirebaseDatabase.instance.ref().child('users');

    databaseReference.child(recordKey).remove();
  }

  List<Workout> removeDuplicateWorkouts(List<Workout> inputWorkouts) {
    // Create a set to store unique workout titles
    final uniqueTitles = <String>{};

    // Create a new list to store the unique workouts
    final uniqueWorkouts = <Workout>[];

    for (final workout in inputWorkouts) {
      final workoutTitle = workout.title;

      // Check if the title is unique; if not, skip this workout
      if (!uniqueTitles.contains(workoutTitle)) {
        uniqueTitles.add(workoutTitle!);
        uniqueWorkouts.add(workout);
      }
    }

    return uniqueWorkouts;
  }

  // Define a function to build the dialog content
  Widget buildAddPostDialog(BuildContext context) {
    return Dialog(
        backgroundColor: Colors.transparent,
        child: SingleChildScrollView(
          child: Card(
            margin: const EdgeInsets.all(16.0),
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        // Close the dialog when the button is pressed
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  const Text(
                    'Enter your information:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: usernameController,
                    decoration: const InputDecoration(labelText: 'Username'),
                    onChanged: (value) {
                      setState(() {
                        selectedUsername = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: selectedWorkoutName?.isNotEmpty == true
                        ? selectedWorkoutName
                        : null,
                    items: workouts.map((workout) {
                      return DropdownMenuItem<String>(
                        value: workout
                            .title, // Use a unique identifier as the value
                        child: Text(workout.title!),
                      );
                    }).toList(),
                    decoration:
                        const InputDecoration(labelText: 'Select a Workout'),
                    onChanged: (value) {
                      setState(() {
                        selectedWorkoutName = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                            const Color.fromARGB(255, 104, 66, 255))),
                    onPressed: () async {
                      if (selectedUsername.isNotEmpty &&
                          selectedWorkoutName != null) {
                        createWorkout(
                          selectedUsername,
                          await getWorkoutByName(selectedWorkoutName!),
                        );
                      }

                      setState(() {
                        readAllData();
                      });
                      // Close the dialog when the action is completed
                      if (mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    icon: const Icon(Icons.save),
                    label: const Text('Save to Database'),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  void removePost(String workoutKey) {
    // Implement the logic to remove the post with the specified workoutKey
    setState(() {
      workoutPosts.removeWhere((post) => post['workoutKey'] == workoutKey);
    });
  }

  @override
  Widget build(BuildContext context) {
    workouts = removeDuplicateWorkouts(workouts);

    return Scaffold(
      backgroundColor: const Color.fromARGB(181, 232, 234, 238),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 104, 66, 255),
        title: const Text('Share Page'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // Replace with the back icon
          onPressed: () {
            // Call your function here when the back button is pressed
            // For example, you can use Navigator.pop(context) to navigate back
            FocusScope.of(context).unfocus();

            _onItemTapped(0);
          },
        ),
        actions: [
          IconButton(
            onPressed: goUp,
            icon: const Icon(Icons.move_up), // Wrap with Icon widget
          ),
          InkWell(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return buildAddPostDialog(
                      context); // Call the function to build the dialog
                },
              );
            },
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.post_add),
            ),
          ),
        ],
      ),
      bottomNavigationBar: PreferredSize(
        preferredSize: const Size.fromHeight(56), // Adjust the height as needed
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
      resizeToAvoidBottomInset: false,
      body: RefreshIndicator(
        key: refreshKey,
        onRefresh: () async {
          // Implement your data refreshing logic here, typically by calling readAllData or a similar method
          readAllData();
        },
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(0.0),
                child: Center(
                  child: Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                            'assets/blur_gym_room_3.jpg'), // Replace with your image path
                        fit: BoxFit.cover, // You can adjust the fit as needed
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        // Display workout posts in a ListView
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25.0),
                                    color: Colors.grey[
                                        200], // Set your desired background color
                                  ),
                                  child: Row(
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Icon(Icons.search),
                                      ),
                                      Expanded(
                                        child: TextField(
                                          decoration: InputDecoration(
                                            hintText: selectedSearchType ==
                                                    SearchType.Type
                                                ? 'General, Abs, Legs, Arms, Back, or Glutes'
                                                : 'Search',
                                            hintStyle: selectedSearchType ==
                                                    SearchType.Type
                                                ? const TextStyle(fontSize: 10)
                                                : const TextStyle(fontSize: 16),
                                            border: InputBorder
                                                .none, // Remove the border
                                          ),
                                          onChanged: updateSearchQuery,
                                          controller: searchController,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10.0), // Add some spacing
                              Container(
                                width:
                                    120.0, // Set a fixed width for the DropdownButton
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25.0),
                                  color: Colors.grey[
                                      200], // Set your desired background color
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: DropdownButton<SearchType>(
                                    isExpanded: true,
                                    value: selectedSearchType,
                                    onChanged: (SearchType? type) {
                                      if (type != null) {
                                        updateSearchType(type);
                                      }
                                    },
                                    items: const [
                                      //here my man
                                      DropdownMenuItem(
                                        value: SearchType.UserId,
                                        child: Text('User ID'),
                                      ),
                                      DropdownMenuItem(
                                        value: SearchType.Title,
                                        child: Text('Title'),
                                      ),
                                      DropdownMenuItem(
                                        value: SearchType.Type,
                                        child: Text('Type'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10.0), // Add some spacing
                              IconButton(
                                color: Colors.black,
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  searchController.clear(); // Clear the text

                                  // Clear the search query and remove the keyboard

                                  updateSearchQuery('');

                                  FocusScope.of(context).unfocus();
                                },
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: !isWorkoutsLoaded,
                child: const Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Center(
                        child: CircularProgressIndicator(
                            color: Color.fromARGB(255, 104, 66, 255)))),
              ),

              // Use FutureBuilder to display loading screen or workout posts
              FutureBuilder<void>(
                // Replace 'void' with the data type of your loadWorkoutsFromJsonFile method
                future:
                    loadWorkoutsFromJsonFile(), // Change this to your loading data function
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // If the Future is still running, display a loading indicator
                    // print("CircularProgressIndicator 685");
                    return const Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: Center(
                            child: CircularProgressIndicator(
                                color: Color.fromARGB(255, 104, 66, 255))));
                  } else if (snapshot.hasError) {
                    // If there's an error, display an error message
                    return Text('Error loading data: ${snapshot.error}');
                  } else {
                    isWorkoutsLoaded = true;
                    // If the Future has completed, display the workout posts
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: workoutPosts.length,
                      itemBuilder: (context, index) {
                        return WorkoutPostWidget(
                          workoutData: workoutPosts[index],
                          workouts: workouts,
                          onRemove: () =>
                              removePost(workoutPosts[index]['workoutKey']),
                        );
                      },
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WorkoutPostWidget extends StatefulWidget {
  final Map<String, dynamic> workoutData;
  final List<Workout> workouts; // Add this line
  final VoidCallback onRemove;

  const WorkoutPostWidget({
    Key? key,
    required this.workoutData,
    required this.workouts,
    required this.onRemove,
  }) : super(key: key);

  @override
  WorkoutPostWidgetState createState() => WorkoutPostWidgetState();
}

class WorkoutPostWidgetState extends State<WorkoutPostWidget> {
  bool isLiked;
  bool isExerciseListOpen = false;
  int likeCount;

  WorkoutPostWidgetState()
      : isLiked = false,
        likeCount = 0;

  @override
  void initState() {
    super.initState();
    // Initialize isLiked and get the like count based on workoutData.
    getLikeStatus(widget.workoutData['workoutKey']).then((isLiked) {
      if (mounted) {
        setState(() {
          this.isLiked = isLiked;
        });
      }
    });

    getLikeCount(widget.workoutData['workoutKey']).then((count) {
      if (mounted) {
        setState(() {
          likeCount = count;
        });
      }
    });
  }

  void shareWorkout() {
    // Implement the logic to share the workout using the share_plus package
    Share.share(
        'Check out this amazing workout: ${widget.workoutData['title']}');
  }

  final List<String> reportReasons = [
    "Inappropriate content",
    "Spam",
    "Misleading information",
    "Offensive language",
    "Other",
  ];
  String selectedReportReason = "Inappropriate content"; // Default reason

  Future<void> reportWorkout() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Report Workout"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text("Select a reason for reporting this workout:"),
              const SizedBox(height: 10),
              DropdownButton<String>(
                value: selectedReportReason,
                items: reportReasons.map((String reason) {
                  return DropdownMenuItem<String>(
                    value: reason,
                    child: Text(reason),
                  );
                }).toList(),
                onChanged: (String? reason) {
                  if (reason != null) {
                    setState(() {
                      selectedReportReason = reason;
                    });
                  }
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                // Get workout data
                final Map<String, dynamic> workoutData = widget.workoutData;

                // Create a report object with reason, workout name, and user
                final Map<String, dynamic> report = {
                  'reason': selectedReportReason,
                  'workoutName': workoutData['title'],
                  'user': workoutData['userId'],
                };

                // Send the report to Firebase Realtime Database
                await sendReport(report);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Workout reported successfully!'),
                    ),
                  );

                  Navigator.of(context).pop();
                }
              },
              child: const Text("Report"),
            ),
          ],
        );
      },
    );
  }

  Future<void> sendReport(Map<String, dynamic> report) async {
    final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
    final reportsRef = databaseReference.child('reports');

    // Push the report to the "reports" node
    await reportsRef.push().set(report);
  }

  Widget getCategoryCircleIcon(String category) {
    String imagePath;

    if (category == "General") {
      imagePath = "assets/muscle.png"; // Replace with the correct image path
    } else if (category == "Abs") {
      imagePath = "assets/abs.png"; // Replace with the correct image path
    } else if (category == "Legs") {
      imagePath = "assets/leg.png"; // Replace with the correct image path
    } else if (category == "Arms") {
      imagePath = "assets/arm.png"; // Replace with the correct image path
    } else if (category == "Back") {
      imagePath = "assets/back.png"; // Replace with the correct image path
    } else if (category == "Glutes") {
      imagePath = "assets/gluteus.png"; // Replace with the correct image path
    } else {
      imagePath = "assets/muscle.png"; // Default image path
    }

    return Tooltip(
      message: category,
      child: GestureDetector(
        onLongPress: () {
          final snackBar = SnackBar(
            content: Text(category),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        },
        child: CircleAvatar(
          radius: 20, // Adjust the radius as needed
          backgroundColor: const Color.fromARGB(
              255, 104, 66, 255), // Set the background color
          child: Image.asset(
            imagePath, // Use the provided image path
            color: Colors.white, // Set the image color
          ),
        ),
      ),
    );
  }

  Future<bool> getLikeStatus(String workoutKey) async {
    final databaseReference = FirebaseDatabase.instance.ref();
    final likesRef =
        databaseReference.child('workouts').child(workoutKey).child('likes');
    final String deviceIdentifier = SharePageState.deviceIdentifier;

    if (deviceIdentifier.isEmpty) {
      return false; // Handle the case when the device identifier is empty
    }

    final DatabaseEvent event = await likesRef.child(deviceIdentifier).once();
    final bool isLiked = event.snapshot.value == true;
    return isLiked;
  }

  @override
  Widget build(BuildContext context) {
    // Use workoutData to build your post UI
    return Center(
      child: Container(
        margin: const EdgeInsets.only(bottom: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
              0), // Set the border radius to 0 for no curves
          color: Colors.white, // Specify the background color
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      getCategoryCircleIcon(widget.workoutData['type']),
                      Container(
                        width: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment
                            .start, // Align the content to the left
                        children: [
                          Row(
                            children: [
                              Text(
                                'User: ${widget.workoutData['userId']}',
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16 // Add a bold font
                                    ),
                              ),
                            ],
                          ),
                          Container(
                            height: 7,
                          ),
                          Text(
                            'Posted ${timeAgo(DateTime.fromMillisecondsSinceEpoch(widget.workoutData['timestamp']))}',
                            style: const TextStyle(
                                fontSize: 13,
                                color: Color.fromRGBO(102, 103, 107, 1)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                            color: Color.fromRGBO(33, 34, 35, 1),
                            Icons.more_horiz),
                        onPressed: () {
                          // Call the shareWorkout method to share the workout
                          reportWorkout();
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                            color: Color.fromRGBO(33, 34, 35, 1), Icons.close),
                        onPressed: () {
                          widget.onRemove();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Content Section
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Title: ${widget.workoutData['title']}'),
                  TextButton(
                    onPressed: () {
                      // Toggle the exercise list visibility when the button is pressed
                      setState(() {
                        isExerciseListOpen = !isExerciseListOpen;
                      });
                    },
                    child: Text(
                      isExerciseListOpen ? 'Close' : 'More...',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(102, 103, 107, 1)),
                    ),
                  ),
                  if (isExerciseListOpen) ...[
                    const SizedBox(height: 8.0),
                    const Text('Exercises:'),
                    widget.workoutData['exercises'] != null
                        ? ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: widget.workoutData['exercises'].length,
                            itemBuilder: (context, index) {
                              Map<Object?, Object?> exerciseData =
                                  widget.workoutData['exercises'][index];
                              return Center(
                                child: ExerciseWidget(exercises: exerciseData),
                              );
                            },
                          )
                        : const Text('No exercises available')
                  ],
                ],
              ),
            ),

            const SizedBox(
              height: 30, // Adjust the spacing
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Row(
                    children: [
                      const Icon(
                          color: Color.fromARGB(255, 104, 66, 255),
                          Icons.thumb_up_alt_outlined),
                      FutureBuilder<int>(
                        future: getLikeCount(widget.workoutData['workoutKey']),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            //print("CircularProgressIndicator 1056");
                            return const Center(
                                child: CircularProgressIndicator(
                                    color: Color.fromARGB(255, 104, 66, 255)));
                          }
                          var likeCount = snapshot.data ?? 0;
                          return Text(' $likeCount',
                              style: const TextStyle(color: Colors.black87));
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 2,
                  ),
                  GestureDetector(
                    onTap: () {
                      // Toggle the like state when the user taps the row
                      setState(() {
                        isLiked = !isLiked;
                      });
                      // Call the updateLikes method and pass a callback function to update likeCount
                      updateLikes(widget.workoutData['workoutKey'], isLiked,
                          (count) {
                        setState(() {
                          likeCount = count;
                        });
                      });
                    },
                    child: Row(
                      children: [
                        Icon(
                          isLiked
                              ? Icons.thumb_up
                              : Icons.thumb_up_alt_outlined,
                          color: isLiked
                              ? const Color.fromARGB(255, 104, 66, 255)
                              : const Color.fromRGBO(102, 103, 107, 1),
                        ),
                        const SizedBox(width: 10),
                        Text('Like',
                            style: TextStyle(
                                color: isLiked
                                    ? const Color.fromARGB(255, 104, 66, 255)
                                    : const Color.fromRGBO(102, 103, 107, 1))),
                      ],
                    ),
                  ),
                  Container(
                    width: 2,
                  ),
                  GestureDetector(
                    onTap: () async {
                      // Check if the workoutData contains the necessary information
                      if (widget.workoutData.containsKey('title') &&
                          widget.workoutData.containsKey('type') &&
                          widget.workoutData.containsKey('exercises')) {
                        // Create a new Workout object based on the workoutData
                        Workout newWorkout = Workout(
                          title: widget.workoutData['title'],
                          type: widget.workoutData['type'],
                          exercieses: (widget.workoutData['exercises'] as List)
                              .map((exerciseData) {
                            // Map the exercise data to Exercise objects
                            return Exercise(
                              title: exerciseData['title'],
                              prelude: exerciseData['prelude'],
                              duration: exerciseData['duration'],
                              sets: exerciseData['sets'],
                            );
                          }).toList(),
                        );

                        // Call the createAndSaveNewWorkout function from SharePageState
                        SharePageState().createAndSaveNewWorkout(
                            widget.workouts, newWorkout);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Workout imported and saved!'),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Invalid workout data.'),
                          ),
                        );
                      }
                    },
                    child: const Row(
                      children: [
                        Icon(
                          Icons.save,
                          color: Color.fromRGBO(102, 103, 107, 1),
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Save',
                          style: TextStyle(
                            color: Color.fromRGBO(102, 103, 107, 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 2,
                  ),
                  GestureDetector(
                    onTap: () {
                      // Call the shareWorkout method to share the workout
                      shareWorkout();
                    },
                    child: const Row(
                      children: [
                        Icon(
                          Icons.share,
                          color: Color.fromRGBO(102, 103, 107, 1),
                        ),
                        SizedBox(width: 10),
                        Text('Share',
                            style: TextStyle(
                                color: Color.fromRGBO(102, 103, 107, 1))),
                      ],
                    ),
                  ),
                  Container(
                    width: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void updateLikes(
    String workoutKey,
    bool isLiked,
    Function(int) onLikeCountUpdated,
  ) async {
    final databaseReference = FirebaseDatabase.instance.ref();
    final likesRef =
        databaseReference.child('workouts').child(workoutKey).child('likes');

    final String deviceIdentifier = SharePageState.deviceIdentifier;

    if (deviceIdentifier.isNotEmpty) {
      if (isLiked) {
        // User liked the workout, add a like with the device identifier
        likesRef.child(deviceIdentifier).set(true).then((_) {
          // Update the isLiked state and likeCount after successfully updating the like in the database
          setState(() {
            this.isLiked = true;
            likeCount += 1;
          });
          likeCountCache[workoutKey] = likeCount; // Update cache
          onLikeCountUpdated(likeCount); // Notify callback with updated count
        });
      } else {
        // User unliked the workout, remove the like with the device identifier
        likesRef.child(deviceIdentifier).remove().then((_) {
          // Update the isLiked state and likeCount after successfully updating the like in the database
          setState(() {
            this.isLiked = false;
            likeCount -= 1;
          });
          likeCountCache[workoutKey] = likeCount; // Update cache
          onLikeCountUpdated(likeCount); // Notify callback with updated count
        });
      }
    } else {
      // Handle the case when the device identifier is empty
      //print("Device identifier is empty.");
    }
  }

  Map<String, int> likeCountCache = {}; // Cache for like counts

  Future<int> getLikeCount(String workoutKey) async {
    if (likeCountCache.containsKey(workoutKey)) {
      return likeCountCache[workoutKey]!;
    }

    final databaseReference = FirebaseDatabase.instance.ref();
    final likesRef =
        databaseReference.child('workouts').child(workoutKey).child('likes');

    final StreamController<int> controller = StreamController<int>();

    final StreamSubscription<DatabaseEvent> subscription =
        likesRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value;
      final int likeCount =
          data != null ? (data as Map<dynamic, dynamic>).length : 0;
      likeCountCache[workoutKey] = likeCount;
      controller.add(likeCount);
    });

    try {
      final int likeCount = await controller.stream.first;
      await subscription.cancel();
      return likeCount;
    } catch (e) {
      await subscription.cancel();
      return 0;
    }
  }
}

class ExerciseWidget extends StatelessWidget {
  final Map<Object?, Object?> exercises;

  const ExerciseWidget({super.key, required this.exercises});

  @override
  Widget build(BuildContext context) {
    final title = exercises['title'] as String?; // Explicitly cast to String

    return Center(
      child: Column(
        // crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('Title: ${replaceUnderscoresWithSpaces(title ?? '')}'),
          Text('Prelude: ${exercises['prelude']}'),
          Text('Duration: ${exercises['duration']}'),
          Text('Sets: ${exercises['sets']}'),
          const Divider(), // Add a divider between exercises
        ],
      ),
    );
  }
}
