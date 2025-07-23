import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/models/feed_model.dart';

class FeedController extends GetxController {
  final RxList<FeedModel> feedList = <FeedModel>[
    FeedModel(feedId: 'F1', name: 'Pakan A', type: 'hijauan', stock: 100.0),
    FeedModel(feedId: 'F2', name: 'Pakan B', type: 'konsentrat', stock: 50.0),
    FeedModel(feedId: 'F3', name: 'Pakan C', type: 'hijauan', stock: 75.0),
    FeedModel(feedId: 'F4', name: 'Pakan D', type: 'konsentrat', stock: 62.0),
    FeedModel(feedId: 'F5', name: 'Pakan E', type: 'hijauan', stock: 80.0),
    FeedModel(feedId: 'F6', name: 'Pakan F', type: 'konsentrat', stock: 55.0),
    FeedModel(feedId: 'F7', name: 'Pakan G', type: 'hijauan', stock: 90.0),
    FeedModel(feedId: 'F8', name: 'Pakan H', type: 'konsentrat', stock: 70.0),
    FeedModel(feedId: 'F9', name: 'Pakan I', type: 'hijauan', stock: 78.0),
    FeedModel(feedId: 'F10', name: 'Pakan J', type: 'konsentrat', stock: 80.0),
    FeedModel(feedId: 'F11', name: 'Pakan K', type: 'hijauan', stock: 60.0),
    FeedModel(feedId: 'F12', name: 'Pakan L', type: 'konsentrat', stock: 71.0),
    FeedModel(feedId: 'F13', name: 'Pakan M', type: 'hijauan', stock: 93.0),
    FeedModel(feedId: 'F14', name: 'Pakan N', type: 'konsentrat', stock: 86.0),
    FeedModel(feedId: 'F15', name: 'Pakan O', type: 'hijauan', stock: 65.0),
    FeedModel(feedId: 'F16', name: 'Pakan P', type: 'konsentrat', stock: 59.0),
    FeedModel(feedId: 'F17', name: 'Pakan Q', type: 'hijauan', stock: 85.0),
    FeedModel(feedId: 'F18', name: 'Pakan R', type: 'konsentrat', stock: 67.0),
    FeedModel(feedId: 'F19', name: 'Pakan S', type: 'hijauan', stock: 95.0),
    FeedModel(feedId: 'F20', name: 'Pakan T', type: 'konsentrat', stock: 77.0),
  ].obs;
}
