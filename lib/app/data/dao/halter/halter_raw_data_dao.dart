import 'package:sqflite/sqflite.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_raw_data_model.dart';

class HalterRawDataDao {
  final Database db;
  HalterRawDataDao(this.db);

  Future<int> insert(HalterRawDataModel model) async {
    return await db.insert(
      'halter_raw_data',
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<HalterRawDataModel>> getAll() async {
    final result = await db.query('halter_raw_data', orderBy: 'time DESC');
    return result.map((e) => HalterRawDataModel.fromMap(e)).toList();
  }

  Future<void> deleteById(int rawId) async {
    await db.delete(
      'halter_raw_data',
      where: 'raw_id = ?',
      whereArgs: [rawId],
    );
  }

  Future<void> clearAll() async {
    await db.delete('halter_raw_data');
  }
}