class HalterDeviceDetailModel {
  final String deviceId;
  final double? latitude;
  final double? longitude;
  final double? altitude;
  final int? sog;
  final int? cog;
  final double? acceX;
  final double? acceY;
  final double? acceZ;
  final double? gyroX;
  final double? gyroY;
  final double? gyroZ;
  final double? magX;
  final double? magY;
  final double? magZ;
  final int? roll;
  final int? pitch;
  final int? yaw;
  final double? arus;
  final int? voltase;
  final int? bpm;
  final double? spo;
  final double? suhu;
  final double? respirasi;
  final DateTime? time;

  HalterDeviceDetailModel({
    required this.deviceId,
    this.latitude,
    this.longitude,
    this.altitude,
    this.sog,
    this.cog,
    this.acceX,
    this.acceY,
    this.acceZ,
    this.gyroX,
    this.gyroY,
    this.gyroZ,
    this.magX,
    this.magY,
    this.magZ,
    this.roll,
    this.pitch,
    this.yaw,
    this.arus,
    this.voltase,
    this.bpm,
    this.spo,
    this.suhu,
    this.respirasi,
    this.time,
  });

  factory HalterDeviceDetailModel.fromSerial(String line) {
    if (line.endsWith('*')) {
      line = line.substring(0, line.length - 1);
    }
    final parts = line.split(',');

    return HalterDeviceDetailModel(
      deviceId: parts[0],
      latitude: _toDouble(parts[1]),
      longitude: _toDouble(parts[2]),
      altitude: _toDouble(parts[3]),
      sog: _toInt(parts[4]),
      cog: _toInt(parts[5]),
      acceX: _toDouble(parts[6]),
      acceY: _toDouble(parts[7]),
      acceZ: _toDouble(parts[8]),
      gyroX: _toDouble(parts[9]),
      gyroY: _toDouble(parts[10]),
      gyroZ: _toDouble(parts[11]),
      magX: _toDouble(parts[12]),
      magY: _toDouble(parts[13]),
      magZ: _toDouble(parts[14]),
      roll: _toInt(parts[15]),
      pitch: _toInt(parts[16]),
      yaw: _toInt(parts[17]),
      arus: _toDouble(parts[18]),
      voltase: _toInt(parts[19]),
      bpm: _toInt(parts[20]),
      spo: _toDouble(parts[21]),
      suhu: _toDouble(parts[22]),
      respirasi: _toDouble(parts[23]),
      time: DateTime.now(),
    );
  }

  static double? _toDouble(String v) => v == 'NAN' ? null : double.tryParse(v);
  static int? _toInt(String v) => v == 'NAN' ? null : int.tryParse(v);
}