class HalterHorseLogModel {
  final int logId;
  final String message;
  final String type;
  final DateTime? time;
  final String deviceId;

  HalterHorseLogModel({
    required this.logId,
    required this.message,
    required this.type,
    this.time,
    required this.deviceId,
  });

  factory HalterHorseLogModel.fromMap(Map<String, dynamic> map) => HalterHorseLogModel(
    logId: map['log_id'],
    message: map['message'],
    type: map['type'],
    time: map['time'] != null ? DateTime.tryParse(map['time']) : null,
    deviceId: map['device_id'],
  );

  Map<String, dynamic> toMap() => {
    'log_id': logId,
    'message': message,
    'type': type,
    'time': time?.toIso8601String(),
    'device_id': deviceId,
  };
}