import 'dart:ui';

import 'package:json_annotation/json_annotation.dart';

import 'slider_question.dart';

part 'visual_analogue_question.g.dart';

@JsonSerializable()
class VisualAnalogueQuestion extends SliderQuestion {
  static const String questionType = 'visualAnalogue';

  @JsonKey(fromJson: parseColor, toJson: colorToJson)
  Color minimumColor;
  @JsonKey(fromJson: parseColor, toJson: colorToJson)
  Color maximumColor;

  VisualAnalogueQuestion();

  factory VisualAnalogueQuestion.fromJson(Map<String, dynamic> json) => _$VisualAnalogueQuestionFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$VisualAnalogueQuestionToJson(this);

  static Color parseColor(String colorString) => Color(int.parse('${colorString.substring(1)}ff', radix: 16));
  static String colorToJson(Color color) => '#${color.value.toRadixString(16).padLeft(8, '0').substring(0, 6)}';
}
