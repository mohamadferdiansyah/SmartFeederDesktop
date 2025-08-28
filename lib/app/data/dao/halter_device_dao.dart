import 'package:smart_feeder_desktop/app/models/halter/halter_device_model.dart';
import 'package:sqflite/sqflite.dart';

class HalterDeviceDao {
  final Database db;
  HalterDeviceDao(this.db);

  // CREATE
  Future<int> insert(HalterDeviceModel model) async {
    return await db.insert(
      'halter_devices',
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // READ ALL
  Future<List<HalterDeviceModel>> getAll() async {
    final maps = await db.query('halter_devices');
    return maps.map((m) => HalterDeviceModel.fromMap(m)).toList();
  }

  // READ BY ID
  Future<HalterDeviceModel?> getById(String deviceId) async {
    final maps = await db.query(
      'halter_devices',
      where: 'device_id = ?',
      whereArgs: [deviceId],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return HalterDeviceModel.fromMap(maps.first);
    }
    return null;
  }

  // UPDATE
  Future<int> update(HalterDeviceModel model) async {
    return await db.update(
      'halter_devices',
      model.toMap(),
      where: 'device_id = ?',
      whereArgs: [model.deviceId],  
    );
  }

  // DELETE BY ID
  Future<int> delete(String deviceId) async {
    return await db.delete(
      'halter_devices',
      where: 'device_id = ?',
      whereArgs: [deviceId],
    );
  }

  // DELETE ALL (optional)
  Future<int> deleteAll() async {
    return await db.delete('halter_devices');
  }
}