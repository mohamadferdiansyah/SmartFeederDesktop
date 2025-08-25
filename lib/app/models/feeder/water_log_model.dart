class WaterLogModel {
  final String logId;
  final String waterId;
  final double quantity;
  final DateTime date;

  WaterLogModel({
    required this.logId,
    required this.waterId,
    required this.quantity,
    required this.date,
  });

  factory WaterLogModel.fromMap(Map<String, dynamic> map) => WaterLogModel(
        logId: map['log_id'],
        waterId: map['water_id'],
        quantity: (map['quantity'] ?? 0.0).toDouble(),
        date: DateTime.parse(map['date']),
      );

  Map<String, dynamic> toMap() => {
        'log_id': logId,
        'water_id': waterId,
        'quantity': quantity,
        'date': date.toIso8601String(),
      };
}