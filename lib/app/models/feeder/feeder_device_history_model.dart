class FeederDeviceHistoryModel {
  final int? id;
  final DateTime timestamp;
  final String deviceId;
  final String mode;
  final String roomId;
  final double amount;

  FeederDeviceHistoryModel({
    this.id,
    required this.timestamp,
    required this.deviceId,
    required this.mode,
    required this.roomId,
    required this.amount,
  });

  factory FeederDeviceHistoryModel.fromMap(Map<String, dynamic> map) => FeederDeviceHistoryModel(
        id: map['id'],
        timestamp: DateTime.parse(map['timestamp']),
        deviceId: map['device_id'],
        mode: map['mode'],
        roomId: map['room_id'],
        amount: (map['amount'] ?? 0.0).toDouble(),
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'timestamp': timestamp.toIso8601String(),
        'device_id': deviceId,
        'mode': mode,
        'room_id': roomId,
        'amount': amount,
      };
}