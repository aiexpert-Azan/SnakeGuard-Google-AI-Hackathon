import 'hospital.dart';
export 'hospital.dart';

class ScanResult {
  final String species;
  final String dangerLevel;
  final String reasoning;
  final List<Hospital> hospitals;
  final List<TraceLog> traceLogs;
  final String? pdfPath;

  String get description => reasoning;

  ScanResult({
    required this.species,
    required this.dangerLevel,
    required this.reasoning,
    required this.hospitals,
    required this.traceLogs,
    this.pdfPath,
  });

  factory ScanResult.fromJson(Map<String, dynamic> json) {
    final assessment = json['assessment'] as Map<String, dynamic>?;
    final analysis = assessment?['analysis'] as Map<String, dynamic>?;
    final emergencyInfo = assessment?['emergency_info'] as Map<String, dynamic>?;
    final hospitalsList = emergencyInfo?['hospitals'] as List?;

    List<Hospital> parsedHospitals = [];
    if (hospitalsList != null && hospitalsList.isNotEmpty) {
      parsedHospitals = hospitalsList.map((e) => Hospital.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      parsedHospitals = [
        Hospital(name: "Services Hospital Lahore", mapsLink: "https://www.google.com/maps?q=31.5497,74.3236", antiVenomAvailable: true),
        Hospital(name: "Mayo Hospital Lahore", mapsLink: "https://www.google.com/maps?q=31.5744,74.3142", antiVenomAvailable: true),
        Hospital(name: "Jinnah Hospital Lahore", mapsLink: "https://www.google.com/maps?q=31.4697,74.2728", antiVenomAvailable: true),
      ];
    }

    final rawLogs = json['logs'] as List?;

    return ScanResult(
      species: analysis?['species'] as String? ?? json['species'] as String? ?? 'Unknown',
      dangerLevel: analysis?['danger_level'] as String? ?? json['danger_level'] as String? ?? 'None',
      reasoning: analysis?['reasoning'] as String? ?? json['reasoning'] as String? ?? '',
      pdfPath: json['pdf_path'] as String? ?? '',
      traceLogs: rawLogs != null
          ? rawLogs.map((e) => TraceLog.fromJson(e as Map<String, dynamic>)).toList()
          : [],
      hospitals: parsedHospitals,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'species': species,
      'danger_level': dangerLevel,
      'dangerLevel': dangerLevel,
      'reasoning': reasoning,
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
