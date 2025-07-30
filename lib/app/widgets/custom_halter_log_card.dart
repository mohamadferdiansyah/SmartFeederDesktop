import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomHalterLogCard extends StatelessWidget {
  final String horseName;
  final String roomName;
  final String logMessage;
  final DateTime time;
  final Color iconBgColor;

  const CustomHalterLogCard({
    super.key,
    required this.horseName,
    required this.roomName,
    required this.logMessage,
    required this.time,
    this.iconBgColor = const Color(0xFFD34B40),
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
                  fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold,
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
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: const Icon(Icons.pets, color: Colors.white, size: 26),
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
                      Text(
                        roomName,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        logMessage,
                        style: const TextStyle(
                          fontSize: 13.5,
                          color: Color(0xFFD34B40),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}