import 'package:equatable/equatable.dart';
import 'package:plan_workout/models/workout.dart';

abstract class WorkoutState extends Equatable {
  final Workout? workout;
  final int? elapsed;
  const WorkoutState(this.workout, this.elapsed);
}

class WorkoutIntial extends WorkoutState {
  const WorkoutIntial() : super(null, 0);

  @override
  List<Object?> get props => [];
}

class WorkoutCompleted extends WorkoutState {
  const WorkoutCompleted(Workout? workout, int? elapsed)
      : super(workout, elapsed);

  @override
  List<Object?> get props => [workout, elapsed];
}

class WorkoutPaused extends WorkoutState {
  const WorkoutPaused(Workout? workout, int? elapsed) : super(workout, elapsed);

  @override
  List<Object?> get props => [workout, elapsed];
}

class WorkoutInProgress extends WorkoutState {
  const WorkoutInProgress(Workout? workout, int? elapsed)
      : super(workout, elapsed);

  @override
  List<Object?> get props => [workout, elapsed];
}

class WorkoutEditing extends WorkoutState {
  final int index;
  final int? exIndex;

  const WorkoutEditing(Workout? workout, this.index, this.exIndex)
      : super(workout, 0);

  @override
  List<Object?> get props => [workout, index, exIndex];

  WorkoutEditing copyWith(
      {required Workout workout, int? index, int? exIndex}) {
    return WorkoutEditing(
      workout, // If workout is not provided, use the existing workout
      index ?? this.index, // If index is not provided, use the existing index
      exIndex ??
          this.exIndex, // If exIndex is not provided, use the existing exIndex
    );
  }
}
