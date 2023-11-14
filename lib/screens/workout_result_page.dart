import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../helpers.dart';
import '../home_page.dart';

class WorkoutResultPage extends StatelessWidget {
  final int totalTime; // The total time in seconds the workout took

  const WorkoutResultPage({super.key, required this.totalTime});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 104, 66, 255),
        title: const Text('Workout Result'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animation_cong.json',
              width: 200,
              height: 200,
              fit: BoxFit.fill,
              repeat: false,
            ),
            const Text(
              'Workout Completed!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              'Total Time: ${formatTime(totalTime, true)}', // Use your time formatting function
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () {
                Get.to(() => const HomePage());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.blue, // Change the button's background color
                foregroundColor: Colors.white, // Change the text color
                elevation: 3, // Add a slight shadow
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Rounded corners
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                  "Go Home",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold, // Use a bold font weight
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
