import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/modules/login/login_controller.dart';
import 'package:smart_feeder_desktop/app/modules/main_menu/main_menu_controller.dart';

class MainMenuBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(() => LoginController());
    Get.lazyPut<MainMenuController>(() => MainMenuController());
  }
}
