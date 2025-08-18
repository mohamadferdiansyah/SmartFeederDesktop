import 'package:flutter/material.dart';

class CustomBatteryIndicator extends StatelessWidget {
  final int percent;
  final double iconSize;
  final Color? iconColor;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;

  const CustomBatteryIndicator({
    Key? key,
    required this.percent,
    this.iconSize = 50,
    this.iconColor,
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  }) : super(key: key);

  IconData _getBatteryIcon(int percent) {
    if (percent <= 5) return Icons.battery_0_bar;
    if (percent <= 15) return Icons.battery_1_bar;
    if (percent <= 25) return Icons.battery_2_bar;
    if (percent <= 35) return Icons.battery_3_bar;
    if (percent <= 50) return Icons.battery_4_bar;
    if (percent <= 65) return Icons.battery_5_bar;
    if (percent <= 80) return Icons.battery_6_bar;
    if (percent <= 95) return Icons.battery_full;
    return Icons.battery_full;
  }

  Color _getBatteryColor(int percent) {
    if (percent <= 15) return Colors.red;
    if (percent <= 40) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Icon(
          _getBatteryIcon(percent),
          color: iconColor ?? _getBatteryColor(percent),
          size: iconSize,
        ),
        const SizedBox(width: 6),
        Text(
          "$percent%",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: iconSize * 0.68,
            color: iconColor ?? _getBatteryColor(percent),
          ),
        ),
      ],
    );
  }
}
