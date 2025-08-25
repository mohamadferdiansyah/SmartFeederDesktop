class StableModel {
  final String stableId;
  final String name;
  final String address;

  StableModel({
    required this.stableId,
    required this.name,
    required this.address,
  });

  factory StableModel.fromMap(Map<String, dynamic> map) => StableModel(
        stableId: map['stable_id'],
        name: map['name'],
        address: map['address'],
      );

  Map<String, dynamic> toMap() => {
        'stable_id': stableId,
        'name': name,
        'address': address,
      };
}