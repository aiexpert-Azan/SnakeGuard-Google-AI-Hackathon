class Hospital {
  final String name;
  final String address;
  final String distance;
  final String mapsUrl;

  Hospital({
    required this.name,
    required this.address,
    required this.distance,
    required this.mapsUrl,
  });

  factory Hospital.fromJson(Map<String, dynamic> json) {
    return Hospital(
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      distance: json['distance'] as String? ?? (json['distance_km'] != null ? '${json['distance_km']} km' : '2.5 km'),
      mapsUrl: json['maps_url'] as String? ?? json['maps_link'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'distance': distance,
      'maps_url': mapsUrl,
    };
  }
}
