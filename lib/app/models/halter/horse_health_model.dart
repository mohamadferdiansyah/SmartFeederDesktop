class HorseHealthModel {
  final String healthId;
  final String horseId;
  // Tambahkan field kesehatan sesuai kebutuhan UI
  final int heartRate;
  final double bodyTemp;
  final double oxygen;
  final int respiration;
  final String posture;
  final double postureAccuracy;
  final int batteryPercent;

  HorseHealthModel({
    required this.healthId,
    required this.horseId,
    required this.heartRate,
    required this.bodyTemp,
    required this.oxygen,
    required this.respiration,
    required this.posture,
    required this.postureAccuracy,
    required this.batteryPercent,
  });

  get healthStatus => null;
}