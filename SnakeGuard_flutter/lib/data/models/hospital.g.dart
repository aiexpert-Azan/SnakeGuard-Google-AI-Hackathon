part of 'hospital.dart';

Hospital _$HospitalFromJson(Map<String, dynamic> json) => Hospital(
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      mapsUrl: (json['maps_link'] as String?) ?? (json['maps_url'] as String?) ?? '',
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 2.5,
    );

Map<String, dynamic> _$HospitalToJson(Hospital instance) => <String, dynamic>{
      'name': instance.name,
      'address': instance.address,
      'maps_link': instance.mapsUrl,
      'distance_km': instance.distanceKm,
    };
