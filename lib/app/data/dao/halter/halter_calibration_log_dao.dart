import 'package:sqflite/sqflite.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_calibration_log_model.dart';

class HalterCalibrationLogDao {
  final Database db;
  HalterCalibrationLogDao(this.db);

  Future<int> insert(HalterCalibrationLogModel model) async {
    return await db.insert(
      'halter_calibration_log',
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<HalterCalibrationLogModel>> getAll() async {
    final result = await db.query(
      'halter_calibration_log',
      orderBy: 'timestamp DESC',
    );
    return result.map((e) => HalterCalibrationLogModel.fromMap(e)).toList();
  }

  Future<void> delete(int id) async {
    await db.delete(
      'halter_calibration_log',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearAll() async {
    await db.delete('halter_calibration_log');
  }
}