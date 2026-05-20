import 'hospital.dart';
export 'hospital.dart';

class ScanResult {
  final String? species;
  final String? dangerLevel;
  final String? reasoning;
  final String? pdfPath;
  final List<dynamic>? logs;
  final List<Hospital>? hospitals;

  ScanResult({
    this.species,
    this.dangerLevel,
    this.reasoning,
    this.pdfPath,
    this.logs,
    this.hospitals,
  });

  factory ScanResult.fromJson(Map<String, dynamic> json) {
    return ScanResult(
      species: json['assessment']?['analysis']?['species'],
      dangerLevel: json['assessment']?['analysis']?['danger_level'],
      reasoning: json['assessment']?['analysis']?['reasoning'],
      pdfPath: json['pdf_path'],
      logs: json['logs'],
      hospitals: [
        Hospital(name: 'Services Hospital Lahore', 
                 mapsLink: 'https://www.google.com/maps?q=31.5497,74.3236',
                 antiVenomAvailable: true),
        Hospital(name: 'Mayo Hospital Lahore',
                 mapsLink: 'https://www.google.com/maps?q=31.5744,74.3142', 
                 antiVenomAvailable: true),
        Hospital(name: 'Jinnah Hospital Lahore',
                 mapsLink: 'https://www.google.com/maps?q=31.4697,74.2728',
                 antiVenomAvailable: true),
      ],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'species': species,
      'danger_level': dangerLevel,
      'dangerLevel': dangerLevel,
      'reasoning': reasoning,
      'hospitals': hospitals?.map((e) => e.toJson()).toList(),
      'logs': logs,
      'pdf_path': pdfPath,
      'pdfPath': pdfPath,
    };
  }
}

class TraceLog {
  final String step;
  final String message;

  TraceLog({
    required this.step,
    required this.message,
  });

  factory TraceLog.fromJson(Map<String, dynamic> json) {
    return TraceLog(
      step: json['step'] as String? ?? '',
      message: json['message'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'step': step,
      'message': message,
    };
  }
}

