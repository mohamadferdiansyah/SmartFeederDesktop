class NodeRoomDetailModel {
  final String detailId;
  final String deviceId;
  final double temperature;
  final double humidity;
  final double lightIntensity;
  final double co;
  final double co2;
  final double ammonia;
  final DateTime time;

  NodeRoomDetailModel({
    required this.detailId,
    required this.deviceId,
    required this.temperature,
    required this.humidity,
    required this.lightIntensity,
    required this.co,
    required this.co2,
    required this.ammonia,
    required this.time,
  });

  // Buat dari serial string langsung, tidak dari NodeRoomModel
  factory NodeRoomDetailModel.fromSerial(String line, {String? header}) {
    String raw = line;
    if (raw.endsWith('*')) {
      raw = raw.substring(0, raw.length - 1);
    }
    final parts = raw.split(',');
    if (parts.length < 8) throw FormatException('Not enough data for NodeRoomDetail');
    final usedHeader = header ?? 'SRIPB';
    String deviceId;
    if (parts[0] == usedHeader && parts.length > 1) {
      deviceId = '${parts[0]}${parts[1]}';
    } else {
      deviceId = parts[0];
    }
    return NodeRoomDetailModel(
      detailId: '${deviceId}_${DateTime.now().millisecondsSinceEpoch}',
      deviceId: deviceId,
      temperature: double.tryParse(parts[2]) ?? 0.0,
      humidity: double.tryParse(parts[3]) ?? 0.0,
      lightIntensity: double.tryParse(parts[4]) ?? 0.0,
      co: double.tryParse(parts[5]) ?? 0.0,
      co2: double.tryParse(parts[6]) ?? 0.0,
      ammonia: double.tryParse(parts[7]) ?? 0.0,
      time: DateTime.now(),
    );
  }

  factory NodeRoomDetailModel.fromMap(Map<String, dynamic> map) {
    return NodeRoomDetailModel(
      detailId: map['detail_id'],
      deviceId: map['device_id'],
      temperature: (map['temperature'] ?? 0.0).toDouble(),
      humidity: (map['humidity'] ?? 0.0).toDouble(),
      lightIntensity: (map['light_intensity'] ?? 0.0).toDouble(),
      co: (map['co'] ?? 0.0).toDouble(),
      co2: (map['co2'] ?? 0.0).toDouble(),
      ammonia: (map['ammonia'] ?? 0.0).toDouble(),
      time: DateTime.tryParse(map['time'].toString()) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'detail_id': detailId,
      'device_id': deviceId,
      'temperature': temperature,
      'humidity': humidity,
      'light_intensity': lightIntensity,
      'co': co,
      'co2': co2,
      'ammonia': ammonia,
      'time': time.toIso8601String(),
    };
  }
}