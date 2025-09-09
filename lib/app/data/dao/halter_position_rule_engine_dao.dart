import 'package:sqflite/sqflite.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_position_rule_engine_model.dart';

class HalterPositionRuleEngineDao {
  final Database db;
  HalterPositionRuleEngineDao(this.db);

  Future<int> insert(HalterPositionRuleEngineModel model) async {
    return await db.insert(
      'halter_position_rule_engine',
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> update(HalterPositionRuleEngineModel model) async {
    return await db.update(
      'halter_position_rule_engine',
      model.toMap(),
      where: 'id = ?',
      whereArgs: [model.id],
    );
  }

  Future<void> delete(int id) async {
    await db.delete(
      'halter_position_rule_engine',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<HalterPositionRuleEngineModel>> getAll() async {
    final result = await db.query('halter_position_rule_engine');
    return result.map((e) => HalterPositionRuleEngineModel.fromMap(e)).toList();
  }
}