import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/data/data_controller.dart';
import 'package:smart_feeder_desktop/app/models/cctv_model.dart';
import 'package:smart_feeder_desktop/app/models/room_model.dart';

class HalterRoomController extends GetxController {
  final DataController dataController = Get.find<DataController>();

  List<RoomModel> get roomList => dataController.roomList;

  List<CctvModel> get cctvList => dataController.cctvList;

  String getCctvNames(List<String> cctvIds) {
    final names = cctvIds.map((id) {
      final cctv = cctvList.firstWhereOrNull((c) => c.cctvId == id);
      if (cctv != null) {
        return '${cctv.ipAddress} (${cctv.cctvId})';
      }
      return id;
    }).toList();
    return names.join(' / ');
  }
}
