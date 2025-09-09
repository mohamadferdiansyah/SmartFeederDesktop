import 'package:sqflite/sqflite.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_log_model.dart';

class HalterAlertRuleEngineDao {
  final Database db;
  HalterAlertRuleEngineDao(this.db);

  Future<int> insert(HalterLogModel model) async {
    return await db.insert(
      'halter_horse_logs',
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<HalterLogModel>> getAll() async {
    final result = await db.query(
      'halter_horse_logs',
      orderBy: 'time DESC',
    );
    return result.map((e) => HalterLogModel.fromMap(e)).toList();
  }

  Future<void> deleteById(int logId) async {
    await db.delete(
      'halter_horse_logs',
      where: 'log_id = ?',
      whereArgs: [logId],
    );
  }

  Future<void> clearAll() async {
    await db.delete('halter_horse_logs');
  }
}