class HalterBiometricRuleEngineModel {
  final int? id;
  final String name;
  final double? suhuMin;
  final double? suhuMax;
  final int? heartRateMin;
  final int? heartRateMax;
  final double? spoMin;
  final double? spoMax;
  final int? respirasiMin;
  final int? respirasiMax;

  HalterBiometricRuleEngineModel({
    this.id,
    required this.name,
    this.suhuMin,
    this.suhuMax,
    this.heartRateMin,
    this.heartRateMax,
    this.spoMin,
    this.spoMax,
    this.respirasiMin,
    this.respirasiMax,
  });

  factory HalterBiometricRuleEngineModel.fromMap(Map<String, dynamic> map) =>
      HalterBiometricRuleEngineModel(
        id: map['id'],
        name: map['name'],
        suhuMin: map['suhu_min'] != null
            ? (map['suhu_min'] as num?)?.toDouble()
            : null,
        suhuMax: map['suhu_max'] != null
            ? (map['suhu_max'] as num?)?.toDouble()
            : null,
        heartRateMin: map['heart_rate_min'],
        heartRateMax: map['heart_rate_max'],
        spoMin: map['spo_min'] != null
            ? (map['spo_min'] as num?)?.toDouble()
            : null,
        spoMax: map['spo_max'] != null
            ? (map['spo_max'] as num?)?.toDouble()
            : null,
        respirasiMin: map['respirasi_min'],
        respirasiMax: map['respirasi_max'],
      );

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'name': name,
    'suhu_min': suhuMin,
    'suhu_max': suhuMax,
    'heart_rate_min': heartRateMin,
    'heart_rate_max': heartRateMax,
    'spo_min': spoMin,
    'spo_max': spoMax,
    'respirasi_min': respirasiMin,
    'respirasi_max': respirasiMax,
  };

  factory HalterBiometricRuleEngineModel.fromJson(Map<String, dynamic> json) =>
      HalterBiometricRuleEngineModel(
        name: json['name'],
        suhuMin: json['suhuMin'],
        suhuMax: json['suhuMax'],
        heartRateMin: json['heartRateMin'],
        heartRateMax: json['heartRateMax'],
        spoMin: json['spoMin'],
        spoMax: json['spoMax'],
        respirasiMin: json['respirasiMin'],
        respirasiMax: json['respirasiMax'],
      );

  Map<String, dynamic> toJson() => {
    'name': name,
    'suhuMin': suhuMin,
    'suhuMax': suhuMax,
    'heartRateMin': heartRateMin,
    'heartRateMax': heartRateMax,
    'spoMin': spoMin,
    'spoMax': spoMax,
    'respirasiMin': respirasiMin,
    'respirasiMax': respirasiMax,
  };
}
