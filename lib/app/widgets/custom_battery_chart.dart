import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/dashboard/halter_dashboard_controller.dart';

class CustomBatteryChart extends StatefulWidget {
  const CustomBatteryChart({super.key});

  @override
  State<CustomBatteryChart> createState() => _CustomBatteryChartState();
}

class _CustomBatteryChartState extends State<CustomBatteryChart> {
  bool isShowingMainData = true;
  final controller = Get.find<HalterDashboardController>();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2.8,
      child: Obx(() {
        final data = controller.getSelectedHorseDetailHistory();
        if (data.isEmpty) {
          return Center(child: Text('Belum ada data'));
        }

        // Buat FlSpot & label waktu
        List<FlSpot> bpmSpots = [];
        List<FlSpot> suhuSpots = [];
        List<FlSpot> spoSpots = [];
        List<FlSpot> respirasiSpots = [];
        List<String> timeLabels = [];

        for (int i = 0; i < data.length; i++) {
          final d = data[i];
          bpmSpots.add(FlSpot(i.toDouble(), (d.heartRate ?? 0).toDouble()));
          suhuSpots.add(FlSpot(i.toDouble(), (d.temperature ?? 0)));
          spoSpots.add(FlSpot(i.toDouble(), (d.spo ?? 0)));
          respirasiSpots.add(FlSpot(i.toDouble(), (d.respiratoryRate ?? 0)));
          timeLabels.add((d.time).toString());
        }

        double minY = [
          ...bpmSpots.map((e) => e.y),
          ...suhuSpots.map((e) => e.y),
          ...spoSpots.map((e) => e.y),
          ...respirasiSpots.map((e) => e.y)
        ].reduce((a, b) => a < b ? a : b);
        double maxY = [
          ...bpmSpots.map((e) => e.y),
          ...suhuSpots.map((e) => e.y),
          ...spoSpots.map((e) => e.y),
          ...respirasiSpots.map((e) => e.y)
        ].reduce((a, b) => a > b ? a : b);
        minY = minY - 5;
        maxY = maxY + 5;

        return Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 16, left: 6, top: 12, bottom: 10),
              child: LineChart(
                isShowingMainData
                    ? mainChartData(bpmSpots, suhuSpots, spoSpots, respirasiSpots, minY, maxY, timeLabels)
                    : mainChartData(bpmSpots, suhuSpots, spoSpots, respirasiSpots, minY, maxY, timeLabels, faded: true),
                duration: const Duration(milliseconds: 250),
              ),
            ),
            Positioned(
              right: 10,
              top: 15,
              child: IconButton(
                icon: Icon(
                  Icons.refresh,
                  color: isShowingMainData ? Colors.black : Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    isShowingMainData = !isShowingMainData;
                  });
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  LineChartData mainChartData(
    List<FlSpot> bpm,
    List<FlSpot> suhu,
    List<FlSpot> spo,
    List<FlSpot> respirasi,
    double minY,
    double maxY,
    List<String> timeLabels, {
    bool faded = false,
  }) {
    return LineChartData(
      lineTouchData: LineTouchData(
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              return LineTooltipItem(
                '${spot.bar == bpmBar ? "BPM" : spot.bar == suhuBar ? "Suhu" : spot.bar == spoBar ? "SPO" : "Respirasi"}: ${spot.y}',
                TextStyle(
                  color: spot.bar.gradient?.colors.first ?? spot.bar.color ?? Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              );
            }).toList();
          },
        ),
      ),
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,
        horizontalInterval: 5,
        verticalInterval: 1,
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
                style: TextStyle(fontSize: 12, color: Colors.black87),
              ),
            ),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 32,
            interval: 1,
            getTitlesWidget: (value, meta) {
              int idx = value.toInt();
              if (idx < 0 || idx >= timeLabels.length) return Container();
              return Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  timeLabels[idx],
                  style: TextStyle(fontSize: 12),
                ),
              );
            },
          ),
        ),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      minX: 0,
      maxX: bpm.length > 1 ? bpm.length - 1 : 1,
      minY: minY,
      maxY: maxY,
      borderData: FlBorderData(
        show: true,
        border: Border(
          bottom: BorderSide(color: Colors.black.withOpacity(0.3), width: 1),
          left: BorderSide(color: Colors.black.withOpacity(0.3), width: 1),
          right: const BorderSide(color: Colors.transparent),
          top: const BorderSide(color: Colors.transparent),
        ),
      ),
      lineBarsData: [
        bpmBar.copyWith(
          spots: bpm,
          color: Colors.black.withOpacity(faded ? 0.15 : 1.0),
        ),
        suhuBar.copyWith(
          spots: suhu,
          color: Colors.red.withOpacity(faded ? 0.15 : 1.0),
        ),
        spoBar.copyWith(
          spots: spo,
          color: Colors.blue.withOpacity(faded ? 0.15 : 1.0),
        ),
        respirasiBar.copyWith(
          spots: respirasi,
          color: Colors.orange.withOpacity(faded ? 0.15 : 1.0),
        ),
      ],
    );
  }

  // Template LineChartBarData for easy customization
  LineChartBarData get bpmBar => LineChartBarData(
        isCurved: true,
        color: Colors.black,
        barWidth: 3.5,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: true),
        belowBarData: BarAreaData(show: false),
        spots: const [],
      );
  LineChartBarData get suhuBar => LineChartBarData(
        isCurved: true,
        color: Colors.red,
        barWidth: 3.5,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: true),
        belowBarData: BarAreaData(show: false),
        spots: const [],
      );
  LineChartBarData get spoBar => LineChartBarData(
        isCurved: true,
        color: Colors.blue,
        barWidth: 3.5,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: true),
        belowBarData: BarAreaData(show: false),
        spots: const [],
      );
  LineChartBarData get respirasiBar => LineChartBarData(
        isCurved: true,
        color: Colors.orange,
        barWidth: 3.5,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: true),
        belowBarData: BarAreaData(show: false),
        spots: const [],
      );
}