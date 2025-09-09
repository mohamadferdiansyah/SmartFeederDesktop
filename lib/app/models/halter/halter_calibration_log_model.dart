class HalterCalibrationLogModel {
  final int? id;
  final String deviceId;
  final DateTime timestamp;
  final String sensorName;
  final String referensi;
  final String sensorValue;
  final String nilaiKalibrasi;

  HalterCalibrationLogModel({
    this.id,
    required this.deviceId,
    required this.timestamp,
    required this.sensorName,
    required this.referensi,
    required this.sensorValue,
    required this.nilaiKalibrasi,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'device_id': deviceId,
    'timestamp': timestamp.toIso8601String(),
    'sensor_name': sensorName,
    'referensi': referensi,
    'sensor_value': sensorValue,
    'nilai_kalibrasi': nilaiKalibrasi,
  };

  factory HalterCalibrationLogModel.fromMap(Map<String, dynamic> map) =>
      HalterCalibrationLogModel(
        id: map['id'],
        deviceId: map['device_id'],
        timestamp: DateTime.parse(map['timestamp']),
        sensorName: map['sensor_name'],
        referensi: map['referensi'],
        sensorValue: map['sensor_value'],
        nilaiKalibrasi: map['nilai_kalibrasi'],
      );

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