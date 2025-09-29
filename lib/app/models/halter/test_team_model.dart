class TestTeamModel {
  final String? teamName;
  final String? location;
  final DateTime? date;
  final List<String>? members;
  final double? latitude;
  final double? longitude;
  final double? altitude;

  TestTeamModel({
    required this.teamName,
    required this.location,
    required this.date,
    required this.members,
    this.latitude,
    this.longitude,
    this.altitude,
  });

  factory TestTeamModel.fromJson(Map<String, dynamic> json) => TestTeamModel(
        teamName: json['teamName'] ?? '',
        location: json['location'] ?? '',
        date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
        members: (json['members'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList(),
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        altitude: (json['altitude'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'teamName': teamName,
        'location': location,
        'date': date?.toIso8601String(),
        'members': members,
        'latitude': latitude,
        'longitude': longitude,
        'altitude': altitude,
      };
}