import 'hospital.dart';
export 'hospital.dart';

class ScanResult {
  final String species;
  final String dangerLevel;
  final String description;
  final List<Hospital> hospitals;
  final List<TraceLog> traceLogs;
  final String? pdfPath;

  ScanResult({
    required this.species,
    required this.dangerLevel,
    required this.description,
    required this.hospitals,
    required this.traceLogs,
    this.pdfPath,
  });

  factory ScanResult.fromJson(Map<String, dynamic> json) {
    return ScanResult(
      species: json['species'] as String? ?? json['snakeName'] as String? ?? '',
      dangerLevel: json['danger_level'] as String? ?? json['dangerLevel'] as String? ?? '',
      description: json['description'] as String? ?? '',
      hospitals: (json['hospitals'] as List?)
              ?.map((e) => Hospital.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      traceLogs: (json['trace_logs'] as List?)
              ?.map((e) => TraceLog.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      pdfPath: json['pdf_path'] as String? ?? json['pdfPath'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'species': species,
      'danger_level': dangerLevel,
      'dangerLevel': dangerLevel,
      'description': description,
      'hospitals': hospitals.map((e) => e.toJson()).toList(),
      'trace_logs': traceLogs.map((e) => e.toJson()).toList(),
      'traceLogs': traceLogs.map((e) => e.toJson()).toList(),
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
