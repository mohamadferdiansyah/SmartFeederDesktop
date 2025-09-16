import 'package:smart_feeder_desktop/app/models/feeder/feeder_device_model.dart';
import 'package:sqflite/sqflite.dart';

class FeederDeviceDao {
  final Database db;
  FeederDeviceDao(this.db);

  Future<int> insert(FeederDeviceModel model) async {
    return await db.insert(
      'feeder_devices',
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> update(FeederDeviceModel model, String oldDeviceId) async {
    return await db.update(
      'feeder_devices',
      model.toMap(),
      where: 'device_id = ?',
      whereArgs: [oldDeviceId],
    );
  }

  Future<int> delete(String deviceId) async {
    return await db.delete(
      'feeder_devices',
      where: 'device_id = ?',
      whereArgs: [deviceId],
    );
  }

  Future<List<FeederDeviceModel>> getAll() async {
    final maps = await db.query('feeder_devices');
    return maps.map((m) => FeederDeviceModel.fromMap(m)).toList();
  }

  Future<FeederDeviceModel?> getById(String deviceId) async {
    final maps = await db.query(
      'feeder_devices',
      where: 'device_id = ?',
      whereArgs: [deviceId],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return FeederDeviceModel.fromMap(maps.first);
    }
    return null;
  }
}