class HalterCalibrationModel {
  final double temperature;
  final double heartRate;
  final double spo;
  final double respiration;
  final double roomTemperature;
  final double humidity;
  final double lightIntensity;

  HalterCalibrationModel({
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
        temperature: json['temperature'],
        heartRate: json['heartRate'],
        spo: json['spo'],
        respiration: json['respiration'],
        roomTemperature: json['roomTemperature'],
        humidity: json['humidity'],
        lightIntensity: json['lightIntensity'],
      );

  Map<String, dynamic> toJson() => {
    'temperature': temperature,
    'heartRate': heartRate,
    'spo': spo,
    'respiration': respiration,
    'roomTemperature': roomTemperature,
    'humidity': humidity,
    'lightIntensity': lightIntensity,
  };
}
