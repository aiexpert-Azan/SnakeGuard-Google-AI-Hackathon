import 'hospital.g.dart';

class Hospital {
  final String name;
  final String address;
  final String mapsUrl;
  final double distanceKm;

  Hospital({
    required this.name,
    required this.address,
    required this.mapsUrl,
    required this.distanceKm,
  });

  factory Hospital.fromJson(Map<String, dynamic> json) => _$HospitalFromJson(json);

  Map<String, dynamic> toJson() => _$HospitalToJson(this);
}
