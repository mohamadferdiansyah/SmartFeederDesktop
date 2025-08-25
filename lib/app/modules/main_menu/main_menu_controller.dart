import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/data/data_controller.dart';

class MainMenuController extends GetxController {
  final DataController dataController = Get.find<DataController>();

  @override
  void onInit() {
    super.onInit();
    dataController.initAllDaosAndLoadAll().then((_) {
      // Setelah semua data di-load, bisa melakukan inisialisasi lain jika perlu
      print('Semua data telah dimuat dan DAO diinisialisasi.');
    });
  }
}
