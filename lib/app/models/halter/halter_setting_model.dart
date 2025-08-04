class HalterSettingModel {
  String cloudUrl;
  bool cloudConnected;
  String loraPort;
  bool loraConnected;
  String jenisPengiriman;

  HalterSettingModel({
    required this.cloudUrl,
    required this.cloudConnected,
    required this.loraPort,
    required this.loraConnected,
    required this.jenisPengiriman,
  });
}