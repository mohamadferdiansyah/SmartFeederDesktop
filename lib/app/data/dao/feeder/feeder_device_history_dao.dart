import 'package:smart_feeder_desktop/app/models/feeder/feeder_device_history_model.dart';
import 'package:sqflite/sqflite.dart';

class FeederDeviceHistoryDao {
  final Database db;
  FeederDeviceHistoryDao(this.db);

  Future<int> insert(FeederDeviceHistoryModel model) async {
    return await db.insert(
      'feeder_device_histories',
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<FeederDeviceHistoryModel>> getAll() async {
    final maps = await db.query('feeder_device_histories', orderBy: 'timestamp DESC');
    return maps.map((m) => FeederDeviceHistoryModel.fromMap(m)).toList();
  }

  Future<void> clear() async {
    await db.delete('feeder_device_histories');
  }
}