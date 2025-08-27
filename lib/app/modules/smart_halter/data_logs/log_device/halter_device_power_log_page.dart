import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/data_logs/log_device/halter_device_power_log_controller.dart';

class HalterDevicePowerLogPage extends StatelessWidget {
  final HalterDevicePowerLogController controller =
      Get.find<HalterDevicePowerLogController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Log Nyala/Mati Halter Device')),
      body: Obx(() {
        final logs = controller.logList;
        return DataTable(
          columns: const [
            DataColumn(label: Text('Device ID')),
            DataColumn(label: Text('Waktu Nyala')),
            DataColumn(label: Text('Waktu Mati')),
            DataColumn(label: Text('Durasi Nyala')),
          ],
          rows: logs.map((log) {
            return DataRow(
              cells: [
                DataCell(Text(log.deviceId)),
                DataCell(Text(log.powerOnTime.toString())),
                DataCell(Text(log.powerOffTime?.toString() ?? '-')),
                DataCell(
                  Text(
                    log.durationOn != null
                        ? '${log.durationOn!.inMinutes} menit'
                        : '-',
                  ),
                ),
              ],
            );
          }).toList(),
        );
      }),
    );
  }
}
