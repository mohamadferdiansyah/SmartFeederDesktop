import 'package:flutter/material.dart';

class CustomStableTankCard extends StatelessWidget {
  final bool isWater;
  final dynamic current; // bisa double (pakan) atau String (air)
  final double max;
  final String lastText;
  final String Function(dynamic, double, bool) getTankImageAsset;

  const CustomStableTankCard({
    super.key,
    required this.isWater,
    required this.current,
    required this.max,
    required this.lastText,
    required this.getTankImageAsset,
  });

  @override
  Widget build(BuildContext context) {
    final folderColor = isWater ? Colors.blue : Colors.deepOrange;
    final title = isWater ? "Tempat Air" : "Tempat Pakan";
    final unit = isWater ? "" : "g";
    final maxUnit = isWater ? "" : "Gram";
    final img = getTankImageAsset(current, max, isWater);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: folderColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: folderColor),
      ),
      child: Row(
        children: [
          Image.asset(img, width: 120, height: 120),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isWater ? 'Status Air:' : 'Sisa Pakan:',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              isWater
                                  ? (current == "penuh"
                                      ? "Penuh"
                                      : "Kosong")
                                  : '${(current as double).toStringAsFixed(1)}$unit',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: folderColor,
                              ),
                            ),
                            if (!isWater) ...[
                              Text(
                                ' /',
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueGrey,
                                ),
                              ),
                              Text(
                                '${max.toStringAsFixed(1)} $maxUnit',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueGrey,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  isWater ? 'Terakhir Diberi Air:' : 'Terakhir Diberi Pakan:',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                Text(
                  lastText,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 