import 'package:get_storage/get_storage.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_calibration_log_model.dart';

class DataHalterCalibrationLog {
  static final _box = GetStorage();

  static List<HalterCalibrationLogModel> getAll() {
    final list = _box.read('halter_calibration_logs') ?? [];
    return List<Map<String, dynamic>>.from(list)
        .map(HalterCalibrationLogModel.fromJson)
        .toList();
  }

  static void saveAll(List<HalterCalibrationLogModel> logs) {
    _box.write('halter_calibration_logs', logs.map((e) => e.toJson()).toList());
  }

  static void addLog(HalterCalibrationLogModel log) {
    final logs = getAll();
    logs.add(log);
    saveAll(logs);
  }

  static void clear() {
    _box.remove('halter_calibration_logs');
  }
}