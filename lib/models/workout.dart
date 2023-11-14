import 'package:equatable/equatable.dart';
import 'package:plan_workout/models/exercise.dart';

class Workout extends Equatable {
  final String? title;
  final String? type;
  final List<Exercise> exercieses;
  const Workout(
      {required this.title, required this.type, required this.exercieses});

  factory Workout.fromJson(Map<String, dynamic> json) {
    List<Exercise> exercieses = [];
    int index = 0;
    int startTime = 0;
    for (var ex in (json['exercises']) as Iterable) {
      exercieses.add(Exercise.fromJson(ex, index, startTime));
      index++;
      startTime += exercieses.last.prelude! + exercieses.last.duration!;
    }
    return Workout(
        title: json['title'] as String?,
        type: json['type'] as String?,
        exercieses: exercieses);
  }

  Map<String, dynamic> toJson() =>
      {'title': title, 'type': type, 'exercises': exercieses};
  Workout copyWith({String? title, String? type}) => Workout(
      title: title ?? this.title,
      type: type ?? this.type,
      exercieses: exercieses);

  int getTotal() => exercieses.fold(
      0,
      (previousValue, element) =>
          previousValue + element.duration! + element.prelude!);

  Exercise getCurrentExercise(int? elapsed) =>
      //last smalled element object
      exercieses.lastWhere((element) => element.startTime! <= elapsed!);

  @override
  List<Object?> get props => [title, type, exercieses];

  @override
  bool get stringify => true;
}
