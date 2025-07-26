import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/data/data_controller.dart';
import 'package:smart_feeder_desktop/app/models/halter_device_model.dart';
import 'package:smart_feeder_desktop/app/models/horse_model.dart';

class HalterDeviceController extends GetxController {
  final DataController dataController = Get.find<DataController>();

  List<HalterDeviceModel> get halterDeviceList => dataController.halterDeviceList;

  List<HorseModel> get horseList => dataController.horseList;

  String getHorseNameById(String? horseId) {
    if (horseId == null) return "Tidak Digunakan";
    return horseList.firstWhereOrNull((h) => h.horseId == horseId)?.name ??
        "Tidak Diketahui";
  }
}
