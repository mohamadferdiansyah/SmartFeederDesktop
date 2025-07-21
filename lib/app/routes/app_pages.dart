import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/modules/horse_walker/dashboard/walker_dashboard_page.dart';
import 'package:smart_feeder_desktop/app/modules/horse_walker/layout/walker_layout_binding.dart';
import 'package:smart_feeder_desktop/app/modules/horse_walker/layout/walker_layout_page.dart';
import 'package:smart_feeder_desktop/app/modules/login/login_binding.dart';
import 'package:smart_feeder_desktop/app/modules/login/login_page.dart';
import 'package:smart_feeder_desktop/app/modules/main_menu/main_menu_binding.dart';
import 'package:smart_feeder_desktop/app/modules/main_menu/main_menu_page.dart';
import 'package:smart_feeder_desktop/app/modules/smart_feeder/control_schedule/control_schedule_page.dart';
import 'package:smart_feeder_desktop/app/modules/smart_feeder/dashboard/feeder_dashboard_binding.dart';
import 'package:smart_feeder_desktop/app/modules/smart_feeder/dashboard/feeder_dashboard_page.dart';
import 'package:smart_feeder_desktop/app/modules/smart_feeder/layout/feeder_layout_binding.dart';
import 'package:smart_feeder_desktop/app/modules/smart_feeder/layout/feeder_layout_page.dart';
import 'package:smart_feeder_desktop/app/modules/smart_feeder/monitoring_data/device/feeder_device_binding.dart';
import 'package:smart_feeder_desktop/app/modules/smart_feeder/monitoring_data/device/feeder_device_page.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/dashboard/halter_dashboard_page.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/help/halter_help_page.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/layout/halter_layout_binding.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/layout/halter_layout_page.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/monitoring_data/camera/halter_camera_page.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/monitoring_data/device/halter_device_page.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/monitoring_data/feed/halter_feed_page.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/monitoring_data/horse/halter_horse_page.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/monitoring_data/stable/halter_stable_page.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/raw_data/halter_raw_data_page.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/setting/halter_setting_page.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/sync/halter_sync_page.dart';
// import page lainnya jika sudah ada

class AppPages {
  static final pages = [
    GetPage(name: '/login', page: () => LoginPage(), binding: LoginBinding()),
    GetPage(
      name: '/main-menu',
      page: () => MainMenuPage(),
      binding: MainMenuBinding(),
    ),
    GetPage(
      name: '/smart-feeder',
      page: () => FeederLayoutPage(),
      binding: FeederLayoutBinding(),
      children: [
        GetPage(
          name: '/dashboard',
          page: () => FeederDashboardPage(),
          binding: FeederDashboardBinding(),
        ),
        GetPage(name: '/schedule', page: () => ControlSchedulePage()),
        GetPage(
          name: '/device',
          page: () => FeederDevicePage(),
          binding: FeederDeviceBinding(),
        ),
      ],
    ),
    GetPage(
      name: '/smart-halter',
      page: () => HalterLayoutPage(),
      binding: HalterLayoutBinding(),
      children: [
        GetPage(name: '/dashboard', page: () => HalterDashboardPage()),
        GetPage(name: '/horse', page: () => HalterHorsePage()),
        GetPage(name: '/feed', page: () => HalterFeedPage()),
        GetPage(name: '/device', page: () => HalterDevicePage()),
        GetPage(name: '/stable', page: () => HalterStablePage()),
        GetPage(name: '/camera', page: () => HalterCameraPage()),
        GetPage(name: '/raw-data', page: () => HalterRawDataPage()),
        GetPage(name: '/setting', page: () => HalterSettingPage()),
        GetPage(name: '/help', page: () => HalterHelpPage()),
        GetPage(name: '/sync', page: () => HalterSyncPage()),
      ],
    ),
    GetPage(
      name: '/horse-walker',
      page: () => WalkerLayoutPage(),
      binding: WalkerLayoutBinding(),
      children: [
        GetPage(name: '/dashboard', page: () => WalkerDashboardPage()),
      ],
    ),
  ];
}
