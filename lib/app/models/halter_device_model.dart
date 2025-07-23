class HalterDeviceModel {
  final String deviceId;  // serial number
  final String? horseId;  // relasi ke horse, null = tidak digunakan
  final String status;

  HalterDeviceModel({
    required this.deviceId,
    this.horseId,
    required this.status,
  });
}