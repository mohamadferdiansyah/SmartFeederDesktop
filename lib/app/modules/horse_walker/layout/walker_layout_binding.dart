import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/modules/horse_walker/dashboard/walker_dashboard_controller.dart';
import 'package:smart_feeder_desktop/app/modules/horse_walker/dashboard/walker_dashboard_page.dart';
import 'package:smart_feeder_desktop/app/modules/horse_walker/layout/walker_layout_controller.dart';
import 'package:smart_feeder_desktop/app/modules/horse_walker/setting/walker_setting_controller.dart';
import 'package:smart_feeder_desktop/app/services/mqtt_walker_service.dart';

class WalkerLayoutBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MqttWalkerService>(() => MqttWalkerService());
    Get.lazyPut<WalkerDashboardController>(() => WalkerDashboardController());
    Get.lazyPut<WalkerDashboardPage>(() => WalkerDashboardPage());
    Get.lazyPut<WalkerLayoutController>(() => WalkerLayoutController());
    Get.lazyPut<WalkerSettingController>(() => WalkerSettingController());
  }
}
