class HalterRawDataModel {
  final int rawId;
  final String data;
  final DateTime? time;

  HalterRawDataModel({
    required this.rawId,
    required this.data,
    this.time,
  });

  factory HalterRawDataModel.fromMap(Map<String, dynamic> map) => HalterRawDataModel(
    rawId: map['raw_id'],
    data: map['data'],
    time: map['time'] != null ? DateTime.tryParse(map['time']) : null,
  );

  Map<String, dynamic> toMap() => {
    'raw_id': rawId,
    'data': data,
    'time': time?.toIso8601String(),
  };
}