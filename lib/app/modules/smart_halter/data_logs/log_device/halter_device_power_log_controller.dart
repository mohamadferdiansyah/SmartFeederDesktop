import 'dart:io';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:smart_feeder_desktop/app/data/data_controller.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_device_power_log_model.dart';

class HalterDevicePowerLogController extends GetxController {
  final DataController dataController = Get.find<DataController>();
  RxList<HalterDevicePowerLogModel> get logList =>
      dataController.halterDeviceLogList;

  @override
  void onInit() {
    super.onInit();
    dataController.loadHalterDevicePowerLogsFromDb();
  }

  Future<bool> exportLogExcel(List<HalterDevicePowerLogModel> logs) async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];
    sheet.appendRow([
      TextCellValue('No'),
      TextCellValue('Device ID'),
      TextCellValue('Waktu Nyala'),
      TextCellValue('Waktu Mati'),
      TextCellValue('Durasi Nyala (menit)'),
    ]);
    for (int i = 0; i < logs.length; i++) {
      final log = logs[i];
      sheet.appendRow([
        TextCellValue('${i + 1}'),
        TextCellValue(log.deviceId),
        TextCellValue(
          DateFormat('dd-MM-yyyy HH:mm:ss').format(log.powerOnTime),
        ),
        TextCellValue(
          log.powerOffTime != null
              ? DateFormat('dd-MM-yyyy HH:mm:ss').format(log.powerOffTime!)
              : '-',
        ),
        TextCellValue(
          log.durationOn != null
              ? '${log.durationOn!.inMinutes}'
              : log.powerOffTime == null
              ? '${DateTime.now().difference(log.powerOnTime).inMinutes}'
              : '-',
        ),
      ]);
    }
    final fileBytes = excel.encode();
    String? path = await FilePicker.platform.saveFile(
      dialogTitle: 'Simpan file Excel Log Power Device',
      fileName: 'Smart_Halter_Log_Power_Device.xlsx',
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );
    if (path != null) {
      // Pastikan file berekstensi .xlsx
      if (!path.toLowerCase().endsWith('.xlsx')) {
        path = '$path.xlsx';
      }
      await File(path).writeAsBytes(fileBytes!);
      return true;
    }
    return false;
  }

  Future<bool> exportLogPDF(List<HalterDevicePowerLogModel> logs) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        orientation: pw.PageOrientation.landscape,
        build: (context) => pw.Table.fromTextArray(
          headers: [
            'No',
            'Device ID',
            'Waktu Nyala',
            'Waktu Mati',
            'Durasi Nyala (menit)',
          ],
          data: List.generate(logs.length, (i) {
            final log = logs[i];
            return [
              '${i + 1}',
              log.deviceId,
              DateFormat('dd-MM-yyyy HH:mm:ss').format(log.powerOnTime),
              log.powerOffTime != null
                  ? DateFormat('dd-MM-yyyy HH:mm:ss').format(log.powerOffTime!)
                  : '-',
              log.durationOn != null
                  ? '${log.durationOn!.inMinutes}'
                  : log.powerOffTime == null
                  ? '${DateTime.now().difference(log.powerOnTime).inMinutes}'
                  : '-',
            ];
          }),
        ),
      ),
    );
    String? path = await FilePicker.platform.saveFile(
      dialogTitle: 'Simpan file PDF Log Power Device',
      fileName: 'Smart_Halter_Log_Power_Device.pdf',
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (path != null) {
      // Pastikan file berekstensi .pdf
      if (!path.toLowerCase().endsWith('.pdf')) {
        path = '$path.pdf';
      }
      final file = File(path);
      await file.writeAsBytes(await pdf.save());
      return true;
    }
    return false;
  }
}
