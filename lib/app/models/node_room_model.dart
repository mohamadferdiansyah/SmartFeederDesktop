import 'package:get/get.dart';

class NodeRoomModel {
  final String deviceId;
  final RxDouble temperature;
  final RxDouble humidity;
  final RxDouble lightIntensity;

  NodeRoomModel({
    required this.deviceId,
    required double temperature,
    required double humidity,
    required double lightIntensity,
  })  : temperature = temperature.obs,
        humidity = humidity.obs,
        lightIntensity = lightIntensity.obs;

  factory NodeRoomModel.fromSerial(String line) {
    // Format: SRIPB1223003,29.00,69.90,26.67,0.00,0.00,0.00,0.00,0.00,0.00,*
    final parts = line.split(',');
    if (parts.length < 4) throw FormatException('Not enough data for NodeRoom');
    return NodeRoomModel(
      deviceId: parts[0],
      temperature: double.tryParse(parts[1]) ?? 0.0,
      humidity: double.tryParse(parts[2]) ?? 0.0,
      lightIntensity: double.tryParse(parts[3]) ?? 0.0,
    );
  }
}