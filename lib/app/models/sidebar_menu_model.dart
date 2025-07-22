import 'package:flutter/material.dart';

class SidebarMenuItem {
  final String title;
  final IconData icon;
  final Widget? page;
  final List<SidebarMenuItem>? children;

  SidebarMenuItem({
    required this.title,
    this.icon = Icons.menu,
    this.page,
    this.children,
  });
}
