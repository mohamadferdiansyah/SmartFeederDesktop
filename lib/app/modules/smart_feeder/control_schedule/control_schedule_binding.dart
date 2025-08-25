import 'package:get/get.dart';
import 'control_schedule_controller.dart';

class ControlScheduleBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ControlScheduleController>(() => ControlScheduleController());
  }
}