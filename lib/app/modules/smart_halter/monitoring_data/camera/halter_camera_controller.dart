import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/data/data_controller.dart';
import 'package:smart_feeder_desktop/app/models/cctv_model.dart';

class HalterCameraController extends GetxController {
  final DataController dataController = Get.find<DataController>();

  List<CctvModel> get cctvList => dataController.cctvList;
}
