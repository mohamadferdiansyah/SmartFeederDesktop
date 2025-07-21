import 'package:flutter/material.dart';
import 'package:smart_feeder_desktop/app/constants/app_colors.dart';

class CustomCard extends StatelessWidget {
  final String title;
  final double titleFontSize;
  final double headerHeight;
  final Widget content;
  final Widget? trailing;
  final Color headerColor;
  final double borderRadius;
  final bool scrollable;
  final double width;
  final double height;

  const CustomCard({
    super.key,
    required this.title,
    required this.content,
    this.trailing,
    this.width = double.infinity,
    this.height = double.infinity,
    this.titleFontSize = 24,
    this.headerHeight = 70,
    this.headerColor = AppColors.primary,
    this.borderRadius = 12,
    this.scrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              height: headerHeight,
              width: double.infinity,
              decoration: BoxDecoration(
                color: headerColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(borderRadius),
                  topRight: Radius.circular(borderRadius),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 12),
                      if (trailing != null) trailing!,
                    ],
                  ),
                ),
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: scrollable
                    ? SingleChildScrollView(child: content)
                    : content,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
