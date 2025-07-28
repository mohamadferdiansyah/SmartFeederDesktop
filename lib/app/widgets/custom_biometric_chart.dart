import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/dashboard/halter_dashboard_controller.dart';

class CustomBiometricChart extends StatelessWidget {
  final controller = Get.find<HalterDashboardController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // GANTI: ambil history yang sesuai kuda dipilih
      final data = controller.getSelectedHorseDetailHistory();
      if (data.isEmpty) {
        return Center(child: Text('Belum ada data'));
      }

      List<FlSpot> bpmSpots = [];
      List<FlSpot> suhuSpots = [];
      List<FlSpot> spoSpots = [];
      List<FlSpot> respirasiSpots = [];
      for (int i = 0; i < data.length; i++) {
        final d = data[i];
        bpmSpots.add(FlSpot(i.toDouble(), (d.bpm ?? 0).toDouble()));
        suhuSpots.add(FlSpot(i.toDouble(), (d.suhu ?? 0)));
        spoSpots.add(FlSpot(i.toDouble(), (d.spo ?? 0)));
        respirasiSpots.add(FlSpot(i.toDouble(), (d.respirasi ?? 0)));
      }

      return LineChart(
        LineChartData(
          titlesData: FlTitlesData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: bpmSpots,
              isCurved: true,
              color: Colors.black,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
            LineChartBarData(
              spots: suhuSpots,
              isCurved: true,
              color: Colors.red,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
            LineChartBarData(
              spots: spoSpots,
              isCurved: true,
              color: Colors.blueGrey,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
            LineChartBarData(
              spots: respirasiSpots,
              isCurved: true,
              color: Colors.orange,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      );
    });
  }
}