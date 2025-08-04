class WaterLogModel {
  final String logId;
  final String waterId;
  final double quantity; // liter
  final DateTime date;

  WaterLogModel({
    required this.logId,
    required this.waterId,
    required this.quantity,
    required this.date,
  });
}