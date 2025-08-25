import 'package:flutter/material.dart';

class BiometrikLegendItem {
  final Color color;
  final String label;
  final String value;

  const BiometrikLegendItem({
    required this.color,
    required this.label,
    required this.value,
  });
}

class CustomBiometricLegend extends StatelessWidget {
  final List<BiometrikLegendItem> items;

  const CustomBiometricLegend({
    Key? key,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              child: Row(
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: item.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.label,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Text(
                    item.value,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}