class HalterCalibrationLogModel {
  final int id;
  final DateTime timestamp;
  final String parameter;
  final String category;
  final double referensi;
  final double sensor;
  final double value;

  HalterCalibrationLogModel({
    required this.id,
    required this.timestamp,
    required this.parameter,
    required this.category,
    required this.referensi,
    required this.sensor,
    required this.value,
  });

  factory HalterCalibrationLogModel.fromJson(Map<String, dynamic> json) {
    return HalterCalibrationLogModel(
      id: json['id'] ?? 0,
      timestamp: DateTime.tryParse(json['timestamp'] ?? "") ?? DateTime.now(),
      parameter: json['parameter'] ?? "",
      category: json['category'] ?? "",
      referensi: (json['referensi'] ?? 0).toDouble(),
      sensor: (json['sensor'] ?? 0).toDouble(),
      value: (json['value'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'parameter': parameter,
      'category': category,
      'referensi': referensi,
      'sensor': sensor,
      'value': value,
    };
  }
}
