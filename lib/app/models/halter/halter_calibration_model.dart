class HalterCalibrationModel {
  final int id;
  final double temperature;
  final double heartRate;
  final double spo;
  final double respiration;
  final double roomTemperature;
  final double humidity;
  final double lightIntensity;

  HalterCalibrationModel({
    required this.id,
    required this.temperature,
    required this.heartRate,
    required this.spo,
    required this.respiration,
    required this.roomTemperature,
    required this.humidity,
    required this.lightIntensity,
  });

  factory HalterCalibrationModel.fromJson(Map<String, dynamic> json) =>
      HalterCalibrationModel(
        id: json['id'] ?? 0,
        temperature: (json['temperature'] ?? 0).toDouble(),
        heartRate: (json['heartRate'] ?? 0).toDouble(),
        spo: (json['spo'] ?? 0).toDouble(),
        respiration: (json['respiration'] ?? 0).toDouble(),
        roomTemperature: (json['roomTemperature'] ?? 0).toDouble(),
        humidity: (json['humidity'] ?? 0).toDouble(),
        lightIntensity: (json['lightIntensity'] ?? 0).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'temperature': temperature,
        'heartRate': heartRate,
        'spo': spo,
        'respiration': respiration,
        'roomTemperature': roomTemperature,
        'humidity': humidity,
        'lightIntensity': lightIntensity,
      };
}
