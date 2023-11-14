import 'dart:math';

import 'package:flutter/material.dart';

String formatTime(int seconds, bool pad) {
  return (pad)
      ? "${(seconds / 60).floor()}:${(seconds % 60).toString().padLeft(2, "0")}"
      : (seconds > 59)
          ? "${(seconds / 60).floor()}:${(seconds % 60).toString().padLeft(2, "0")}"
          : seconds.toString();
}

int calculateDelay(TimeOfDay selectedTime) {
  final now = DateTime.now();
  final selectedDateTime = DateTime(
    now.year,
    now.month,
    now.day,
    selectedTime.hour,
    selectedTime.minute,
  );

  // Calculate the time difference in seconds
  final timeDifference = selectedDateTime.isBefore(now)
      ? selectedDateTime.add(const Duration(days: 1)).difference(now)
      : selectedDateTime.difference(now);

  return timeDifference.inSeconds;
}

int parseWorkoutTime(String time) {
  final RegExp regex = RegExp(r'\d+'); // Match one or more digits
  final RegExpMatch? match = regex.firstMatch(time);

  if (match != null) {
    final String? timeStr = match.group(0);
    return int.parse(timeStr!);
  } else {
    // Handle the case where no numeric value is found in the string.
    return 0; // You can provide a default value.
  }
}

String replaceUnderscoresWithSpaces(String input) {
  return input.replaceAll('_', ' ');
}

// Function to generate a unique workout ID (you can use a UUID library)
String generateUniqueWorkoutId() {
  // Implement your unique ID generation logic here
  // For simplicity, you can use a combination of timestamp and random number
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final randomNumber = Random().nextInt(10000);
  return '$timestamp$randomNumber';
}

String generateRandomId() {
  // Generate a random number using the Random class.
  final random = Random();
  final randomNumber =
      random.nextInt(999999); // You can adjust the range as needed.

  // Get the current timestamp (milliseconds since epoch).
  final timestamp = DateTime.now().millisecondsSinceEpoch;

  // Combine the timestamp and random number to create a unique ID.
  final uniqueId = '$timestamp$randomNumber';

  return uniqueId;
}

String timeAgo(DateTime timestamp) {
  final now = DateTime.now();
  final difference = now.difference(timestamp);

  if (difference.inSeconds < 60) {
    return "${difference.inSeconds} seconds ago";
  } else if (difference.inMinutes < 60) {
    return "${difference.inMinutes} minutes ago";
  } else if (difference.inHours < 24) {
    return "${difference.inHours} hours ago";
  } else if (difference.inDays < 30) {
    return "${difference.inDays} days ago";
  } else if (difference.inDays < 365) {
    final months = difference.inDays ~/ 30;
    return "$months months ago";
  } else {
    final years = difference.inDays ~/ 365;
    return "$years years ago";
  }
}

List<String> tips = [
  // Exercise Tips
  "Maintain proper form for maximum results.",
  "Stay consistent with your workout routine.",
  "Challenge yourself with progressive overload.",
  "Incorporate both cardio and strength training.",
  "Listen to your body and rest when needed.",
  "Set achievable fitness goals for motivation.",
  "Variety is key; switch up your exercises.",
  "Warm up before each workout to prevent injuries.",
  "Focus on compound exercises for efficiency.",
  "Don't forget to cool down and stretch after.",

  // More Exercise Tips
  "Use a fitness tracker to monitor progress.",
  "Get a workout buddy for accountability.",
  "Try a new fitness class or sport for fun.",
  "Modify exercises to suit your fitness level.",
  "Practice mindfulness during your workouts.",
  "Include balance and flexibility exercises.",
  "Mix up your training with HIIT workouts.",
  "Don't neglect core and stability training.",
  "Set rest days to aid muscle recovery.",
  "Invest in quality workout gear and shoes.",

  // Nutrition Tips
  "Balance your plate with protein, carbs, and fats.",
  "Stay hydrated throughout the day.",
  "Eat whole, unprocessed foods for nutrients.",
  "Portion control is crucial for weight management.",
  "Include a variety of fruits and vegetables.",
  "Don't skip breakfast; it jumpstarts your day.",
  "Limit sugar and unhealthy snacking.",
  "Plan meals and snacks for better choices.",
  "Eat mindfully; savor each bite and enjoy food.",
  "Protein-rich snacks aid muscle recovery.",

  // More Nutrition Tips
  "Read food labels to make informed choices.",
  "Cook meals at home for healthier options.",
  "Limit alcohol and sugary beverage intake.",
  "Stay aware of hidden trans fats in food.",
  "Consume healthy fats like avocados and nuts.",
  "Don't skip post-workout nutrition; refuel.",
  "Fiber is essential for digestive health.",
  "Stay consistent with meal timing.",
  "Limit processed and fast food consumption.",
  "Stay accountable with a food journal.",

  // Motivational Quotes
  "The only bad workout is the one that didn't happen.",
  "Success starts with self-discipline.",
  "Your body can stand almost anything; it's your mind you have to convince.",
  "Believe in yourself and all that you are.",
  "The harder you work, the luckier you get.",
  "Every step is progress.",
  "Great things never came from comfort zones.",
  "Fitness is not about being better than someone else; it's about being better than you used to be.",
  "Your health is an investment, not an expense.",
  "Sweat, smile, repeat.",

  // More Motivational Quotes
  "Strive for progress, not perfection.",
  "Don't watch the clock; do what it does. Keep going.",
  "The pain you feel today is the strength you'll feel tomorrow.",
  "You don't have to be great to start, but you have to start to be great.",
  "Fitness is a journey, not a destination.",
  "When you feel like quitting, think about why you started.",
  "The only limit is the one you set yourself.",
  "Small daily improvements lead to significant results.",
  "Your body achieves what your mind believes.",
  "Success is not final; failure is not fatal: it's the courage to continue that counts.",

  // Fitness Facts
  "Muscles burn more calories at rest than fat.",
  "Regular exercise reduces the risk of chronic diseases.",
  "It takes 21 days to build a habit.",
  "The heart is the strongest muscle in the body.",
  "Exercise increases the release of endorphins.",
  "You're burning calories even when you sleep.",
  "Fitness can improve mental clarity and focus.",
  "Consistency is the key to success.",
  "Exercise can boost your immune system.",
  "Stretching improves flexibility and reduces injury risk.",

  // More Fitness Facts
  "Proper nutrition fuels your workouts.",
  "Cardio exercise is great for heart health.",
  "Strength training helps maintain bone density.",
  "Exercise reduces the risk of depression.",
  "Staying active can increase your lifespan.",
  "High-intensity workouts torch calories quickly.",
  "Regular physical activity improves sleep quality.",
  "Endurance workouts build stamina and endurance.",
  "Exercise increases your overall energy levels.",
  "The benefits of exercise extend to mental health."
];

List<String> savedWorkouts = [
  "Custom",
  'Barbell_Bench_Press',
  'Barbell_Bent_Over',
  'Barbell_Decline_Bench',
  'Barbell_Front_Raise',
  'Barbell_Incline_Bench_Press',
  'Barbell_Seated_Behind',
  'Barbell_Straight_Leg',
  'Barbell_Underhand',
  'Barbell_Underhand_2',
  'Barbell_Upright_Row',
  'Barebell_Bent_Over_Row',
  'Barebell_Curl',
  'Barebell_Decline_Bench_Press',
  'Barebell_Drag_Curl',
  'Barebell_Incline_Bench_Press',
  'Barebell_Lungs',
  'Barebell_Prone_Incline_Curl',
  'Barebell_Seated_Behind_Head_Military_Press',
  'Barebell_Straight_Leg_Deadlift',
  'Barebell_Underhand_Bent_Over_Row',
  'Cable_Bar_Lateral',
  'Cable_Bsr_Lateral_Pulldown',
  'Cable_Bsr_Lateral_Pull-Down',
  'Cable_Bsr_Pull-Down',
  'Cable_Crossover_Reverse',
  'Cable_Crossover_Reverse_Fly',
  'Cable_Front_Raise',
  'Cable_Front_Raise_2',
  'Cable_Lateral_Raise',
  'Cable_Lateral_Raise_3',
  'Cable_Lying_Fly_Flat_Bench_Cable_Fly',
  'Cable_One_Arm_Curl',
  'Cable_One_Arm_Forward_Raise',
  'Cable_One_Arm_Forwardf',
  'Cable_One_Arm_Latera',
  'Cable_One_Arm_Latera_2',
  'Cable_One_Arm_Latera_3',
  'Cable_One_Arm_Lateral_Pull-Down',
  'Cable_One_Arm_Lateral_Raise',
  'Cable_One_Arm_Twisting_Seated_Row',
  'Cable_Pulldown',
  'Cable_Pull-Down',
  'Cable_Pull-Downs',
  'Cable_Rear_Delt_Row',
  'Cable_Rear_Delt_Row_With_Rope',
  'Cable_Seated_High_Ro',
  'Cable_Seated_High_Row',
  'Cable_Seated_Row',
  'Cable_Seated_Row_2',
  'Cable_Seated_Row_Normal_Grip',
  'Cable_Seated_Row_Parallel_Grip',
  'Cable_Standing__Fly',
  'Cable_Standing_Fly_2',
  'Cable_Standing_Fly_Crossover_Fly',
  'Cable_Standing_Inner_Curl',
  'Cable_Straight_Arm',
  'Cable_Straight_Arm_Pull-Down',
  'Cable_Straight_Back',
  'Cable_Straight_Back_Seated_Row',
  'Cambered_Bar_Lying_Row',
  'Chest_Dips',
  'Chest_Dips_2',
  'Chest_Dips_3',
  'Chest_Dips_4',
  'Chin-_Ups_Narrow_Parallel_Grip',
  'Chin-Up_Or_Pull-Ups',
  'Chin-Ups',
  'Chin-Ups__Pull-Ups',
  'Commando_Pull-_Up',
  'Decline_Barbell_Bench_Press',
  'Decline_Dumbbell_Ben',
  'Decline_Dumbbell_Bench_Press_45_Degree',
  'Deep_Push_-_Ups',
  'Dumbbell_Alternate',
  'Dumbbell_Alternate_Biceps_Curl',
  'Dumbbell_Alternate_Shoulder_Press',
  'Dumbbell_Arnold_Press',
  'Dumbbell_Arnold_Press_2',
  'Dumbbell_Bench_Fly',
  'Dumbbell_Bench_Press',
  'Dumbbell_Bench_Press_2',
  'Dumbbell_Bench_Press_3',
  'Dumbbell_Bench_Seated',
  'Dumbbell_Bench_Seated_Press',
  'Dumbbell_Bent_-_Over_Row',
  'Dumbbell_Bent-Over_Gym',
  'Dumbbell_Biceps_Curl',
  'Dumbbell_Concentration_Curl',
  'Dumbbell_Cross_Body_Hammer_Curl',
  'Dumbbell_Deadlift',
  'Dumbbell_Decline_Fly',
  'Dumbbell_Decline_Fly_45_Degree',
  'Dumbbell_Fly',
  'Dumbbell_Front_Raise',
  'Dumbbell_Front_Raise_2',
  'Dumbbell_Incline_Bench_Press',
  'Dumbbell_Incline_Biceps_Curl',
  'Dumbbell_Incline_Fly',
  'Dumbbell_Incline_Fly_2',
  'Dumbbell_Incline_Hammer_Curl',
  'Dumbbell_Incline_Row',
  'Dumbbell_Incline_Row_2',
  'Dumbbell_Iron_Cross',
  'Dumbbell_Iron_Cross_2',
  'Dumbbell_Lateral_Rai',
  'Dumbbell_Lateral_Raise',
  'Dumbbell_Lying_Hammer_Press',
  'Dumbbell_Rear_Delt',
  'Dumbbell_Rear_Delt_Row',
  'Dumbbell_Rear_Delt_Roww',
  'Dumbbell_Rear_Latera',
  'Dumbbell_Rear_Lateral_Raise',
  'Dumbbell_Seated_Lateral_Raise',
  'Dumbbell_Seated_Preacher_Curl',
  'Dumbbell_Single_Leg_Squat',
  'Dumbell_Lunge',
  'Dumbell_Stiff_Leg_Deadlift',
  'Ez_Barbell_Anti_Gravity',
  'Ez_Barbell_Anti_Gravity_Press',
  'Ez_Barebell_Curl',
  'Incline_Push_-_Ups',
  'Lever_-_T_Bar_Row',
  'Lever_Back_Extension',
  'Lever_Back_Extension_2',
  'Lever_Chest_Press',
  'Lever_High_Row',
  'Lever_High_Row__3',
  'Lever_High_Row_2',
  'Lever_Horizontal_Leg_Press',
  'Lever_Incline_Hammer_Chest_Press',
  'Lever_Incline_Hammer_Chest_Press_2',
  'Lever_Kneeling_Leg_Curl',
  'Lever_Lateral_Raise',
  'Lever_Lateral_Raise_2',
  'Lever_Leg_Extension',
  'Lever_Lying_Chest',
  'Lever_Lying_Chest__Press',
  'Lever_Lying_Chest_Press_2',
  'Lever_Lying_Chest_Press_3',
  'Lever_Military_Press',
  'Lever_Military_Press_2',
  'Lever_Pec_Deck_Fly',
  'Lever_Preacher_Curl',
  'Lever_Reverse_Hypere',
  'Lever_Reverse_T_Bar_Row',
  'Lever_Seated_Reverse',
  'Lever_Seated_Reverse_Fly',
  'Lever_Standing_Hip_Extension',
  'Lever_Standing_Hip_Extensionn',
  'Lever_Standing_Rear_Kick',
  'Lever_T-Bar_Row',
  'Lever_T-Bar_Row_2',
  'Lever_Teverse_Hyperextension',
  'Lying_Supine_Dumbbell_Curl',
  'Military_Press',
  'Military_Press_2',
  'Pull_Up',
  'Pull_Up_2',
  'Push_Ups',
  'Push_Ups_Weights',
  'Reverse_Grip_Machine',
  'Reverse_Grip_Machine_Lat_Pull_Down',
  'Smith_Deadlift',
  'Smith_Deadlift_2',
  'Smith_Seated_Shoulder',
  'Smith_Seated_Shoulder_Press',
  'Streaching_Hamstring_Stretch',
  'Streaching_Middle_Back_Stretch',
  'Streaching-_Spine_Stretch',
  'Streaching-Kneeling_Lst_Stretch',
  'Streaching-Seated_Lower_Back_Stretch',
  'Streaching-Spine_Stretch_Forward',
  'Streaching-Standing_Back_Rotation_Streach',
  'Stretching_-_Above_Head',
  'Stretching_-_Back',
  'Stretching_-_Back_Pec_Stretch',
  'Stretching_-_Band',
  'Stretching_-_Butterfly_Yoga_Pose',
  'Stretching_-_Dynamic',
  'Stretching_-_Dynamic_2',
  'Stretching_-_Elbows',
  'Stretching_-_Kneelin',
  'Stretching_-_Kneelin_2',
  'Stretching_-_Middle',
  'Stretching_-_Rear',
  'Stretching_-_Seated',
  'Stretching_-_Seated_2',
  'Stretching_-_Seated_3',
  'Stretching_-_Sitting',
  'Stretching_-_Slopes',
  'Stretching_-_Spine',
  'Stretching_-_Standin',
  'Stretching_-_Standin_2',
  'Stretching_-_Standin_3',
  'Stretching_-_Standin_4',
  'Stretching_-_Standing_Wheel_Rollout',
  'Stretching-_Above_Head_Chest_Stretch',
  'Stretching-_Band_Warm-Up_Shoulder_Stretch',
  'Stretching-_Dynamiy_Chest_Stretch',
  'Stretching-_Elbows_Back_Stretch',
  'Stretching-_Kneeling_Back_Rotation_Streach',
  'Stretching-_Rear_Deltoid_Stretch',
  'Stretching-_Standing_Lateral_Streach',
  'Stretching-_Standing_Reach_Up_Back_Rotation',
  'Stretching-Dynamic_Back_Stretch',
  'Stretching-Seated_Should_Flexour_Depressor_Retract',
  'Wide_Grip_Push-_Ups',
  'Wide_Grip_Push-Ups',
  'Widegrip_Push_Ups',
];

class WorkoutTips {
  String name;
  String howTo;
  String tips;

  WorkoutTips(this.name, this.howTo, this.tips);
}

List<WorkoutTips> savedWorkoutsTips = [
  WorkoutTips(
    'Custom',
    'Create your own custom workout tailored to your goals and preferences.',
    'Custom workouts can be highly effective because they are personalized to your specific needs.',
  ),
  WorkoutTips(
    'Barbell_Bench_Press',
    'Lie on a flat bench and grip the barbell slightly wider than shoulder-width.',
    'Keep your feet flat on the floor for stability. Arch your back slightly and engage your chest muscles.',
  ),
  WorkoutTips(
    'Barbell_Bent_Over',
    'Stand with your feet shoulder-width apart, bend at the hips, and grasp the barbell with a shoulder-width grip.',
    'Maintain a straight back and avoid using your lower back to lift the weight. Focus on squeezing your shoulder blades together.',
  ),
  WorkoutTips(
    'Barebell_Bent_Over_Row',
    'Stand with your feet shoulder-width apart, bend at the hips, and grasp the barbell with a shoulder-width grip.',
    'Maintain a straight back and avoid using your lower back to lift the weight. Focus on squeezing your shoulder blades together.',
  ),
  WorkoutTips(
    'Barbell_Decline_Bench',
    'Lie on a decline bench, grip the barbell, and press it up. This targets the lower chest.',
    'Ensure the bench is properly set at a decline angle. Use a spotter if lifting heavy weights.',
  ),
  WorkoutTips(
    'Barbell_Front_Raise',
    'Stand with your feet shoulder-width apart and hold the barbell in front of your thighs.',
    'Keep your arms slightly bent and avoid using momentum to lift the barbell. Focus on your shoulder muscles.',
  ),
  WorkoutTips(
    'Barbell_Incline_Bench_Press',
    'Lie on an inclined bench, grip the barbell, and press it up. This targets the upper chest.',
    'Ensure the bench is set at an appropriate incline angle. Maintain a stable and controlled motion.',
  ),
  WorkoutTips(
    'Barbell_Seated_Behind',
    'Sit on a bench with back support, hold the barbell behind your neck, and press it overhead. This exercise targets the shoulders.',
    'Use a spotter to assist with heavy weights. Be cautious with this exercise to avoid straining your neck or shoulders.',
  ),
  WorkoutTips(
    'Barbell_Straight_Leg',
    'Stand with your feet hip-width apart, bend at the hips, and grip the barbell with an overhand grip.',
    'Keep your back flat and legs straight. Avoid rounding your back to prevent injury.',
  ),
  WorkoutTips(
    'Barbell_Underhand',
    'Similar to the Barbell Bent Over Row, but use an underhand (supinated) grip. This targets the upper back and biceps.',
    'Maintain proper form and control throughout the exercise.',
  ),
  WorkoutTips(
    'Barbell_Underhand_2',
    'Similar to the Barbell Bent Over Row, but use an underhand (supinated) grip. This targets the upper back and biceps.',
    'Maintain proper form and control throughout the exercise.',
  ),
  WorkoutTips(
    'Barbell_Upright_Row',
    'Stand with your feet hip-width apart, hold the barbell with an overhand grip, and lift it to chin level. This exercise targets the shoulders and upper traps.',
    'Use a shoulder-width grip and keep your elbows high.',
  ),
  WorkoutTips(
    'Barebell_Curl',
    'Stand with your feet shoulder-width apart and curl the barbell toward your chest. This targets the biceps.',
    'Keep your back straight and elbows close to your body. Use controlled, deliberate motions.',
  ),
  WorkoutTips(
    'Barebell_Drag_Curl',
    'Similar to the Barbell Curl but with the barbell brushing against your torso. Focus on the biceps.',
    'Keep the barbell close to your body throughout the movement.',
  ),
  WorkoutTips(
    'Barebell_Lungs',
    'Hold the barbell on your back, step forward, and lunge down. This exercise works the legs and glutes.',
    'Keep your back straight and take controlled steps. Use proper balance and stability.',
  ),
  WorkoutTips(
    'Barebell_Prone_Incline_Curl',
    'Similar to a regular Barbell Curl but performed on an incline bench. Targets the biceps.',
    'Adjust the bench angle to target different parts of the biceps.',
  ),
  WorkoutTips(
    'Barebell_Seated_Behind_Head_Military_Press',
    'Similar to the Seated Behind-Neck Press but with a wider grip. Be cautious to avoid strain on your shoulders.',
    '',
  ),
  WorkoutTips(
    'Barebell_Underhand_Bent_Over_Row',
    'Similar to the Barbell Bent Over Row but with an underhand grip. Targets the upper back and biceps.',
    'Maintain proper form and control.',
  ),
  WorkoutTips(
    'Barebell_Decline_Bench_Press',
    'Lie on a decline bench, grip the barbell, and press it up. This targets the lower chest.',
    'Ensure the bench is properly set at a decline angle. Use a spotter if lifting heavy weights.',
  ),
  WorkoutTips(
    'Barebell_Incline_Bench_Press',
    'Lie on an inclined bench, grip the barbell, and press it up. This targets the upper chest.',
    'Ensure the bench is set at an appropriate incline angle. Maintain a stable and controlled motion.',
  ),
  WorkoutTips(
    'Barebell_Straight_Leg_Deadlift',
    'Stand with your feet hip-width apart, bend at the hips, and grip the barbell with an overhand grip.',
    'Keep your back flat and legs straight. Avoid rounding your back to prevent injury.',
  ),

  ///
  WorkoutTips(
    'Cable_Bar_Lateral',
    'The Cable Bar Lateral exercise is a great way to target your lateral deltoids (shoulder muscles). It involves using a cable machine with a low pulley and a straight bar attachment.',
    'Tips for the exercise:\n1. Attach a straight bar to the low pulley of the cable machine.\n2. Stand facing the machine with your feet shoulder-width apart.\n3. Grasp the bar with an overhand grip and keep your arms fully extended.\n4. Lift the bar by raising your arms to the sides, keeping a slight bend in your elbows.\n5. Squeeze your shoulder blades together at the top of the movement for maximum contraction.\n6. Lower the bar in a controlled manner and repeat for the desired number of reps.',
  ),
  WorkoutTips(
    'Cable_Bsr_Lateral_Pulldown',
    'The Cable Bsr Lateral Pulldown is an exercise that targets the muscles of the back, specifically the lats. Its performed using a cable machine with a straight bar attachment.',
    'Tips for the exercise:\n1. Attach a straight bar to the cable machines high pulley.\n2. Sit down on the machines seat and place your knees securely under the pads.\n3. Grab the bar with a wider-than-shoulder-width grip, palms facing forward.\n4. Pull the bar down to your upper chest while arching your back slightly.\n5. Squeeze your lats at the bottom of the movement.\n6. Slowly release the bar to the starting position and repeat.\n7. Keep your core engaged and maintain good posture throughout the exercise.',
  ),
  WorkoutTips(
    'Cable_Bsr_Lateral_Pull-Down',
    'The Cable Bsr Lateral Pull-Down is an effective back exercise that targets the lats and other upper back muscles. Its performed using a cable machine with a straight bar attachment.',
    'Tips for the exercise:\n1. Attach a straight bar to the high pulley of the cable machine.\n2. Sit down on the machines seat and secure your knees under the pads.\n3. Grab the bar with a wide, overhand grip.\n4. Pull the bar down to your upper chest, keeping your back slightly arched.\n5. Squeeze your lats and upper back muscles at the bottom of the movement.\n6. Slowly release the bar to the starting position and repeat.\n7. Maintain proper posture and core engagement throughout the exercise.',
  ),
  WorkoutTips(
    'Cable_Bsr_Pull-Down',
    'The Cable Bsr Pull-Down is a back exercise that primarily targets the latissimus dorsi (lats). Its performed using a cable machine with a straight bar attachment.',
    'Tips for the exercise:\n1. Attach a straight bar to the high pulley of the cable machine.\n2. Sit on the machines seat and secure your knees under the pads.\n3. Grab the bar with a wide, overhand grip, slightly wider than shoulder-width apart.\n4. Pull the bar down to your upper chest while arching your back slightly.\n5. Squeeze your lats at the bottom of the movement.\n6. Slowly release the bar to the starting position and repeat for the desired number of reps.\n7. Maintain good posture and engage your core to stabilize your body during the exercise.',
  ),
  WorkoutTips(
    'Cable_Crossover_Reverse',
    'The Cable Crossover Reverse is an exercise that targets the chest and shoulder muscles. Its performed using a cable machine with the pulleys set at shoulder level.',
    'Tips for the exercise:\n1. Set the pulleys of the cable machine at shoulder level.\n2. Stand in the middle of the machine, one foot in front of the other for stability.\n3. Grab the handles with an overhand grip and keep your arms slightly bent.\n4. Bring your arms forward and together in a reverse fly motion, squeezing your chest muscles at the peak of the movement.\n5. Slowly return your arms to the starting position and repeat.\n6. Keep your core engaged and maintain proper posture throughout the exercise.',
  ),
  WorkoutTips(
    'Cable_Crossover_Reverse_Fly',
    'The Cable Crossover Reverse Fly is an exercise that primarily targets the rear deltoids (shoulder muscles) and the upper back. Its performed using a cable machine with the pulleys set at shoulder level.',
    'Tips for the exercise:\n1. Set the pulleys of the cable machine at shoulder level.\n2. Stand in the middle of the machine, one foot in front of the other for stability.\n3. Grab the handles with an overhand grip and maintain a slight bend in your elbows.\n4. Open your arms in a reverse fly motion, squeezing your rear deltoids and upper back at the peak of the movement.\n5. Slowly bring your arms back together and repeat for the desired number of reps.\n6. Maintain proper posture, engage your core, and control the movement.',
  ),
  WorkoutTips(
    'Cable_Front_Raise',
    'The Cable Front Raise is an exercise that targets the front deltoids (shoulder muscles). Its performed using a cable machine with a straight bar attachment.',
    'Tips for the exercise:\n1. Attach a straight bar to the low pulley of the cable machine.\n2. Stand facing the machine with your feet shoulder-width apart.\n3. Grasp the bar with an overhand grip, arms fully extended in front of you.\n4. Lift the bar by raising your arms to shoulder level while keeping them straight.\n5. Squeeze your front deltoids at the top of the movement.\n6. Lower the bar in a controlled manner and repeat for the desired number of reps.',
  ),
  WorkoutTips(
    'Cable_Front_Raise_2',
    'The Cable Front Raise is an exercise that targets the front deltoids (shoulder muscles). Its performed using a cable machine with a straight bar attachment.',
    'Tips for the exercise:\n1. Attach a straight bar to the low pulley of the cable machine.\n2. Stand facing the machine with your feet shoulder-width apart.\n3. Grasp the bar with an overhand grip, arms fully extended in front of you.\n4. Lift the bar by raising your arms to shoulder level while keeping them straight.\n5. Squeeze your front deltoids at the top of the movement.\n6. Lower the bar in a controlled manner and repeat for the desired number of reps.',
  ),
  WorkoutTips(
    'Cable_Lateral_Raise',
    'The Cable Lateral Raise is an exercise that targets the lateral deltoids (shoulder muscles). Its performed using a cable machine with a D-handle attachment.',
    'Tips for the exercise:\n1. Attach a D-handle to the low pulley of the cable machine.\n2. Stand sideways to the machine with your feet shoulder-width apart.\n3. Grasp the D-handle with the hand that is farthest from the machine.\n4. Keep your arm slightly bent and raise it to the side until its parallel to the ground.\n5. Squeeze your lateral deltoids at the top of the movement.\n6. Lower the handle in a controlled manner and repeat for the desired number of reps.\n7. Perform the exercise on both sides.',
  ),
  WorkoutTips(
    'Cable_Lateral_Raise_3',
    'The Cable Lateral Raise is an exercise that targets the lateral deltoids (shoulder muscles). Its performed using a cable machine with a D-handle attachment.',
    'Tips for the exercise:\n1. Attach a D-handle to the low pulley of the cable machine.\n2. Stand sideways to the machine with your feet shoulder-width apart.\n3. Grasp the D-handle with the hand that is farthest from the machine.\n4. Keep your arm slightly bent and raise it to the side until its parallel to the ground.\n5. Squeeze your lateral deltoids at the top of the movement.\n6. Lower the handle in a controlled manner and repeat for the desired number of reps.\n7. Perform the exercise on both sides.',
  ),
  WorkoutTips(
    'Cable_Lying_Fly_Flat_Bench_Cable_Fly',
    'The Cable Lying Fly on a Flat Bench is a chest exercise that targets the pectoral muscles. Its performed using a cable machine and a flat bench.',
    'Tips for the exercise:\n1. Attach D-handles to the lower pulleys of the cable machine.\n2. Lie on a flat bench between the pulleys with one handle in each hand.\n3. Extend your arms straight above your chest with a slight bend in your elbows.\n4. Open your arms wide, bringing the handles toward the sides of your body.\n5. Squeeze your chest muscles at the peak of the movement.\n6. Slowly bring the handles back together and repeat for the desired number of reps.\n7. Keep your core engaged and maintain a stable body position on the bench.',
  ),
  WorkoutTips(
    'Cable_One_Arm_Curl',
    'The Cable One-Arm Curl is an isolation exercise that targets the biceps. Its performed using a low pulley and a D-handle attachment on a cable machine.',
    'Tips for the exercise:\n1. Attach a D-handle to the low pulley of the cable machine.\n2. Stand facing the machine with your feet shoulder-width apart.\n3. Grasp the handle with one hand, palm facing upward.\n4. Keep your elbow close to your side and curl the handle upward, contracting your biceps.\n5. Slowly lower the handle back down and repeat for the desired number of reps.\n6. Perform the exercise on both arms.',
  ),
  WorkoutTips(
    'Cable_One_Arm_Forward_Raise',
    'The Cable One-Arm Forward Raise is an exercise that targets the front deltoids (shoulder muscles). Its performed using a cable machine with a low pulley and a D-handle attachment.',
    'Tips for the exercise:\n1. Attach a D-handle to the low pulley of the cable machine.\n2. Stand facing the machine with your feet shoulder-width apart.\n3. Grasp the handle with one hand and keep your arm straight.\n4. Raise your arm in front of you until its parallel to the ground.\n5. Squeeze your front deltoid at the top of the movement.\n6. Lower the handle in a controlled manner and repeat for the desired number of reps.\n7. Perform the exercise on both arms.',
  ),
  WorkoutTips(
    'Cable_One_Arm_Forwardf',
    'The Cable One-Arm Forward Raise is an exercise that targets the front deltoids (shoulder muscles). It\'s performed using a cable machine with a low pulley and a D-handle attachment.',
    'Tips for the exercise:\n1. Attach a D-handle to the low pulley of the cable machine.\n2. Stand facing the machine with your feet shoulder-width apart.\n3. Grasp the handle with one hand and keep your arm straight.\n4. Raise your arm in front of you until it\'s parallel to the ground.\n5. Squeeze your front deltoid at the top of the movement.\n6. Lower the handle in a controlled manner and repeat for the desired number of reps.\n7. Perform the exercise on both arms.',
  ),

  //
  WorkoutTips(
    'Cable_One_Arm_Latera',
    'This exercise is performed using a cable machine. It primarily targets the lateral deltoid muscles. Stand with your side to the machine, hold the handle with one hand, and raise your arm to the side until its parallel to the ground.',
    'Maintain proper form and control the weight throughout the movement. Keep your core engaged to stabilize your body.',
  ),
  WorkoutTips(
    'Cable_One_Arm_Latera_2',
    'This exercise is performed using a cable machine. It primarily targets the lateral deltoid muscles. Stand with your side to the machine, hold the handle with one hand, and raise your arm to the side until its parallel to the ground.',
    'Maintain proper form and control the weight throughout the movement. Keep your core engaged to stabilize your body.',
  ),
  WorkoutTips(
    'Cable_One_Arm_Latera_3',
    'This exercise is performed using a cable machine. It primarily targets the lateral deltoid muscles. Stand with your side to the machine, hold the handle with one hand, and raise your arm to the side until its parallel to the ground.',
    'Maintain proper form and control the weight throughout the movement. Keep your core engaged to stabilize your body.',
  ),
  WorkoutTips(
    'Cable_One_Arm_Lateral_Pull-Down',
    'This exercise focuses on the latissimus dorsi (lats) muscles. It involves pulling a cable handle downward with one arm to target the lats.',
    'Ensure a full range of motion and control the weight. Maintain a stable posture and avoid using excessive momentum',
  ),
  WorkoutTips(
    'Cable_One_Arm_Lateral_Raise',
    'This exercise involves using a cable machine to perform lateral raises, targeting the lateral deltoid muscles.',
    ' Maintain proper form, control the weight, and avoid swinging the arm. Focus on the contraction of the deltoid muscle.',
  ),
  WorkoutTips(
    'Cable_One_Arm_Twisting_Seated_Row',
    ' This exercise targets the upper back and biceps. Its performed by pulling a cable handle with one hand while twisting your torso.',
    'Keep your back straight, engage your core, and use a controlled motion when pulling the cable handle. Focus on squeezing your shoulder blades together.',
  ),

  ///
  WorkoutTips(
    'Cable_Pulldown',
    'The cable pulldown is a compound exercise that targets the latissimus dorsi (lats). It involves pulling a cable attachment down towards your chest while seated at a cable machine.',
    'Maintain a straight posture, engage your lats, and use a controlled motion. Avoid using excessive momentum to ensure proper muscle engagement.',
  ),
  WorkoutTips(
    'Cable_Pull-Down',
    'Similar to the cable pulldown, this exercise involves pulling a cable attachment down to work the latissimus dorsi muscles.',
    'Maintain a straight back, control the weight, and focus on squeezing the lats as you pull down.',
  ),
  WorkoutTips(
    'Cable_Pull-Downs',
    'Cable pull-downs are variations of the exercise, often performed with different grips and attachments.',
    'Select a grip that targets your desired muscle groups (wide grip for lats, close grip for biceps) and maintain good form throughout.',
  ),
  WorkoutTips(
    'Cable_Rear_Delt_Row',
    'This exercise targets the rear deltoid muscles. It involves pulling a cable attachment toward your rear deltoids while maintaining proper form.',
    'Keep your back straight, engage your rear delts, and use a controlled motion. Focus on the contraction of the rear deltoid muscle.',
  ),
  WorkoutTips(
    'Cable_Rear_Delt_Row_With_Rope',
    'A variation of the cable rear delt row using a rope attachment, which can provide a different range of motion and muscle engagement.',
    'Maintain good posture, control the movement, and focus on working the rear deltoids.',
  ),
  WorkoutTips(
    'Cable_Seated_High_Ro',
    'The cable seated high row targets the upper back and trapezius muscles. It involves pulling a cable attachment toward your upper chest while seated.',
    'Keep your back straight, engage your upper back muscles, and use a controlled motion for best results.',
  ),
  WorkoutTips(
    'Cable_Seated_High_Row',
    'A variation of the cable seated high row, which may involve different grips or attachments.',
    'Choose the grip that suits your goals and maintain good form throughout the exercise.',
  ),
  WorkoutTips(
    'Cable_Seated_Row',
    'The cable seated row primarily targets the mid-back muscles. It involves pulling a cable handle toward your abdomen while seated.',
    'Maintain proper posture, engage your mid-back muscles, and control the weight throughout the exercise.',
  ),
  WorkoutTips(
    'Cable_Seated_Row_2',
    'The cable seated row primarily targets the mid-back muscles. It involves pulling a cable handle toward your abdomen while seated.',
    'Maintain proper posture, engage your mid-back muscles, and control the weight throughout the exercise.',
  ),
  WorkoutTips(
    'Cable_Seated_Row_Normal_Grip',
    'A variation of the cable seated row using a normal grip handle.',
    'Focus on the muscles being worked, maintain good posture, and use a controlled motion.',
  ),
  WorkoutTips(
    'Cable_Seated_Row_Parallel_Grip',
    'A variation of the cable seated row with a parallel grip handle for a different hand position.',
    'Maintain a parallel grip to engage different muscle groups, maintain good form, and control the weight.',
  ),
  WorkoutTips(
    'Cable_Standing__Fly',
    'The cable standing fly targets the chest muscles. It involves pulling cable handles together in front of you to work the pectoral muscles.',
    'Maintain proper posture, control the weight, and focus on the chest muscles contracting during the movement.',
  ),

  //
  WorkoutTips(
    'Cable_Standing_Fly_2',
    'A variation of the cable standing fly exercise, which targets the chest muscles. It involves pulling cable handles together in front of you to work the pectoral muscles.',
    'Maintain proper posture, control the weight, and focus on the chest muscles contracting during the movement.',
  ),
  WorkoutTips(
    'Cable_Standing_Fly_Crossover_Fly',
    'The cable standing fly crossover fly is an exercise that targets the chest muscles. It involves pulling cable handles from an elevated position to create a crossover motion.',
    'Ensure a controlled and smooth crossover motion, focusing on chest muscle engagement.',
  ),
  WorkoutTips(
    'Cable_Standing_Inner_Curl',
    'This exercise targets the biceps. Stand in front of a cable machine and curl the handle inward to engage the biceps.',
    'Maintain a good posture, focus on the biceps, and control the curling motion.',
  ),
  WorkoutTips(
    'Cable_Straight_Arm',
    'The cable straight arm exercise primarily targets the lats and upper back. It involves pulling a cable attachment down with straight arms.',
    'Keep your back straight, engage your lats, and use a controlled motion to avoid swinging.',
  ),
  WorkoutTips(
    'Cable_Straight_Arm_Pull-Down',
    'Similar to the cable straight arm exercise, this variation involves pulling a cable attachment down with straight arms.',
    'Maintain good posture, control the weight, and focus on the lats and upper back muscles.',
  ),
  WorkoutTips(
    'Cable_Straight_Back',
    'The cable straight back exercise targets the upper back and trapezius muscles. It involves pulling a cable attachment towards your upper body while maintaining proper form.',
    'Keep your back straight, engage your upper back muscles, and use a controlled motion for best results.',
  ),
  WorkoutTips(
    'Cable_Straight_Back_Seated_Row',
    'The cable straight back seated row is an exercise that targets the upper back and trapezius muscles. It involves pulling a cable handle towards your upper chest while seated.',
    'Maintain proper posture, engage your upper back muscles, and control the weight throughout the exercise.',
  ),
  WorkoutTips(
    'Cambered_Bar_Lying_Row',
    'The cambered bar lying row is an exercise that targets the upper back and trapezius muscles. It involves rowing a cambered bar while lying face down on an incline bench.',
    'Maintain a stable position on the bench, engage your upper back muscles, and use a controlled rowing motion.',
  ),
  WorkoutTips(
    'Chest_Dips',
    'Chest dips primarily target the chest muscles. It involves dipping your body down between parallel bars and pushing back up.',
    'Maintain proper form, focus on the chest muscles, and control your movement during dips.',
  ),
  WorkoutTips(
    'Chest_Dips_2',
    'Chest dips primarily target the chest muscles. It involves dipping your body down between parallel bars and pushing back up.',
    'Maintain proper form, focus on the chest muscles, and control your movement during dips.',
  ),
  WorkoutTips(
    'Chest_Dips_3',
    'Chest dips primarily target the chest muscles. It involves dipping your body down between parallel bars and pushing back up.',
    'Maintain proper form, focus on the chest muscles, and control your movement during dips.',
  ),
  WorkoutTips(
    'Chest_Dips_4',
    'Chest dips primarily target the chest muscles. It involves dipping your body down between parallel bars and pushing back up.',
    'Maintain proper form, focus on the chest muscles, and control your movement during dips.',
  ),
  WorkoutTips(
    'Chin-_Ups_Narrow_Parallel_Grip',
    'Chin-ups with a narrow parallel grip primarily target the biceps and upper back. This grip involves placing your hands close together on the pull-up bar.',
    'Maintain good form, control the movement, and engage the biceps and upper back muscles.',
  ),
  WorkoutTips(
    'Chin-Up_Or_Pull-Ups',
    'Chin-ups or pull-ups are excellent compound exercises that target the upper body, including the back and biceps.',
    'Ensure proper form, control your movements, and engage the back and biceps.',
  ),
  WorkoutTips(
    'Chin-Ups',
    ' Chin-ups are another version of the pull-up exercise that primarily targets the back and biceps.',
    'Maintain good form, control your movements, and focus on engaging the back and biceps.',
  ),

  //
  WorkoutTips(
    'Chin-Ups__Pull-Ups',
    'Chin-ups and pull-ups are compound upper body exercises that primarily target the muscles in your back, as well as your arms and shoulders. Chin-ups involve an underhand grip with your palms facing you, while pull-ups use an overhand grip with your palms facing away from you.',
    'Start with a grip that is comfortable for you. Engage your core muscles to maintain stability. Perform a full range of motion, from a dead hang to chin over the bar.',
  ),
  WorkoutTips(
    'Commando_Pull-_Up',
    'The commando pull-up is a variation of the standard pull-up. It involves gripping the bar with one hand facing forward and the other facing backward. This exercise targets your back, biceps, and shoulders.',
    'Keep a strong core and engage your back muscles, Alternate your hand positions with each set to work both sides evenly.',
  ),
  WorkoutTips(
    'Decline_Barbell_Bench_Press',
    'The decline barbell bench press is a chest exercise that is performed on a decline bench. It primarily targets the lower chest muscles.',
    'Use a spotter when lifting heavy weights, Maintain a stable and controlled movement during the exercise.',
  ),
  WorkoutTips(
    'Decline_Dumbbell_Ben',
    'Similar to the barbell version, the decline dumbbell bench press is a chest exercise performed on a decline bench using dumbbells. It helps target the lower chest muscles.',
    'Keep your elbows at a slight angle, not fully flared out, Use a controlled motion and avoid bouncing the weights.',
  ),
  WorkoutTips(
    'Decline_Dumbbell_Bench_Press_45_Degree',
    'This variation of the decline dumbbell bench press is performed on a 45-degree decline bench, targeting the lower chest and engaging the upper chest muscles as well.',
    'Adjust the bench to a 45-degree angle, Focus on a full range of motion, going as low as your flexibility allows.',
  ),
  WorkoutTips(
    'Deep_Push_-_Ups',
    'Deep push-ups are a variation of standard push-ups that involve a deeper range of motion, emphasizing chest and triceps engagement.',
    'Maintain a straight body alignment from head to heels, Go as deep as your flexibility allows without straining your shoulders.',
  ),
  WorkoutTips(
    'Dumbbell_Alternate',
    'Dumbbell alternate biceps curls are an isolation exercise for the biceps. You curl one dumbbell at a time, alternating between arms.',
    'Keep your back straight and core engaged, Control the movement and avoid swinging the weights.',
  ),
  WorkoutTips(
    'Dumbbell_Alternate_Biceps_Curl',
    'Dumbbell alternate shoulder press is a shoulder exercise that targets the deltoid muscles. You press one dumbbell at a time overhead while the other rests.',
    'Maintain a neutral spine and engage your core for stability, Press the dumbbells overhead while keeping your wrists in line with your elbows.',
  ),
  WorkoutTips(
    'Dumbbell_Alternate_Shoulder_Press',
    'Dumbbell alternate shoulder press is a shoulder exercise that targets the deltoid muscles. You press one dumbbell at a time overhead while the other rests.',
    'Maintain a neutral spine and engage your core for stability, Press the dumbbells overhead while keeping your wrists in line with your elbows.',
  ),
  WorkoutTips(
    'Dumbbell_Arnold_Press',
    'The Dumbbell Arnold Press is a shoulder exercise that involves a seated dumbbell press with a rotating motion during the movement, targeting various shoulder muscles.',
    'Start with the dumbbells at shoulder height, Rotate your palms as you press the weights overhead.',
  ),
  WorkoutTips(
    'Dumbbell_Arnold_Press_2',
    'The Dumbbell Arnold Press is a shoulder exercise that involves a seated dumbbell press with a rotating motion during the movement, targeting various shoulder muscles.',
    'Start with the dumbbells at shoulder height, Rotate your palms as you press the weights overhead.',
  ),

  //
  WorkoutTips(
    'Dumbbell_Bench_Fly',
    'Dumbbell bench fly is an isolation exercise that primarily targets the chest muscles. It involves lying on a bench and using dumbbells to perform a fly-like motion.',
    'Keep a slight bend in your elbows to avoid overextension, Use a controlled motion, and focus on feeling the chest muscles contract.',
  ),
  WorkoutTips(
    'Dumbbell_Bench_Press',
    'The dumbbell bench press is a compound exercise that targets the chest, shoulders, and triceps. It involves pressing dumbbells while lying on a bench.',
    'Maintain a stable and flat back on the bench., Keep your wrists in line with your elbows during the press.',
  ),
  WorkoutTips(
    'Dumbbell_Bench_Press_2',
    'The dumbbell bench press is a compound exercise that targets the chest, shoulders, and triceps. It involves pressing dumbbells while lying on a bench.',
    'Maintain a stable and flat back on the bench., Keep your wrists in line with your elbows during the press.',
  ),
  WorkoutTips(
    'Dumbbell_Bench_Press_3',
    'The dumbbell bench press is a compound exercise that targets the chest, shoulders, and triceps. It involves pressing dumbbells while lying on a bench.',
    'Maintain a stable and flat back on the bench., Keep your wrists in line with your elbows during the press.',
  ),
  WorkoutTips(
    'Dumbbell_Bench_Seated',
    'The dumbbell bench seated exercise involves sitting on a bench and pressing dumbbells overhead. It targets the shoulder and triceps muscles.',
    'Ensure your back is supported and straight on the bench., Press the dumbbells overhead in a controlled manner.',
  ),
  WorkoutTips(
    'Dumbbell_Bench_Seated_Press',
    'This is another seated dumbbell shoulder press variation that targets the shoulder muscles. It is similar to the previous exercise but may involve different angles or grips.',
    'Maintain proper posture and a stable base on the bench, Adjust the bench angle and hand positioning as needed.',
  ),
  WorkoutTips(
    'Dumbbell_Bent_-_Over_Row',
    'Dumbbell bent-over rows are a compound back exercise that involves bending at the hips and pulling dumbbells toward your torso. It targets the upper back and lats.',
    'Keep your back straight and engage your core, Squeeze your shoulder blades together at the top of the movement.',
  ),
  WorkoutTips(
    'Dumbbell_Bent-Over_Gym',
    'Dumbbell bent-over gym rows are a variation of the bent-over row that can be performed with gym equipment. It targets the back and lats.',
    'Maintain a strong posture, hinging at the hips, and keeping your back flat, Use gym equipment like a cable machine or a barbell for this exercise.',
  ),
  WorkoutTips(
    'Dumbbell_Biceps_Curl',
    'Dumbbell biceps curls are an isolation exercise targeting the biceps. You curl dumbbells using your arms strength.',
    'Keep your elbows close to your body during the curl, Avoid swinging or using momentum; focus on controlled movements.',
  ),

  //
  WorkoutTips(
    'Dumbbell_Concentration_Curl',
    'Dumbbell concentration curls are a bicep isolation exercise that targets the biceps. It is typically performed in a seated position with one arm at a time.',
    'Sit on a bench with your legs spread and your elbow resting against your thigh, Keep your back straight and curl the dumbbell toward your shoulder.',
  ),
  WorkoutTips(
    'Dumbbell_Cross_Body_Hammer_Curl',
    'Dumbbell cross-body hammer curls are a variation of the bicep curl that targets the biceps. You curl the dumbbell across your body while keeping your palm facing your torso.',
    'Keep your upper arm stationary during the curl, Focus on the controlled and deliberate movement.',
  ),
  WorkoutTips(
    'Dumbbell_Deadlift',
    'Dumbbell deadlift is a compound exercise that targets the lower back, glutes, and hamstrings. It is performed by lifting dumbbells from the floor while maintaining a straight back.',
    'Keep your back straight, chest up, and engage your core, Use proper lifting form and avoid rounding your back.',
  ),
  WorkoutTips(
    'Dumbbell_Decline_Fly',
    'Dumbbell decline fly is a chest exercise performed on a decline bench, targeting the lower chest muscles.',
    'Use a controlled motion and focus on the chest muscle contraction, Avoid using excessively heavy weights to maintain form.',
  ),
  WorkoutTips(
    'Dumbbell_Decline_Fly_45_Degree',
    'This is a variation of the decline fly, performed on a 45-degree decline bench. It works the lower and upper chest muscles.',
    'Adjust the bench angle to 45 degrees and control the weights, Maintain a full range of motion during the exercise.',
  ),
  WorkoutTips(
    'Dumbbell_Fly',
    'Dumbbell fly is a chest isolation exercise that involves lying on a bench and opening your arms wide with dumbbells in hand to target the pectoral muscles.',
    'Keep a slight bend in your elbows to avoid overextension, Focus on the stretch and contraction of the chest muscles.',
  ),
  WorkoutTips(
    'Dumbbell_Front_Raise',
    'Dumbbell front raise is a shoulder exercise that targets the anterior deltoids. It involves lifting dumbbells in front of you to shoulder height.',
    'Keep a slight bend in your elbows to avoid strain, Lift the dumbbells in a controlled manner.',
  ),
  WorkoutTips(
    'Dumbbell_Front_Raise_2',
    'Dumbbell front raise is a shoulder exercise that targets the anterior deltoids. It involves lifting dumbbells in front of you to shoulder height.',
    'Keep a slight bend in your elbows to avoid strain, Lift the dumbbells in a controlled manner.',
  ),
  WorkoutTips(
    'Dumbbell_Incline_Bench_Press',
    'The dumbbell incline bench press is a chest exercise performed on an inclined bench, focusing on the upper chest muscles.',
    'Adjust the bench angle to target the upper chest, Maintain stability and control during the press.',
  ),
  WorkoutTips(
    'Dumbbell_Incline_Biceps_Curl',
    'Dumbbell incline biceps curl is a bicep isolation exercise that targets the biceps. It is performed on an inclined bench.',
    'Keep your upper arms stationary and engage the biceps, Use a controlled motion and avoid swinging.',
  ),
  WorkoutTips(
    'Dumbbell_Incline_Fly',
    'Dumbbell incline fly is a chest isolation exercise performed on an inclined bench, focusing on the upper chest muscles.',
    'Adjust the bench angle and maintain control during the fly, Avoid using excessive weight to ensure proper form.',
  ),
  WorkoutTips(
    'Dumbbell_Incline_Fly_2',
    'Dumbbell incline fly is a chest isolation exercise performed on an inclined bench, focusing on the upper chest muscles.',
    'Adjust the bench angle and maintain control during the fly, Avoid using excessive weight to ensure proper form.',
  ),

  //
  WorkoutTips(
    'Dumbbell_Incline_Hammer_Curl',
    'The Dumbbell Incline Hammer Curl is an upper arm exercise that primarily targets the biceps. It is performed on an incline bench with a neutral grip (palms facing each other), allowing for a different angle of stress on the biceps compared to traditional curls.',
    'Ensure your back is firmly pressed against the incline bench to maintain proper form and stability, Keep your upper arms stationary and only move your forearms during the curling motion, Use a controlled and smooth tempo, avoiding swinging or jerking the weights.',
  ),
  WorkoutTips(
    'Dumbbell_Incline_Row',
    'The Dumbbell Incline Row is an upper back and rear shoulder exercise. It involves lying face down on an incline bench and pulling dumbbells towards your hips, engaging the upper back muscles.',
    'Maintain a neutral spine and avoid arching your back excessively, Squeeze your shoulder blades together at the top of the movement for maximum engagement of the upper back muscles, Use a weight that allows you to perform the exercise with proper form.',
  ),

  WorkoutTips(
    'Dumbbell_Incline_Row_2',
    'The Dumbbell Incline Row is an upper back and rear shoulder exercise. It involves lying face down on an incline bench and pulling dumbbells towards your hips, engaging the upper back muscles.',
    'Maintain a neutral spine and avoid arching your back excessively, Squeeze your shoulder blades together at the top of the movement for maximum engagement of the upper back muscles, Use a weight that allows you to perform the exercise with proper form.',
  ),
  WorkoutTips(
    'Dumbbell_Iron_Cross',
    'The Dumbbell Iron Cross is a chest and shoulder exercise. It involves lying on a bench with a dumbbell in each hand and extending your arms out to the sides, forming a cross shape.',
    'Choose an appropriate weight that allows you to control the movement and maintain proper form, Keep a slight bend in your elbows to reduce stress on the joints, Engage your chest and shoulders as you lift the dumbbells.',
  ),
  WorkoutTips(
    'Dumbbell_Iron_Cross_2',
    'The Dumbbell Iron Cross is a chest and shoulder exercise. It involves lying on a bench with a dumbbell in each hand and extending your arms out to the sides, forming a cross shape.',
    'Choose an appropriate weight that allows you to control the movement and maintain proper form, Keep a slight bend in your elbows to reduce stress on the joints, Engage your chest and shoulders as you lift the dumbbells.',
  ),
  WorkoutTips(
    'Dumbbell_Lateral_Rai',
    'The Dumbbell Lateral Raise is a shoulder exercise that targets the lateral deltoid muscles. It involves lifting dumbbells out to the sides to shoulder level.',
    'Maintain a slight bend in your elbows throughout the movement to prevent excessive stress on the joints, Use a controlled tempo and avoid swinging the weights, Focus on engaging your shoulder muscles to lift the dumbbells.',
  ),
  WorkoutTips(
    'Dumbbell_Lateral_Raise',
    'The Dumbbell Lateral Raise is a shoulder exercise that targets the lateral deltoid muscles. It involves lifting dumbbells out to the sides to shoulder level.',
    'Maintain a slight bend in your elbows throughout the movement to prevent excessive stress on the joints, Use a controlled tempo and avoid swinging the weights, Focus on engaging your shoulder muscles to lift the dumbbells.',
  ),
  WorkoutTips(
    'Dumbbell_Lying_Hammer_Press',
    'The Dumbbell Lying Hammer Press is a chest exercise that involves lying on your back and pressing dumbbells with a neutral (hammer) grip. This variation targets the chest differently than traditional bench press.',
    'Keep your elbows at a 90-degree angle at the bottom of the movement to maintain tension on the chest, Use a spotter if lifting heavy weights, as it can be challenging to get the dumbbells into position.',
  ),
  WorkoutTips(
    'Dumbbell_Rear_Delt',
    'The Dumbbell Rear Delt exercise targets the rear deltoid muscles. It is typically performed by bending at the hips and raising dumbbells out to the sides.',
    'Keep a slight bend in your elbows and focus on using your rear deltoids to lift the dumbbells, Maintain a strong and stable core to support your back during the exercise.',
  ),
  WorkoutTips(
    'Dumbbell_Rear_Delt_Row',
    'The Dumbbell Rear Delt exercise targets the rear deltoid muscles. It is typically performed by bending at the hips and raising dumbbells out to the sides.',
    'Keep a slight bend in your elbows and focus on using your rear deltoids to lift the dumbbells, Maintain a strong and stable core to support your back during the exercise.',
  ),

  ///
  WorkoutTips(
    'Dumbbell_Rear_Delt_Roww',
    'The Dumbbell Rear Delt exercise targets the rear deltoid muscles. It is typically performed by bending at the hips and raising dumbbells out to the sides.',
    'Keep a slight bend in your elbows and focus on using your rear deltoids to lift the dumbbells, Maintain a strong and stable core to support your back during the exercise.',
  ),
  WorkoutTips(
    'Dumbbell_Rear_Latera',
    'The Dumbbell Rear Lateral Raise is a shoulder exercise that focuses on the rear deltoid muscles. It involves lifting dumbbells out to the sides while bending at the hips, keeping your back straight.',
    'Maintain a slight bend in your elbows and focus on engaging the rear deltoids during the movement, Keep your core engaged for stability, Use a controlled and smooth tempo to avoid using momentum.',
  ),
  WorkoutTips(
    'Dumbbell_Rear_Lateral_Raise',
    'The Dumbbell Rear Lateral Raise is a shoulder exercise that focuses on the rear deltoid muscles. It involves lifting dumbbells out to the sides while bending at the hips, keeping your back straight.',
    'Maintain a slight bend in your elbows and focus on engaging the rear deltoids during the movement, Keep your core engaged for stability, Use a controlled and smooth tempo to avoid using momentum.',
  ),
  WorkoutTips(
    'Dumbbell_Seated_Lateral_Raise',
    'The Dumbbell Seated Lateral Raise is another shoulder exercise that targets the lateral deltoid muscles. It is performed while sitting and lifting dumbbells out to the sides.',
    'Sit with your back supported and maintain proper posture, Avoid swinging the weights and use a controlled motion, Focus on squeezing your shoulder muscles at the top of the movement.',
  ),
  WorkoutTips(
    'Dumbbell_Seated_Preacher_Curl',
    'The Dumbbell Seated Preacher Curl is an arm exercise that targets the biceps. It is performed on a preacher bench, and it isolates the biceps for a concentrated curling motion.',
    'Adjust the preacher bench and pad to your height and comfort, Keep your upper arms pressed firmly against the bench, and curl the dumbbells without using momentum, Use a weight that allows you to complete the exercise with proper form.',
  ),
  WorkoutTips(
    'Dumbbell_Single_Leg_Squat',
    'The Dumbbell Single Leg Squat is a lower body exercise that works the quadriceps, hamstrings, and glutes. It involves squatting down on one leg while holding a dumbbell for added resistance.',
    'Maintain proper balance and stability while performing the exercise, Keep your chest up and back straight during the squat, Start with a light weight and gradually increase as you gain strength.',
  ),
  WorkoutTips(
    'Dumbell_Lunge',
    'The Dumbbell Lunge is a lower body exercise that targets the quadriceps, hamstrings, and glutes. It is performed by stepping forward and lunging with a dumbbell in each hand.',
    'Keep your core engaged and maintain an upright posture, Step far enough forward to ensure a 90-degree angle at both knees when lunging, Control the movement and avoid letting your front knee extend beyond your toes.',
  ),
  WorkoutTips(
    'Dumbell_Stiff_Leg_Deadlift',
    'The Dumbbell Stiff Leg Deadlift is a lower body and lower back exercise. It involves bending at the hips and lowering dumbbells while keeping your legs nearly straight, targeting the hamstrings and lower back.',
    'Maintain a slight bend in the knees, but keep them relatively straight throughout the movement, Keep your back straight and core engaged to prevent rounding of the spine, se a weight that challenges you without compromising your form.',
  ),

  //
  WorkoutTips(
    'Ez_Barbell_Anti_Gravity',
    'The Ez Barbell Anti Gravity exercise typically targets the triceps and is performed with an EZ curl bar. It involves lifting the barbell in an arched motion while lying on a bench.',
    'Ensure your back is firmly supported on the bench, and your feet are flat on the ground, Keep your elbows close to your body throughout the movement, Use a controlled tempo and a weight that you can manage with proper form.',
  ),
  WorkoutTips(
    'Ez_Barbell_Anti_Gravity_Press',
    'The Ez Barbell Anti Gravity Press is a variation of the bench press using an EZ curl bar. It targets the chest, shoulders, and triceps.',
    'Lie flat on a bench with your back and shoulders pressed against it, Keep your grip on the EZ bar slightly wider than shoulder-width, Lower the bar to your chest and press it back up, focusing on chest engagement.',
  ),
  WorkoutTips(
    'Ez_Barebell_Curl',
    'The Ez Barbell Curl is an arm exercise that primarily targets the biceps. It is performed using an EZ curl bar, and it involves curling the barbell to work the bicep muscles.',
    'Stand with your feet shoulder-width apart and maintain proper posture, Keep your upper arms stationary and only move your forearms during the curling motion, Use a controlled and smooth tempo without swinging the barbell.',
  ),
  WorkoutTips(
    'Incline_Push_-_Ups',
    'Incline Push-Ups are a bodyweight exercise that primarily works the chest and triceps. They are performed with your hands on an elevated surface, such as a bench or step.',
    'Maintain a straight line from head to heels by engaging your core, Lower your chest to the elevated surface and push back up, Adjust the incline level to suit your fitness level.',
  ),
  WorkoutTips(
    'Lever_-_T_Bar_Row',
    'The Lever T-Bar Row is a back and upper body exercise. It involves using a T-bar row machine to target the middle and upper back muscles.',
    'Maintain a stable and neutral spine position throughout the exercise, Squeeze your shoulder blades together at the top of the row, Use proper form to prevent excessive stress on the lower back.',
  ),
  WorkoutTips(
    'Lever_Back_Extension',
    'The Lever Back Extension is an exercise that primarily targets the lower back muscles. It is typically performed on a machine specifically designed for this purpose.',
    'Adjust the machine to your bodys proportions and ensure proper alignment, Keep your core engaged and maintain a controlled motion, Avoid hyperextension of the lower back to prevent strain.',
  ),
  WorkoutTips(
    'Lever_Back_Extension_2',
    'The Lever Back Extension is an exercise that primarily targets the lower back muscles. It is typically performed on a machine specifically designed for this purpose.',
    'Adjust the machine to your bodys proportions and ensure proper alignment, Keep your core engaged and maintain a controlled motion, Avoid hyperextension of the lower back to prevent strain.',
  ),
  WorkoutTips(
    'Lever_Chest_Press',
    'The Lever Chest Press is a chest and triceps exercise. It is performed using a machine that allows you to push weight forward to target the chest muscles.',
    'Adjust the machine to your bodys proportions and maintain proper posture, Keep your elbows at a 90-degree angle at the bottom of the press, Use a controlled and smooth motion to avoid jerking the weight.',
  ),
  WorkoutTips(
    'Lever_High_Row',
    'The Lever High Row exercise targets the upper back and shoulder muscles. It is typically performed on a machine with a high pulley.',
    'Maintain proper posture and keep your chest up, Squeeze your shoulder blades together at the end of the rowing motion, Use a weight that allows you to perform the exercise with good form.',
  ),
  WorkoutTips(
    'Lever_High_Row__3',
    'The Lever High Row exercise targets the upper back and shoulder muscles. It is typically performed on a machine with a high pulley.',
    'Maintain proper posture and keep your chest up, Squeeze your shoulder blades together at the end of the rowing motion, Use a weight that allows you to perform the exercise with good form.',
  ),
  WorkoutTips(
    'Lever_High_Row_2',
    'The Lever High Row exercise targets the upper back and shoulder muscles. It is typically performed on a machine with a high pulley.',
    'Maintain proper posture and keep your chest up, Squeeze your shoulder blades together at the end of the rowing motion, Use a weight that allows you to perform the exercise with good form.',
  ),
  WorkoutTips(
    'Lever_Horizontal_Leg_Press',
    'The Lever Horizontal Leg Press is a leg exercise that targets the quadriceps, hamstrings, and glutes. It is performed on a machine that allows you to push weight horizontally.',
    'Adjust the machine to your bodys proportions and maintain proper alignment, Keep your feet hip-width apart and press the weight with controlled movements, Avoid locking your knees at the top of the press.',
  ),
  WorkoutTips(
    'Lever_Incline_Hammer_Chest_Press',
    'The Lever Incline Hammer Chest Press is an exercise that targets the chest and triceps. It is performed on a machine with an incline bench.',
    'Adjust the machine to your bodys proportions and maintain a stable bench incline, Keep your elbows at a 90-degree angle at the bottom of the press, Use a controlled tempo for the exercise.',
  ),
  WorkoutTips(
    'Lever_Incline_Hammer_Chest_Press_2',
    'The Lever Incline Hammer Chest Press is an exercise that targets the chest and triceps. It is performed on a machine with an incline bench.',
    'Adjust the machine to your bodys proportions and maintain a stable bench incline, Keep your elbows at a 90-degree angle at the bottom of the press, Use a controlled tempo for the exercise.',
  ),
  WorkoutTips(
    'Lever_Kneeling_Leg_Curl',
    'The Lever Kneeling Leg Curl is a leg exercise that targets the hamstrings. It is performed on a machine with a kneeling position to isolate the hamstring muscles.',
    'Adjust the machine to your bodys proportions and maintain a stable kneeling position, Keep your core engaged and perform the curling motion with control., Avoid using momentum to lift the weight.',
  ),
  WorkoutTips(
    'Lever_Lateral_Raise',
    'The Lever Lateral Raise is a shoulder exercise that targets the lateral deltoid muscles. It is performed on a machine with a lever arm.',
    'Maintain proper posture and engage your core, Perform the lateral raise with a controlled and smooth motion, Use a weight that challenges your shoulder muscles without compromising your form.',
  ),
  WorkoutTips(
    'Lever_Lateral_Raise_2',
    'The Lever Lateral Raise is a shoulder exercise that targets the lateral deltoid muscles. It is performed on a machine with a lever arm.',
    'Maintain proper posture and engage your core, Perform the lateral raise with a controlled and smooth motion, Use a weight that challenges your shoulder muscles without compromising your form.',
  ),
  WorkoutTips(
    'Lever_Leg_Extension',
    'The Lever Leg Extension is a leg exercise that targets the quadriceps. It is performed on a machine that allows you to extend your legs against resistance.',
    'Adjust the machine to your bodys proportions and maintain proper alignment, Keep your feet hip-width apart and perform the leg extension with control, Avoid locking your knees at the top of the extension.',
  ),
  WorkoutTips(
    'Lever_Lying_Chest',
    'The Lever Lying Chest exercise targets the chest and triceps. It is typically performed on a machine with a lever arm for pressing.',
    'Maintain proper posture and ensure your back is supporter, Keep your elbows at a 90-degree angle at the bottom of the press, Use a controlled tempo and avoid jerking the weight.',
  ),
  WorkoutTips(
    'Lever_Lying_Chest__Press',
    'The Lever Lying Chest Press is a chest and triceps exercise. It is performed on a machine that allows you to press weight from a lying position.',
    'Adjust the machine to your bodys proportions and maintain a stable bench position, Keep your elbows at a 90-degree angle at the bottom of the press, Use a controlled tempo for the exercise.',
  ),
  WorkoutTips(
    'Lever_Lying_Chest_Press_2',
    'The Lever Lying Chest Press is a chest and triceps exercise. It is performed on a machine that allows you to press weight from a lying position.',
    'Adjust the machine to your bodys proportions and maintain a stable bench position, Keep your elbows at a 90-degree angle at the bottom of the press, Use a controlled tempo for the exercise.',
  ),
  WorkoutTips(
    'Lever_Lying_Chest_Press_3',
    'The Lever Lying Chest Press is a chest and triceps exercise. It is performed on a machine that allows you to press weight from a lying position.',
    'Adjust the machine to your bodys proportions and maintain a stable bench position, Keep your elbows at a 90-degree angle at the bottom of the press, Use a controlled tempo for the exercise.',
  ),
  WorkoutTips(
    'Lever_Military_Press',
    'The Lever Military Press is a shoulder exercise that targets the deltoid muscles. It is performed on a machine designed for overhead pressing.',
    'Maintain proper posture and ensure your back is supported, Keep your core engaged for stability during the press, Use a controlled tempo to press the weight overhead.',
  ),
  WorkoutTips(
    'Lever_Military_Press_2',
    'The Lever Military Press is a shoulder exercise that targets the deltoid muscles. It is performed on a machine designed for overhead pressing.',
    'Maintain proper posture and ensure your back is supported, Keep your core engaged for stability during the press, Use a controlled tempo to press the weight overhead.',
  ),
  WorkoutTips(
    'Lever_Pec_Deck_Fly',
    'The Lever Pec Deck Fly is a chest exercise that isolates the pectoral muscles. It is performed on a machine designed for chest fly movements.',
    'Adjust the machine to your bodys proportions and maintain proper alignment, Keep your elbows slightly bent and focus on squeezing your chest during the fly, Use a controlled motion to prevent strain.',
  ),
  WorkoutTips(
    'Lever_Preacher_Curl',
    'The Lever Preacher Curl is an arm exercise that targets the biceps. It is performed on a machine designed for preacher curls.',
    'Adjust the machine to your bodys proportions and maintain proper alignment, Keep your upper arms pressed against the pad and curl with controlled movements, Use a weight that allows you to perform the exercise with proper form.',
  ),
  WorkoutTips(
    'Lever_Reverse_Hypere',
    'The Lever Reverse Hyperextension is an exercise that primarily targets the lower back and glutes. It is typically performed on a machine specifically designed for reverse hyperextensions.',
    'Adjust the machine to your bodys proportions and maintain proper alignment, Keep your core engaged and use a controlled motion, Avoid hyperextension of the lower back to prevent strain.',
  ),
  WorkoutTips(
    'Lever_Reverse_T_Bar_Row',
    'The Lever Reverse T-Bar Row is an exercise that targets the upper back and middle back muscles. It is performed on a machine designed for T-bar rowing.',
    'Maintain proper posture and ensure your back is supported, Keep your back straight and perform the row with controlled movements, Focus on squeezing your back muscles at the end of the row.',
  ),

  ///
  WorkoutTips(
    'Lever_Seated_Reverse',
    'The Lever Seated Reverse exercise typically targets the upper back and rear deltoid muscles. It is performed on a machine with a lever arm.',
    'Maintain proper posture and adjust the machine to your bodys proportions, Keep your back straight and perform the reverse motion with controlled movements, Focus on squeezing your upper back and rear deltoid muscles.',
  ),
  WorkoutTips(
    'Lever_Seated_Reverse_Fly',
    'The Lever Seated Reverse Fly is a shoulder and upper back exercise. It is typically performed on a machine with a lever arm.',
    'Maintain proper posture and adjust the machine to your bodys proportions, Perform the reverse fly with controlled, smooth movements, Focus on engaging your rear deltoid muscles during the exercise.',
  ),
  WorkoutTips(
    'Lever_Standing_Hip_Extension',
    'The Lever Standing Hip Extension targets the glutes and hamstrings. It is performed on a machine designed for hip extension exercises.',
    'TAdjust the machine to your bodys proportions and maintain proper alignment, Keep your core engaged and extend your hips with controlled movements, Avoid using momentum to lift the weight.',
  ),
  WorkoutTips(
    'Lever_Standing_Hip_Extensionn', //here my man
    'Description of the exercise',
    'Tips for the exercise',
  ),
  WorkoutTips(
    'Lever_Standing_Rear_Kick',
    'The Lever Standing Rear Kick targets the glutes and hamstrings. It is performed on a machine that allows you to perform rear leg kicks.',
    'Adjust the machine to your bodys proportions and maintain proper posture, Keep your core engaged and perform the rear kick with control, Focus on engaging your glutes and hamstrings during the movement.',
  ),
  WorkoutTips(
    'Lever_T-Bar_Row',
    'The Lever T-Bar Row is an exercise that targets the upper back and middle back muscles. It is performed on a machine designed for T-bar rowing.',
    'Maintain proper posture and ensure your back is supported, Keep your back straight and perform the row with controlled movements, Focus on squeezing your back muscles at the end of the row.',
  ),
  WorkoutTips(
    'Lever_T-Bar_Row_2',
    'The Lever T-Bar Row is an exercise that targets the upper back and middle back muscles. It is performed on a machine designed for T-bar rowing.',
    'Maintain proper posture and ensure your back is supported, Keep your back straight and perform the row with controlled movements, Focus on squeezing your back muscles at the end of the row.',
  ),
  WorkoutTips(
    'Lever_Teverse_Hyperextension',
    'The Lever Reverse Hyperextension is an exercise that primarily targets the lower back and glutes. It is typically performed on a machine specifically designed for reverse hyperextensions.',
    'Adjust the machine to your bodys proportions and maintain proper alignment, Keep your core engaged and use a controlled motion, Avoid hyperextension of the lower back to prevent strain.',
  ),
  WorkoutTips(
    'Lying_Supine_Dumbbell_Curl',
    'The Lying Supine Dumbbell Curl is an arm exercise that primarily targets the biceps. It is performed while lying supine on a bench, allowing you to isolate the biceps with dumbbells.',
    'Lie flat on a bench with your back supported and your feet flat on the ground, Keep your upper arms stationary and curl the dumbbells with controlled movements, Use a controlled and smooth tempo without swinging the dumbbells.',
  ),
  WorkoutTips(
    'Military_Press',
    'The Military Press, also known as the Overhead Press, is a shoulder exercise that primarily targets the deltoid muscles. It is performed by pressing a barbell or dumbbells overhead while standing or sitting.',
    'Maintain proper posture and engage your core for stability, Press the weight overhead with controlled movements, Avoid leaning back excessively or using momentum during the press.',
  ),
  WorkoutTips(
    'Military_Press_2',
    'The Military Press, also known as the Overhead Press, is a shoulder exercise that primarily targets the deltoid muscles. It is performed by pressing a barbell or dumbbells overhead while standing or sitting.',
    'Maintain proper posture and engage your core for stability, Press the weight overhead with controlled movements, Avoid leaning back excessively or using momentum during the press.',
  ),
  WorkoutTips(
    'Pull_Up',
    'The Pull-Up is a bodyweight exercise that primarily targets the back and biceps. It is performed by hanging from a horizontal bar and pulling your body up to the bar.',
    'Hang from the bar with your hands slightly wider than shoulder-width apart, Keep your core engaged and pull your body up with control, Lower your body back down with controlled movements.',
  ),
  WorkoutTips(
    'Pull_Up_2',
    'The Pull-Up is a bodyweight exercise that primarily targets the back and biceps. It is performed by hanging from a horizontal bar and pulling your body up to the bar.',
    'Hang from the bar with your hands slightly wider than shoulder-width apart, Keep your core engaged and pull your body up with control, Lower your body back down with controlled movements.',
  ),
  WorkoutTips(
    'Push_Ups',
    'Push-Ups are a bodyweight exercise that primarily targets the chest, shoulders, and triceps. They are performed by assuming a plank position and pushing your body up from the ground.',
    'Maintain a straight line from head to heels by engaging your core, Lower your chest to the ground and push back up, Perform the push-ups with control and focus on chest engagement.',
  ),
  WorkoutTips(
    'Push_Ups_Weights',
    'The Push-Ups Weights variation involves adding weight plates or other forms of resistance to traditional push-ups.',
    'Tips for the exercise',
  ),
  WorkoutTips(
    'Reverse_Grip_Machine',
    'The Reverse Grip Machine exercise typically targets the biceps and forearm muscles. It is performed on a machine designed for reverse grip curls.',
    'Adjust the machine to your bodys proportions and maintain proper alignment, Keep your grip in a reverse position (palms facing up) and curl with controlled movements, Focus on engaging your upper back muscles during the exercise.',
  ),
  WorkoutTips(
    'Reverse_Grip_Machine_Lat_Pull_Down',
    'The Reverse Grip Machine exercise typically targets the biceps and forearm muscles. It is performed on a machine designed for reverse grip curls.',
    'Adjust the machine to your bodys proportions and maintain proper alignment, Keep a reverse grip (palms facing up) and perform the lat pull down with controlled movements, Focus on engaging your upper back muscles during the exercise.',
  ),
  WorkoutTips(
    'Smith_Deadlift',
    'The Smith Deadlift is a variation of the traditional deadlift exercise. It targets multiple muscle groups, including the lower back, glutes, hamstrings, and more. It is performed using a Smith machine.',
    'Set up the bar on the Smith machine and adjust the height, Maintain proper posture with a neutral spine and engage your core, Lift the barbell with controlled movements, keeping it close to your body.',
  ),
  WorkoutTips(
    'Smith_Deadlift_2',
    'The Smith Deadlift is a variation of the traditional deadlift exercise. It targets multiple muscle groups, including the lower back, glutes, hamstrings, and more. It is performed using a Smith machine.',
    'Set up the bar on the Smith machine and adjust the height, Maintain proper posture with a neutral spine and engage your core, Lift the barbell with controlled movements, keeping it close to your body.',
  ),
  WorkoutTips(
    'Smith_Seated_Shoulder',
    'The Smith Seated Shoulder exercise primarily targets the deltoid muscles. It is performed on a Smith machine with a seated position.',
    'Adjust the machine to your bodys proportions and maintain proper alignment, Press the barbell overhead with controlled movements, Engage your core for stability during the exercise.',
  ),
  WorkoutTips(
    'Smith_Seated_Shoulder_Press',
    'The Smith Seated Shoulder Press is a shoulder exercise that targets the deltoid muscles. It is performed on a Smith machine with a seated position.',
    'Adjust the machine to your bodys proportions and maintain proper alignment, Press the barbell overhead with controlled movements, Engage your core for stability during the exercise.',
  ),

  ///
  WorkoutTips(
    'Streaching_Hamstring_Stretch',
    'The Hamstring Stretch is a stretching exercise that targets the hamstring muscles in the back of the thigh.',
    'Sit or lie down with one leg extended, Bend the other leg and reach for your toes, keeping your back straight, Hold the stretch for 15-30 seconds and repeat on the other leg.',
  ),
  WorkoutTips(
    'Streaching_Middle_Back_Stretch',
    'The Middle Back Stretch is a stretching exercise that aims to release tension in the middle and upper back.',
    'Sit or stand with your feet shoulder-width apart, Interlace your fingers in front of you, round your back, and push your hands away from your body, Hold the stretch for 15-30 seconds.',
  ),
  WorkoutTips(
    'Streaching-_Spine_Stretch',
    'The Spine Stretch involves stretching and lengthening the spine, promoting flexibility and relieving back tension.',
    'Sit on the floor with your legs extended, Reach forward, aiming to touch your toes or the floor while keeping your back straight, Hold the stretch for 15-30 seconds.',
  ),
  WorkoutTips(
    'Streaching-Kneeling_Lst_Stretch',
    'The Kneeling Lst Stretch is used to stretch and relieve tension in the lower back.',
    'Kneel on the floor with your legs and feet together, Sit back on your heels and reach your arms forward, Hold the stretch for 15-30 seconds.',
  ),
  WorkoutTips(
    'Streaching-Seated_Lower_Back_Stretch',
    'The Seated Lower Back Stretch is designed to target and relieve tension in the lower back.',
    'Sit on the floor with your legs extended, Bend one leg and cross it over the other, twisting your upper body toward the bent knee, Hold the stretch for 15-30 seconds on each side.',
  ),
  WorkoutTips(
    'Streaching-Spine_Stretch_Forward',
    'The Spine Stretch Forward is used to stretch and mobilize the spine.',
    'Sit with your legs extended and feet flexed, Reach your arms forward and try to touch your toes, keeping your back rounded, Hold the stretch for 15-30 seconds.',
  ),
  WorkoutTips(
    'Streaching-Standing_Back_Rotation_Streach',
    'The Standing Back Rotation Stretch involves twisting the upper body to stretch and improve flexibility in the back and obliques.',
    'Stand with your feet shoulder-width apart, Twist your upper body to one side, keeping your lower body stable, Hold the stretch for 15-30 seconds on each side.',
  ),
  WorkoutTips(
    'Stretching-_Above_Head',
    'The Above Head Stretch involves reaching your arms overhead to stretch the upper body and shoulders.',
    'Stand with your feet hip-width apart, Extend your arms overhead and reach for the sky, Hold the stretch for 15-30 seconds',
  ),
  WorkoutTips(
    'Stretching-_Back',
    'The Back Stretch can refer to various stretches targeting the muscles of the back. Its important to specify which specific back stretch youre referring to for detailed tips.',
    '',
  ),
  WorkoutTips(
    'Stretching-_Back_Pec_Stretch',
    'The Back Pec Stretch involves stretching the pectoral (chest) muscles to improve posture and relieve tension.',
    'Stand or sit with your back straight, Interlace your fingers behind your back and gently pull your arms upward to open your chest, Hold the stretch for 15-30 seconds.',
  ),
  WorkoutTips(
    'Stretching-_Band',
    'The Band Stretch can refer to various stretches using resistance bands.',
    '',
  ),
  WorkoutTips(
    'Stretching-_Butterfly_Yoga_Pose',
    'The Butterfly Yoga Pose, also known as Baddha Konasana, stretches the inner thighs and groins.',
    'Sit with your feet together and knees bent outward, Bring your heels toward your pelvis and hold your feet with your hands, Gently press your knees toward the floor to deepen the stretch.',
  ),
  WorkoutTips(
    'Stretching-_Dynamic',
    'Dynamic stretching involves active movements that mimic the motions of the workout to come.',
    '',
  ),
  WorkoutTips(
    'Stretching-_Dynamic_2',
    'Dynamic stretching involves active movements that mimic the motions of the workout to come. ',
    '',
  ),
  WorkoutTips(
    'Stretching-_Elbows',
    'The Elbows Stretch can refer to stretches specifically targeting the elbow joint or surrounding muscles.',
    '',
  ),
  WorkoutTips(
    'Stretching-_Kneelin',
    'The Kneeling Stretch can refer to various stretches performed in a kneeling position.',
    '',
  ),
  WorkoutTips(
    'Stretching-_Kneelin_2',
    'The Kneeling Stretch can refer to various stretches performed in a kneeling position.',
    '',
  ),
  WorkoutTips(
    'Stretching-_Middle',
    'The Middle Stretch can refer to various stretches targeting the middle part of the body.',
    '',
  ),
  WorkoutTips(
    'Stretching-_Rear',
    'The Rear Stretch can refer to various stretches targeting the rear part of the body.',
    '',
  ),
  WorkoutTips(
    'Stretching-_Seated',
    'The Seated Stretch can refer to various stretches performed while seated. ',
    '',
  ),
  WorkoutTips(
    'Stretching-_Seated_2',
    'The Seated Stretch can refer to various stretches performed while seated. ',
    '',
  ),
  WorkoutTips(
    'Stretching-_Seated_3',
    'The Seated Stretch can refer to various stretches performed while seated. ',
    '',
  ),
  WorkoutTips(
    'Stretching-_Sitting',
    'The Sitting Stretch can refer to various stretches performed while sitting. ',
    '',
  ),
  WorkoutTips(
    'Stretching-_Slopes',
    ' The Slopes Stretch can refer to various stretches that involve leaning or sloping motions.',
    'T',
  ),
  WorkoutTips(
    'Stretching-_Spine',
    ' The Spine Stretch can refer to various stretches targeting the spines flexibility and mobility.',
    '',
  ),
  WorkoutTips(
    'Stretching-_Standin',
    'The Standin Stretch can refer to various stretches performed while standing.',
    '',
  ),
  WorkoutTips(
    'Stretching-_Standin_2',
    'The Standin Stretch can refer to various stretches performed while standing.',
    '',
  ),
  WorkoutTips(
    'Stretching-_Standin_3',
    'The Standin Stretch can refer to various stretches performed while standing.',
    '',
  ),
  WorkoutTips(
    'Stretching-_Standin_4',
    'The Standin Stretch can refer to various stretches performed while standing.',
    '',
  ),
  WorkoutTips(
    'Stretching-_Standing_Wheel_Rollout',
    'The Standing Wheel Rollout involves stretching the abdominal and lower back muscles using an exercise wheel or similar equipment.',
    'Kneel on the floor with the wheel in front of you, Roll the wheel forward, keeping your back straight, and extend your body as far as you comfortably can, Roll the wheel back to the starting position.',
  ),
  WorkoutTips(
    'Stretching-_Above_Head_Chest_Stretch',
    'The Above Head Chest Stretch involves stretching the chest and shoulder muscles by reaching the arms overhead.',
    'Stand with your feet hip-width apart, Extend your arms overhead and reach for the sky, Hold the stretch for 15-30 seconds.',
  ),
  WorkoutTips(
    'Stretching-_Band_Warm-Up_Shoulder_Stretch',
    'The Band Warm-Up Shoulder Stretch involves using a resistance band to stretch and warm up the shoulder muscles.',
    'Hold one end of the resistance band with your hand and the other end with your opposite hand behind your back, Gently pull the band to stretch your shoulders, Hold the stretch for 15-30 seconds on each side.',
  ),
  WorkoutTips(
    'Stretching-_Dynamiy_Chest_Stretch',
    ' The Dynamic Chest Stretch is an active stretching exercise for the chest muscles',
    '',
  ),
  WorkoutTips(
    'Stretching-_Elbows_Back_Stretch',
    'The Elbows Back Stretch can refer to stretches specifically targeting the elbow joint or surrounding muscles.',
    '',
  ),
  WorkoutTips(
    'Stretching-_Kneeling_Back_Rotation_Streach',
    'The Kneeling Back Rotation Stretch is used to stretch and mobilize the back and oblique muscles.',
    'Kneel on the floor with your legs and feet together, Rotate your upper body to one side while keeping your lower body stable, Hold the stretch for 15-30 seconds on each side.',
  ),
  WorkoutTips(
    'Stretching-_Rear_Deltoid_Stretch',
    'The Rear Deltoid Stretch involves stretching the rear deltoid muscles, which are located in the back of the shoulders.',
    'Extend one arm across your chest and use your opposite hand to gently pull it closer to your body, Hold the stretch for 15-30 seconds on each arm.',
  ),
  WorkoutTips(
    'Stretching-_Standing_Lateral_Streach',
    'The Standing Lateral Stretch is used to stretch the side of the body, including the oblique muscles.',
    'Stand with your feet shoulder-width apart, Reach one arm overhead and lean to the opposite side, Hold the stretch for 15-30 seconds on each side.',
  ),
  WorkoutTips(
    'Stretching-_Standing_Reach_Up_Back_Rotation',
    'The Standing Reach Up Back Rotation Stretch involves reaching upward and rotating the upper body to stretch the back and oblique muscles.',
    'Stand with your feet hip-width apart, Reach both arms overhead and rotate your upper body to one side, Hold the stretch for 15-30 seconds on each side.',
  ),
  WorkoutTips(
    'Stretching-Dynamic_Back_Stretch',
    'Dynamic back stretching involves active movements that target the muscles of the back.',
    '',
  ),
  WorkoutTips(
    'Stretching-Seated_Should_Flexour_Depressor_Retract',
    'The Seated Shoulder Flexor Depressor Retract Stretch can refer to various seated stretches focusing on the shoulder flexor, depressor, or retractor muscles.',
    '',
  ),
  WorkoutTips(
    'Wide_Grip_Push-_Ups',
    'Wide Grip Push-Ups are a variation of the traditional push-up exercise where the hands are placed wider than shoulder-width apart.',
    'Start in a push-up position with your hands wider than shoulder-width apart, Keep your body straight and engage your core, Lower your chest toward the ground, then push back up to the starting position.',
  ),
  WorkoutTips(
    'Wide_Grip_Push-Ups',
    'Wide Grip Push-Ups are a variation of the traditional push-up exercise where the hands are placed wider than shoulder-width apart.',
    'Start in a push-up position with your hands wider than shoulder-width apart, Keep your body straight and engage your core, Lower your chest toward the ground, then push back up to the starting position.',
  ),
  WorkoutTips(
    'Widegrip_Push_Ups',
    'Widegrip Push-Ups, like Wide Grip Push-Ups, are a variation of the traditional push-up exercise with hands placed wider than shoulder-width apart.',
    'Start in a push-up position with your hands wider than shoulder-width apart, Keep your body straight and engage your core, Lower your chest toward the ground, then push back up to the starting position.',
  ),
];

// List<String> savedWorkouts2 = [
//   "Custom",
//   "Barbell_bench_Chest_Press",
//   "Barbell_bench_press",
//   "Barbell_Bent_over",
//   "Barbell_Decline_Benc",
//   "Barbell_front_raise",
//   "Barbell_incline_bench_press",
//   "Barbell_Seated_Behin",
//   "Barbell_Straight_Leg",
//   "Barbell_Underhand",
//   "Barbell_Underhand_2",
//   "Barbell_Upright_Row",
//   "Barebell_bent_over_row",
//   "Barebell_curl",
//   "Barebell_decline_bench_press",
//   "Barebell_drag_curl",
//   "Barebell_incline_bench_press",
//   "Barebell_lungs",
//   "Barebell_prone_incline_curl",
//   "barebell_seated_behind_head_military_press",
//   "Barebell_straight_leg_deadlift",
//   "Barebell_underhand_bent_over_row",
//   "Cable_Bar_Lateral",
//   "Cable_bsr_lateral_pull-down",
//   "Cable_bsr_lateral_pulldown",
//   "Cable_bsr_pull-down",
//   "Cable_Crossover_reverse",
//   "cable_crossover_reverse_fly",
//   "Cable_front_raise",
//   "Cable_Front_Raise_2",
//   "Cable_lateral_raise",
//   "Cable_Lateral_Raise_3",
//   "Cable_lying_fly_flat_bench_cable_fly",
//   "Cable_one_arm_curl",
//   "Cable_One_Arm_ForwardF",
//   "Cable_one_arm_forward_raise",
//   "Cable_One_Arm_Latera",
//   "Cable_one_arm_lateral_pull-down",
//   "Cable_one_arm_lateral_raise",
//   "Cable_One_Arm_Latera_2",
//   "Cable_One_Arm_Latera_3",
//   "Cable_one_arm_twisting_seated_row",
//   "Cable_pull-down",
//   "cable_pull-downs",
//   "Cable_Pulldown",
//   "Cable_Rear_Delt_Row",
//   "Cable_rear_delt_row_with_rope",
//   "Cable_Seated_High_Ro",
//   "Cable_seated_high_row",
//   "Cable_seated_row",
//   "Cable_Seated_Row_2",
//   "Cable_seated_row_normal_grip",
//   "Cable_seated_row_parallel_grip",
//   "Cable_Standing_Fly_2",
//   "Cable_standing_fly_crossover_fly",
//   "Cable_standing_inner_curl",
//   "Cable_standing__Fly",
//   "Cable_Straight_Arm",
//   "Cable_straight_arm_pull-down",
//   "Cable_Straight_Back",
//   "Cable_straight_back_seated_row",
//   "Cambered_bar_lying_row",
//   "Chest_dips",
//   "Chest_Dips_2",
//   "Chest_Dips_3",
//   "Chest_Dips_4",
//   "Chin-ups",
//   "Chin-ups__Pull-ups",
//   "Chin-up_or_pull-ups",
//   "chin-_ups_narrow_parallel_grip",
//   "Commando_pull-_up",
//   "Decline_barbell_bench_press",
//   "Decline_Dumbbell_Ben",
//   "Decline_dumbbell_bench_press_45_degree",
//   "Deep_push_-_ups",
//   "Dumbbell_Alternate",
//   "Dumbbell_alternate_biceps_curl",
//   "Dumbbell_alternate_shoulder_press",
//   "Dumbbell_Arnold_press",
//   "Dumbbell_Arnold_Press_2",
//   "Dumbbell_bench_fly",
//   "Dumbbell_bench_press",
//   "Dumbbell_Bench_Press_2",
//   "Dumbbell_bench_press_3",
//   "Dumbbell_Bench_Seated",
//   "Dumbbell_bench_seated_press",
//   "Dumbbell_Bent-over_gym",
//   "Dumbbell_bent_-_over_row",
//   "Dumbbell_Biceps_curl",
//   "Dumbbell_concentration_curl",
//   "Dumbbell_cross_body_hammer_curl",
//   "Dumbbell_deadlift",
//   "Dumbbell_Decline_Fly",
//   "Dumbbell_decline_fly_45_degree",
//   "Dumbbell_fly",
//   "Dumbbell_front_raise",
//   "Dumbbell_Front_Raise_2",
//   "Dumbbell_incline_bench_press",
//   "Dumbbell_incline_biceps_curl",
//   "dumbbell_incline_fly",
//   "Dumbbell_Incline_Fly_2",
//   "Dumbbell_incline_hammer_curl",
//   "Dumbbell_incline_row",
//   "Dumbbell_Incline_Row_2",
//   "Dumbbell_iron_cross",
//   "Dumbbell_Iron_Cross_2",
//   "Dumbbell_Lateral_Rai",
//   "Dumbbell_lateral_raise",
//   "Dumbbell_lying_hammer_press",
//   "Dumbbell_Rear_Delt",
//   "Dumbbell_rear_delt_row",
//   "Dumbbell_rear_delt_roww",
//   "Dumbbell_Rear_Latera",
//   "Dumbbell_rear_lateral_raise",
//   "Dumbbell_seated_lateral_raise",
//   "Dumbbell_seated_preacher_curl",
//   "Dumbbell_single_leg_squat",
//   "Dumbell_lunge",
//   "Dumbell_stiff_leg_deadlift",
//   "EZ_Barbell_Anti_Gravity",
//   "EZ_barbell_anti_gravity_press",
//   "EZ_barebell_curl",
//   "Incline_push_-_ups",
//   "Lever_-_T_bar_row",
//   "Lever_back_extension",
//   "Lever_Back_Extension_2",
//   "Lever_chest_press",
//   "Lever_high_row",
//   "Lever_High_Row_2",
//   "Lever_High_Row__3",
//   "Lever_horizontal_leg_press",
//   "lever_incline_hammer_chest_press",
//   "Lever_incline_hammer_chest_press_2",
//   "Lever_kneeling_leg_curl",
//   "Lever_lateral_raise",
//   "Lever_Lateral_Raise_2",
//   "Lever_leg_extension",
//   "Lever_Lying_Chest",
//   "Lever_lying_chest_press_2",
//   "Lever_lying_chest_press_3",
//   "Lever_lying_chest__press",
//   "Lever_military_press",
//   "Lever_Military_Press_2",
//   "Lever_pec_deck_fly",
//   "Lever_preacher_curl",
//   "Lever_Reverse_Hypere",
//   "Lever_reverse_T_bar_row",
//   "Lever_Seated_Reverse",
//   "Lever_seated_reverse_fly",
//   "Lever_standing_hip_extension",
//   "Lever_standing_hip_extensionn",
//   "Lever_standing_rear_kick",
//   "Lever_T-bar_Row",
//   "Lever_T-bar_Row_2",
//   "Lever_teverse_hyperextension",
//   "Lying_supine_dumbbell_curl",
//   "Military_press",
//   "Military_Press_2",
//   "Pull_up",
//   "Pull_up_2",
//   "Push_ups",
//   "Push_ups_weights",
//   "Reverse_Grip_Machine",
//   "Reverse_grip_machine_lat_pull_down",
//   "Smith_deadlift",
//   "Smith_Deadlift_2",
//   "Smith_Seated_Shoulder",
//   "Smith_seated_shoulder_press",
//   "Streaching-kneeling_lst_stretch",
//   "Streaching-seated_lower_back_stretch",
//   "Streaching-spine_stretch_forward",
//   "Streaching-standing_back_rotation_streach",
//   "Streaching-_spine_stretch",
//   "Streaching_Hamstring_Stretch",
//   "Streaching_middle_back_stretch",
//   "Stretching-dynamic_back_stretch",
//   "Stretching-seated_should_flexour_depressor_retract",
//   "Stretching-_above_head_chest_stretch",
//   "Stretching-_band_warm-up_shoulder_stretch",
//   "Stretching-_dynamiy_chest_stretch",
//   "Stretching-_elbows_back_stretch",
//   "Stretching-_kneeling_back_rotation_streach",
//   "Stretching-_rear_deltoid_stretch",
//   "Stretching-_standing_lateral_streach",
//   "Stretching-_standing_reach_up_back_rotation",
//   "Stretching_-_Above_Head",
//   "Stretching_-_Back",
//   "Stretching_-_back_pec_stretch",
//   "Stretching_-_Band",
//   "Stretching_-_butterfly_yoga_pose",
//   "Stretching_-_Dynamic",
//   "Stretching_-_Dynamic_2",
//   "Stretching_-_Elbows",
//   "Stretching_-_Kneelin",
//   "Stretching_-_Kneelin_2",
//   "Stretching_-_Middle",
//   "Stretching_-_Rear",
//   "Stretching_-_Seated",
//   "Stretching_-_Seated_2",
//   "Stretching_-_Seated_3",
//   "Stretching_-_Sitting",
//   "Stretching_-_Slopes",
//   "Stretching_-_Spine",
//   "Stretching_-_Standin",
//   "Stretching_-_standing_wheel_rollout",
//   "Stretching_-_Standin_2",
//   "Stretching_-_Standin_3",
//   "Stretching_-_Standin_4",
//   "Widegrip_push_ups",
//   "Wide_Grip_Push-ups",
//   "Wide_grip_push-_ups",
//   "_45_Degree_Hyperexten",
//   "_45_degree_hyperextension_arms_in_front_of_chest_exercise"
// ];
