import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/data/data_calibration_halter.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_calibration_model.dart';
import 'package:smart_feeder_desktop/app/models/halter_calibration_log_model.dart';

class HalterCalibrationController extends GetxController {
  var calibration = HalterCalibrationModel(
    id: 0,
    temperature: 0,
    heartRate: 0,
    spo: 0,
    respiration: 0,
    roomTemperature: 0,
    humidity: 0,
    lightIntensity: 0,
  ).obs;

  // ✅ logs pakai HalterCalibrationLogModel
  var calibrationLogs = <HalterCalibrationLogModel>[].obs;

  @override
  void onInit() {
    calibration.value = DataHalterCalibrationHalter.getCalibration();
    calibrationLogs.value = DataHalterCalibrationHalter.getCalibrationLogs();
    super.onInit();
  }

  @override
  void onReady() {
    calibration.value = DataHalterCalibrationHalter.getCalibration();
    calibrationLogs.value = DataHalterCalibrationHalter.getCalibrationLogs();
    super.onReady();
  }

  void updateCalibration({
    double? temperature,
    double? heartRate,
    double? spo,
    double? respiration,
    double? roomTemperature,
    double? humidity,
    double? lightIntensity,
  }) {
    calibration.value = HalterCalibrationModel(
      id: calibration.value.id + 1, // increment ID
      temperature: temperature ?? calibration.value.temperature,
      heartRate: heartRate ?? calibration.value.heartRate,
      spo: spo ?? calibration.value.spo,
      respiration: respiration ?? calibration.value.respiration,
      roomTemperature: roomTemperature ?? calibration.value.roomTemperature,
      humidity: humidity ?? calibration.value.humidity,
      lightIntensity: lightIntensity ?? calibration.value.lightIntensity,
    );

    // ✅ simpan data terakhir
    DataHalterCalibrationHalter.saveCalibration(calibration.value);

    // ✅ bikin log baru (contoh: untuk setiap parameter disimpan log terpisah)
    calibrationLogs.addAll([
      HalterCalibrationLogModel(
        id: calibration.value.id,
        timestamp: DateTime.now(),
        parameter: "Suhu Badan",
        category: "Halter",
        referensi: 37.5,
        sensor: calibration.value.temperature,
        value: calibration.value.temperature,
      ),
      HalterCalibrationLogModel(
        id: calibration.value.id,
        timestamp: DateTime.now(),
        parameter: "Detak Jantung",
        category: "Halter",
        referensi: 30,
        sensor: calibration.value.heartRate,
        value: calibration.value.heartRate,
      ),
      HalterCalibrationLogModel(
        id: calibration.value.id,
        timestamp: DateTime.now(),
        parameter: "SPO",
        category: "Halter",
        referensi: 96,
        sensor: calibration.value.spo,
        value: calibration.value.spo,
      ),
      HalterCalibrationLogModel(
        id: calibration.value.id,
        timestamp: DateTime.now(),
        parameter: "Respirasi",
        category: "Halter",
        referensi: 12,
        sensor: calibration.value.respiration,
        value: calibration.value.respiration,
      ),
      HalterCalibrationLogModel(
        id: calibration.value.id,
        timestamp: DateTime.now(),
        parameter: "Suhu Ruangan",
        category: "Node Room",
        referensi: calibration.value.roomTemperature,
        sensor: calibration.value.roomTemperature,
        value: calibration.value.roomTemperature,
      ),
      HalterCalibrationLogModel(
        id: calibration.value.id,
        timestamp: DateTime.now(),
        parameter: "Kelembapan",
        category: "Node Room",
        referensi: calibration.value.humidity,
        sensor: calibration.value.humidity,
        value: calibration.value.humidity,
      ),
      HalterCalibrationLogModel(
        id: calibration.value.id,
        timestamp: DateTime.now(),
        parameter: "Indeks Cahaya",
        category: "Node Room",
        referensi: calibration.value.lightIntensity,
        sensor: calibration.value.lightIntensity,
        value: calibration.value.lightIntensity,
      ),
    ]);

    // ✅ simpan log
    DataHalterCalibrationHalter.saveCalibrationLogs(calibrationLogs);
  }
  void deleteLog(int id) {
  calibrationLogs.removeWhere((log) => log.id == id);
  DataHalterCalibrationHalter.saveCalibrationLogs(calibrationLogs.toList());
}

void updateLog(HalterCalibrationLogModel updatedLog) {
  final index = calibrationLogs.indexWhere((log) => log.id == updatedLog.id);
  if (index != -1) {
    calibrationLogs[index] = updatedLog;
    DataHalterCalibrationHalter.saveCalibrationLogs(calibrationLogs.toList());
  }
}
}
