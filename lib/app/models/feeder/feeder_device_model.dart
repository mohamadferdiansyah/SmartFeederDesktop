class FeederDeviceModel {
  final String deviceId;
  final String status;
  final int batteryPercent;
  final double voltage;
  final double current;
  final double power;

  FeederDeviceModel({
    required this.deviceId,
    required this.status,
    required this.batteryPercent,
    required this.voltage,
    required this.current,
    required this.power,
  });

  factory FeederDeviceModel.fromMap(Map<String, dynamic> map) => FeederDeviceModel(
        deviceId: map['device_id'],
        status: map['status'],
        batteryPercent: map['battery_percent'] ?? 0,
        voltage: (map['voltage'] ?? 0.0).toDouble(),
        current: (map['current'] ?? 0.0).toDouble(),
        power: (map['power'] ?? 0.0).toDouble(),
      );

  Map<String, dynamic> toMap() => {
        'device_id': deviceId,
        'status': status,
        'battery_percent': batteryPercent,
        'voltage': voltage,
        'current': current,
        'power': power,
      };
}