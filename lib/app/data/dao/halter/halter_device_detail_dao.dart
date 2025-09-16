import 'package:smart_feeder_desktop/app/models/halter/halter_device_detail_model.dart';
import 'package:sqflite/sqflite.dart';

class HalterDeviceDetailDao {
  final Database db;
  HalterDeviceDetailDao(this.db);

  // CREATE
  Future<int> insertDetail(HalterDeviceDetailModel model) async {
    return await db.insert(
      'halter_device_detail',
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // READ ALL
  Future<List<HalterDeviceDetailModel>> getAllDetails() async {
    final maps = await db.query('halter_device_detail', orderBy: 'time DESC');
    return maps.map((m) => HalterDeviceDetailModel.fromMap(m)).toList();
  }

  // READ BY ID
  Future<HalterDeviceDetailModel?> getById(int detailId) async {
    final maps = await db.query(
      'halter_device_detail',
      where: 'detail_id = ?',
      whereArgs: [detailId],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return HalterDeviceDetailModel.fromMap(maps.first);
    }
    return null;
  }

  // UPDATE
  Future<int> updateDetail(HalterDeviceDetailModel model) async {
    return await db.update(
      'halter_device_detail',
      model.toMap(),
      where: 'detail_id = ?',
      whereArgs: [model.detailId],
    );
  }

  // DELETE BY ID
  Future<int> deleteDetail(int detailId) async {
    return await db.delete(
      'halter_device_detail',
      where: 'detail_id = ?',
      whereArgs: [detailId],
    );
  }

  // DELETE ALL
  Future<int> clearAll() async {
    return await db.delete('halter_device_detail');
  }
}