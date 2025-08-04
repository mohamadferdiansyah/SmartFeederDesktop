class HalterDeviceModel {
  final String deviceId;
  final String? horseId;
  final String status;
  final int batteryPercent;

  HalterDeviceModel({
    required this.deviceId,
    this.horseId,
    required this.status,
    required this.batteryPercent,
  });
}