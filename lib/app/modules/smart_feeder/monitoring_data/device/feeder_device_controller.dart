import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/data/data_controller.dart';
import 'package:smart_feeder_desktop/app/models/feeder_room_device_model.dart';
import 'package:smart_feeder_desktop/app/models/room_model.dart';

class FeederDeviceController extends GetxController {
  final DataController dataController = Get.find<DataController>();

  List<RoomModel> get roomList => dataController.roomList;

  List<FeederRoomDeviceModel> get feederRoomDeviceList =>
      dataController.feederRoomDeviceList;

  String getRoomName(String roomId) {
    return roomList.firstWhere((room) => room.roomId == roomId).name;
  }
}
