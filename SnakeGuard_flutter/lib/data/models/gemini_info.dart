import 'gemini_info.g.dart';

class GeminiInfo {
  final String species;
  final String dangerLevel;
  final String description;
  final List<String> instructions;

  GeminiInfo({
    required this.species,
    required this.dangerLevel,
    required this.description,
    required this.instructions,
  });

  factory GeminiInfo.fromJson(Map<String, dynamic> json) => _$GeminiInfoFromJson(json);

  Map<String, dynamic> toJson() => _$GeminiInfoToJson(this);
}
