import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/dashboard/halter_dashboard_controller.dart';

class CustomBatteryChart extends StatelessWidget {
  final controller = Get.find<HalterDashboardController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final history = controller.getSelectedHorseDetailHistory();
      if (history.isEmpty) {
        return Center(child: Text('Belum ada data baterai'));
      }

      // Ambil data baterai sebagai FlSpot (pakai voltase atau batteryPercent, sesuai model)
      List<FlSpot> batterySpots = [];
      for (int i = 0; i < history.length; i++) {
        // Ganti dengan field batteryPercent jika ada
        final percent = history[i].voltase ?? 0;
        batterySpots.add(FlSpot(i.toDouble(), percent.toDouble()));
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Persentase Baterai IoT Halter",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 8),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: batterySpots,
                    isCurved: true,
                    color: Colors.blue[900],
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      // Tampilkan jam dari data, jika ada
                      getTitlesWidget: (value, meta) {
                        // Contoh: jika ada field time di HalterDeviceDetailModel
                        String timeLabel = "";
                        int idx = value.toInt();
                        if (idx >= 0 && idx < history.length) {
                          // Ganti field ini jika model ada time/timestamp
                          timeLabel = "";
                        }
                        return Text(timeLabel, style: TextStyle(fontSize: 8));
                      },
                      interval: 5, // Tampilkan setiap 5 data, sesuaikan
                    ),
                  ),
                ),
                gridData: FlGridData(show: true),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ],
      );
    });
  }
}
