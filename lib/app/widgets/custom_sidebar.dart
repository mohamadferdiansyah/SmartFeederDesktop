import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/constants/app_colors.dart';
import 'package:smart_feeder_desktop/app/modules/control_schedule/control_schedule_page.dart';
import 'package:smart_feeder_desktop/app/modules/dashboard/dashboard_page.dart';
import 'package:smart_feeder_desktop/app/modules/device/device_page.dart';
import 'package:smart_feeder_desktop/app/modules/device_setting/device_setting_page.dart';
import 'package:smart_feeder_desktop/app/modules/feed/feed_page.dart';
import 'package:smart_feeder_desktop/app/modules/help/help_page.dart';
import 'package:smart_feeder_desktop/app/modules/layout/layout_controller.dart';
import 'package:smart_feeder_desktop/app/modules/water/water_page.dart';

class CustomSidebar extends StatefulWidget {
  final Function(Widget) onMenuTap;

  const CustomSidebar({super.key, required this.onMenuTap});

  @override
  State<CustomSidebar> createState() => _CustomSidebarState();
}

class _CustomSidebarState extends State<CustomSidebar> {
  final controller = Get.find<LayoutController>();
  int? hoveredIndex;
  bool controlMenu = false;
  bool monitoringDataMenu = false;

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          backgroundColor: Colors.white,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.25 < 320
                ? 320
                : MediaQuery.of(context).size.width *
                      0.25, // min width biar gak terlalu kecil
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.logout, color: AppColors.primary, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Konfirmasi Logout',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Apakah kamu yakin ingin keluar dari aplikasi?',
                  style: TextStyle(color: Colors.grey[700], fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          foregroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Batal'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          // TODO: aksi logout
                          Navigator.pop(context);
                        },
                        child: const Text('Keluar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      color: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Image.asset(
                          'assets/images/ipb.png',
                          height: 80,
                          width: 80,
                        ),
                        Container(
                          width: 2,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        Image.asset(
                          'assets/images/biofarma.png',
                          height: 120,
                          width: 120,
                        ),
                      ],
                    ),
                    Text(
                      'Smart Feeder',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Obx(
                      () => Text(
                        controller.currentDate.value,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.access_time,
                          color: AppColors.primary,
                          size: 24,
                        ),
                        SizedBox(width: 8),
                        Obx(
                          () => Text(
                            controller.currentTime.value,
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 26,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildMenuItem(
                    index: 0,
                    icon: Icons.space_dashboard_rounded,
                    title: 'Dashboard',
                    fontSize: 20,
                    onTap: () => widget.onMenuTap(DashboardPage()),
                  ),
                  SizedBox(height: 2),
                  _buildMenuItem(
                    index: 6,
                    icon: Icons.schedule_rounded,
                    title: 'Kontrol Jadwal',
                    fontSize: 20,
                    onTap: () => widget.onMenuTap(ControlSchedulePage()),
                  ),
                  SizedBox(height: 2),
                  _buildDropdownMenuItem(
                    index: 2,
                    icon: Icons.storage_rounded,
                    title: 'Monitoring Data',
                    fontSize: 20,
                    expanded: monitoringDataMenu,
                    onTap: () => setState(
                      () => monitoringDataMenu = !monitoringDataMenu,
                    ),
                    children: [
                      _buildSubMenuItem(
                        index: 20,
                        title: 'Data Perangkat',
                        onTap: () {
                          widget.onMenuTap(DevicePage());
                        },
                      ),
                      Divider(color: AppColors.primary.withOpacity(0.2)),
                      _buildSubMenuItem(
                        index: 21,
                        title: 'Data Pakan',
                        onTap: () {
                          widget.onMenuTap(FeedPage());
                        },
                      ),
                      Divider(color: AppColors.primary.withOpacity(0.2)),
                      _buildSubMenuItem(
                        index: 22,
                        title: 'Data Air',
                        onTap: () {
                          widget.onMenuTap(WaterPage());
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 2),
                  _buildMenuItem(
                    index: 3,
                    icon: Icons.settings_rounded,
                    title: 'Pengaturan Perangkat',
                    fontSize: 20,
                    onTap: () => widget.onMenuTap(DeviceSettingPage()),
                  ),
                  SizedBox(height: 2),
                  _buildMenuItem(
                    index: 4,
                    icon: Icons.help_outline_rounded,
                    title: 'Bantuan',
                    fontSize: 20,
                    onTap: () => widget.onMenuTap(HelpPage()),
                  ),
                ],
              ),
            ),
          ),
          Divider(color: Colors.white.withOpacity(0.2)),
          _buildMenuItem(
            index: 5,
            bgColor: Colors.red.withOpacity(0.8),
            icon: Icons.logout,
            title: 'Logout',
            fontSize: 20,
            onTap: () => _showLogoutDialog(context),
          ),
          SizedBox(height: 8),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                '© 2024 IPB University',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ),
          ),
          SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required int index,
    required IconData icon,
    required String title,
    required double fontSize,
    required VoidCallback onTap,
    Color? bgColor,
  }) {
    final isHovered = hoveredIndex == index;

    return Obx(() {
      final isActive = controller.currentPageName.value == title;

      return MouseRegion(
        onEnter: (_) => setState(() => hoveredIndex = index),
        onExit: (_) => setState(() => hoveredIndex = null),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color:
                bgColor ??
                (isActive
                    ? Colors
                          .white // Warna saat halaman aktif
                    : (isHovered
                          ? Colors.white.withOpacity(0.2) // Warna saat hover
                          : Colors.transparent)), // Warna default
          ),
          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          child: ListTile(
            leading: Icon(
              icon,
              color: isActive ? AppColors.primary : Colors.white,
              size: 30,
            ),
            title: Text(
              title,
              style: TextStyle(
                color: isActive ? AppColors.primary : Colors.white,
                fontSize: fontSize,
                fontWeight: isActive
                    ? FontWeight.bold
                    : FontWeight.normal, // Bold saat aktif
              ),
            ),
            onTap: onTap,
          ),
        ),
      );
    });
  }

  Widget _buildDropdownMenuItem({
    required int index,
    required IconData icon,
    required String title,
    required double fontSize,
    required bool expanded,
    required VoidCallback onTap,
    required List<Widget> children,
  }) {
    final isHovered = hoveredIndex == index;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MouseRegion(
          onEnter: (_) => setState(() => hoveredIndex = index),
          onExit: (_) => setState(() => hoveredIndex = null),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: isHovered
                  ? Colors.white.withOpacity(0.2)
                  : Colors.transparent,
            ),
            margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
            child: ListTile(
              leading: Icon(icon, color: Colors.white, size: 30),
              title: Text(
                title,
                style: TextStyle(color: Colors.white, fontSize: fontSize),
              ),
              trailing: Icon(
                expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: Colors.white,
              ),
              onTap: onTap,
            ),
          ),
        ),
        if (expanded)
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSubMenuItem({
    required int index,
    required String title,
    required VoidCallback onTap,
  }) {
    final isHovered = hoveredIndex == index;

    return Obx(() {
      final isActive = controller.currentPageName.value == title;

      return MouseRegion(
        onEnter: (_) => setState(() => hoveredIndex = index),
        onExit: (_) => setState(() => hoveredIndex = null),
        child: InkWell(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: isActive
                  ? AppColors
                        .primary // Warna saat halaman aktif
                  : (isHovered
                        ? AppColors.primary.withOpacity(0.2) // Warna saat hover
                        : Colors.transparent), // Warna default
            ),
            child: Text(
              title,
              style: TextStyle(
                color: isActive
                    ? Colors.white
                    : AppColors.primary, // Text putih saat aktif
                fontSize: 20,
                fontWeight: isActive
                    ? FontWeight.bold
                    : FontWeight.w500, // Bold saat aktif
              ),
            ),
          ),
        ),
      );
    });
  }
}
