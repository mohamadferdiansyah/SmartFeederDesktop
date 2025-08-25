import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomHalterLogCard extends StatelessWidget {
  final String horseName;
  final String? roomName;
  final String logMessage;
  final String type;
  final DateTime time;
  final Color iconBgColor;
  final bool isHigh;

  const CustomHalterLogCard({
    super.key,
    required this.horseName,
    this.roomName,
    required this.type,
    required this.logMessage,
    this.isHigh = false,
    required this.time,
    this.iconBgColor = const Color(0xFF1565C0), // biru tua/dingin
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
                    color: isHigh ? Colors.red : iconBgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    type == 'temperature' && isHigh
                        ? Icons.thermostat_outlined
                        : type == 'temperature' && !isHigh
                        ? Icons.thermostat_auto_outlined
                        : type == 'spo'
                        ? Icons.local_fire_department_outlined
                        : type == 'bpm'
                        ? Icons.monitor_weight_outlined
                        : type == 'respirasi'
                        ? Icons.air_outlined
                        : type == 'room_temperature'
                        ? Icons.house_siding_rounded
                        : type == 'humidity'
                        ? Icons.opacity_outlined
                        : type == 'light_intensity'
                        ? Icons.light_mode_outlined
                        : type == 'battery'
                        ? Icons.battery_alert_outlined
                        : Icons.info_outline,
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
                        horseName,
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
                          color: isHigh ? Colors.red : Color(0xFF1565C0),
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
}
