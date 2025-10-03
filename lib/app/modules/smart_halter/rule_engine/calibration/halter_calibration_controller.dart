import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/data/storage/halter/data_calibration_halter.dart';
import 'package:smart_feeder_desktop/app/data/data_controller.dart';
import 'package:smart_feeder_desktop/app/data/storage/halter/data_halter_device_calibration.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_calibration_model.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_device_calibration_model.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_device_detail_model.dart';

class HalterCalibrationController extends GetxController {
  final DataController dataController = Get.find<DataController>();

  RxList<HalterDeviceDetailModel> get rawDetailHistoryList =>
      dataController.rawDetailHistoryList;

  var logRows = <DataRow>[].obs;

  final RxList<HalterDeviceCalibrationModel> deviceCalibrations =
    <HalterDeviceCalibrationModel>[].obs;

  // Per-device calibration slopes
  final RxList<HalterCalibrationModel> deviceCalibrationSlopes =
    <HalterCalibrationModel>[].obs;

  @override
  void onInit() {
    deviceCalibrations.assignAll(DataHalterDeviceCalibration.getAll());
    deviceCalibrationSlopes.assignAll(DataCalibrationHalter.getAll());
    super.onInit();
  }

  HalterCalibrationModel getCalibrationForDevice(String deviceId) {
    return DataCalibrationHalter.getByDeviceId(deviceId);
  }

  void updateDeviceCalibration({
    required String deviceId,
    double? temperatureSlope,
    double? temperatureIntercept,
    double? heartRateSlope,
    double? heartRateIntercept,
    double? respirationSlope,
    double? respirationIntercept,
  }) {
    final existing = getCalibrationForDevice(deviceId);
    
    final updated = HalterCalibrationModel(
      deviceId: deviceId,
      temperatureSlope: temperatureSlope ?? existing.temperatureSlope,
      temperatureIntercept: temperatureIntercept ?? existing.temperatureIntercept,
      heartRateSlope: heartRateSlope ?? existing.heartRateSlope,
      heartRateIntercept: heartRateIntercept ?? existing.heartRateIntercept,
      respirationSlope: respirationSlope ?? existing.respirationSlope,
      respirationIntercept: respirationIntercept ?? existing.respirationIntercept,
      updatedAt: DateTime.now(),
    );
    
    DataCalibrationHalter.save(updated);
    
    // Update RxList
    final idx = deviceCalibrationSlopes.indexWhere((c) => c.deviceId == deviceId);
    if (idx != -1) {
      deviceCalibrationSlopes[idx] = updated;
    } else {
      deviceCalibrationSlopes.add(updated);
    }
  }
}