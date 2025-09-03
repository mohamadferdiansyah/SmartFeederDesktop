import 'package:uuid/uuid.dart';

class HalterDeviceDetailModel {
  final String detailId;
  final double? latitude;
  final double? longitude;
  final double? altitude;
  final int? sog;
  final int? cog;
  // final double? acceX;
  // final double? acceY;
  // final double? acceZ;
  // final double? gyroX;
  // final double? gyroY;
  // final double? gyroZ;
  // final double? magX;
  // final double? magY;
  // final double? magZ;
  final double? pitch;
  final double? yaw;
  final double? roll;
  // final double? current;
  final double? voltage;
  final double? heartRate;
  final double? spo;
  final double? temperature;
  final double? respiratoryRate;
  final String deviceId;
  final DateTime time;
  final int? interval;
  final int? rssi; // dBm (misal -40)
  final double? snr; // dB (misal 9.50)

  HalterDeviceDetailModel({
    required this.detailId,
    this.latitude,
    this.longitude,
    this.altitude,
    this.sog,
    this.cog,
    // this.acceX,
    // this.acceY,
    // this.acceZ,
    // this.gyroX,
    // this.gyroY,
    // this.gyroZ,
    // this.magX,
    // this.magY,
    // this.magZ,
    this.roll,
    this.pitch,
    this.yaw,
    // this.current,
    this.voltage,
    this.heartRate,
    this.spo,
    this.temperature,
    this.respiratoryRate,
    required this.deviceId,
    required this.time,
    this.interval,
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
        // acceX: (map['acce_x'] as num?)?.toDouble(),
        // acceY: (map['acce_y'] as num?)?.toDouble(),
        // acceZ: (map['acce_z'] as num?)?.toDouble(),
        // gyroX: (map['gyro_x'] as num?)?.toDouble(),
        // gyroY: (map['gyro_y'] as num?)?.toDouble(),
        // gyroZ: (map['gyro_z'] as num?)?.toDouble(),
        // magX: (map['mag_x'] as num?)?.toDouble(),
        // magY: (map['mag_y'] as num?)?.toDouble(),
        // magZ: (map['mag_z'] as num?)?.toDouble(),
        pitch: (map['pitch'] as num?)?.toDouble(),
        yaw: (map['yaw'] as num?)?.toDouble(),
        roll: (map['roll'] as num?)?.toDouble(),
        // current: (map['current'] as num?)?.toDouble(),
        voltage: (map['voltage'] as num?)?.toDouble(),
        heartRate: (map['heart_rate'] as num?)?.toDouble(),
        spo: (map['spo'] as num?)?.toDouble(),
        temperature: (map['temperature'] as num?)?.toDouble(),
        respiratoryRate: (map['respiratory_rate'] as num?)?.toDouble(),
        deviceId: map['device_id'],
        time: DateTime.parse(map['time']),
        interval: (map['interval'] as num?)?.toInt(),
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
    // 'acce_x': acceX,
    // 'acce_y': acceY,
    // 'acce_z': acceZ,
    // 'gyro_x': gyroX,
    // 'gyro_y': gyroY,
    // 'gyro_z': gyroZ,
    // 'mag_x': magX,
    // 'mag_y': magY,
    // 'mag_z': magZ,
    'pitch': pitch,
    'yaw': yaw,
    'roll': roll,
    // 'current': current,
    'voltage': voltage,
    'heart_rate': heartRate,
    'spo': spo,
    'temperature': temperature,
    'respiratory_rate': respiratoryRate,
    'device_id': deviceId,
    'time': time.toIso8601String(),
    'interval': interval,
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
    String? header, // Tambahkan parameter header
  }) {
    String raw = line;
  if (raw.endsWith('*')) {
    raw = raw.substring(0, raw.length - 1);
  }
  final parts = raw.split(',');

  String deviceId;
  final usedHeader = header ?? 'SHIPB';
  if (parts[0] == usedHeader && parts.length > 1) {
    deviceId = '${parts[0]}${parts[1]}';
  } else {
    deviceId = parts[0];
  }

    final uuid = const Uuid().v4();

    return HalterDeviceDetailModel(
      detailId: uuid,
      deviceId: deviceId,
      latitude: _toDouble(parts[2]),
      longitude: _toDouble(parts[3]),
      altitude: _toDouble(parts[4]),
      sog: _toInt(parts[5]),
      cog: _toInt(parts[6]),
      pitch: _toDouble(parts[7]),
      yaw: _toDouble(parts[8]),
      roll: _toDouble(parts[9]),
      voltage: _toDouble(parts[10]),
      heartRate: _toDouble(parts[11]),
      spo: _toDouble(parts[12]),
      temperature: _toDouble(parts[13]),
      respiratoryRate: _toDouble(parts[14]),
      interval: _toInt(parts[15]),
      time: DateTime.now(),
      rssi: rssi,
      snr: snr,
    );
  }

  static double? _toDouble(String v) => v == 'NAN' ? null : double.tryParse(v);
  static int? _toInt(String v) => v == 'NAN' ? null : int.tryParse(v);
}
