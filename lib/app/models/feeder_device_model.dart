
class FeederDeviceModel {
  final String deviceId;
  final String? roomId; // relasi ke room
  final String status;
  final String type;

  FeederDeviceModel({
    required this.deviceId,
    this.roomId,
    required this.status,
    required this.type,
  });
}