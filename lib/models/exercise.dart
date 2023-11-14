//we can build in the website 'quicktype'  a convert from json to map, make sure to select dart as the language

// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

import 'package:equatable/equatable.dart';

Exercise exerciseFromJson(String str, int index, int startTime) =>
    Exercise.fromJson(json.decode(str), index, startTime);

String exerciseToJson(Exercise data) => json.encode(data.toJson());

class Exercise extends Equatable {
  final String? title;
  final int? prelude;
  final int? duration;
  final int? index;
  final int? startTime;
  final int? sets;

  const Exercise({
    required this.title,
    required this.prelude,
    required this.duration,
    this.index,
    this.startTime,
    this.sets,
  });

  factory Exercise.fromJson(
          Map<String, dynamic> json, int index, int startTime) =>
      Exercise(
        title: json["title"],
        prelude: json["prelude"],
        duration: json["duration"],
        index: index,
        startTime: startTime,
        sets: json["sets"],
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "prelude": prelude,
        "duration": duration,
        "sets": sets,
      };

  Exercise copyWith({
    int? prelude,
    String? title,
    int? duration,
    int? index,
    int? startTime,
    int? sets,
  }) =>
      Exercise(
          prelude: prelude ?? this.prelude,
          title: title ?? this.title,
          duration: duration ?? this.duration,
          index: index ?? this.index,
          startTime: startTime ?? this.startTime,
          sets: sets ?? this.sets);

  @override
  List<Object?> get props => [title, prelude, duration, index, startTime, sets];

  @override
  bool get stringify => true;
}
