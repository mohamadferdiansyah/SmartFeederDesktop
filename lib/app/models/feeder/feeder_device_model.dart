class FeederDeviceModel {
  final String deviceId;
  final String? stableId;
  final String version;

  FeederDeviceModel({
    required this.deviceId,
    this.stableId,
    required this.version,
  });

  factory FeederDeviceModel.fromMap(Map<String, dynamic> map) => FeederDeviceModel(
        deviceId: map['device_id'],
        stableId: map['room_id'],
        version: map['version'],
      );

  Map<String, dynamic> toMap() => {
        'device_id': deviceId,
        'stable_id': stableId,
        'version': stableId,
      };
}