import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_device_detail_model.dart';
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

      // Sort data dari terbaru ke terlama
      final sortedData = List<HalterDeviceDetailModel>.from(data)
        ..sort(
          (a, b) => (b.time ?? DateTime(0)).compareTo(a.time ?? DateTime(0)),
        );

      // Ambil hanya 10 data terbaru
      final displayData = sortedData.take(maxData).toList();

      // Reverse agar urutan waktu dari lama ke baru di sumbu X
      final reversedData = displayData.reversed.toList();

      List<FlSpot> rollSpots = [];
      List<FlSpot> pitchSpots = [];
      List<FlSpot> yawSpots = [];
      List<String> timeLabels = [];

      for (int i = 0; i < reversedData.length; i++) {
        final d = reversedData[i];
        rollSpots.add(FlSpot(i.toDouble(), (d.roll ?? 0).toDouble()));
        pitchSpots.add(FlSpot(i.toDouble(), (d.pitch ?? 0).toDouble()));
        yawSpots.add(FlSpot(i.toDouble(), (d.yaw ?? 0).toDouble()));
        final timeStr = d.time != null
            ? d.time.toIso8601String().split('T')[1].split('.')[0]
            : '-';
        timeLabels.add(timeStr);
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
