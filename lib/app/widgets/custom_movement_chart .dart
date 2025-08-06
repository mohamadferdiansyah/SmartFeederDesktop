import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/dashboard/halter_dashboard_controller.dart';

class CustomMovementChart extends StatelessWidget {
  final controller = Get.find<HalterDashboardController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.filteredRoomList.isEmpty ||
          controller.selectedRoom.horseId == null ||
          controller.selectedRoom.horseId!.isEmpty) {
        return Center(
          child: Text(
            'Tidak ada data kuda',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        );
      }
      final data = controller.getSelectedHorseDetailHistory();
      const maxData = 10;
      // Ambil hanya 10 data terakhir
      final displayData = data.length > maxData
          ? data.sublist(data.length - maxData)
          : data;

      List<FlSpot> rollSpots = [];
      List<FlSpot> pitchSpots = [];
      List<FlSpot> yawSpots = [];
      for (int i = 0; i < displayData.length; i++) {
        rollSpots.add(
          FlSpot(i.toDouble(), (displayData[i].roll ?? 0).toDouble()),
        );
        pitchSpots.add(
          FlSpot(i.toDouble(), (displayData[i].pitch ?? 0).toDouble()),
        );
        yawSpots.add(
          FlSpot(i.toDouble(), (displayData[i].yaw ?? 0).toDouble()),
        );
      }

      return LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(spots: rollSpots, color: Colors.red),
            LineChartBarData(spots: pitchSpots, color: Colors.green),
            LineChartBarData(spots: yawSpots, color: Colors.blue),
          ],
        ),
      );
    });
  }
}
