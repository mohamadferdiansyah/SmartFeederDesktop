class FeedModel {
  final String code;
  final String brand;
  final double capacity;
  final String type;

  FeedModel({
    required this.code,
    required this.brand,
    required this.capacity,
    required this.type,
  });

  factory FeedModel.fromMap(Map<String, dynamic> map) => FeedModel(
        code: map['code'],
        brand: map['brand'],
        capacity: (map['capacity'] ?? 0.0).toDouble(),
        type: map['type'],
      );

  Map<String, dynamic> toMap() => {
        'code': code,
        'brand': brand,
        'capacity': capacity,
        'type': type,
      };
}