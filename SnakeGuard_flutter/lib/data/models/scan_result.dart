import 'package:snakeguard_flutter/data/models/hospital.dart';
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
      species: json['species'] ?? '',
      dangerLevel: json['danger_level'] ?? '',
      description: json['description'] ?? '',
      hospitals: (json['hospitals'] as List?)
              ?.map((e) => Hospital.fromJson(e))
              .toList() ??
          [],
      traceLogs: (json['trace_logs'] as List?)
              ?.map((e) => TraceLog.fromJson(e))
              .toList() ??
          [],
      pdfPath: json['pdf_path'] ?? '',
    );
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
      step: json['step'] ?? '',
      message: json['message'] ?? '',
    );
  }
}
