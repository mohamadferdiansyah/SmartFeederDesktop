import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/dashboard/halter_dashboard_controller.dart';
  
class CustomMovementChart  extends StatelessWidget {
  final controller = Get.find<HalterDashboardController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final data = controller.getSelectedHorseDetailHistory();
      List<FlSpot> acceXSpots = [];
      List<FlSpot> acceYSpots = [];
      List<FlSpot> acceZSpots = [];
      for (int i = 0; i < data.length; i++) {
        acceXSpots.add(FlSpot(i.toDouble(), (data[i].acceX ?? 0)));
        acceYSpots.add(FlSpot(i.toDouble(), (data[i].acceY ?? 0)));
        acceZSpots.add(FlSpot(i.toDouble(), (data[i].acceZ ?? 0)));
      }

      return LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(spots: acceXSpots, color: Colors.red),
            LineChartBarData(spots: acceYSpots, color: Colors.green),
            LineChartBarData(spots: acceZSpots, color: Colors.blue),
          ],
        ),
      );
    });
  }
}
