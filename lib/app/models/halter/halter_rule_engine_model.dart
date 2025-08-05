class HalterRuleEngineModel {
  final int ruleId;
  final double tempMax;
  final double tempMin;
  final double spoMax;
  final double spoMin;
  final int heartRateMax;
  final int heartRateMin;
  final double respiratoryMax;

  HalterRuleEngineModel({
    required this.ruleId,
    required this.tempMax,
    required this.tempMin,
    required this.spoMax,
    required this.spoMin,
    required this.heartRateMax,
    required this.heartRateMin,
    required this.respiratoryMax,
  });

  factory HalterRuleEngineModel.fromMap(Map<String, dynamic> map) => HalterRuleEngineModel(
    ruleId: map['rule_id'],
    tempMax: (map['temp_max'] ?? 0).toDouble(),
    tempMin: (map['temp_min'] ?? 0).toDouble(),
    spoMax: (map['spo_max'] ?? 0).toDouble(),
    spoMin: (map['spo_min'] ?? 0).toDouble(),
    heartRateMax: map['heart_rate_max'] ?? 0,
    heartRateMin: map['heart_rate_min'] ?? 0,
    respiratoryMax: (map['respiratory_max'] ?? 0).toDouble(),
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

  static HalterRuleEngineModel defaultValue() {
    return HalterRuleEngineModel(
      ruleId: 1,
      tempMin: 36.5,
      tempMax: 39.0,
      spoMin: 95.0,
      spoMax: 100.0,
      heartRateMin: 28,
      heartRateMax: 44,
      respiratoryMax: 20.0,
    );
  }
}