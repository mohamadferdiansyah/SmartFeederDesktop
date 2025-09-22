import 'package:smart_feeder_desktop/app/models/feeder/feeder_room_water_device_model.dart';
import 'package:sqflite/sqflite.dart';

class FeederRoomWaterDeviceDao {
  final Database db;
  FeederRoomWaterDeviceDao(this.db);

  Future<int> insert(FeederRoomWaterDeviceModel model) async {
    return await db.insert(
      'feeder_room_water_devices',
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> update(
    FeederRoomWaterDeviceModel model,
    String? oldDeviceId,
  ) async {
    return await db.update(
      'feeder_room_water_devices',
      model.toMap(),
      where: 'device_id = ?',
      whereArgs: [oldDeviceId],
    );
  }

  Future<int> delete(String deviceId) async {
    return await db.delete(
      'feeder_room_water_devices',
      where: 'device_id = ?',
      whereArgs: [deviceId],
    );
  }

  Future<List<FeederRoomWaterDeviceModel>> getAll() async {
    final maps = await db.query('feeder_room_water_devices');
    return maps.map((m) => FeederRoomWaterDeviceModel.fromMap(m)).toList();
  }

  Future<FeederRoomWaterDeviceModel?> getById(String deviceId) async {
    final maps = await db.query(
      'feeder_room_water_devices',
      where: 'device_id = ?',
      whereArgs: [deviceId],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return FeederRoomWaterDeviceModel.fromMap(maps.first);
    }
    return null;
  }
}
