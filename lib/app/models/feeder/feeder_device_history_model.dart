class FeederDeviceHistoryModel {
  final int? id;
  final DateTime timestamp;
  final String deviceId;
  final String mode;
  final String roomId;
  final double? amount; // nullable, hanya untuk pakan
  final String? status; // nullable, hanya untuk air ("penuh"/"kosong")
  final String type; // "feed" atau "water"

  FeederDeviceHistoryModel({
    this.id,
    required this.timestamp,
    required this.deviceId,
    required this.mode,
    required this.roomId,
    this.amount,
    this.status,
    required this.type,
  });

  factory FeederDeviceHistoryModel.fromMap(Map<String, dynamic> map) => FeederDeviceHistoryModel(
        id: map['id'],
        timestamp: DateTime.parse(map['timestamp']),
        deviceId: map['device_id'],
        mode: map['mode'],
        roomId: map['room_id'],
        amount: map['amount'] != null ? (map['amount'] as num?)?.toDouble() : null,
        status: map['status'],
        type: map['type'] ?? 'feed',
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'timestamp': timestamp.toIso8601String(),
        'device_id': deviceId,
        'mode': mode,
        'room_id': roomId,
        if (amount != null) 'amount': amount,
        if (status != null) 'status': status,
        'type': type,
      };
}