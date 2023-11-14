import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:plan_workout/blocs/workouts_cubit.dart';
import 'package:plan_workout/helpers.dart';

import 'package:plan_workout/models/workout.dart';

class EditExerciseScreen extends StatefulWidget {
  final Workout? workout;
  final int index;
  final int? exIndex;

  const EditExerciseScreen({
    Key? key,
    this.workout,
    required this.index,
    this.exIndex,
  }) : super(key: key);

  @override
  State<EditExerciseScreen> createState() => _EditExerciseScreenState();
}

class _EditExerciseScreenState extends State<EditExerciseScreen> {
  late TextEditingController _title;

  @override
  void initState() {
    _title = TextEditingController(
      text: widget.workout!.exercieses[widget.exIndex!].title,
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Add labels for each attribute
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(width: 8), // Add spacing between top row and labels
              Text(
                "Prelude",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(width: 8), // Add spacing between top row and labels
              Text(
                "Title",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(width: 8), // Add spacing between top row and labels
              Text(
                "Duration",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                "Reps",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8), // Add spacing between top row and labels

        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.delete,
                  color: Color.fromARGB(255, 104, 66, 255)),
              onPressed: () {
                _showDeleteExerciseConfirmation(context);
              },
            ),
            Expanded(
              child: InkWell(
                onLongPress: () => showDialog(
                  context: context,
                  builder: (_) {
                    final controller = TextEditingController(
                      text: widget.workout!.exercieses[widget.exIndex!].prelude!
                          .toString(),
                    );

                    return AlertDialog(
                      content: TextField(
                        controller: controller,
                        decoration: const InputDecoration(
                          labelText: "Prelude (seconds)",
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            if (controller.text.isNotEmpty) {
                              Navigator.pop(context);
                              setState(() {
                                widget.workout!.exercieses[widget.exIndex!] =
                                    widget.workout!.exercieses[widget.exIndex!]
                                        .copyWith(
                                  prelude: int.parse(controller.text),
                                );
                                BlocProvider.of<WorkoutsCubit>(context)
                                    .saveWorkout(widget.workout!, widget.index);
                              });
                            }
                          },
                          child: const Text("Save"),
                        ),
                      ],
                    );
                  },
                ),
                child: NumberPicker(
                  itemHeight: 30,
                  value: widget.workout!.exercieses[widget.exIndex!].prelude!,
                  minValue: 0,
                  maxValue: 3599,
                  textMapper: (strVal) => formatTime(int.parse(strVal), false),
                  onChanged: (value) => setState(() {
                    widget.workout!.exercieses[widget.exIndex!] = widget
                        .workout!.exercieses[widget.exIndex!]
                        .copyWith(prelude: value);
                    BlocProvider.of<WorkoutsCubit>(context)
                        .saveWorkout(widget.workout!, widget.index);
                  }),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: TextField(
                textAlign: TextAlign.center,
                controller: _title,
                onChanged: (value) => setState(() {
                  widget.workout!.exercieses[widget.exIndex!] = widget
                      .workout!.exercieses[widget.exIndex!]
                      .copyWith(title: value);
                  BlocProvider.of<WorkoutsCubit>(context)
                      .saveWorkout(widget.workout!, widget.index);
                }),
              ),
            ),
            Expanded(
              child: InkWell(
                onLongPress: () => showDialog(
                  context: context,
                  builder: (_) {
                    final controller = TextEditingController(
                      text: widget
                          .workout!.exercieses[widget.exIndex!].duration!
                          .toString(),
                    );

                    return AlertDialog(
                      content: TextField(
                        controller: controller,
                        decoration: const InputDecoration(
                          labelText: "Duration (seconds)",
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            if (controller.text.isNotEmpty) {
                              Navigator.pop(context);
                              setState(() {
                                widget.workout!.exercieses[widget.exIndex!] =
                                    widget.workout!.exercieses[widget.exIndex!]
                                        .copyWith(
                                  duration: int.parse(controller.text),
                                );
                                BlocProvider.of<WorkoutsCubit>(context)
                                    .saveWorkout(widget.workout!, widget.index);
                              });
                            }
                          },
                          child: const Text("Save"),
                        ),
                      ],
                    );
                  },
                ),
                child: NumberPicker(
                  itemHeight: 30,
                  value: widget.workout!.exercieses[widget.exIndex!].duration!,
                  minValue: 0,
                  maxValue: 3599,
                  textMapper: (strVal) => formatTime(int.parse(strVal), false),
                  onChanged: (value) => setState(() {
                    widget.workout!.exercieses[widget.exIndex!] = widget
                        .workout!.exercieses[widget.exIndex!]
                        .copyWith(duration: value);
                    BlocProvider.of<WorkoutsCubit>(context)
                        .saveWorkout(widget.workout!, widget.index);
                  }),
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onLongPress: () => showDialog(
                  context: context,
                  builder: (_) {
                    final controller = TextEditingController(
                      text: widget.workout!.exercieses[widget.exIndex!].sets
                          .toString(),
                    );

                    return AlertDialog(
                      content: TextField(
                        controller: controller,
                        decoration: const InputDecoration(
                          labelText: "Reps",
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            if (controller.text.isNotEmpty) {
                              Navigator.pop(context);
                              setState(() {
                                widget.workout!.exercieses[widget.exIndex!] =
                                    widget.workout!.exercieses[widget.exIndex!]
                                        .copyWith(
                                  sets: int.parse(controller.text),
                                );
                                BlocProvider.of<WorkoutsCubit>(context)
                                    .saveWorkout(widget.workout!, widget.index);
                              });
                            }
                          },
                          child: const Text("Save"),
                        ),
                      ],
                    );
                  },
                ),
                child: NumberPicker(
                  itemHeight: 30,
                  value: widget.workout!.exercieses[widget.exIndex!].sets!,
                  minValue: 1,
                  maxValue: 100,
                  onChanged: (value) => setState(() {
                    widget.workout!.exercieses[widget.exIndex!] = widget
                        .workout!.exercieses[widget.exIndex!]
                        .copyWith(sets: value);
                    BlocProvider.of<WorkoutsCubit>(context)
                        .saveWorkout(widget.workout!, widget.index);
                  }),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showDeleteExerciseConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content: const Text("Are you sure you want to delete this exercise?"),
          actions: [
            TextButton(
              onPressed: () {
                //Navigator.pop(dialogContext); // Close the dialog
                BlocProvider.of<WorkoutsCubit>(context)
                    .deleteExercise(widget.index, widget.exIndex!);
                Navigator.pop(context); // Close the edit exercise screen
              },
              child: const Text("Delete"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }
}
