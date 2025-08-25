import 'package:smart_feeder_desktop/app/models/halter/cctv_model.dart';
import 'package:sqflite/sqflite.dart';

class CctvDao {
  final Database db;
  CctvDao(this.db);

  // CREATE
  Future<int> insert(CctvModel model) async {
    return await db.insert(
      'cctv',
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // READ ALL
  Future<List<CctvModel>> getAll() async {
    final maps = await db.query('cctv');
    return maps.map((m) => CctvModel.fromMap(m)).toList();
  }

  // READ BY ID
  Future<CctvModel?> getById(String cctvId) async {
    final maps = await db.query(
      'cctv',
      where: 'cctv_id = ?',
      whereArgs: [cctvId],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return CctvModel.fromMap(maps.first);
    }
    return null;
  }

  // UPDATE
  Future<int> update(CctvModel model) async {
    return await db.update(
      'cctv',
      model.toMap(),
      where: 'cctv_id = ?',
      whereArgs: [model.cctvId],
    );
  }

  // DELETE BY ID
  Future<int> delete(String cctvId) async {
    return await db.delete(
      'cctv',
      where: 'cctv_id = ?',
      whereArgs: [cctvId],
    );
  }

  // DELETE ALL (optional)
  Future<int> deleteAll() async {
    return await db.delete('cctv');
  }
}