import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/data/data_controller.dart';
import 'package:smart_feeder_desktop/app/models/halter_device_detail_model.dart';
import 'package:smart_feeder_desktop/app/models/halter_device_model.dart';
import 'package:smart_feeder_desktop/app/models/horse_model.dart';
import 'package:smart_feeder_desktop/app/services/halter_serial_service.dart';

class HalterDeviceController extends GetxController {
  final DataController dataController = Get.find<DataController>();
  final HalterSerialService halterSerialService = Get.find<HalterSerialService>();

  List<HalterDeviceModel> get halterDeviceList => dataController.halterDeviceList;

  List<HorseModel> get horseList => dataController.horseList;

  RxList<HalterDeviceDetailModel> get detailHistory => halterSerialService.detailHistory;

  String getHorseNameById(String? horseId) {
    if (horseId == null) return "Tidak Digunakan";
    return horseList.firstWhereOrNull((h) => h.horseId == horseId)?.name ??
        "Tidak Diketahui";
  }
}
