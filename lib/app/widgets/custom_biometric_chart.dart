import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CustomBiometricChart extends StatelessWidget {
  final List<FlSpot> bpmSpots;
  final List<FlSpot> suhuSpots;
  final List<FlSpot> spoSpots;
  final List<FlSpot> respirasiSpots;
  final List<String> timeLabels;

  const CustomBiometricChart({
    super.key,
    required this.bpmSpots,
    required this.suhuSpots,
    required this.spoSpots,
    required this.respirasiSpots,
    required this.timeLabels,
  });

  @override
  Widget build(BuildContext context) {
    double minY = [
      ...bpmSpots.map((e) => e.y),
      ...suhuSpots.map((e) => e.y),
      ...spoSpots.map((e) => e.y),
      ...respirasiSpots.map((e) => e.y),
    ].reduce((a, b) => a < b ? a : b);

    double maxY = [
      ...bpmSpots.map((e) => e.y),
      ...suhuSpots.map((e) => e.y),
      ...spoSpots.map((e) => e.y),
      ...respirasiSpots.map((e) => e.y),
    ].reduce((a, b) => a > b ? a : b);

    minY -= 5;
    maxY += 5;

    return LineChart(
      LineChartData(
        minY: minY,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          horizontalInterval: 5,
          verticalInterval: 1,
          checkToShowHorizontalLine: (value) => value % 5 == 0,
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              getTitlesWidget: (value, meta) => Padding(
                padding: const EdgeInsets.only(right: 6.0),
                child: Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                ),
              ),
            ),
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
            spots: bpmSpots,
            isCurved: true,
            color: Colors.black,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(show: false),
            barWidth: 2.5,
          ),
          LineChartBarData(
            spots: suhuSpots,
            isCurved: true,
            color: Colors.red,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(show: false),
            barWidth: 2.5,
          ),
          LineChartBarData(
            spots: spoSpots,
            isCurved: true,
            color: Colors.blue,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(show: false),
            barWidth: 2.5,
          ),
          LineChartBarData(
            spots: respirasiSpots,
            isCurved: true,
            color: Colors.orange,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(show: false),
            barWidth: 2.5,
          ),
        ],
      ),
    );
  }
}
