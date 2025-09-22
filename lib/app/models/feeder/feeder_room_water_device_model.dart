class FeederRoomWaterDeviceModel {
  final String deviceId;
  final String? roomId;
  final String status;
  final int batteryPercent;
  final String waterRemaining;

  FeederRoomWaterDeviceModel({
    required this.deviceId,
    required this.status,
    required this.batteryPercent,
    required this.waterRemaining,
    this.roomId,
  });

  factory FeederRoomWaterDeviceModel.fromMap(Map<String, dynamic> map) =>
      FeederRoomWaterDeviceModel(
        deviceId: map['device_id'],
        roomId: map['room_id'],
        status: map['status'],
        batteryPercent: map['battery_percent'],
        waterRemaining: map['water_remaining'],
      );

  Map<String, dynamic> toMap() => {
    'device_id': deviceId,
    'room_id': roomId,
    'status': status,
    'battery_percent': batteryPercent,
    'water_remaining': waterRemaining,
  };
}
