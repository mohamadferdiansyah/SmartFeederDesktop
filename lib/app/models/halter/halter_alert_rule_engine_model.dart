class HalterAlertRuleEngineModel {
  final int ruleId;
  final double tempMax;
  final double tempMin;
  final double spoMax;
  final double spoMin;
  final int heartRateMax;
  final int heartRateMin;
  final double respiratoryMax;
  final double batteryMin;
  final double tempRoomMin;
  final double tempRoomMax;
  final double humidityMin;
  final double humidityMax;
  final double lightIntensityMin;
  final double lightIntensityMax;

  HalterAlertRuleEngineModel({
    required this.ruleId,
    required this.tempMax,
    required this.tempMin,
    required this.spoMax,
    required this.spoMin,
    required this.heartRateMax,
    required this.heartRateMin,
    required this.respiratoryMax,
    required this.batteryMin,
    required this.tempRoomMin,
    required this.tempRoomMax,
    required this.humidityMin,
    required this.humidityMax,
    required this.lightIntensityMin,
    required this.lightIntensityMax,
  });

  factory HalterAlertRuleEngineModel.fromMap(Map<String, dynamic> map) =>
      HalterAlertRuleEngineModel(
        ruleId: map['rule_id'],
        tempMax: (map['temp_max'] ?? 0).toDouble(),
        tempMin: (map['temp_min'] ?? 0).toDouble(),
        spoMax: (map['spo_max'] ?? 0).toDouble(),
        spoMin: (map['spo_min'] ?? 0).toDouble(),
        heartRateMax: map['heart_rate_max'] ?? 0,
        heartRateMin: map['heart_rate_min'] ?? 0,
        respiratoryMax: (map['respiratory_max'] ?? 0).toDouble(),
        batteryMin: (map['battery_min'] ?? 0).toDouble(),
        tempRoomMin: (map['temp_room_min'] ?? 0).toDouble(),
        tempRoomMax: (map['temp_room_max'] ?? 0).toDouble(),
        humidityMin: (map['humidity_min'] ?? 0).toDouble(),
        humidityMax: (map['humidity_max'] ?? 0).toDouble(),
        lightIntensityMin: (map['light_intensity_min'] ?? 0).toDouble(),
        lightIntensityMax: (map['light_intensity_max'] ?? 0).toDouble(),
      );

  Map<String, dynamic> toMap() => {
    'rule_id': ruleId,
    'temp_max': tempMax,
    'temp_min': tempMin,
    'spo_max': spoMax,
    'spo_min': spoMin,
    'heart_rate_max': heartRateMax,
    'heart_rate_min': heartRateMin,
    'respiratory_max': respiratoryMax,
  };

  static HalterAlertRuleEngineModel defaultValue() {
    return HalterAlertRuleEngineModel(
      ruleId: 1,
      tempMin: 36.5,
      tempMax: 39.0,
      spoMin: 95.0,
      spoMax: 100.0,
      heartRateMin: 28,
      heartRateMax: 44,
      respiratoryMax: 20.0,
      batteryMin: 20.0,
      tempRoomMin: 20.0,
      tempRoomMax: 30.0,
      humidityMin: 30.0,
      humidityMax: 70.0,
      lightIntensityMin: 100.0,
      lightIntensityMax: 1000.0,
    );
  }
}
