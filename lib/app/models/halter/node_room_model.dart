class NodeRoomModel {
  final String deviceId;
  // final double temperature;
  // final double humidity;
  // final double lightIntensity;
  // final double co;
  // final double co2;
  // final double ammonia;
  // final DateTime? time;
  final String status;
  final String version;

  NodeRoomModel({
    required this.deviceId,
    // required this.temperature,
    // required this.humidity,
    // required this.lightIntensity,
    // required this.co,
    // required this.co2,
    // required this.ammonia,
    // this.time,
    required this.status,
    required this.version,
  });

  factory NodeRoomModel.fromSerial(
    String line, {
    String? header,
    String version = "2.0",
    String? status,
  }) {
    String raw = line;
    if (raw.endsWith('*')) {
      raw = raw.substring(0, raw.length - 1);
    }
    final parts = raw.split(',');
    if (parts.length < 8) throw FormatException('Not enough data for NodeRoom');
    final usedHeader = header ?? 'SRIPB';
    String deviceId;
    if (parts[0] == usedHeader && parts.length > 1) {
      deviceId = '${parts[0]}${parts[1]}';
    } else {
      deviceId = parts[0];
    }
    return NodeRoomModel(
      deviceId: deviceId,
      status: status ?? 'on', // Status default 'on' saat terima data
      version: version,
    );
  }

  factory NodeRoomModel.fromMap(Map<String, dynamic> map) {
    return NodeRoomModel(
      deviceId: map['device_id'],
      // temperature: (map['temperature'] ?? 0.0).toDouble(),
      // humidity: (map['humidity'] ?? 0.0).toDouble(),
      // lightIntensity: (map['light_intensity'] ?? 0.0).toDouble(),
      // co: (map['co'] ?? 0.0).toDouble(),
      // co2: (map['co2'] ?? 0.0).toDouble(),
      // ammonia: (map['ammonia'] ?? 0.0).toDouble(),
      // time: map['time'] != null
      //     ? DateTime.tryParse(map['time'].toString())
      //     : null,
      status: map['status'],
      version: map['version'] ?? '2.0',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'device_id': deviceId,
      // 'temperature': temperature,
      // 'humidity': humidity,
      // 'light_intensity': lightIntensity,
      // 'co': co,
      // 'co2': co2,
      // 'ammonia': ammonia,
      // 'time': time?.toIso8601String(),
      'status': status,
      'version': version,
    };
  }
}
