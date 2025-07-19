import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:smart_feeder_desktop/app/modules/control_schedule/control_schedule_page.dart';
import 'package:smart_feeder_desktop/app/modules/dashboard/dashboard_binding.dart';
import 'package:smart_feeder_desktop/app/modules/dashboard/dashboard_page.dart';
import 'package:smart_feeder_desktop/app/modules/feed/feed_page.dart';
import 'package:smart_feeder_desktop/app/modules/layout/layout_binding.dart';
import 'package:smart_feeder_desktop/app/modules/layout/layout_page.dart';
import 'package:smart_feeder_desktop/app/modules/water/water_page.dart';

class AppPages {
  static final pages = [
    GetPage(name: '/main', page: () => LayoutPage(), binding: LayoutBinding()),
    GetPage(name: '/dashboard', page: () => DashboardPage(), binding: DashboardBinding()),
    GetPage(name: '/schedule', page: () => ControlSchedulePage()),
    GetPage(name: '/feed', page: () => FeedPage()),
    GetPage(name: '/water', page: () => WaterPage()),
  ];
}
