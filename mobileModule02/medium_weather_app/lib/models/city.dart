class City {
  final String name;
  final String country;
  final String region;
  final double latitude;
  final double longitude;

  City({
    required this.name,
    required this.country,
    required this.region,
    required this.latitude,
    required this.longitude,
  });

  factory City.fromJson(Map<String,dynamic> json) {
    return City(
      name: json["name"],
      country: json["country"],
      region: json["admin1"] ?? "",
      latitude: json["latitude"].toDouble(),
      longitude: json["longitude"].toDouble(),
    );
  }
}