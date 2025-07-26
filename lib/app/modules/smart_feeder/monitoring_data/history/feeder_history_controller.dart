import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/data/data_controller.dart';
import 'package:smart_feeder_desktop/app/models/history_entry_model.dart';
import 'package:smart_feeder_desktop/app/models/room_model.dart';
import 'package:smart_feeder_desktop/app/models/stable_model.dart';

class FeederHistoryController extends GetxController {

  final DataController dataController = Get.find<DataController>();

  List<StableModel> get stableList => dataController.stableList;

  List<HistoryEntryModel> get historyEntryList => dataController.historyEntryList;

  List<RoomModel> get roomList => dataController.roomList;

  String getStableName(String stableId) {
    return stableList.firstWhere((stable) => stable.stableId == stableId).name;
  }

  String getRoomName(String roomId) {
    return roomList.firstWhere((room) => room.roomId == roomId).name;
  }
}
