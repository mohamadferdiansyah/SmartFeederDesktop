import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/data/data_halter_calibration_log.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_calibration_log_model.dart';

class HalterCalibrationLogController extends GetxController {
  RxList<HalterCalibrationLogModel> logs = <HalterCalibrationLogModel>[].obs;

  @override
  void onInit() {
    logs.value = DataHalterCalibrationLog.getAll();
    super.onInit();
  }

  void addLog(HalterCalibrationLogModel log) {
    logs.add(log);
    DataHalterCalibrationLog.saveAll(logs);
  }

  void clearLogs() {
    logs.clear();
    DataHalterCalibrationLog.clear();
  }
}