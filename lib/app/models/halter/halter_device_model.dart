class HalterDeviceModel {
  final String deviceId;
  final String status;
  final int batteryPercent;
  final String? horseId;

  HalterDeviceModel({
    required this.deviceId,
    required this.status,
    required this.batteryPercent,
    this.horseId,
  });

  factory HalterDeviceModel.fromMap(Map<String, dynamic> map) => HalterDeviceModel(
    deviceId: map['device_id'],
    status: map['status'],
    batteryPercent: map['battery_percent'],
    horseId: map['horse_id'],
  );

  Map<String, dynamic> toMap() => {
    'device_id': deviceId,
    'status': status,
    'battery_percent': batteryPercent,
    'horse_id': horseId,
  };
}