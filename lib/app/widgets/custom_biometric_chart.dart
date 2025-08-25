import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CustomBiometricChart extends StatelessWidget {
  final List<FlSpot> spots;
  final List<String> timeLabels;
  final String titleY;
  final String titleX;
  final Color lineColor;

  const CustomBiometricChart({
    super.key,
    required this.spots,
    required this.timeLabels,
    required this.titleY,
    required this.titleX,
    required this.lineColor,
  });

  @override
  Widget build(BuildContext context) {
    if (spots.isEmpty) {
      return const Center(
        child: Text(
          'Tidak ada data biometrik yang tersedia',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    double minY = spots.map((e) => e.y).reduce((a, b) => a < b ? a : b);
    double maxY = spots.map((e) => e.y).reduce((a, b) => a > b ? a : b);

    if (minY == maxY) {
      minY -= 5;
      maxY += 5;
    } else {
      minY -= 5;
      maxY += 5;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: SizedBox(
        height: 260,
        child: LineChart(
          LineChartData(
            minY: minY,
            maxY: maxY,
            gridData: FlGridData(
              show: true,
              drawHorizontalLine: true,
              horizontalInterval: ((maxY - minY) / 5).abs(),
              verticalInterval: 1,
              checkToShowHorizontalLine: (value) => true,
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 48,
                  getTitlesWidget: (value, meta) => Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      value.toInt().toString(),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                axisNameWidget: Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: Text(
                    titleY,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                axisNameSize: 50,
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 36,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    int idx = value.toInt();
                    if (idx < 0 || idx >= timeLabels.length)
                      return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        timeLabels[idx],
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  },
                ),
                axisNameWidget: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    titleX,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                axisNameSize: 40,
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: lineColor,
                dotData: const FlDotData(show: true),
                belowBarData: BarAreaData(show: false),
                barWidth: 2.5,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
