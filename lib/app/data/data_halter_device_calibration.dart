import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_device_calibration_model.dart';

class DataHalterDeviceCalibration {
  static final _box = GetStorage();

  static List<HalterDeviceCalibrationModel> getAll() {
    final list = _box.read('device_calibrations') as List<dynamic>?;
    if (list == null) return [];
    return list
        .map((e) => HalterDeviceCalibrationModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static void save(HalterDeviceCalibrationModel calibration) {
    final all = getAll();
    final idx = all.indexWhere((c) => c.deviceId == calibration.deviceId);
    if (idx != -1) {
      all[idx] = calibration;
    } else {
      all.add(calibration);
    }
    _box.write('device_calibrations', all.map((e) => e.toJson()).toList());
  }

  static HalterDeviceCalibrationModel? getByDeviceId(String deviceId) {
    return getAll().firstWhereOrNull((c) => c.deviceId == deviceId);
  }
}