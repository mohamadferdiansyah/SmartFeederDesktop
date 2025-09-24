import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_feeder_desktop/app/constants/app_colors.dart';

class CustomFeederHistoryCard extends StatelessWidget {
  final String type; // 'feed' atau 'water'
  final double? amount; // hanya untuk feed
  final String? status; // hanya untuk water: 'penuh'/'kosong'
  final DateTime timestamp;
  final String mode;
  final String deviceId;

  const CustomFeederHistoryCard({
    super.key,
    required this.type,
    this.amount,
    this.status,
    required this.timestamp,
    required this.mode,
    required this.deviceId,
  });

  @override
  Widget build(BuildContext context) {
    final isFeed = type == 'feed';
    final icon = isFeed ? Icons.restaurant_rounded : Icons.water_drop_rounded;
    final iconColor = isFeed ? Colors.deepOrange : Colors.blue;
    final valueText = isFeed
        ? 'Jumlah Pakan: ${amount?.toStringAsFixed(2) ?? "-"}g'
        : 'Status Air: ${status?.replaceFirstMapped(RegExp(r'^[a-zA-Z]'), (match) => match.group(0)!.toUpperCase()) ?? "-"}';
    final valueStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 18,
      color: isFeed ? Colors.deepOrange : Colors.blue,
    );
    final dateText = DateFormat('dd MMM yyyy, HH:mm').format(timestamp);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: iconColor.withOpacity(0.07),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: iconColor.withOpacity(0.18), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(child: Icon(icon, color: iconColor)),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(valueText, style: valueStyle),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 18,
                        color: Colors.blueGrey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        dateText,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.blueGrey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Icon(
                      mode == 'auto'
                          ? Icons.autorenew_rounded
                          : mode == 'penjadwalan'
                          ? Icons.schedule_rounded
                          : mode == 'manual'
                          ? Icons.settings_rounded
                          : Icons.help_outline,
                      size: 18,
                      color: mode == 'penjadwalan'
                          ? Colors.teal
                          : mode == 'auto'
                          ? Colors.blue
                          : Colors.orange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      mode == 'penjadwalan'
                          ? 'Penjadwalan'
                          : mode == 'auto'
                          ? 'Otomatis'
                          : 'Manual',
                      style: TextStyle(
                        fontSize: 14,
                        color: mode == 'penjadwalan'
                            ? Colors.teal
                            : mode == 'auto'
                            ? Colors.blue
                            : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.devices_other,
                      size: 18,
                      color: Colors.orange[800],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      deviceId,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.orange[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
