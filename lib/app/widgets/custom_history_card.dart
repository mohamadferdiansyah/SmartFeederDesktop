import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class HistoryEntryCard extends StatelessWidget {
  final DateTime datetime;
  final double water;
  final double feed;
  final String scheduleText;

  const HistoryEntryCard({
    super.key,
    required this.datetime,
    required this.water,
    required this.feed,
    required this.scheduleText,
  });

  @override
  Widget build(BuildContext context) {
    final dateString = DateFormat('EEEE, d MMM yyyy', 'id_ID').format(datetime);

    final timeString = DateFormat('HH:mm', 'id_ID').format(datetime);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Kolom 1: Tanggal & Jam
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dateString,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    timeString,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Kolom 2: Air
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Air',
                    style: TextStyle(fontSize: 14, color: Colors.blue),
                  ),
                  Text(
                    '${water.toStringAsFixed(1)} Liter',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            // Kolom 3: Pakan
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pakan',
                    style: TextStyle(fontSize: 14, color: Colors.deepOrange),
                  ),
                  Text(
                    '${feed.toStringAsFixed(1)} Gram',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            // Kolom 4: Mode
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mode',
                    style: TextStyle(fontSize: 14, color: Colors.teal),
                  ),
                  Text(
                    scheduleText,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
