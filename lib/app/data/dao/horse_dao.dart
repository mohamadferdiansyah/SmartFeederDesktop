import 'package:smart_feeder_desktop/app/models/horse_model.dart';
import 'package:sqflite/sqflite.dart';

class HorseDao {
  final Database db;
  HorseDao(this.db);

  // CREATE
  Future<int> insert(HorseModel model) async {
    return await db.insert(
      'horses',
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace, // replace on duplicate key
    );
  }

  // READ ALL
  Future<List<HorseModel>> getAll() async {
    final maps = await db.query('horses');
    return maps.map((m) => HorseModel.fromMap(m)).toList();
  }

  // READ BY ID
  Future<HorseModel?> getById(String horseId) async {
    final maps = await db.query(
      'horses',
      where: 'horse_id = ?',
      whereArgs: [horseId],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return HorseModel.fromMap(maps.first);
    }
    return null;
  }

  // UPDATE
  Future<int> update(HorseModel model) async {
    return await db.update(
      'horses',
      model.toMap(),
      where: 'horse_id = ?',
      whereArgs: [model.horseId],
    );
  }

  // DELETE BY ID
  Future<int> delete(String horseId) async {
    return await db.delete(
      'horses',
      where: 'horse_id = ?',
      whereArgs: [horseId],
    );
  }

  // OPTIONAL: DELETE ALL (wipe table)
  Future<int> deleteAll() async {
    return await db.delete('horses');
  }
}