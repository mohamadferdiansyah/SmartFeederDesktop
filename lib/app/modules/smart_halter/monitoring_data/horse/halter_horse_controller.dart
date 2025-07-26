import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/data/data_controller.dart';
import 'package:smart_feeder_desktop/app/models/horse_model.dart';

class HalterHorseController extends GetxController {
  final DataController dataController = Get.find<DataController>();

  List<HorseModel> get horseList => dataController.horseList;

}