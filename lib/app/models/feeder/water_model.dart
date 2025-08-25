class WaterModel {
  final String waterId;
  final String name;
  final double stock;

  WaterModel({
    required this.waterId,
    required this.name,
    required this.stock,
  });

  factory WaterModel.fromMap(Map<String, dynamic> map) => WaterModel(
        waterId: map['water_id'],
        name: map['name'],
        stock: (map['stock'] ?? 0.0).toDouble(),
      );

  Map<String, dynamic> toMap() => {
        'water_id': waterId,
        'name': name,
        'stock': stock,
      };
}