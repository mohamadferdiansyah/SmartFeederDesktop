import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/constants/app_colors.dart';
import 'package:smart_feeder_desktop/app/data/data_team_halter.dart';
import 'package:smart_feeder_desktop/app/models/sidebar_menu_model.dart';
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
  bool isCollapsed = false; // State untuk collapse/expand

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 250),
      width: isCollapsed ? 70 : 350, // Lebar sidebar berubah
      color: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tombol collapse/expand di header
          Padding(
            padding: EdgeInsets.only(top: 12, left: 12, right: 12, bottom: 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: Icon(
                  isCollapsed ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 24,
                ),
                onPressed: () {
                  setState(() {
                    isCollapsed = !isCollapsed;
                  });
                },
                tooltip: isCollapsed ? 'Expand Sidebar' : 'Collapse Sidebar',
              ),
            ),
          ),
          // HEADER: Logo, Title, Date, Timer
          if (!isCollapsed)
            Padding(
              padding: EdgeInsets.all(20),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(8, 8, 8, 16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Image.asset(
                            'assets/images/ipb.png',
                            height: 60,
                            width: 60,
                          ),
                          Image.asset(
                            'assets/images/biofarma.png',
                            height: 90,
                            width: 90,
                          ),
                          Image.asset(
                            'assets/images/lpdp.png',
                            height: 75,
                            width: 75,
                          ),
                        ],
                      ),
                      Text(
                        widget.sidebarTitle,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 40,
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
                    if (isCollapsed) {
                      // Saat collapsed, tampilkan semua child sebagai menu utama icon
                      return Column(
                        children: [
                          for (final child in item.children!)
                            _buildCollapsedMenuItem(
                              index: idx * 1000 + item.children!.indexOf(child),
                              icon: child.icon,
                              onTap: () {
                                if (child.page != null) {
                                  widget.onMenuTap(child.page!);
                                }
                              },
                            ),
                        ],
                      );
                    } else {
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
                    }
                  } else {
                    return isCollapsed
                        ? _buildCollapsedMenuItem(
                            index: idx,
                            icon: item.icon,
                            onTap: () {
                              if (item.page != null) {
                                widget.onMenuTap(item.page!);
                              }
                            },
                          )
                        : _buildMenuItem(
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
          if (!isCollapsed) ...[
            Divider(color: Colors.white.withOpacity(0.2)),
            _buildMenuItem(
              index: 999,
              bgColor: Colors.blueGrey,
              icon: Icons.arrow_back_rounded,
              title: 'Kembali Ke Menu',
              fontSize: 20,
              onTap: () => showCustomDialog(
                context: context,
                title: 'Konfirmasi Kembali',
                message: 'Apakah kamu yakin ingin kembali ke menu?',
                confirmText: 'Kembali',
                cancelText: 'Batal',
                icon: Icons.logout,
                iconColor: AppColors.primary,
                onConfirm: () {
                  Get.offAndToNamed('/main-menu');
                },
              ),
            ),
            SizedBox(height: 8),
            _buildMenuItem(
              index: 999,
              bgColor: Colors.red.withOpacity(0.8),
              icon: Icons.logout,
              title: 'Keluar Aplikasi',
              fontSize: 20,
              onTap: () => showCustomDialog(
                context: context,
                title: 'Konfirmasi Keluar',
                message: 'Apakah kamu yakin ingin keluar dari aplikasi?',
                confirmText: 'Keluar',
                cancelText: 'Batal',
                icon: Icons.logout,
                iconColor: Colors.red,
                onConfirm: () async {
                  DataTeamHalter.clearTeam();
                  print('tim :${DataTeamHalter.getTeam()}');
                  await Future.delayed(Duration(milliseconds: 1000));
                  exit(0);
                },
              ),
            ),
            SizedBox(height: 8),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  '© 2025 IPB University',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            SizedBox(height: 32),
          ],
          if (isCollapsed)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: _buildCollapsedMenuItem(
                index: 999,
                icon: Icons.logout,
                bgColor: Colors.red, // background merah
                iconColor: Colors.white, // icon putih
                onTap: () => showCustomDialog(
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
            ),
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

    return Tooltip(
      message: title,
      waitDuration: Duration(milliseconds: 400),
      child: MouseRegion(
        onEnter: (_) => setState(() => hoveredIndex = index),
        onExit: (_) => setState(() => hoveredIndex = null),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color:
                bgColor ??
                (isActive
                    ? Colors.white
                    : (isHovered
                          ? Colors.white.withOpacity(0.2)
                          : Colors.transparent)),
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
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            onTap: onTap,
          ),
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

    return Tooltip(
      message: title,
      waitDuration: Duration(milliseconds: 400),
      child: Column(
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
                      ? AppColors.primary
                      : (isHovered
                            ? AppColors.primary.withOpacity(0.2)
                            : Colors.transparent),
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
      ),
    );
  }

  Widget _buildCollapsedMenuItem({
    required int index,
    required IconData icon,
    required VoidCallback onTap,
    Color? bgColor,
    Color? iconColor,
  }) {
    final isHovered = hoveredIndex == index;
    // Ambil title dari menuItems jika ingin tooltip dinamis
    final title = index == 999
        ? 'Kembali Ke Menu'
        : (index < widget.menuItems.length
              ? widget.menuItems[index].title
              : '');

    final isActive = widget.currentMenuTitle == title;
    return Tooltip(
      message: title,
      waitDuration: Duration(milliseconds: 400),
      child: MouseRegion(
        onEnter: (_) => setState(() => hoveredIndex = index),
        onExit: (_) => setState(() => hoveredIndex = null),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color:
                bgColor ??
                (isActive
                    ? Colors.white
                    : (isHovered
                          ? Colors.white.withOpacity(0.2)
                          : Colors.transparent)),
          ),
          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: IconButton(
            icon: Icon(
              icon,
              color: iconColor ?? (isActive ? AppColors.primary : Colors.white),
              size: 30,
            ),
            onPressed: onTap,
            tooltip: '', // Tooltip sudah di luar
          ),
        ),
      ),
    );
  }

  // Dropdown menu versi collapsed (hanya icon + indicator)
  // Widget _buildCollapsedDropdownMenuItem({
  //   required int index,
  //   required IconData icon,
  //   required bool expanded,
  //   required VoidCallback onTap,
  // }) {
  //   final isHovered = hoveredIndex == index;
  //   return MouseRegion(
  //     onEnter: (_) => setState(() => hoveredIndex = index),
  //     onExit: (_) => setState(() => hoveredIndex = null),
  //     child: Container(
  //       decoration: BoxDecoration(
  //         borderRadius: BorderRadius.circular(8),
  //         color: isHovered ? Colors.white.withOpacity(0.2) : Colors.transparent,
  //       ),
  //       margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
  //       child: Row(
  //         children: [
  //           IconButton(
  //             icon: Icon(icon, color: Colors.white, size: 30),
  //             onPressed: onTap,
  //             tooltip: '', // Bisa diisi dengan nama menu jika ingin
  //           ),
  //           Icon(
  //             expanded ? Icons.keyboard_arrow_right : Icons.keyboard_arrow_left,
  //             color: Colors.white,
  //             size: 18,
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}
