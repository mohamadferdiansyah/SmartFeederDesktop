import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/modules/smart_feeder/monitoring_data/water/water_contorller.dart';

class WaterBinding extends Bindings {
    @override
  void dependencies() {
    Get.lazyPut<WaterContorller>(() => WaterContorller());
  }
}