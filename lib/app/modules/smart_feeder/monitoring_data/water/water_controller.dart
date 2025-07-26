import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/data/data_controller.dart';
import 'package:smart_feeder_desktop/app/models/water_model.dart';

class WaterContorller extends GetxController {
  final DataController dataController = Get.find<DataController>();

  List<WaterModel> get waterList => dataController.waterList;

}
  