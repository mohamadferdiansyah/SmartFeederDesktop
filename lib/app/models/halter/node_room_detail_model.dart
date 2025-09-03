import 'package:smart_feeder_desktop/app/models/halter/node_room_model.dart';

class NodeRoomDetailModel {
  final String detailId;
  final String deviceId;
  final double temperature;
  final double humidity;
  final double lightIntensity;
  final DateTime time;

  NodeRoomDetailModel({
    required this.detailId,
    required this.deviceId,
    required this.temperature,
    required this.humidity,
    required this.lightIntensity,
    required this.time,
  });

  factory NodeRoomDetailModel.fromNodeRoom(NodeRoomModel node) {
    return NodeRoomDetailModel(
      detailId: '${node.deviceId}_${node.time?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch}',
      deviceId: node.deviceId,
      temperature: node.temperature,
      humidity: node.humidity,
      lightIntensity: node.lightIntensity,
      time: node.time ?? DateTime.now(),
    );
  }

  factory NodeRoomDetailModel.fromMap(Map<String, dynamic> map) {
    return NodeRoomDetailModel(
      detailId: map['detail_id'],
      deviceId: map['device_id'],
      temperature: (map['temperature'] ?? 0.0).toDouble(),
      humidity: (map['humidity'] ?? 0.0).toDouble(),
      lightIntensity: (map['light_intensity'] ?? 0.0).toDouble(),
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
      'time': time.toIso8601String(),
    };
  }
}