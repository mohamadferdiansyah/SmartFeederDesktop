class HalterSensorThresholdModel {
  final String sensorName; // e.g. "temperature", "heartRate", "spo", "respiratoryRate"
  final double minValue;
  final double maxValue;

  HalterSensorThresholdModel({
    required this.sensorName,
    required this.minValue,
    required this.maxValue,
  });

  Map<String, dynamic> toJson() => {
    'sensorName': sensorName,
    'minValue': minValue,
    'maxValue': maxValue,
  };

  factory HalterSensorThresholdModel.fromJson(Map<String, dynamic> json) =>
      HalterSensorThresholdModel(
        sensorName: json['sensorName'],
        minValue: (json['minValue'] as num).toDouble(),
        maxValue: (json['maxValue'] as num).toDouble(),
      );
}