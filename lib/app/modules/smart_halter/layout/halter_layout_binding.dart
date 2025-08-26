import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/dashboard/halter_dashboard_controller.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/dashboard/halter_dashboard_page.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/layout/halter_layout_controller.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/monitoring_data/camera/halter_camera_controller.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/monitoring_data/device/halter_device_controller.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/monitoring_data/horse/halter_horse_controller.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/monitoring_data/node_room/halter_node_controller.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/monitoring_data/room/halter_room_controller.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/monitoring_data/stable/halter_stable_controller.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/raw_data/halter_raw_data_controller.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/rule_engine/alert/halter_alert_rule_engine_controller.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/rule_engine/calibration/halter_calibration_controller.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/rule_engine/table/halter_table_rule_engine_controller.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/rule_engine/threshold/halter_threshold_controller.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/setting/halter_setting_controller.dart';
import 'package:smart_feeder_desktop/app/services/halter_serial_service.dart';

class HalterLayoutBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HalterDashboardPage>(() => HalterDashboardPage());
    Get.lazyPut<HalterLayoutController>(() => HalterLayoutController());
    Get.lazyPut<HalterDashboardController>(() => HalterDashboardController());
    Get.lazyPut<HalterRoomController>(() => HalterRoomController());
    Get.lazyPut<HalterDeviceController>(() => HalterDeviceController());
    Get.lazyPut<HalterCameraController>(() => HalterCameraController());
    Get.lazyPut<HalterHorseController>(() => HalterHorseController());
    Get.lazyPut<HalterSettingController>(() => HalterSettingController());
    Get.lazyPut<HalterSerialService>(() => HalterSerialService());
    Get.lazyPut<HalterRawDataController>(() => HalterRawDataController());
    Get.lazyPut<HalterAlertRuleEngineController>(
      () => HalterAlertRuleEngineController(),
    );
    Get.lazyPut<HalterTableRuleEngineController>(
      () => HalterTableRuleEngineController(),
    );
    Get.lazyPut<HalterStableController>(() => HalterStableController());
    Get.lazyPut<HalterNodeController>(() => HalterNodeController());
    Get.lazyPut<HalterCalibrationController>(
      () => HalterCalibrationController(),
    );
    Get.lazyPut<HalterThresholdController>(() => HalterThresholdController());
  }
}
