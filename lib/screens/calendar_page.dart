import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:plan_workout/helpers.dart';
import 'package:plan_workout/main.dart';
import 'package:plan_workout/screens/share_page.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../blocs/workout_cubit.dart';
import '../home_page.dart';
import 'bmi_calculator.dart';

class WorkoutData {
  final String name;
  final DateTime date;
  final String id;
  final String time;

  WorkoutData({
    required this.id,
    required this.name,
    required this.date,
    required this.time,
  });
}

class CommonListItem {
  final String type; // "workout" or "bmi"
  final dynamic data;

  CommonListItem(this.type, this.data);
}

class CalendarPage extends StatefulWidget {
  final VoidCallback refreshCallback;
  const CalendarPage({Key? key, required this.refreshCallback})
      : super(key: key);

  @override
  CalendarPageState createState() => CalendarPageState();
}

class CalendarPageState extends State<CalendarPage> {
  late List<WorkoutData> workouts = [];
  late Map<DateTime, List<WorkoutData>> workoutEvents = {}; // Initialize here;
  DateTime? _selectedDate; // Track the selected date
  List<BMIEntry> bmiEntries = [];

  List<CommonListItem> commonItems = [];

  @override
  void initState() {
    super.initState();

    loadWorkouts();

    loadBMIEntries(); // Load BMI entries when the page is initialized.
  }

  int _selectedIndex = 1;

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

  Future<void> loadBMIEntries() async {
    final bmiList = await getBMIEntries();
    setState(() {
      bmiEntries = bmiList;
    });
  }

  Future<List<BMIEntry>> getBMIEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final bmiEntriesJson = prefs.getStringList('bmiEntries') ?? [];
    return bmiEntriesJson
        .map((json) => BMIEntry.fromJson(jsonDecode(json)))
        .toList();
  }

  Future<void> deleteBMIEntry(BMIEntry bmiEntry) async {
    final prefs = await SharedPreferences.getInstance();
    final bmiEntriesJson = prefs.getStringList('bmiEntries') ?? [];

    // Find and remove the entry with the same ID
    bmiEntriesJson.removeWhere((entryJson) {
      final entry = BMIEntry.fromJson(jsonDecode(entryJson));
      return entry.id == bmiEntry.id;
    });

    prefs.setStringList('bmiEntries', bmiEntriesJson);

    // Refresh the UI
    if (mounted) {
      setState(() {
        loadBMIEntries();
        commonItems
            .removeWhere((item) => item.type == "bmi" && item.data == bmiEntry);
      });
    }
  }

  bool hasSavedBMI(DateTime date) {
    final dateKey = DateTime(date.year, date.month, date.day);
    return bmiEntries.any((entry) {
      final entryDate = DateTime.parse(
          entry.date); // Assuming entry.date is a valid date string
      return entryDate.year == dateKey.year &&
          entryDate.month == dateKey.month &&
          entryDate.day == dateKey.day;
    });
  }

  bool hasSavedWorkouts(DateTime date) {
    final dateKey = DateTime(date.year, date.month, date.day);
    return workoutEvents.containsKey(dateKey) &&
        workoutEvents[dateKey]!.isNotEmpty;
  }

  Map<DateTime, List<WorkoutData>> getWorkoutEvents(
      List<WorkoutData> workouts) {
    final workoutEvents = <DateTime, List<WorkoutData>>{};

    for (var workout in workouts) {
      final date =
          DateTime(workout.date.year, workout.date.month, workout.date.day);
      if (workoutEvents.containsKey(date)) {
        workoutEvents[date]!.add(workout);
      } else {
        workoutEvents[date] = [workout];
      }
    }

    return workoutEvents;
  }

  void _onDaySelected(DateTime selectedDate, DateTime focusedDate) async {
    final workoutData = await showDialog<WorkoutData>(
      context: context,
      builder: (BuildContext context) {
        return MultiBlocProvider(
          providers: [
            // Add your other providers here if needed
            BlocProvider<WorkoutCubit>(
              create: (BuildContext context) => WorkoutCubit(),
            ),
          ],
          child: AddWorkoutDialog(
            selectedDate: selectedDate,
          ),
        );
      },
    );

    if (workoutData != null) {
      // Save the workout data to shared preferences.
      await saveWorkout(workoutData);

      // Update workoutEvents with the newly added workout
      final dateKey = DateTime(
        workoutData.date.year,
        workoutData.date.month,
        workoutData.date.day,
      );
      if (workoutEvents.containsKey(dateKey)) {
        workoutEvents[dateKey]!.add(workoutData);
      } else {
        workoutEvents[dateKey] = [workoutData];
      }
      final commonItem = CommonListItem("workout", workoutData);
      setState(() {
        loadWorkouts();
        commonItems.add(commonItem);
      });
    }
  }

  void _onDaySelected2(DateTime selectedDate, DateTime focusedDate) async {
    final selectedDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );

    setState(() {
      _selectedDate = selectedDateTime;
      // Merge workout events into the common list
      commonItems.clear();
      if (workoutEvents[_selectedDate!] != null) {
        for (var event in workoutEvents[_selectedDate!]!) {
          commonItems.add(CommonListItem("workout", event));
        }
      }

      final selectedBMIEntries = bmiEntries.where((entry) {
        final entryDate = DateTime.parse(
            entry.date); // Assuming entry.date is a valid date string
        return entryDate.year == _selectedDate!.year &&
            entryDate.month == _selectedDate!.month &&
            entryDate.day == _selectedDate!.day;
      }).toList();

// Merge BMI entries into the common list
      for (var bmiEntry in selectedBMIEntries) {
        commonItems.add(CommonListItem("bmi", bmiEntry));
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> _confirmDeleteBMI(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Delete BMI Entry'),
              content: const Text('Do you want to delete the BMI entry?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false); // Cancel deletion
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true); // Confirm deletion
                  },
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        ) ??
        false; // Return false if the dialog is dismissed
  }

  Future<void> _deleteBMIEntry(BMIEntry bmiEntry) async {
    await deleteBMIEntry(bmiEntry);
  }

  String formatBMIEntryInfo(BMIEntry bmiEntry) {
    return '''
    Date: ${bmiEntry.date}
    BMI: ${bmiEntry.bmi.toStringAsFixed(2)}
    Age: ${bmiEntry.age}
    Weight: ${bmiEntry.weight} kg
    Height: ${bmiEntry.height} cm
    Gender: ${bmiEntry.gender}
    Measurement System: ${bmiEntry.measurementSystem.name}
  ''';
  }

//
  String formatWorkOutDataEntryInfo(WorkoutData workoutData) {
    return 'Date: ${workoutData.date}\n'
        'Name: ${workoutData.name}\n'
        'Time: ${"${formatTime(parseWorkoutTime(workoutData.time), true)} min"}';
  }

  Widget buildAddPostDialog(BuildContext context, String text) {
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
                  'Entry Information', // Display a title
                  style: TextStyle(
                    fontSize: 18, // Increased font size for a modern look
                    fontWeight: FontWeight.bold,
                    color: Colors.blue, // Change the title text color
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16), // Increased spacing
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 14, // Increased font size for content
                    color: Colors.black87, // Change content text color
                  ),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 104, 66, 255),
        title: const Text('Calendar'),
        actions: <Widget>[
          Container(
            margin: const EdgeInsets.only(right: 8.0),
            width: 60,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue[400] ?? Colors.blue,
                  Colors.blue[400] ?? Colors.blue
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              shape: BoxShape.rectangle,
            ),
            child: const Stack(
              children: <Widget>[
                Center(
                  child: Text(
                    'Workouts',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white, // Text color
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8.0),
            width: 60,
            height: 40,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red, Colors.red],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              shape: BoxShape.rectangle,
            ),
            child: const Stack(
              children: <Widget>[
                Center(
                  child: Text(
                    'BMI',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white, // Text color
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Call the refreshCallback to refresh the HomePage
            FocusScope.of(context).unfocus();

            widget.refreshCallback();
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2010, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              focusedDay: _selectedDate ?? DateTime.now(),
              availableCalendarFormats: const {CalendarFormat.month: 'Month'},
              onPageChanged: (focusedDate) {
                if (_selectedDate != null) {
                  // Only update the focusedDate when _selectedDate is set
                  focusedDate = _selectedDate!;
                }
              },
              calendarFormat: CalendarFormat.month,
              eventLoader: (date) => workoutEvents[date] ?? [],
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  if (events.isNotEmpty ||
                      (hasSavedBMI(date) && !hasSavedWorkouts(date))) {
                    return _buildEventMarker(2);
                  } else if (events.isNotEmpty ||
                      (!hasSavedBMI(date) && hasSavedWorkouts(date))) {
                    return _buildEventMarker(1);
                  } else if (events.isNotEmpty ||
                      (hasSavedBMI(date) && hasSavedWorkouts(date))) {
                    return _buildEventMarker(3);
                  }
                  return const SizedBox.shrink();
                },
              ),

              onDayLongPressed: _onDaySelected,

              onDaySelected: _onDaySelected2, // Call when a date is selected
              selectedDayPredicate: (day) {
                return _selectedDate != null
                    ? isSameDay(_selectedDate!, day)
                    : false;
              },
            ),
            const Divider(
              color: Colors.black26,
            ),
            _selectedDate != null
                ? Column(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 300,
                            child: ListView.builder(
                              padding: const EdgeInsets.only(bottom: 100),
                              physics: const AlwaysScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: commonItems.length,
                              itemBuilder: (context, index) {
                                final item = commonItems[index];

                                if (item.type == "workout") {
                                  final event = item.data as WorkoutData;
                                  return Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Dismissible(
                                      key: UniqueKey(),
                                      direction: DismissDirection.endToStart,
                                      background: Container(
                                        alignment: Alignment.centerRight,
                                        color: Colors.red,
                                        padding:
                                            const EdgeInsets.only(right: 16.0),
                                        child: const Icon(
                                          Icons.delete,
                                          color: Colors.white,
                                        ),
                                      ),
                                      confirmDismiss: (direction) async {
                                        return await _confirmDelete(context);
                                      },
                                      onDismissed: (direction) async {
                                        await _deleteWorkout(event);
                                      },
                                      child: ListTile(
                                        leading: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Container(
                                            color: Colors.blue,
                                            child: const SizedBox(
                                              height: 50,
                                              width: 50,
                                              child: Padding(
                                                padding:
                                                    EdgeInsets.only(bottom: 5),
                                                child: Column(
                                                  children: [
                                                    SizedBox(
                                                      height: 8,
                                                    ),
                                                    Center(
                                                        child: Icon(Icons
                                                            .directions_run)),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        title: Text(event.name),
                                        subtitle: Text(
                                          DateFormat('yyyy-MM-dd hh:mm a')
                                              .format(event.date),
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        trailing: GestureDetector(
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return buildAddPostDialog(
                                                      context,
                                                      formatWorkOutDataEntryInfo(
                                                          event)); // Call the function to build the dialog //event
                                                },
                                              );
                                            },
                                            child:
                                                const Icon(Icons.drag_handle)),
                                      ),
                                    ),
                                  );
                                } else if (item.type == "bmi") {
                                  final bmiEntry = item.data as BMIEntry;
                                  return Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Dismissible(
                                      key: UniqueKey(), // Use a unique key
                                      direction: DismissDirection.endToStart,
                                      background: Container(
                                        alignment: Alignment.centerRight,
                                        color: Colors.red,
                                        padding:
                                            const EdgeInsets.only(right: 16.0),
                                        child: const Icon(
                                          Icons.delete,
                                          color: Colors.white,
                                        ),
                                      ),
                                      confirmDismiss: (direction) async {
                                        return await _confirmDeleteBMI(context);
                                      },
                                      onDismissed: (direction) async {
                                        await _deleteBMIEntry(bmiEntry);
                                      },
                                      child: ListTile(
                                        leading: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Container(
                                            color: Colors.red,
                                            child: const SizedBox(
                                              height: 50,
                                              width: 50,
                                              child: Padding(
                                                padding:
                                                    EdgeInsets.only(bottom: 5),
                                                child: Column(
                                                  children: [
                                                    SizedBox(
                                                      height: 8,
                                                    ),
                                                    Center(
                                                        child: Icon(
                                                            Icons.auto_graph)),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        title: Text(
                                            'BMI: ${bmiEntry.bmi.toStringAsFixed(2)}'),
                                        subtitle: Text(
                                          'Age: ${bmiEntry.age}, Gender: ${bmiEntry.gender}',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        trailing: GestureDetector(
                                            onTap: () {
                                              final formattedInfo =
                                                  formatBMIEntryInfo(
                                                      bmiEntry); // Format the BMI entry info
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return buildAddPostDialog(
                                                      context,
                                                      formattedInfo); // Call the function to build the dialog
                                                },
                                              );
                                            },
                                            child:
                                                const Icon(Icons.drag_handle)),
                                      ),
                                    ),
                                  );
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Widget _buildEventMarker(int choice) {
    LinearGradient gradient;

    if (choice == 1) {
      gradient = LinearGradient(
        colors: [
          Colors.blue[400] ?? Colors.blue,
          Colors.blue[400] ?? Colors.blue
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    } else if (choice == 2) {
      gradient = const LinearGradient(
        colors: [Colors.red, Colors.red],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    } else if (choice == 3) {
      gradient = LinearGradient(
        colors: [Colors.blue[400] ?? Colors.blue, Colors.red],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    } else {
      gradient = LinearGradient(
        colors: [
          Colors.blue[400] ?? Colors.blue,
          Colors.blue[400] ?? Colors.blue
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ); // Default gradient
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        gradient: gradient,
      ),
      width: 16.0,
      height: 16.0,
    );
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

  Future<void> loadWorkouts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final workoutKeys =
          prefs.getKeys().where((key) => key.startsWith('workout_')).toList();
      final List<WorkoutData> loadedWorkouts = [];

      for (var key in workoutKeys) {
        final workoutData = prefs.getString(key);
        if (workoutData != null) {
          final parts = workoutData.split(' - ');
          if (parts.length == 3) {
            // Assuming time is the third part
            final workoutName = parts[0];
            final workoutDate = DateTime.tryParse(parts[1]);
            final workoutTime = parts[2]; // Extract the time
            if (workoutDate != null) {
              final id = key; // Use the key as the ID
              loadedWorkouts.add(
                WorkoutData(
                  id: id,
                  name: workoutName,
                  date: workoutDate,
                  time: workoutTime,
                ), // Include time
              );
            }
          }
        }
      }

      setState(() {
        workouts = loadedWorkouts;
        workoutEvents = getWorkoutEvents(workouts);
      });
    } catch (e) {
      // ignore: avoid_print
      print('Error loading workouts: $e');
    }
  }

  Future<void> _deleteWorkout(WorkoutData workout) async {
    // Remove the workout from the data structures
    workouts.remove(workout);

    final date =
        DateTime(workout.date.year, workout.date.month, workout.date.day);

    if (workoutEvents.containsKey(date)) {
      // Check if workoutEvents[date] is not null
      if (workoutEvents[date] != null) {
        workoutEvents[date]!.remove(workout);

        if (workoutEvents[date]!.isEmpty) {
          workoutEvents.remove(date);
        }
      }
    }

    // Delete the workout from shared preferences using its id
    await deleteWorkout(workout.id);

    // Refresh the calendar
    if (mounted) {
      setState(() {
        // Check if workoutEvents[date] is not null
        if (workoutEvents[date] != null) {
          workoutEvents[date] =
              workoutEvents[date]!.where((w) => w != workout).toList();
        }

        commonItems.removeWhere(
            (item) => item.type == "workout" && item.data == workout);
      });
    }
  }

  Future<void> deleteWorkout(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final workoutKey = id;
    await prefs.remove(workoutKey);

    // Reload the workouts and refresh the calendar

    if (mounted) {
      setState(() {
        loadWorkouts();
      });
    }
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Delete Workout'),
              content: const Text('Do you want to delete the workout?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false); // Cancel deletion
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true); // Confirm deletion
                  },
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        ) ??
        false; // Return false if the dialog is dismissed
  }
}

class AddWorkoutDialog extends StatefulWidget {
  final DateTime selectedDate;

  const AddWorkoutDialog({Key? key, required this.selectedDate})
      : super(key: key);

  @override
  AddWorkoutDialogState createState() => AddWorkoutDialogState();
}

class AddWorkoutDialogState extends State<AddWorkoutDialog> {
  TimeOfDay? _selectedTime;
  bool _isCompleted = false;

  List<WorkoutInfo> availableWorkoutInfos = [];
  String? selectedWorkoutTitle;
  String? selectedWorkoutTime;

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedTime = TimeOfDay.now();
    _loadAvailableWorkoutTitles();
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime!,
    );

    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  Future<void> _loadAvailableWorkoutTitles() async {
    final cubit = context.read<WorkoutCubit>();
    final List<WorkoutInfo> workoutInfos =
        await cubit.getAvailableWorkoutTitles();
    setState(() {
      availableWorkoutInfos = workoutInfos;
    });
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

  List<WorkoutInfo> searchWorkoutTitles(String query) {
    return availableWorkoutInfos
        .where((workout) =>
            workout.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Add Workout for ${DateFormat('dd.MM.yyyy').format(widget.selectedDate.toLocal())}',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Text(
                  'Workout Title: ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: TextField(
                    onTap: () {
                      setState(() {
                        selectedWorkoutTitle =
                            null; // Clear selected workout when the text field is tapped.
                        // Show the search list.
                      });
                    },
                    controller: searchController,
                    onChanged: (query) {
                      setState(() {});
                    },
                    decoration: const InputDecoration(
                        hintText: 'Search for a workout',
                        hintStyle: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (selectedWorkoutTitle == null)
              Column(
                children: searchWorkoutTitles(searchController.text)
                    .map(
                      (workout) => ListTile(
                        title: Text(workout.title),
                        onTap: () {
                          setState(() {
                            selectedWorkoutTitle = workout.title;
                            selectedWorkoutTime =
                                getWorkoutTimeForTitle(workout.title);
                            searchController.clear();
                          });
                        },
                      ),
                    )
                    .toList(),
              ),
            if (selectedWorkoutTitle != null)
              Text(
                'Selected Workout: $selectedWorkoutTitle',
                style: const TextStyle(
                  fontSize: 12,
                ),
              ),
            Row(
              children: <Widget>[
                const Text('Workout Time:'),
                TextButton(
                  onPressed: () => _selectTime(context),
                  child: Text(
                    _selectedTime!.format(context),
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Checkbox(
                  value: _isCompleted,
                  onChanged: (value) {
                    setState(() {
                      _isCompleted = value ?? false;
                    });
                  },
                ),
                const Text('Completed'),
              ],
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog.
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final workoutName = selectedWorkoutTitle;

            if (workoutName!.isNotEmpty && _selectedTime != null) {
              DateTime selectedDateTime = DateTime(
                widget.selectedDate.year,
                widget.selectedDate.month,
                widget.selectedDate.day,
                _selectedTime!.hour,
                _selectedTime!.minute,
              );

              final workoutData = WorkoutData(
                  id: generateRandomId(),
                  name:
                      "${_isCompleted ? 'Completed' : 'Planned'} Workout: $workoutName",
                  date: selectedDateTime,
                  time: getWorkoutTimeForTitle(workoutName)!);
              Navigator.of(context)
                  .pop(workoutData); // Close the dialog and pass workout data.

              if (!_isCompleted) {
                final now = DateTime.now();
                final timeDifferenceInSeconds =
                    selectedDateTime.difference(now).inSeconds;

                // Schedule a background task to notify the user after the specified delay.
                startBackgroundTask2(timeDifferenceInSeconds,
                    "You have workout now!,  $workoutName");
              }
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
