import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/modules/horse_walker/dashboard/walker_dashboard_page.dart';
import 'package:smart_feeder_desktop/app/modules/horse_walker/layout/walker_layout_controller.dart';
import 'package:smart_feeder_desktop/app/modules/horse_walker/setting/walker_setting_page.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_sidebar.dart';
import 'package:smart_feeder_desktop/app/models/sidebar_menu_model.dart';

class WalkerLayoutPage extends StatelessWidget {
  WalkerLayoutPage({super.key});
  final controller = Get.put(WalkerLayoutController());

  // Menu items smart halter (dummy content, silakan ganti sesuai kebutuhan)
  final List<SidebarMenuItem> menuItems = [
    SidebarMenuItem(
      title: "Dashboard",
      icon: Icons.space_dashboard_rounded,
      page: WalkerDashboardPage(),
    ),
    SidebarMenuItem(
      title: "Monitoring Data",
      icon: Icons.storage_rounded,
      children: [
        SidebarMenuItem(
          title: "Data Perangkat",
          icon: Icons.device_hub,
          page: Center(
            child: Text('Ini Data Perangkat', style: TextStyle(fontSize: 30)),
          ),
        ),
        // Tambahkan submenu lain di sini nanti jika dibutuhkan
      ],
    ),
    SidebarMenuItem(
      title: "Data Raw",
      icon: Icons.data_object,
      page: Center(child: Text('Ini Raw Data', style: TextStyle(fontSize: 30))),
    ),
    SidebarMenuItem(
      title: "Pengaturan Aplikasi",
      icon: Icons.settings,
      page: WalkerSettingPage(),
    ),
    SidebarMenuItem(
      title: "Bantuan",
      icon: Icons.help_outline_rounded,
      page: Center(
        child: Text('Ini Bantuan Smart Halter', style: TextStyle(fontSize: 30)),
      ),
    ),
    SidebarMenuItem(
      title: "Sinkronisasi data",
      icon: Icons.sync,
      page: Center(
        child: Text(
          'Ini Sinkronisasi data Edge - cloud',
          style: TextStyle(fontSize: 30),
        ),
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Obx(
            () => CustomSidebar(
              sidebarTitle: 'Horse Walker',
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
