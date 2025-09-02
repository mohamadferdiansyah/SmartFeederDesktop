import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_device_calibration_offset_model.dart';

class DataHalterDeviceCalibrationOffset {
  static final _box = GetStorage();

  static List<HalterDeviceCalibrationOffsetModel> getAll() {
    final list = _box.read('device_calibration_offsets') as List<dynamic>?;
    if (list == null) return [];
    return list
        .map((e) => HalterDeviceCalibrationOffsetModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static void save(HalterDeviceCalibrationOffsetModel offset) {
    final all = getAll();
    final idx = all.indexWhere((c) => c.deviceId == offset.deviceId);
    if (idx != -1) {
      all[idx] = offset;
    } else {
      all.add(offset);
    }
    _box.write('device_calibration_offsets', all.map((e) => e.toJson()).toList());
  }

  static HalterDeviceCalibrationOffsetModel? getByDeviceId(String deviceId) {
    return getAll().firstWhereOrNull((c) => c.deviceId == deviceId);
  }
}