class FeederRoomDeviceModel {
  final String deviceId;
  final String? roomId;
  final String status;
  final int batteryPercent;
  final double feedRemaining;
  final double waterRemaining;

  FeederRoomDeviceModel({
    required this.deviceId,
    required this.status,
    required this.batteryPercent,
    required this.feedRemaining,
    required this.waterRemaining,
    this.roomId,
  });

  factory FeederRoomDeviceModel.fromMap(Map<String, dynamic> map) => FeederRoomDeviceModel(
        deviceId: map['device_id'],
        roomId: map['room_id'],
        status: map['status'],
        batteryPercent: map['battery_percent'],
        feedRemaining: map['feed_remaining'],
        waterRemaining: map['water_remaining'],
      );

  Map<String, dynamic> toMap() => {
        'device_id': deviceId,
        'room_id': roomId,
        'status': status,
        'battery_percent': batteryPercent,
        'feed_remaining': feedRemaining,
        'water_remaining': waterRemaining,
      };
}