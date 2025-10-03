import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_calibration_model.dart';

class DataCalibrationHalter {
  static final _box = GetStorage();

  static List<HalterCalibrationModel> getAll() {
    final list = _box.read('device_calibration_slopes') as List<dynamic>?;
    if (list == null) return [];
    return list
        .map((e) => HalterCalibrationModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static HalterCalibrationModel getByDeviceId(String deviceId) {
    final all = getAll();
    final existing = all.firstWhereOrNull((c) => c.deviceId == deviceId);
    return existing ?? HalterCalibrationModel.defaultForDevice(deviceId);
  }

  static void save(HalterCalibrationModel calibration) {
    final all = getAll();
    final idx = all.indexWhere((c) => c.deviceId == calibration.deviceId);
    if (idx != -1) {
      all[idx] = calibration;
    } else {
      all.add(calibration);
    }
    _box.write('device_calibration_slopes', all.map((e) => e.toJson()).toList());
  }
}