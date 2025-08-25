import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/modules/smart_feeder/monitoring_data/device/feeder_device_controller.dart';

class FeederDeviceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FeederDeviceController>(() => FeederDeviceController());
  }
}