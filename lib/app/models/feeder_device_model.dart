class FeederDeviceModel {
  final String id;
  final String name;
  final String type;
  final String status;
  final DateTime lastActive;

  FeederDeviceModel({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.lastActive,
  });
}