import 'package:smart_feeder_desktop/app/models/feeder/feeder_room_device_model.dart';
import 'package:sqflite/sqflite.dart';

class FeederRoomDeviceDao {
  final Database db;
  FeederRoomDeviceDao(this.db);

  Future<int> insert(FeederRoomDeviceModel model) async {
    return await db.insert(
      'feeder_room_devices',
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> update(FeederRoomDeviceModel model, String? oldDeviceId) async {
    return await db.update(
      'feeder_room_devices',
      model.toMap(),
      where: 'device_id = ?',
      whereArgs: [oldDeviceId],
    );
  }

  Future<int> delete(String deviceId) async {
    return await db.delete(
      'feeder_room_devices',
      where: 'device_id = ?',
      whereArgs: [deviceId],
    );
  }

  Future<List<FeederRoomDeviceModel>> getAll() async {
    final maps = await db.query('feeder_room_devices');
    return maps.map((m) => FeederRoomDeviceModel.fromMap(m)).toList();
  }

  Future<FeederRoomDeviceModel?> getById(String deviceId) async {
    final maps = await db.query(
      'feeder_room_devices',
      where: 'device_id = ?',
      whereArgs: [deviceId],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return FeederRoomDeviceModel.fromMap(maps.first);
    }
    return null;
  }
}