class Hospital {
  final String name;
  final String mapsLink;
  final bool antiVenomAvailable;

  Hospital({
    required this.name,
    required this.mapsLink,
    required this.antiVenomAvailable,
  });

  String get mapsUrl => mapsLink;
  String get address => antiVenomAvailable ? "Anti-venom Available" : "Emergency Care Unit";
  String get distance => "Nearby";

  factory Hospital.fromJson(Map<String, dynamic> json) {
    return Hospital(
      name: json['name'] as String? ?? '',
      mapsLink: json['maps_link'] as String? ?? json['maps_url'] as String? ?? '',
      antiVenomAvailable: json['anti_venom_available'] as bool? ?? json['anti_venom'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'maps_link': mapsLink,
      'anti_venom_available': antiVenomAvailable,
    };
  }
}
