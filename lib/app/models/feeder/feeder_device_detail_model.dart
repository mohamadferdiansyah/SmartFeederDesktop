class FeederDeviceDetailModel {
  final int? detailId;
  final String deviceId;
  final String status;
  final String? destination;
  final double? amount;
  final int batteryPercent;
  final double voltage;
  final double current;
  final double power;
  final DateTime lastUpdate;

  FeederDeviceDetailModel({
    this.detailId,
    required this.deviceId,
    required this.status,
    this.destination,
    this.amount,
    required this.batteryPercent,
    required this.voltage,
    required this.current,
    required this.power,
    required this.lastUpdate,
  });

  factory FeederDeviceDetailModel.fromStatusJson(Map<String, dynamic> json) {
    // Handle timestamp bisa null
    final timestamp = json['timestamp'];
    DateTime lastUpdate;
    if (timestamp is String && timestamp.isNotEmpty) {
      lastUpdate = DateTime.tryParse(timestamp) ?? DateTime.now();
    } else {
      lastUpdate = DateTime.now();
    }

    // Handle amount bisa null, int, atau double
    double? amount;
    if (json['amount'] != null) {
      if (json['amount'] is int) {
        amount = (json['amount'] as int).toDouble();
      } else if (json['amount'] is double) {
        amount = json['amount'];
      } else if (json['amount'] is String) {
        amount = double.tryParse(json['amount']);
      }
    }

    return FeederDeviceDetailModel(
      detailId: json['detail_id'],
      deviceId: json['device_id'],
      status: json['status'],
      destination: json['destination'],
      amount: amount,
      batteryPercent: 0, // Diupdate dari feeder/baterai topic
      voltage: 0.0,
      current: 0.0,
      power: 0.0,
      lastUpdate: lastUpdate,
    );
  }

  factory FeederDeviceDetailModel.fromBateraiJson(
    Map<String, dynamic> json,
    FeederDeviceDetailModel? old,
  ) => FeederDeviceDetailModel(
    detailId: json['detail_id'],
    deviceId: json['device_id'],
    status: old?.status ?? 'off',
    destination: old?.destination,
    amount: old?.amount,
    batteryPercent: json['battery_percent'] ?? 0,
    voltage: (json['voltage'] ?? 0.0).toDouble(),
    current: (json['current_mA'] ?? 0.0).toDouble(),
    power: old?.power ?? 0.0,
    lastUpdate: DateTime.now(),
  );

  FeederDeviceDetailModel copyWith({
    int? detailId,
    String? status,
    String? destination,
    double? amount,
    int? batteryPercent,
    double? voltage,
    double? current,
    double? power,
    DateTime? lastUpdate,
  }) {
    return FeederDeviceDetailModel(
      detailId: detailId,
      deviceId: deviceId,
      status: status ?? this.status,
      destination: destination ?? this.destination,
      amount: amount ?? this.amount,
      batteryPercent: batteryPercent ?? this.batteryPercent,
      voltage: voltage ?? this.voltage,
      current: current ?? this.current,
      power: power ?? this.power,
      lastUpdate: lastUpdate ?? this.lastUpdate,
    );
  }
}
