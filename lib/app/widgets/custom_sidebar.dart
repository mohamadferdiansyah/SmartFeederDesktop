import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/constants/app_colors.dart';
import 'package:smart_feeder_desktop/app/models/sidebar_menu.dart';
import 'package:smart_feeder_desktop/app/utils/dialog_utils.dart';

class CustomSidebar extends StatefulWidget {
  final List<SidebarMenuItem> menuItems;
  final String currentMenuTitle;
  final Function(Widget) onMenuTap;
  final String sidebarTitle;

  // Tambahkan parameter controller
  final RxString currentDate;
  final RxString currentTime;

  const CustomSidebar({
    super.key,
    required this.sidebarTitle,
    required this.menuItems,
    required this.currentMenuTitle,
    required this.onMenuTap,
    required this.currentDate,
    required this.currentTime,
  });

  @override
  State<CustomSidebar> createState() => _CustomSidebarState();
}

class _CustomSidebarState extends State<CustomSidebar> {
  int? hoveredIndex;
  Map<int, bool> expandedMap = {};

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      color: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER: Logo, Title, Date, Timer
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
                      widget.sidebarTitle,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Obx(
                      () => Text(
                        widget.currentDate.value,
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
                            widget.currentTime.value,
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

          // === MENU ===
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: widget.menuItems.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final item = entry.value;
                  if (item.children != null && item.children!.isNotEmpty) {
                    return _buildDropdownMenuItem(
                      index: idx,
                      icon: item.icon,
                      title: item.title,
                      fontSize: 20,
                      expanded: expandedMap[idx] ?? false,
                      onTap: () => setState(() {
                        expandedMap[idx] = !(expandedMap[idx] ?? false);
                      }),
                      children: item.children!
                          .asMap()
                          .entries
                          .map(
                            (e) => _buildSubMenuItem(
                              index: 1000 * idx + e.key,
                              title: e.value.title,
                              onTap: () {
                                if (e.value.page != null) {
                                  widget.onMenuTap(e.value.page!);
                                }
                              },
                            ),
                          )
                          .toList(),
                    );
                  } else {
                    return _buildMenuItem(
                      index: idx,
                      icon: item.icon,
                      title: item.title,
                      fontSize: 20,
                      onTap: () {
                        if (item.page != null) {
                          widget.onMenuTap(item.page!);
                        }
                      },
                    );
                  }
                }).toList(),
              ),
            ),
          ),

          // === FOOTER ===
          Divider(color: Colors.white.withOpacity(0.2)),
          _buildMenuItem(
            index: 999,
            bgColor: Colors.red.withOpacity(0.8),
            icon: Icons.logout,
            title: 'Kembali Ke Menu',
            fontSize: 20,
            onTap: () => showConfirmationDialog(
              context: context,
              title: 'Konfirmasi Kembali',
              message: 'Apakah kamu yakin ingin kembali ke menu?',
              confirmText: 'Kembali',
              cancelText: 'Batal',
              icon: Icons.logout,
              iconColor: AppColors.primary,
              onConfirm: () {
                Get.back();
              },
            ),
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
    final isActive = widget.currentMenuTitle == title;

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
                        .white // Warna saat aktif
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
    final isActive = widget.currentMenuTitle == title;

    return Column(
      children: [
        MouseRegion(
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
                          ? AppColors.primary.withOpacity(
                              0.2,
                            ) // Warna saat hover
                          : Colors.transparent), // Warna default
              ),
              child: Text(
                title,
                style: TextStyle(
                  color: isActive ? Colors.white : AppColors.primary,
                  fontSize: 20,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
        Divider(color: AppColors.primary.withOpacity(0.2)),
      ],
    );
  }
}
