class HalterHorseLogModel {
  final String deviceId;
  final String message;
  final String type;
  final DateTime time;

  HalterHorseLogModel({
    required this.deviceId,
    required this.message,
    required this.type,
    required this.time,
  });
}