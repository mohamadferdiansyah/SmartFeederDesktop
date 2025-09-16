import 'package:sqflite/sqflite.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_biometric_rule_engine_model.dart';

class HalterBiometricRuleEngineDao {
  final Database db;
  HalterBiometricRuleEngineDao(this.db);

  Future<int> insert(HalterBiometricRuleEngineModel model) async {
    return await db.insert(
      'halter_biometric_rule_engine',
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> update(HalterBiometricRuleEngineModel model) async {
    return await db.update(
      'halter_biometric_rule_engine',
      model.toMap(),
      where: 'id = ?',
      whereArgs: [model.id],
    );
  }

  Future<void> delete(int id) async {
    await db.delete(
      'halter_biometric_rule_engine',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<HalterBiometricRuleEngineModel>> getAll() async {
    final result = await db.query('halter_biometric_rule_engine');
    return result
        .map((e) => HalterBiometricRuleEngineModel.fromMap(e))
        .toList();
  }
}
