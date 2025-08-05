class NodeRoomModel {
  final String deviceId;
  final double temperature;
  final double humidity;
  final double lightIntensity;
  final DateTime? time;

  NodeRoomModel({
    required this.deviceId,
    required this.temperature,
    required this.humidity,
    required this.lightIntensity,
    this.time,
  });

  factory NodeRoomModel.fromMap(Map<String, dynamic> map) => NodeRoomModel(
        deviceId: map['device_id'],
        temperature: (map['temperature'] ?? 0.0).toDouble(),
        humidity: (map['humidity'] ?? 0.0).toDouble(),
        lightIntensity: (map['light_intensity'] ?? 0.0).toDouble(),
        time: map['time'] != null ? DateTime.tryParse(map['time']) : null,
      );

  Map<String, dynamic> toMap() => {
        'device_id': deviceId,
        'temperature': temperature,
        'humidity': humidity,
        'light_intensity': lightIntensity,
        'time': time?.toIso8601String(),
      };

  /// Parsing dari string serial, misal: SRIPB1223003,29.00,69.90,26.67,0.00,0.00,0.00,0.00,0.00,0.00,*
  factory NodeRoomModel.fromSerial(String line) {
    String raw = line;
    if (raw.endsWith('*')) {
      raw = raw.substring(0, raw.length - 1);
    }
    final parts = raw.split(',');
    if (parts.length < 4) throw FormatException('Not enough data for NodeRoom');
    return NodeRoomModel(
      deviceId: parts[0],
      temperature: double.tryParse(parts[1]) ?? 0.0,
      humidity: double.tryParse(parts[2]) ?? 0.0,
      lightIntensity: double.tryParse(parts[3]) ?? 0.0,
      time: DateTime.now(),
    );
  }
}