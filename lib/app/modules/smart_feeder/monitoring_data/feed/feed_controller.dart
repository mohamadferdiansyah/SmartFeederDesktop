import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/data/data_controller.dart';
import 'package:smart_feeder_desktop/app/models/feed_model.dart';

class FeedController extends GetxController {
  final DataController dataController = Get.find<DataController>();

  List<FeedModel> get feedList => dataController.feedList;
}

