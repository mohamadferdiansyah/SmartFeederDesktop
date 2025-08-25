import 'package:uuid/uuid.dart';

class HalterDeviceDetailModel {
  final String detailId;
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
  final double? current;
  final double? voltage;
  final double? heartRate;
  final double? spo;
  final double? temperature;
  final double? respiratoryRate;
  final String deviceId;
  final DateTime time;
  final int? rssi; // dBm (misal -40)
  final double? snr; // dB (misal 9.50)

  HalterDeviceDetailModel({
    required this.detailId,
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
    this.current,
    this.voltage,
    this.heartRate,
    this.spo,
    this.temperature,
    this.respiratoryRate,
    required this.deviceId,
    required this.time,
    this.rssi,
    this.snr,
  });

  factory HalterDeviceDetailModel.fromMap(Map<String, dynamic> map) =>
      HalterDeviceDetailModel(
        detailId: map['detail_id'],
        latitude: (map['latitude'] as num?)?.toDouble(),
        longitude: (map['longitude'] as num?)?.toDouble(),
        altitude: (map['altitude'] as num?)?.toDouble(),
        sog: (map['sog'] as num?)?.toInt(),
        cog: (map['cog'] as num?)?.toInt(),
        acceX: (map['acce_x'] as num?)?.toDouble(),
        acceY: (map['acce_y'] as num?)?.toDouble(),
        acceZ: (map['acce_z'] as num?)?.toDouble(),
        gyroX: (map['gyro_x'] as num?)?.toDouble(),
        gyroY: (map['gyro_y'] as num?)?.toDouble(),
        gyroZ: (map['gyro_z'] as num?)?.toDouble(),
        magX: (map['mag_x'] as num?)?.toDouble(),
        magY: (map['mag_y'] as num?)?.toDouble(),
        magZ: (map['mag_z'] as num?)?.toDouble(),
        roll: (map['roll'] as num?)?.toInt(),
        pitch: (map['pitch'] as num?)?.toInt(),
        yaw: (map['yaw'] as num?)?.toInt(),
        current: (map['current'] as num?)?.toDouble(),
        voltage: (map['voltage'] as num?)?.toDouble(),
        heartRate: (map['heart_rate'] as num?)?.toDouble(),
        spo: (map['spo'] as num?)?.toDouble(),
        temperature: (map['temperature'] as num?)?.toDouble(),
        respiratoryRate: (map['respiratory_rate'] as num?)?.toDouble(),
        deviceId: map['device_id'],
        time: DateTime.parse(map['time']),
        rssi: map['rssi'],
        snr: (map['snr'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toMap() => {
    'detail_id': detailId,
    'latitude': latitude,
    'longitude': longitude,
    'altitude': altitude,
    'sog': sog,
    'cog': cog,
    'acce_x': acceX,
    'acce_y': acceY,
    'acce_z': acceZ,
    'gyro_x': gyroX,
    'gyro_y': gyroY,
    'gyro_z': gyroZ,
    'mag_x': magX,
    'mag_y': magY,
    'mag_z': magZ,
    'roll': roll,
    'pitch': pitch,
    'yaw': yaw,
    'current': current,
    'voltage': voltage,
    'heart_rate': heartRate,
    'spo': spo,
    'temperature': temperature,
    'respiratory_rate': respiratoryRate,
    'device_id': deviceId,
    'time': time.toIso8601String(),
    'rssi': rssi,
    'snr': snr,
  };

  /// Factory untuk parsing dari serial string (format: SHIPBxxxx,...*)
  /// detailId diisi -1 (atau kamu bisa isi auto increment dari DB)
  /// Sekarang support juga RSSI dan SNR (jika ada)
  factory HalterDeviceDetailModel.fromSerial(
    String line, {
    int? rssi,
    double? snr,
  }) {
    String raw = line;
    if (raw.endsWith('*')) {
      raw = raw.substring(0, raw.length - 1);
    }
    final parts = raw.split(',');
    final uuid = const Uuid().v4();

    return HalterDeviceDetailModel(
      detailId: uuid,
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
      current: _toDouble(parts[18]),
      voltage: _toDouble(parts[19]),
      heartRate: _toDouble(parts[20]),
      spo: _toDouble(parts[21]),
      temperature: _toDouble(parts[22]),
      respiratoryRate: _toDouble(parts[23]),
      time: DateTime.now(),
      rssi: rssi,
      snr: snr,
    );
  }

  static double? _toDouble(String v) => v == 'NAN' ? null : double.tryParse(v);
  static int? _toInt(String v) => v == 'NAN' ? null : int.tryParse(v);
}
