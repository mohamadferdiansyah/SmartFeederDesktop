import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/data/data_controller.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_device_power_log_model.dart';

class HalterDevicePowerLogController extends GetxController {
  final DataController dataController = Get.find<DataController>();
  RxList<HalterDevicePowerLogModel> get logList => dataController.halterDeviceLogList;

  @override
  void onInit() {
    super.onInit();
    dataController.loadHalterDevicePowerLogsFromDb();
  }
}