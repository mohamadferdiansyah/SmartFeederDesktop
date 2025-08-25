import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/modules/horse_walker/dashboard/walker_dashboard_page.dart';
import 'package:smart_feeder_desktop/app/modules/horse_walker/layout/walker_layout_controller.dart';

class WalkerLayoutBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WalkerDashboardPage>(() => WalkerDashboardPage());
    Get.lazyPut<WalkerLayoutController>(() => WalkerLayoutController());
  }
}