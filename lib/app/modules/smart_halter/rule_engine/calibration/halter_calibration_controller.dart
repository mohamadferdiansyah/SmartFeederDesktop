import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/data/storage/halter/data_calibration_halter.dart';
import 'package:smart_feeder_desktop/app/data/data_controller.dart';
import 'package:smart_feeder_desktop/app/data/storage/halter/data_halter_device_calibration.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_calibration_model.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_device_calibration_model.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_device_detail_model.dart';

class HalterCalibrationController extends GetxController {
  var calibration = HalterCalibrationModel(
    temperature: 0,
    heartRate: 0,
    spo: 0,
    respiration: 0,
    roomTemperature: 0,
    humidity: 0,
    lightIntensity: 0,
  ).obs;

  final DataController dataController = Get.find<DataController>();

  RxList<HalterDeviceDetailModel> get rawDetailHistoryList =>
      dataController.rawDetailHistoryList;

  var logRows = <DataRow>[].obs;

  final RxList<HalterDeviceCalibrationModel> deviceCalibrations =
    <HalterDeviceCalibrationModel>[].obs;

  @override
  void onInit() {
    calibration.value = DataHalterCalibrationHalter.getCalibration();
  // Inisialisasi RxList dari storage
  deviceCalibrations.assignAll(DataHalterDeviceCalibration.getAll());
  super.onInit();
  }

  @override
  void onReady() {
    calibration.value = DataHalterCalibrationHalter.getCalibration();
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
      temperature: temperature ?? calibration.value.temperature,
      heartRate: heartRate ?? calibration.value.heartRate,
      spo: spo ?? calibration.value.spo,
      respiration: respiration ?? calibration.value.respiration,
      roomTemperature: roomTemperature ?? calibration.value.roomTemperature,
      humidity: humidity ?? calibration.value.humidity,
      lightIntensity: lightIntensity ?? calibration.value.lightIntensity,
    );
    DataHalterCalibrationHalter.saveCalibration(calibration.value);
  }

  // void saveCalibrationToStorage() {
  //   DataHalterCalibrationHalter.saveCalibration(calibration.value);
  // }
}
