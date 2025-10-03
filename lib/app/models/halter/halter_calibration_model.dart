class HalterCalibrationModel {
  final String deviceId;
  final double temperatureSlope;
  final double temperatureIntercept;
  final double heartRateSlope;
  final double heartRateIntercept;
  final double respirationSlope;
  final double respirationIntercept;
  final DateTime updatedAt;

  HalterCalibrationModel({
    required this.deviceId,
    required this.temperatureSlope,
    required this.temperatureIntercept,
    required this.heartRateSlope,
    required this.heartRateIntercept,
    required this.respirationSlope,
    required this.respirationIntercept,
    required this.updatedAt,
  });

  factory HalterCalibrationModel.fromJson(Map<String, dynamic> json) =>
      HalterCalibrationModel(
        deviceId: json['deviceId'],
        temperatureSlope: (json['temperatureSlope'] ?? 1.0).toDouble(),
        temperatureIntercept: (json['temperatureIntercept'] ?? 0.0).toDouble(),
        heartRateSlope: (json['heartRateSlope'] ?? 1.0).toDouble(),
        heartRateIntercept: (json['heartRateIntercept'] ?? 0.0).toDouble(),
        respirationSlope: (json['respirationSlope'] ?? 1.0).toDouble(),
        respirationIntercept: (json['respirationIntercept'] ?? 0.0).toDouble(),
        updatedAt: DateTime.parse(json['updatedAt']),
      );

  Map<String, dynamic> toJson() => {
        'deviceId': deviceId,
        'temperatureSlope': temperatureSlope,
        'temperatureIntercept': temperatureIntercept,
        'heartRateSlope': heartRateSlope,
        'heartRateIntercept': heartRateIntercept,
        'respirationSlope': respirationSlope,
        'respirationIntercept': respirationIntercept,
        'updatedAt': updatedAt.toIso8601String(),
      };

  // Factory untuk default values per device
  factory HalterCalibrationModel.defaultForDevice(String deviceId) =>
      HalterCalibrationModel(
        deviceId: deviceId,
        temperatureSlope: 0.03988603989,
        temperatureIntercept: 34.59280627,
        heartRateSlope: 0.01497044188,
        heartRateIntercept: 44.09126866,
        respirationSlope: 0.005082592122,
        respirationIntercept: 16.24650572,
        updatedAt: DateTime.now(),
      );
}