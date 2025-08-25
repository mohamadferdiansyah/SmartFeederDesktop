class HalterSettingModel {
  final int settingId;
  final String cloudUrl;
  final String loraPort;
  final String type;

  HalterSettingModel({
    required this.settingId,
    required this.cloudUrl,
    required this.loraPort,
    required this.type,
  });

  factory HalterSettingModel.fromMap(Map<String, dynamic> map) => HalterSettingModel(
    settingId: map['setting_id'],
    cloudUrl: map['cloud_url'],
    loraPort: map['lora_port'],
    type: map['type'],
  );

  Map<String, dynamic> toMap() => {
    'setting_id': settingId,
    'cloud_url': cloudUrl,
    'lora_port': loraPort,
    'type': type,
  };
}