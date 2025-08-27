class HalterDevicePowerLogModel {
  final String deviceId;
  final DateTime powerOnTime;
  final DateTime? powerOffTime;
  final Duration? durationOn;

  HalterDevicePowerLogModel({
    required this.deviceId,
    required this.powerOnTime,
    this.powerOffTime,
    this.durationOn,
  });

  Map<String, dynamic> toMap() => {
    'device_id': deviceId,
    'power_on_time': powerOnTime.toIso8601String(),
    'power_off_time': powerOffTime?.toIso8601String(),
    'duration_on': durationOn?.inSeconds,
  };

  factory HalterDevicePowerLogModel.fromMap(Map<String, dynamic> map) {
    return HalterDevicePowerLogModel(
      deviceId: map['device_id'],
      powerOnTime: DateTime.parse(map['power_on_time']),
      powerOffTime: map['power_off_time'] != null ? DateTime.parse(map['power_off_time']) : null,
      durationOn: map['duration_on'] != null ? Duration(seconds: map['duration_on']) : null,
    );
  }
}