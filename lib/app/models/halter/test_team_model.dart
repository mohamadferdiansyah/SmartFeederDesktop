class TestTeamModel {
  final String? teamName;
  final String? location;
  final DateTime? date;
  final List<String>? members;

  TestTeamModel({
    required this.teamName,
    required this.location,
    required this.date,
    required this.members,
  });

  factory TestTeamModel.fromJson(Map<String, dynamic> json) => TestTeamModel(
        teamName: json['teamName'] ?? '',
        location: json['location'] ?? '',
        date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
        members: (json['members'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'teamName': teamName,
        'location': location,
        'date': date?.toIso8601String(),
        'members': members,
      };
}