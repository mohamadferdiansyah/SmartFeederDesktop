class HalterDeviceCalibrationModel {
  final String deviceId;
  final double temperature;
  final double heartRate;
  final double spo;
  final double respiration;
  final DateTime updatedAt;

  HalterDeviceCalibrationModel({
    required this.deviceId,
    required this.temperature,
    required this.heartRate,
    required this.spo,
    required this.respiration,
    required this.updatedAt,
  });

  factory HalterDeviceCalibrationModel.fromJson(Map<String, dynamic> json) =>
      HalterDeviceCalibrationModel(
        deviceId: json['deviceId'],
        temperature: (json['temperature'] ?? 0).toDouble(),
        heartRate: (json['heartRate'] ?? 0).toDouble(),
        spo: (json['spo'] ?? 0).toDouble(),
        respiration: (json['respiration'] ?? 0).toDouble(),
        updatedAt: DateTime.parse(json['updatedAt']),
      );

  Map<String, dynamic> toJson() => {
        'deviceId': deviceId,
        'temperature': temperature,
        'heartRate': heartRate,
        'spo': spo,
        'respiration': respiration,
        'updatedAt': updatedAt.toIso8601String(),
      };
}