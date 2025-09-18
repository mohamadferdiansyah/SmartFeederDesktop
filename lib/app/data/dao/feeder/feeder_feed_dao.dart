import 'package:smart_feeder_desktop/app/models/feeder/feed_model.dart';
import 'package:sqflite/sqflite.dart';

class FeederFeedDao {
  final Database db;
  FeederFeedDao(this.db);

  Future<int> insert(FeedModel model) async {
    return await db.insert(
      'feeds',
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> update(FeedModel model, String oldCode) async {
    return await db.update(
      'feeds',
      model.toMap(),
      where: 'code = ?',
      whereArgs: [oldCode],
    );
  }

  Future<int> delete(String code) async {
    return await db.delete(
      'feeds',
      where: 'code = ?',
      whereArgs: [code],
    );
  }

  Future<List<FeedModel>> getAll() async {
    final maps = await db.query('feeds');
    return maps.map((m) => FeedModel.fromMap(m)).toList();
  }

  Future<FeedModel?> getByCode(String code) async {
    final maps = await db.query(
      'feeds',
      where: 'code = ?',
      whereArgs: [code],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return FeedModel.fromMap(maps.first);
    }
    return null;
  }
}