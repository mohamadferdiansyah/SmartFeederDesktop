import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/modules/monitoring_room/layout/monitor_layout_controller.dart';
import 'package:smart_feeder_desktop/app/modules/monitoring_room/layout/monitor_layout_page.dart';

class MonitorLayoutBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MonitorLayoutPage>(() => MonitorLayoutPage());
    Get.lazyPut<MonitorLayoutController>(() => MonitorLayoutController());
  }
}