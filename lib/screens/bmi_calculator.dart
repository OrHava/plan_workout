import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:plan_workout/screens/share_page.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animated_button/flutter_animated_button.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../blocs/workout_cubit.dart';
import '../helpers.dart';
import '../home_page.dart';
import 'calendar_page.dart'; // Add this import
import 'workout_planner_page.dart'; // Add this import

enum MeasurementSystem {
  // ignore: constant_identifier_names
  Metric,
  // ignore: constant_identifier_names
  Imperial,
}

class BMIEntry {
  final String id; // Special ID for each entry
  final String date;
  final double bmi;
  final int age;
  final double weight;
  final double height;
  final String gender;
  final MeasurementSystem measurementSystem;

  BMIEntry({
    required this.id,
    required this.date,
    required this.bmi,
    required this.age,
    required this.weight,
    required this.height,
    required this.gender,
    required this.measurementSystem,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'bmi': bmi,
      'age': age,
      'weight': weight,
      'height': height,
      'gender': gender,
      'measurementSystem': measurementSystem.toString(), // Store as a string
    };
  }

  factory BMIEntry.fromJson(Map<String, dynamic> json) {
    return BMIEntry(
      id: json['id'],
      date: json['date'],
      bmi: json['bmi'],
      age: json['age'],
      weight: json['weight'],
      height: json['height'],
      gender: json['gender'],
      measurementSystem: MeasurementSystem.values
          .firstWhere((e) => e.toString() == json['measurementSystem']),
    );
  }
}

class BMICalculator extends StatefulWidget {
  const BMICalculator({Key? key}) : super(key: key);

  @override
  BMICalculatorState createState() => BMICalculatorState();
}

class BMICalculatorState extends State<BMICalculator> {
  final TextEditingController ageController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  double bmiMarkerPosition = 0.0;
  String gender = "Male"; // Default gender selection
  double bmi = 0.0;
  String bmiCategory = "";
  bool showEmptyFieldError = false;
  MeasurementSystem selectedSystem = MeasurementSystem.Metric;

  String ageHint = 'Age (years)';
  String weightHint = 'Weight (kg)';
  String heightHint = 'Height (cm)';
  String weightUnit = 'kg';
  String heightUnit = 'cm';
  int _selectedIndex = 2;

  File? image;
  String? name;
  bool isEditing = false;
  bool isEditingInfo = false;
  String selectedCategory = "HISTORY";
  late List<WorkoutData> workouts = [];

  @override
  void initState() {
    super.initState();

    loadWorkouts();

    // Load the last saved entry and update the input fields
    loadLastSavedEntry().then((lastSavedEntry) {
      updateInputFieldsFromLastSavedEntry(lastSavedEntry);
    });

    // Load the last saved image
    loadImage().then((savedImage) {
      setState(() {
        image = savedImage;
      });
    });

    // Load the last saved image
    loadUserName().then((savedname) {
      setState(() {
        name = savedname;
      });
    });
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

  void _updateMeasurementUnits() {
    setState(() {
      if (selectedSystem == MeasurementSystem.Metric) {
        ageHint = 'Age (years)';
        weightHint = 'Weight (kg)';
        heightHint = 'Height (cm)';
        weightUnit = 'kg';
        heightUnit = 'cm';
      } else {
        ageHint = 'Age (years)';
        weightHint = 'Weight (lbs)';
        heightHint = 'Height (in)';
        weightUnit = 'lbs';
        heightUnit = 'in';
      }
    });
  }

  Future<void> saveLastBMIEntry(BMIEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final bmiEntryJson = jsonEncode(entry.toJson());
    await prefs.setString('lastBMIEntry', bmiEntryJson);
  }

  Future<BMIEntry?> loadLastSavedEntry() async {
    final prefs = await SharedPreferences.getInstance();
    final bmiEntryJson = prefs.getString('lastBMIEntry');
    if (bmiEntryJson != null) {
      final Map<String, dynamic> entryMap = jsonDecode(bmiEntryJson);
      return BMIEntry.fromJson(entryMap);
    }
    return null;
  }

  String getMonthAbbreviation(DateTime date) {
    List<String> monthAbbreviations = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];

    int monthIndex = date.month - 1; // Adjust for 0-based index

    if (monthIndex >= 0 && monthIndex < 12) {
      return monthAbbreviations[monthIndex];
    } else {
      return "Invalid Month";
    }
  }

  void updateInputFieldsFromLastSavedEntry(BMIEntry? lastSavedEntry) {
    if (lastSavedEntry != null) {
      setState(() {
        ageController.text = lastSavedEntry.age.toString();
        weightController.text = lastSavedEntry.weight.toStringAsFixed(1);
        heightController.text = lastSavedEntry.height.toStringAsFixed(1);
        gender = lastSavedEntry.gender;

        if (lastSavedEntry.measurementSystem == MeasurementSystem.Metric) {
          selectedSystem = MeasurementSystem.Metric;
          _updateMeasurementUnits(); // Update the units and hints
        } else {
          selectedSystem = MeasurementSystem.Imperial;
          _updateMeasurementUnits(); // Update the units and hints
        }
      });
    }
  }

  Future<List<BMIEntry>> getBMIEntriesFromMemory() async {
    final prefs = await SharedPreferences.getInstance();
    final bmiEntriesJson = prefs.getStringList('bmiEntries') ?? [];
    return bmiEntriesJson
        .map((jsonString) => BMIEntry.fromJson(jsonDecode(jsonString)))
        .toList();
  }

  Future<void> calculateBMI(bool save) async {
    FocusScope.of(context).unfocus();

    final age = ageController.text;
    final weight = weightController.text;
    final height = heightController.text;

    if (age.isEmpty || weight.isEmpty || height.isEmpty) {
      setState(() {
        showEmptyFieldError = true;
      });
      return;
    }

    final ageValue = double.parse(age);
    final weightValue = double.parse(weight);
    final heightValue = selectedSystem == MeasurementSystem.Metric
        ? double.parse(height) / 100
        : double.parse(height) * 0.0254;

    final calculatedBMI = weightValue / (heightValue * heightValue);

    final entryId = const Uuid().v4();
    final bmiEntry = BMIEntry(
      id: entryId,
      date: DateTime.now().toString(),
      bmi: calculatedBMI,
      age: ageValue.toInt(),
      weight: weightValue,
      height: double.parse(height),
      gender: gender,
      measurementSystem: selectedSystem,
    );

    if (save) {
// Save the BMI entry to SharedPreferences as JSON string
      final prefs = await SharedPreferences.getInstance();
      final bmiEntriesJson = prefs.getStringList('bmiEntries') ?? [];
      final bmiEntryJson = jsonEncode(bmiEntry.toJson());
      bmiEntriesJson.add(bmiEntryJson);
      prefs.setStringList('bmiEntries', bmiEntriesJson);

      saveLastBMIEntry(bmiEntry);
    }

    setState(() {
      bmi = calculatedBMI;
      bmiMarkerPosition = ((bmi - 0.0) / (60.0 - 0.0)) * 100.0;

      if (ageValue >= 2 && ageValue <= 18) {
        if (bmi < 18.5) {
          bmiCategory = "Underweight";
        } else if (bmi <= 24.9) {
          bmiCategory = "Normal";
        } else if (bmi <= 29.9) {
          bmiCategory = "Overweight";
        } else {
          bmiCategory = "Obese";
        }
      } else {
        if (bmi < 18.5) {
          bmiCategory = "Underweight";
        } else if (bmi <= 24.9) {
          bmiCategory = "Normal";
        } else if (bmi <= 29.9) {
          bmiCategory = "Overweight";
        } else {
          bmiCategory = "Obese";
        }
      }

      showEmptyFieldError = false;
    });
  }

  Color getBMIScaleColor() {
    if (bmi < 18.5) {
      return Colors.blue;
    } else if (bmi < 24.9) {
      return Colors.green;
    } else if (bmi < 29.9) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  Future<File?> loadImage() async {
    final appDir = await getApplicationDocumentsDirectory();
    const fileName = 'profile_picture.png';
    final profilePicturePath = '${appDir.path}/$fileName';

    final file = File(profilePicturePath);
    if (await file.exists()) {
      return file;
    } else {
      return null;
    }
  }

  Future<void> saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', name);
  }

  Future<String?> loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userName');
  }

  void toggleEditing() {
    setState(() {
      nameController = TextEditingController(text: name);
      isEditing = true;
    });
  }

  void changeCategory(String category) {
    setState(() {
      selectedCategory = category;

      if (category == "BMI") {
        calculateBMI(false);
      }
    });
  }

  Future<void> getImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    final appDir = await getApplicationDocumentsDirectory();
    const fileName = 'profile_picture.png';
    final savedImage =
        await File(pickedFile.path).copy('${appDir.path}/$fileName');

    setState(() {
      image = savedImage;
    });
  }

  Future<void> loadWorkouts() async {
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
            if (words.isNotEmpty && (words[0] == "Completed")) {
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

      // Sort the loadedWorkouts list by date in descending order
      loadedWorkouts.sort((a, b) => b.date.compareTo(a.date));

      setState(() {
        workouts = loadedWorkouts; // Update the workouts list
      });
    } catch (e) {
      // ignore: avoid_print
      print('Error loading workouts: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 104, 66, 255),
        title: const Text('BMI Calculator'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // Replace with the back icon
          onPressed: () {
            // Call your function here when the back button is pressed
            // For example, you can use Navigator.pop(context) to navigate back
            FocusScope.of(context).unfocus();

            _onItemTapped(0);
          },
        ),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                children: [
                  IconButton(
                      onPressed: () {
                        // here
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => MultiBlocProvider(providers: [
                              // Add your other providers here if needed
                              BlocProvider<WorkoutCubit>(
                                create: (BuildContext context) =>
                                    WorkoutCubit(),
                              ),
                            ], child: const WorkoutPlannerPage()),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.next_plan,
                        color: Color.fromARGB(255, 104, 66, 255),
                      )),
                  Expanded(child: Container()),
                  IconButton(
                      onPressed: () {
                        setState(() {
                          if (isEditingInfo) {
                            isEditingInfo = false;
                          } else {
                            isEditingInfo = true;
                          }
                        });
                      },
                      icon: const Icon(Icons.settings,
                          color: Color.fromARGB(255, 104, 66, 255)))
                ],
              ),
              GestureDetector(
                onTap: () {
                  getImage();
                },
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[300],
                    image: image == null
                        ? null
                        : DecorationImage(
                            image: FileImage(image!),
                            fit: BoxFit.cover,
                          ),
                  ),
                  child: image == null
                      ? const Icon(
                          Icons.camera_alt,
                          size: 40,
                          color: Colors.grey,
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 10),
              if (name != null && !isEditing)
                GestureDetector(
                  onTap: toggleEditing,
                  child: Text(
                    '$name',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              if (name == null || name!.isEmpty)
                Column(
                  children: [
                    const Text('User Name'),
                    SizedBox(
                      width: 200,
                      child: TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          hintText: 'Enter your name',
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            const Color.fromARGB(255, 104, 66, 255)),
                      ),
                      onPressed: () {
                        final enteredName = nameController.text;
                        saveUserName(enteredName);
                        setState(() {
                          name = enteredName;
                          isEditing = false;
                        });
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              if (isEditing)
                Column(
                  children: [
                    const Text('User Name'),
                    SizedBox(
                      width: 200,
                      child: TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          hintText: 'Enter your name',
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 104, 66, 255)),
                      onPressed: () {
                        final enteredName = nameController.text;
                        saveUserName(enteredName);
                        setState(() {
                          name = enteredName;
                          isEditing = false;
                        });
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              const SizedBox(height: 20),
              if (isEditingInfo)
                DropdownButtonFormField<MeasurementSystem>(
                  value: selectedSystem,
                  onChanged: (system) {
                    setState(() {
                      selectedSystem = system!;
                      _updateMeasurementUnits();
                    });
                  },
                  items: MeasurementSystem.values.map((system) {
                    return DropdownMenuItem<MeasurementSystem>(
                      value: system,
                      child: Text(system == MeasurementSystem.Metric
                          ? 'Metric'
                          : 'Imperial'),
                    );
                  }).toList(),
                  decoration: const InputDecoration(
                    labelText: 'Measurement System',
                    border: OutlineInputBorder(),
                  ),
                ),
              if (isEditingInfo) const SizedBox(height: 5),
              if (isEditingInfo)
                DropdownButtonFormField<String>(
                  value: gender,
                  onChanged: (value) {
                    setState(() {
                      gender = value!;
                    });
                  },
                  items: ['Male', 'Female'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  decoration: const InputDecoration(
                    labelText: 'Gender',
                    border: OutlineInputBorder(),
                  ),
                ),
              const SizedBox(height: 5),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  height: 80,
                  color: const Color.fromARGB(255, 104, 66, 255),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: 40,
                              child: TextFormField(
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                                textAlign: TextAlign.center,
                                controller: ageController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  border: InputBorder.none, // Remove the border
                                  contentPadding:
                                      EdgeInsets.zero, // Remove extra padding
                                ),
                              ),
                            ),
                            Text(
                              ageHint,
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 50,
                        child: VerticalDivider(
                          color: Colors.white,

                          // Set the thickness as desired
                        ),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: 40,
                              child: TextFormField(
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                                textAlign: TextAlign.center,
                                controller: weightController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  border: InputBorder.none, // Remove the border
                                  contentPadding:
                                      EdgeInsets.zero, // Remove extra padding
                                ),
                              ),
                            ),
                            Text(
                              'Weight ($weightUnit)',
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 50,
                        child: VerticalDivider(
                          color: Colors.white,

                          // Set the thickness as desired
                        ),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: 40,
                              child: TextFormField(
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                                textAlign: TextAlign.center,
                                controller: heightController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  border: InputBorder.none, // Remove the border
                                  contentPadding:
                                      EdgeInsets.zero, // Remove extra padding
                                ),
                              ),
                            ),
                            Text(
                              'Height ($heightUnit)',
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (isEditingInfo)
                AnimatedButton(
                  height: 70,
                  width: 200,
                  text: 'Calculate BMI',
                  isReverse: true,
                  selectedTextColor: const Color.fromARGB(255, 104, 66, 255),
                  transitionType: TransitionType.LEFT_TO_RIGHT,
                  textStyle: const TextStyle(fontSize: 18),
                  backgroundColor: const Color.fromRGBO(104, 66, 255, 0.5),
                  borderColor: const Color.fromRGBO(104, 66, 255, 0.5),
                  borderRadius: 50,
                  borderWidth: 2,
                  onPress: () {
                    setState(() {
                      calculateBMI(true);
                    });
                  },
                ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      width: 100,
                      child: ElevatedButton(
                        onPressed: () => changeCategory("BMI"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedCategory == "BMI"
                              ? const Color.fromARGB(255, 104, 66, 255)
                              : Colors.white,
                          foregroundColor: selectedCategory == "BMI"
                              ? Colors.white
                              : const Color.fromARGB(255, 104, 66, 255),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                10.0), // Adjust the value for the desired roundness
                            side: const BorderSide(
                              color: Color.fromARGB(255, 104, 66,
                                  255), // Set the border color to purple
                              width: 2.0, // Adjust the border width as needed
                            ),
                          ),
                        ),
                        child: const Text("BMI"),
                      ),
                    ),
                    const SizedBox(width: 5),
                    SizedBox(
                      width: 100,
                      child: ElevatedButton(
                        onPressed: () => changeCategory("HISTORY"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedCategory == "HISTORY"
                              ? const Color.fromARGB(255, 104, 66, 255)
                              : Colors.white,
                          foregroundColor: selectedCategory == "HISTORY"
                              ? Colors.white
                              : const Color.fromARGB(255, 104, 66, 255),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                10.0), // Adjust the value for the desired roundness
                            side: const BorderSide(
                              color: Color.fromARGB(255, 104, 66,
                                  255), // Set the border color to purple
                              width: 2.0, // Adjust the border width as needed
                            ),
                          ),
                        ),
                        child: const Text("History"),
                      ),
                    ),
                    const SizedBox(width: 5),
                    SizedBox(
                      width: 100,
                      child: ElevatedButton(
                        onPressed: () => changeCategory("STATS"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedCategory == "STATS"
                              ? const Color.fromARGB(255, 104, 66, 255)
                              : Colors.white,
                          foregroundColor: selectedCategory == "STATS"
                              ? Colors.white
                              : const Color.fromARGB(255, 104, 66, 255),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                10.0), // Adjust the value for the desired roundness
                            side: const BorderSide(
                              color: Color.fromARGB(255, 104, 66,
                                  255), // Set the border color to purple
                              width: 2.0, // Adjust the border width as needed
                            ),
                          ),
                        ),
                        child: const Text("STATS"),
                      ),
                    ),
                  ],
                ),
              ),
              if (selectedCategory == "BMI") ...[
                if (showEmptyFieldError)
                  const Text(
                    'Please fill in all fields before calculating BMI.',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                const SizedBox(height: 20),
                Text(
                  'Your BMI: ${bmi.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Category: $bmiCategory',
                  style: TextStyle(
                    fontSize: 18,
                    color: getBMIScaleColor(),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  height: 30,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Colors.blue,
                        Colors.green,
                        Colors.orange,
                        Colors.red,
                      ],
                      stops: [0.0, 0.25, 0.5, 1.0],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Stack(
                    children: [
                      AnimatedPositioned(
                        left: (bmiMarkerPosition / 100) *
                            280, // Adjust to your needs
                        duration: const Duration(milliseconds: 500),
                        child: Container(
                          width: 5,
                          height: 30,
                          color: Colors.black,
                          child: const Center(
                            child: Text(
                              ' ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        'Underweight - 18.5',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        'Normal - 24.9',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        'Overweight - 29.9',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        'Obese - 30.0',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (selectedCategory == "HISTORY") ...[
                const SizedBox(height: 20),
                Container(
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(244, 244, 246, 1),
                  ),
                  height: 350,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 150),
                    itemCount: workouts.length,
                    itemBuilder: (context, index) {
                      final workout = workouts[index];
                      List<String> words = workout.name.split(' ');
                      String modifiedString = words.sublist(2).join(' ');
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          //    borderRadius: BorderRadius.circular(10),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              color: const Color.fromARGB(255, 104, 66, 255),
                              child: SizedBox(
                                height: 50,
                                width: 50,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 5),
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      Center(
                                        child: Text(
                                          workout.date.day.toString(),
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                      ),
                                      Center(
                                          child: Text(
                                        getMonthAbbreviation(workout.date),
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ))
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            modifiedString,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17),
                          ),
                          subtitle: Text(
                              'Time: ${"${formatTime(parseWorkoutTime(workout.time), true)} min"}',
                              style: const TextStyle(fontSize: 14)),
                        ),
                      );
                    },
                  ),
                )
              ],
              if (selectedCategory == "STATS") ...[
                const SizedBox(height: 20),
                const Text(
                  'BMI Graph Info:',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: FutureBuilder<List<BMIEntry>>(
                    future: getBMIEntriesFromMemory(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator(); // Show a loading indicator while fetching data
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text(
                            'No BMI entries available.'); // Handle the case when there are no entries
                      } else {
                        final bmiEntries = snapshot.data;

                        // Create a list of data points for the weight progress graph
                        final List<FlSpot> weightDataPoints = bmiEntries!
                            .map((entry) => FlSpot(
                                  bmiEntries
                                      .indexOf(entry)
                                      .toDouble(), // X-axis position
                                  double.parse((entry.bmi).toStringAsFixed(
                                      2)), // Y-axis position (weight)
                                ))
                            .toList();

                        // Customize the appearance of the graph
                        final LineChartBarData weightData = LineChartBarData(
                          spots: weightDataPoints,
                          isCurved: true,
                          color: const Color.fromARGB(255, 104, 66, 255),
                          belowBarData: BarAreaData(show: false),
                          dotData: FlDotData(
                            show: true, // Show value indicators
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 4,
                                color: const Color.fromARGB(255, 104, 66, 255),
                                strokeColor: Colors.white,
                                strokeWidth: 2,
                              );
                            },
                          ),
                          isStrokeCapRound: true,
                        );

                        // Create horizontal lines for BMI ranges
                        final List<HorizontalLine> horizontalLines = [
                          HorizontalLine(
                            y: 18.5,
                            label: HorizontalLineLabel(
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                              show: true,
                              labelResolver: (line) => 'Underweight - 18.5',
                            ),
                            color: Colors.grey,
                          ),
                          HorizontalLine(
                            y: 24.9,
                            label: HorizontalLineLabel(
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                              show: true,
                              labelResolver: (line) => 'Normal - 24.9',
                            ),
                            color: Colors.grey,
                          ),
                          HorizontalLine(
                            y: 29.9,
                            label: HorizontalLineLabel(
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                              show: true,
                              labelResolver: (line) => 'Overweight - 29.9',
                            ),
                            color: Colors.grey,
                          ),
                        ];

                        // Calculate maxYValue with increased spacing
                        double maxYValue = bmiEntries
                                .map((entry) => double.parse(
                                    (entry.bmi).toStringAsFixed(2)))
                                .reduce((a, b) => a > b ? a : b) +
                            20; // Increase the spacing to 20 (adjust as needed)

                        // Create ExtraLinesData object to hold the horizontal lines
                        final ExtraLinesData extraLinesData = ExtraLinesData(
                          horizontalLines: horizontalLines,
                        );
                        return SizedBox(
                          width: double.infinity,
                          height: 200,
                          child: LineChart(
                            LineChartData(
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                horizontalInterval: 5.0,
                                getDrawingHorizontalLine: (value) {
                                  return FlLine(
                                    color: Colors.grey.withOpacity(0.3),
                                    strokeWidth: 0.5,
                                  );
                                },
                              ),
                              titlesData: FlTitlesData(
                                  leftTitles: const AxisTitles(
                                    drawBelowEverything: false,
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true, // Show X-axis titles
                                      reservedSize: 22,
                                      getTitlesWidget: (value, titleMeta) {
                                        final index = value.toInt();
                                        if (index < 0 ||
                                            index >= bmiEntries.length) {
                                          return const SizedBox
                                              .shrink(); // Return an empty SizedBox if no title is needed
                                        }
                                        final entry = bmiEntries[index];
                                        final date = DateFormat('MMM d')
                                            .format(DateTime.parse(entry.date));

                                        // Create a Text widget to display the date
                                        return Text(
                                          date,
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 10,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  rightTitles: const AxisTitles(
                                    drawBelowEverything: false,
                                  ),
                                  topTitles: const AxisTitles(
                                      drawBelowEverything: false)),
                              borderData: FlBorderData(show: false),
                              minX: 0,
                              maxX: bmiEntries.length.toDouble() - 1,
                              minY: 0,
                              maxY: maxYValue,
                              lineBarsData: [
                                weightData,
                              ],
                              extraLinesData: extraLinesData,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
