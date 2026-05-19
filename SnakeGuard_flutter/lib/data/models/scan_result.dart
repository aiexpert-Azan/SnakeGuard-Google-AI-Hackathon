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

class Hospital {
  final String name;
  final String address;
  final String mapsUrl;
  final double distanceKm;

  Hospital({
    required this.name,
    required this.address,
    required this.mapsUrl,
    this.distanceKm = 2.5,
  });

  factory Hospital.fromJson(Map<String, dynamic> json) {
    return Hospital(
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      // backend may return maps_link or maps_url
      mapsUrl: json['maps_link'] ?? json['maps_url'] ?? '',
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 2.5,
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
