import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/modules/dashboard/dashboard_controller.dart';
import 'layout_controller.dart';

class LayoutBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LayoutController>(() => LayoutController());
    Get.lazyPut<DashboardController>(() => DashboardController());
  }
}