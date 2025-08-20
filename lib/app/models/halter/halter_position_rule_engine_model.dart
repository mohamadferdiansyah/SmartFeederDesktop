class HalterPositionRuleEngineModel {
  final String name;
  final double? pitchMin;
  final double? pitchMax;
  final double? rollMin;
  final double? rollMax;
  final double? yawMin;
  final double? yawMax;

  HalterPositionRuleEngineModel({
    required this.name,
    this.pitchMin,
    this.pitchMax,
    this.rollMin,
    this.rollMax,
    this.yawMin,
    this.yawMax,
  });

  factory HalterPositionRuleEngineModel.fromJson(Map<String, dynamic> json) =>
      HalterPositionRuleEngineModel(
        name: json['name'],
        pitchMin: json['pitchMin'],
        pitchMax: json['pitchMax'],
        rollMin: json['rollMin'],
        rollMax: json['rollMax'],
        yawMin: json['yawMin'],
        yawMax: json['yawMax'],
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'pitchMin': pitchMin,
        'pitchMax': pitchMax,
        'rollMin': rollMin,
        'rollMax': rollMax,
        'yawMin': yawMin,
        'yawMax': yawMax,
      };
}