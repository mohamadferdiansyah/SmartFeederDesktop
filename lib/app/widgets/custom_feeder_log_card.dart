import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomFeederLogCard extends StatelessWidget {
  final String deviceName;
  final String? roomName;
  final String logMessage;
  final String type;
  final DateTime time;
  final Color iconBgColor;
  final bool isWarning;

  const CustomFeederLogCard({
    super.key,
    required this.deviceName,
    this.roomName,
    required this.type,
    required this.logMessage,
    this.isWarning = false,
    required this.time,
    this.iconBgColor = const Color(0xFF1565C0),
  });

  @override
  Widget build(BuildContext context) {
    final dateText = DateFormat('dd MMM', 'id_ID').format(time);
    final timeText = DateFormat('HH:mm', 'id_ID').format(time);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 62,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                dateText,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$timeText\nWIB',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 2,
          height: 48,
          color: Colors.grey[300],
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.09),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: isWarning ? Colors.red : iconBgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    _getLogIcon(type, isWarning),
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        deviceName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      if (roomName != null) ...[
                        Text(
                          roomName!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                      const SizedBox(height: 2),
                      Text(
                        logMessage,
                        style: TextStyle(
                          fontSize: 13.5,
                          color: isWarning ? Colors.red : const Color(0xFF1565C0),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  IconData _getLogIcon(String type, bool isWarning) {
    switch (type) {
      case 'feed_min':
      case 'feed_tank_min':
        return Icons.rice_bowl_rounded;
      case 'water_min':
      case 'water_tank_min':
        return Icons.water_drop_rounded;
      case 'battery_min':
        return Icons.battery_alert_outlined;
      case 'ph_min':
      case 'ph_tank_min':
        return Icons.science_rounded;
      default:
        return Icons.info_outline;
    }
  }
}