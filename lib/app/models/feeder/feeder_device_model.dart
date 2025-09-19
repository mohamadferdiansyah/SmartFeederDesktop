class FeederDeviceModel {
  final String deviceId;
  final String? stableId;
  final String scheduleType;
  final String version;

  FeederDeviceModel({
    required this.deviceId,
    this.stableId,
    required this.scheduleType,
    required this.version,
  });

  factory FeederDeviceModel.fromMap(Map<String, dynamic> map) =>
      FeederDeviceModel(
        deviceId: map['device_id'],
        stableId: map['stable_id'],
        scheduleType: map['schedule_type'],
        version: map['version'],
      );

  Map<String, dynamic> toMap() => {
    'device_id': deviceId,
    'stable_id': stableId,
    'schedule_type': scheduleType,
    'version': version,
  };
}
