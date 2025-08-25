import 'package:get_storage/get_storage.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_calibration_model.dart';

class DataHalterCalibrationHalter {
  static final _box = GetStorage();

  static HalterCalibrationModel getCalibration() {
    final map = _box.read('halter_calibration');
    if (map == null) {
      // Default value jika belum ada
      return HalterCalibrationModel(
        temperature: 0,
        heartRate: 0,
        spo: 0,
        respiration: 0,
        roomTemperature: 0,
        humidity: 0,
        lightIntensity: -0,
      );
    }
    return HalterCalibrationModel.fromJson(Map<String, dynamic>.from(map));
  }

  static void saveCalibration(HalterCalibrationModel calibration) {
    _box.write('halter_calibration', calibration.toJson());
  }
}
