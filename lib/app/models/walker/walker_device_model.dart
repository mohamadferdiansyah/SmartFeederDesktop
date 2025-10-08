class WalkerDeviceModel {
  final String deviceId; // Gabungan header + id_device (contoh: SHWIPB1)
  final String status;
  final DateTime lastUpdate;

  WalkerDeviceModel({
    required this.deviceId,
    required this.status,
    required this.lastUpdate,
  });

  factory WalkerDeviceModel.fromJson(Map<String, dynamic> json) {
    final header = json['header'] ?? 'SHWIPB';
    final idDevice = json['id_device'].toString();
    final deviceId = '$header$idDevice';
    
    return WalkerDeviceModel(
      deviceId: deviceId,
      status: json['status'],
      lastUpdate: DateTime.now(),
    );
  }

  factory WalkerDeviceModel.fromMap(Map<String, dynamic> map) {
    return WalkerDeviceModel(
      deviceId: map['device_id'],
      status: map['status'],
      lastUpdate: DateTime.parse(map['last_update']),
    );
  }

  Map<String, dynamic> toMap() => {
    'device_id': deviceId,
    'status': status,
    'last_update': lastUpdate.toIso8601String(),
  };

  WalkerDeviceModel copyWith({
    String? deviceId,
    String? status,
    DateTime? lastUpdate,
  }) {
    return WalkerDeviceModel(
      deviceId: deviceId ?? this.deviceId,
      status: status ?? this.status,
      lastUpdate: lastUpdate ?? this.lastUpdate,
    );
  }

  @override
  String toString() {
    return 'WalkerDeviceModel(deviceId: $deviceId, status: $status, lastUpdate: $lastUpdate)';
  }
}