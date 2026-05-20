part of 'gemini_info.dart';

GeminiInfo _$GeminiInfoFromJson(Map<String, dynamic> json) => GeminiInfo(
      species: json['species'] as String? ?? '',
      dangerLevel: json['danger_level'] as String? ?? '',
      description: (json['description'] as String?) ?? (json['reasoning'] as String?) ?? '',
      instructions: (json['instructions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );

Map<String, dynamic> _$GeminiInfoToJson(GeminiInfo instance) => <String, dynamic>{
      'species': instance.species,
      'danger_level': instance.dangerLevel,
      'description': instance.description,
      'instructions': instance.instructions,
    };
