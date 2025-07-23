import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/modules/smart_feeder/monitoring_data/history/feeder_history_page.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_sidebar.dart';
import 'package:smart_feeder_desktop/app/models/sidebar_menu_model.dart';
import 'package:smart_feeder_desktop/app/modules/smart_feeder/layout/feeder_layout_controller.dart';
import 'package:smart_feeder_desktop/app/modules/smart_feeder/dashboard/feeder_dashboard_page.dart';
import 'package:smart_feeder_desktop/app/modules/smart_feeder/control_schedule/control_schedule_page.dart';
import 'package:smart_feeder_desktop/app/modules/smart_feeder/monitoring_data/feed/feed_page.dart';
import 'package:smart_feeder_desktop/app/modules/smart_feeder/monitoring_data/device/feeder_device_page.dart';
import 'package:smart_feeder_desktop/app/modules/smart_feeder/monitoring_data/water/water_page.dart';
import 'package:smart_feeder_desktop/app/modules/smart_feeder/setting/feeder_setting_page.dart';
import 'package:smart_feeder_desktop/app/modules/smart_feeder/help/feeder_help_page.dart';

class FeederLayoutPage extends StatelessWidget {
  FeederLayoutPage({super.key});
  final controller = Get.put(FeederLayoutController());

  final List<SidebarMenuItem> menuItems = [
    SidebarMenuItem(
      title: "Dashboard",
      icon: Icons.space_dashboard_rounded,
      page: FeederDashboardPage(),
    ),
    SidebarMenuItem(
      title: "Kontrol Penjadwalan",
      icon: Icons.calendar_month_rounded,
      page: ControlSchedulePage(),
    ),
    SidebarMenuItem(
      title: "Monitoring Data",
      icon: Icons.storage_rounded,
      children: [
        SidebarMenuItem(
          title: "Data Perangkat",
          icon: Icons.device_hub,
          page: FeederDevicePage(),
        ),
        SidebarMenuItem(
          title: "Data Pakan",
          icon: Icons.food_bank,
          page: FeedPage(),
        ),
        SidebarMenuItem(
          title: "Data Air",
          icon: Icons.water,
          page: WaterPage(),
        ),
        SidebarMenuItem(
          title: "Data Riwayat Pengisian",
          icon: Icons.history_rounded,
          page: FeederHistoryPage(),
        ),
      ],
    ),
    SidebarMenuItem(
      title: "Pengaturan Perangkat",
      icon: Icons.settings_rounded,
      page: FeederSettingPage(),
    ),
    SidebarMenuItem(
      title: "Bantuan",
      icon: Icons.help_outline_rounded,
      page: FeederHelpPage(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Obx(
            () => CustomSidebar(
              sidebarTitle: 'Smart Feeder',
              menuItems: menuItems,
              currentMenuTitle: controller.currentMenuTitle.value,
              onMenuTap: (widget) {
                final title = _findMenuTitle(menuItems, widget) ?? '';
                controller.setPage(widget, title);
              },
              currentDate: controller.currentDate,
              currentTime: controller.currentTime,
            ),
          ),
          Expanded(child: Obx(() => controller.currentPage.value)),
        ],
      ),
    );
  }

  String? _findMenuTitle(List<SidebarMenuItem> menus, Widget page) {
    for (final menu in menus) {
      if (menu.page != null && menu.page.runtimeType == page.runtimeType) {
        return menu.title;
      }
      if (menu.children != null) {
        final found = _findMenuTitle(menu.children!, page);
        if (found != null) return found;
      }
    }
    return null;
  }
}
