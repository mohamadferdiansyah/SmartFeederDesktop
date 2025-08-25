import 'package:get_storage/get_storage.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_calibration_model.dart';
import 'package:smart_feeder_desktop/app/models/halter_calibration_log_model.dart';

class DataHalterCalibrationHalter {
  static final box = GetStorage();

  static void saveCalibration(HalterCalibrationModel calibration) {
    box.write('halter_calibration', calibration.toJson());
  }

  static HalterCalibrationModel getCalibration() {
    final data = box.read('halter_calibration');
    if (data != null) {
      return HalterCalibrationModel.fromJson(data);
    }
    return HalterCalibrationModel(

      id: 0,
      temperature: 0,
      heartRate: 0,
      spo: 0,
      respiration: 0,
      roomTemperature: 0,
      humidity: 0,
      lightIntensity: 0,
    );
  }

  // ✅ Logs
  static void saveCalibrationLogs(List<HalterCalibrationLogModel> logs) {
    final data = logs.map((e) => e.toJson()).toList();
    box.write('halter_calibration_logs', data);
  }

  static List<HalterCalibrationLogModel> getCalibrationLogs() {
    final data = box.read('halter_calibration_logs');
    if (data != null) {
      return (data as List)
          .map((e) => HalterCalibrationLogModel.fromJson(e))
          .toList();
    }
    return [];
  }
}
