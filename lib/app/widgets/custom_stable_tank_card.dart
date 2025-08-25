import 'package:flutter/material.dart';

class CustomStableTankCard extends StatelessWidget {
  final bool isWater;
  final double current;
  final double max;
  final double? phLevel;          // hanya untuk air, null jika pakan
  final String lastText;
  final String Function(double, double, bool) getTankImageAsset;

  const CustomStableTankCard({
    super.key,
    required this.isWater,
    required this.current,
    required this.max,
    this.phLevel,
    required this.lastText,
    required this.getTankImageAsset,
  });

  @override
  Widget build(BuildContext context) {
    final folderColor = isWater ? Colors.blue : Colors.deepOrange;
    final title = isWater ? "Tempat Air" : "Tempat Pakan";
    final unit = isWater ? "L" : "g";
    final maxUnit = isWater ? "Liter" : "Gram";
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
                          isWater ? 'Sisa Air:' : 'Sisa Pakan:',
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
                              '${current.toStringAsFixed(1)}$unit',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: folderColor,
                              ),
                            ),
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
                        ),
                      ],
                    ),
                    if (isWater) ...[
                      const SizedBox(width: 24),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ph Level:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            phLevel?.toStringAsFixed(2) ?? '-',
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
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