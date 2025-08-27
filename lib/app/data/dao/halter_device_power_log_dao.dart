import 'package:smart_feeder_desktop/app/models/halter/halter_device_power_log_model.dart';
import 'package:sqflite/sqflite.dart';

class HalterDevicePowerLogDao {
  final Database db;
  HalterDevicePowerLogDao(this.db);

  Future<int> insert(HalterDevicePowerLogModel model) async {
    return await db.insert('halter_device_power_log', model.toMap());
  }

  Future<int> update(HalterDevicePowerLogModel model) async {
    return await db.update(
      'halter_device_power_log',
      model.toMap(),
      where: 'device_id = ? AND power_on_time = ?',
      whereArgs: [model.deviceId, model.powerOnTime.toIso8601String()],
    );
  }

  Future<List<HalterDevicePowerLogModel>> getAll() async {
    final maps = await db.query(
      'halter_device_power_log',
      orderBy: 'power_on_time DESC',
    );
    return maps.map((m) => HalterDevicePowerLogModel.fromMap(m)).toList();
  }
}
