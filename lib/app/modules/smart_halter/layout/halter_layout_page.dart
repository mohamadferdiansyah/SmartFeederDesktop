import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/dashboard/halter_dashboard_page.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/help/halter_help_page.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/layout/halter_layout_controller.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/monitoring_data/camera/halter_camera_page.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/monitoring_data/device/halter_device_page.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/monitoring_data/horse/halter_horse_page.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/monitoring_data/room/halter_room_page.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/raw_data/halter_raw_data_page.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/setting/halter_setting_page.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/sync/halter_sync_page.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_sidebar.dart';
import 'package:smart_feeder_desktop/app/models/sidebar_menu_model.dart';

class HalterLayoutPage extends StatelessWidget {
  HalterLayoutPage({super.key});
  final controller = Get.put(HalterLayoutController());

  // Menu items smart halter (dummy content, silakan ganti sesuai kebutuhan)
  final List<SidebarMenuItem> menuItems = [
    SidebarMenuItem(
      title: "Dashboard",
      icon: Icons.space_dashboard_rounded,
      page: HalterDashboardPage(),
    ),
    SidebarMenuItem(
      title: "Monitoring Data",
      icon: Icons.storage_rounded,
      children: [
        SidebarMenuItem(
          title: "Data Kuda",
          page: HalterHorsePage(),
        ),
        SidebarMenuItem(
          title: "Data Iot Node Halter",
          page: HalterDevicePage()
        ),
        SidebarMenuItem(
          title: "Data Ruang",
          page: HalterRoomPage()
        ),
        SidebarMenuItem(
          title: "Data CCTV",
          page: HalterCameraPage()
        ),
      ],
    ),
    SidebarMenuItem(
      title: "Data Raw",
      icon: Icons.data_object,
      page: HalterRawDataPage(),
    ),
    SidebarMenuItem(
      title: "Pengaturan Aplikasi",
      icon: Icons.settings,
      page: HalterSettingPage()
    ),
    SidebarMenuItem(
      title: "Bantuan",
      icon: Icons.help_outline_rounded,
      page: HalterHelpPage(),
    ),
    SidebarMenuItem(
      title: "Sinkronisasi data",
      icon: Icons.sync,
      page: HalterSyncPage(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Obx(
            () => CustomSidebar(
              sidebarTitle: 'Smart Halter',
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
