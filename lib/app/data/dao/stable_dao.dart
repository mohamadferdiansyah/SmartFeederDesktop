import 'package:smart_feeder_desktop/app/models/stable_model.dart';
import 'package:sqflite/sqflite.dart';

class StableDao {
  final Database db;
  StableDao(this.db);

  // CREATE
  Future<int> insert(StableModel model) async {
    return await db.insert(
      'stables',
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // READ ALL
  Future<List<StableModel>> getAll() async {
    final maps = await db.query('stables');
    return maps.map((m) => StableModel.fromMap(m)).toList();
  }

  // READ BY ID
  Future<StableModel?> getById(String stableId) async {
    final maps = await db.query(
      'stables',
      where: 'stable_id = ?',
      whereArgs: [stableId],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return StableModel.fromMap(maps.first);
    }
    return null;
  }

  // UPDATE
  Future<int> update(StableModel model) async {
    return await db.update(
      'stables',
      model.toMap(),
      where: 'stable_id = ?',
      whereArgs: [model.stableId],
    );
  }

  // DELETE BY ID
  Future<int> delete(String stableId) async {
    return await db.delete(
      'stables',
      where: 'stable_id = ?',
      whereArgs: [stableId],
    );
  }

  // OPTIONAL: DELETE ALL
  Future<int> deleteAll() async {
    return await db.delete('stables');
  }
}