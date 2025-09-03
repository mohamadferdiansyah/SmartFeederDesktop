class HalterDeviceModel {
  final String deviceId;
  final String status;
  final int batteryPercent;
  final String? horseId;
  final String version; // Tambahkan ini

  HalterDeviceModel({
    required this.deviceId,
    required this.status,
    required this.batteryPercent,
    this.horseId,
    required this.version, // Tambahkan ini
  });

  factory HalterDeviceModel.fromMap(Map<String, dynamic> map) => HalterDeviceModel(
    deviceId: map['device_id'],
    status: map['status'],
    batteryPercent: map['battery_percent'],
    horseId: map['horse_id'],
    version: map['version'] ?? '2.0', // default jika null
  );

  Map<String, dynamic> toMap() => {
    'device_id': deviceId,
    'status': status,
    'battery_percent': batteryPercent,
    'horse_id': horseId,
    'version': version,
  };
}