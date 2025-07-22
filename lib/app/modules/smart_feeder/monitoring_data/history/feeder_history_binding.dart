import 'package:get/get.dart';
import 'feeder_history_controller.dart';

class FeederHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FeederHistoryController>(() => FeederHistoryController());
  }
}