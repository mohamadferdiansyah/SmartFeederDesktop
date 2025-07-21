import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/dashboard/halter_dashboard_page.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/layout/halter_layout_controller.dart';

class HalterLayoutBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HalterDashboardPage>(() => HalterDashboardPage());
    Get.lazyPut<HalterLayoutController>(() => HalterLayoutController());
  }
}