import 'package:get/get.dart';
import 'feeder_dashboard_controller.dart';

class FeederDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(FeederDashboardController());
  }
}
