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

  factory GeminiInfo.fromJson(Map<String, dynamic> json) {
    return GeminiInfo(
      species: json['species'] as String? ?? '',
      dangerLevel: json['danger_level'] as String? ?? json['danger'] as String? ?? '',
      description: (json['description'] as String?) ?? (json['reasoning'] as String?) ?? '',
      instructions: (json['instructions'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'species': species,
      'danger_level': dangerLevel,
      'description': description,
      'instructions': instructions,
    };
  }
}
