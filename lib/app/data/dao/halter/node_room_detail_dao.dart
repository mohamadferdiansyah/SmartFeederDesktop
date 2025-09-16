import 'package:sqflite/sqflite.dart';
import 'package:smart_feeder_desktop/app/models/halter/node_room_detail_model.dart';

class NodeRoomDetailDao {
  final Database db;
  NodeRoomDetailDao(this.db);

  Future<void> insert(NodeRoomDetailModel model) async {
    await db.insert(
      'node_room_detail',
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<NodeRoomDetailModel>> getAll() async {
    final result = await db.query(
      'node_room_detail',
      orderBy: 'time DESC',
    );
    return result.map((e) => NodeRoomDetailModel.fromMap(e)).toList();
  }

  Future<List<NodeRoomDetailModel>> getAllByDeviceId(String deviceId) async {
    final result = await db.query(
      'node_room_detail',
      where: 'device_id = ?',
      whereArgs: [deviceId],
      orderBy: 'time DESC',
    );
    return result.map((e) => NodeRoomDetailModel.fromMap(e)).toList();
  }
}