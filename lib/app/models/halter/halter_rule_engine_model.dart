class HalterRuleEngineModel {
  double suhuMin;
  double suhuMax;
  double spoMin;
  double spoMax;
  int bpmMin;
  int bpmMax;
  double respirasiMax;

  HalterRuleEngineModel({
    required this.suhuMin,
    required this.suhuMax,
    required this.spoMin,
    required this.spoMax,
    required this.bpmMin,
    required this.bpmMax,
    required this.respirasiMax,
  });

  factory HalterRuleEngineModel.defaultValue() => HalterRuleEngineModel(
        suhuMin: 36.5,
        suhuMax: 39.0,
        spoMin: 95.0,
        spoMax: 100.0,
        bpmMin: 28,
        bpmMax: 44,
        respirasiMax: 20.0,
      );
}