class HalterBiometricRuleEngineModel {
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
