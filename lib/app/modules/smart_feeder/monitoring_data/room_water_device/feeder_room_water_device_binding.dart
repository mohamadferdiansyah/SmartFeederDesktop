import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/modules/smart_feeder/monitoring_data/room_water_device/feeder_room_water_device_controller.dart';

class FeederRoomWaterDeviceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FeederRoomWaterDeviceController>(
      () => FeederRoomWaterDeviceController(),
    );
  }
}
