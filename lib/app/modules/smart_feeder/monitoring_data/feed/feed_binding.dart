import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/modules/smart_feeder/monitoring_data/feed/feed_controller.dart';

class FeedBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FeedController>(() => FeedController());
  }
}