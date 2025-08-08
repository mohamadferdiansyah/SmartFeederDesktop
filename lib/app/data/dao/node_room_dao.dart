import 'package:sqflite/sqflite.dart';
import 'package:smart_feeder_desktop/app/models/halter/node_room_model.dart';

class NodeRoomDao {
  final Database db;
  NodeRoomDao(this.db);

  // READ ALL
  Future<List<NodeRoomModel>> getAll() async {
    final maps = await db.query('node_room_devices');
    return maps.map((m) => NodeRoomModel.fromMap(m)).toList();
  }

  // READ BY DEVICE ID
  Future<List<NodeRoomModel>> getByDeviceId(String deviceId) async {
    final maps = await db.query(
      'node_room_devices',
      where: 'device_id = ?',
      whereArgs: [deviceId],
    );
    return maps.map((m) => NodeRoomModel.fromMap(m)).toList();
  }

  // INSERT (optional)
  Future<int> insert(NodeRoomModel model) async {
    return await db.insert(
      'node_room_devices',
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // DELETE ALL (optional)
  Future<int> deleteAll() async {
    return await db.delete('node_room_devices');
  }

  // DELETE BY DEVICE ID (optional)
  Future<int> deleteByDeviceId(String deviceId) async {
    return await db.delete(
      'node_room_devices',
      where: 'device_id = ?',
      whereArgs: [deviceId],
    );
  }

  // UPDATE (optional)
  Future<int> update(NodeRoomModel model) async {
    return await db.update(
      'node_room_devices',
      model.toMap(),
      where: 'device_id = ?',
      whereArgs: [model.deviceId],
    );
  }
}