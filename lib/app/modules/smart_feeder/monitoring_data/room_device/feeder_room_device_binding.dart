import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/modules/smart_feeder/monitoring_data/room_device/feeder_room_device_controller.dart';

class FeederRoomDeviceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FeederRoomDeviceController>(() => FeederRoomDeviceController());
  }
}