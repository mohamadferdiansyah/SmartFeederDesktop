import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/modules/smart_feeder/dashboard/feeder_dashboard_controller.dart';
import 'package:smart_feeder_desktop/app/modules/smart_feeder/monitoring_data/device/feeder_device_controller.dart';
import 'feeder_layout_controller.dart';

class FeederLayoutBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FeederLayoutController>(() => FeederLayoutController());
    Get.lazyPut<FeederDashboardController>(() => FeederDashboardController());
    Get.lazyPut<FeederDeviceController>(() => FeederDeviceController());
  }
}