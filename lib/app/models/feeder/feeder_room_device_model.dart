class FeederRoomDeviceModel {
  final String deviceId;
  final String status;
  final String type;
  final String? roomId;

  FeederRoomDeviceModel({
    required this.deviceId,
    required this.status,
    required this.type,
    this.roomId,
  });

  factory FeederRoomDeviceModel.fromMap(Map<String, dynamic> map) => FeederRoomDeviceModel(
        deviceId: map['device_id'],
        status: map['status'],
        type: map['type'],
        roomId: map['room_id'],
      );

  Map<String, dynamic> toMap() => {
        'device_id': deviceId,
        'status': status,
        'type': type,
        'room_id': roomId,
      };
}