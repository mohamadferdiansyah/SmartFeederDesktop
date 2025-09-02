class HalterDeviceCalibrationOffsetModel {
  final String deviceId;
  final double temperatureOffset;
  final double heartRateOffset;
  final double spoOffset;
  final double respirationOffset;
  final DateTime updatedAt;

  HalterDeviceCalibrationOffsetModel({
    required this.deviceId,
    required this.temperatureOffset,
    required this.heartRateOffset,
    required this.spoOffset,
    required this.respirationOffset,
    required this.updatedAt,
  });

  factory HalterDeviceCalibrationOffsetModel.fromJson(Map<String, dynamic> json) =>
      HalterDeviceCalibrationOffsetModel(
        deviceId: json['deviceId'],
        temperatureOffset: (json['temperatureOffset'] ?? 0).toDouble(),
        heartRateOffset: (json['heartRateOffset'] ?? 0).toDouble(),
        spoOffset: (json['spoOffset'] ?? 0).toDouble(),
        respirationOffset: (json['respirationOffset'] ?? 0).toDouble(),
        updatedAt: DateTime.parse(json['updatedAt']),
      );

  Map<String, dynamic> toJson() => {
        'deviceId': deviceId,
        'temperatureOffset': temperatureOffset,
        'heartRateOffset': heartRateOffset,
        'spoOffset': spoOffset,
        'respirationOffset': respirationOffset,
        'updatedAt': updatedAt.toIso8601String(),
      };
}