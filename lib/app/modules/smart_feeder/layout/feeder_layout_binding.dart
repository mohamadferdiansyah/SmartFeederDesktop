import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/modules/smart_feeder/control_schedule/control_schedule_controller.dart';
import 'package:smart_feeder_desktop/app/modules/smart_feeder/dashboard/feeder_dashboard_controller.dart';
import 'package:smart_feeder_desktop/app/modules/smart_feeder/monitoring_data/device/feeder_device_controller.dart';
import 'package:smart_feeder_desktop/app/modules/smart_feeder/monitoring_data/history/feeder_history_controller.dart';
import 'package:smart_feeder_desktop/app/services/mqtt_service.dart';
import 'feeder_layout_controller.dart';

class FeederLayoutBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MqttService>(() => MqttService());
    Get.lazyPut<FeederLayoutController>(() => FeederLayoutController());
    Get.lazyPut<FeederDashboardController>(() => FeederDashboardController());
    Get.lazyPut<FeederDeviceController>(() => FeederDeviceController());
    Get.lazyPut<ControlScheduleController>(() => ControlScheduleController());
    Get.lazyPut<FeederHistoryController>(() => FeederHistoryController());
  }
}
