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

  factory NodeRoomModel.fromSerial(String line, {String? header}) {
    String raw = line;
    if (raw.endsWith('*')) {
      raw = raw.substring(0, raw.length - 1);
    }
    final parts = raw.split(',');
    if (parts.length < 5) throw FormatException('Not enough data for NodeRoom');
    final usedHeader = header ?? 'SRIPB';
    String deviceId;
    if (parts[0] == usedHeader && parts.length > 1) {
      deviceId = '${parts[0]},${parts[1]}';
    } else {
      deviceId = parts[0];
    }
    return NodeRoomModel(
      deviceId: deviceId,
      temperature: double.tryParse(parts[2]) ?? 0.0,
      humidity: double.tryParse(parts[3]) ?? 0.0,
      lightIntensity: double.tryParse(parts[4]) ?? 0.0,
      time: DateTime.now(),
    );
  }

  factory NodeRoomModel.fromMap(Map<String, dynamic> map) {
    return NodeRoomModel(
      deviceId: map['device_id'],
      temperature: (map['temperature'] ?? 0.0).toDouble(),
      humidity: (map['humidity'] ?? 0.0).toDouble(),
      lightIntensity: (map['light_intensity'] ?? 0.0).toDouble(),
      time: map['time'] != null
          ? DateTime.tryParse(map['time'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'device_id': deviceId,
      'temperature': temperature,
      'humidity': humidity,
      'light_intensity': lightIntensity,
      'time': time?.toIso8601String(),
    };
  }
}
