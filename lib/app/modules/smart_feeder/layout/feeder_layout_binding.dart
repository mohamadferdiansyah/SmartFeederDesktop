import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/modules/smart_feeder/control_schedule/control_schedule_controller.dart';
import 'package:smart_feeder_desktop/app/modules/smart_feeder/dashboard/feeder_dashboard_controller.dart';
import 'package:smart_feeder_desktop/app/modules/smart_feeder/monitoring_data/device/feeder_device_controller.dart';
import 'package:smart_feeder_desktop/app/modules/smart_feeder/monitoring_data/feed/feed_binding.dart';
import 'package:smart_feeder_desktop/app/modules/smart_feeder/monitoring_data/feed/feed_controller.dart';
import 'package:smart_feeder_desktop/app/modules/smart_feeder/monitoring_data/history/feeder_history_controller.dart';
import 'package:smart_feeder_desktop/app/modules/smart_feeder/monitoring_data/room_water_device/feeder_room_water_device_controller.dart';
import 'package:smart_feeder_desktop/app/modules/smart_feeder/setting/feeder_setting_controller.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/rule_engine/alert/halter_alert_rule_engine_controller.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/rule_engine/threshold/halter_threshold_controller.dart';
import 'package:smart_feeder_desktop/app/services/halter_serial_service.dart';
import 'package:smart_feeder_desktop/app/services/mqtt_service.dart';
import 'feeder_layout_controller.dart';

class FeederLayoutBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MqttService>(() => MqttService());
    Get.lazyPut<FeederLayoutController>(() => FeederLayoutController());
    Get.lazyPut<FeedController>(() => FeedController());
    Get.lazyPut<FeederDashboardController>(() => FeederDashboardController());
    Get.lazyPut<FeederDeviceController>(() => FeederDeviceController());
    Get.lazyPut<FeederRoomWaterDeviceController>(
      () => FeederRoomWaterDeviceController(),
    );
    Get.lazyPut<ControlScheduleController>(() => ControlScheduleController());
    Get.lazyPut<FeederHistoryController>(() => FeederHistoryController());
    Get.lazyPut<FeederSettingController>(() => FeederSettingController());
    Get.lazyPut<HalterAlertRuleEngineController>(
      () => HalterAlertRuleEngineController(),
    );
    Get.lazyPut<HalterSerialService>(() => HalterSerialService());
    Get.lazyPut<HalterThresholdController>(() => HalterThresholdController());
  }
}
