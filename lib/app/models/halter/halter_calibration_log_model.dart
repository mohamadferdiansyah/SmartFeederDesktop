class HalterCalibrationLogModel {
  final String deviceId;
  final DateTime timestamp;
  final String sensorName;
  final String referensi;
  final String sensorValue;
  final String nilaiKalibrasi;

  HalterCalibrationLogModel({
    required this.deviceId,
    required this.timestamp,
    required this.sensorName,
    required this.referensi,
    required this.sensorValue,
    required this.nilaiKalibrasi,
  });

  Map<String, dynamic> toJson() => {
    'deviceId': deviceId,
    'timestamp': timestamp.toIso8601String(),
    'sensorName': sensorName,
    'referensi': referensi,
    'sensorValue': sensorValue,
    'nilaiKalibrasi': nilaiKalibrasi,
  };

  factory HalterCalibrationLogModel.fromJson(Map<String, dynamic> json) =>
      HalterCalibrationLogModel(
        deviceId: json['deviceId'],
        timestamp: DateTime.parse(json['timestamp']),
        sensorName: json['sensorName'],
        referensi: json['referensi'],
        sensorValue: json['sensorValue'],
        nilaiKalibrasi: json['nilaiKalibrasi'],
      );
}