import 'package:get/get.dart';

class FeederDeviceModel {
  final String deviceId;
  final RxString status;
  final RxInt batteryPercent;

  FeederDeviceModel({
    required this.deviceId,
    required String status,
    required int batteryPercent,
  }) : status = status.obs,
      batteryPercent = batteryPercent.obs;
}
