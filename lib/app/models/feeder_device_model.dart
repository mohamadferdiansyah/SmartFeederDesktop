import 'package:get/get.dart';

class FeederDeviceModel {
  final String deviceId;
  final RxString status;
  final RxInt batteryPercent;
  final RxDouble voltase;
  final RxDouble current;
  final RxDouble power;

  FeederDeviceModel({
    required this.deviceId,
    required String status,
    required int batteryPercent,
    double voltase = 0.0,
    double current = 0.0,
    double power = 0.0,
  })  : status = status.obs,
        batteryPercent = batteryPercent.obs,
        voltase = voltase.obs,
        current = current.obs,
        power = power.obs;
}