import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/dashboard/halter_dashbboard_controller.dart';

class HalterDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HalterDashboardController>(() => HalterDashboardController());
  }
}