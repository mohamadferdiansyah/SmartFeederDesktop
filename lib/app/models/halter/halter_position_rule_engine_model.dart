class HalterPositionRuleEngineModel {
  final int? id;
  final String name;
  final double? pitchMin;
  final double? pitchMax;
  final double? rollMin;
  final double? rollMax;
  final double? yawMin;
  final double? yawMax;

  HalterPositionRuleEngineModel({
    this.id,
    required this.name,
    this.pitchMin,
    this.pitchMax,
    this.rollMin,
    this.rollMax,
    this.yawMin,
    this.yawMax,
  });

  factory HalterPositionRuleEngineModel.fromMap(Map<String, dynamic> map) =>
      HalterPositionRuleEngineModel(
        id: map['id'],
        name: map['name'],
        pitchMin: map['pitch_min'] != null
            ? (map['pitch_min'] as num?)?.toDouble()
            : null,
        pitchMax: map['pitch_max'] != null
            ? (map['pitch_max'] as num?)?.toDouble()
            : null,
        rollMin: map['roll_min'] != null
            ? (map['roll_min'] as num?)?.toDouble()
            : null,
        rollMax: map['roll_max'] != null
            ? (map['roll_max'] as num?)?.toDouble()
            : null,
        yawMin: map['yaw_min'] != null
            ? (map['yaw_min'] as num?)?.toDouble()
            : null,
        yawMax: map['yaw_max'] != null
            ? (map['yaw_max'] as num?)?.toDouble()
            : null,
      );

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'name': name,
    'pitch_min': pitchMin,
    'pitch_max': pitchMax,
    'roll_min': rollMin,
    'roll_max': rollMax,
    'yaw_min': yawMin,
    'yaw_max': yawMax,
  };

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
