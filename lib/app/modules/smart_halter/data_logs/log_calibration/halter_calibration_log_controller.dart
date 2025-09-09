import 'dart:io';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:smart_feeder_desktop/app/data/data_controller.dart';
import 'package:smart_feeder_desktop/app/data/data_halter_calibration_log.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_calibration_log_model.dart';

class HalterCalibrationLogController extends GetxController {
  final DataController dataController = Get.find<DataController>();
  RxList<HalterCalibrationLogModel> get logs =>
      dataController.calibrationLogList;

  @override
  void onInit() {
    logs.value = DataHalterCalibrationLog.getAll();
    super.onInit();
  }

  void addLog(HalterCalibrationLogModel log) async {
    await dataController.addCalibrationLog(log);
  }

  void clearLogs() {
    logs.clear();
    DataHalterCalibrationLog.clear();
  }

  Future<void> exportLogExcel(List<HalterCalibrationLogModel> logs) async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];
    sheet.appendRow([
      TextCellValue('No'),
      TextCellValue('Timestamp'),
      TextCellValue('Device ID'),
      TextCellValue('Nama Sensor'),
      TextCellValue('Data lookup (Referensi)'),
      TextCellValue('Data Sensor'),
      TextCellValue('Nilai Kalibrasi'),
    ]);
    for (int i = 0; i < logs.length; i++) {
      final log = logs[i];
      sheet.appendRow([
        TextCellValue('${i + 1}'),
        TextCellValue(DateFormat('dd-MM-yyyy HH:mm:ss').format(log.timestamp)),
        TextCellValue(log.deviceId),
        TextCellValue(log.sensorName),
        TextCellValue(log.referensi),
        TextCellValue(log.sensorValue),
        TextCellValue(log.nilaiKalibrasi),
      ]);
    }
    final fileBytes = excel.encode();
    String? path = await FilePicker.platform.saveFile(
      dialogTitle: 'Simpan file Excel Log Kalibrasi',
      fileName: 'Smart_Halter_Log_Kalibrasi.xlsx',
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );
    if (path != null) {
      await File(path).writeAsBytes(fileBytes!);
    }
  }

  Future<void> exportLogPDF(List<HalterCalibrationLogModel> logs) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Table.fromTextArray(
          headers: [
            'No',
            'Timestamp',
            'Device ID',
            'Nama Sensor',
            'Data lookup (Referensi)',
            'Data Sensor',
            'Nilai Kalibrasi',
          ],
          data: List.generate(logs.length, (i) {
            final log = logs[i];
            return [
              '${i + 1}',
              DateFormat('dd-MM-yyyy HH:mm:ss').format(log.timestamp),
              log.deviceId,
              log.sensorName,
              log.referensi,
              log.sensorValue,
              log.nilaiKalibrasi,
            ];
          }),
        ),
      ),
    );
    String? path = await FilePicker.platform.saveFile(
      dialogTitle: 'Simpan file PDF Log Kalibrasi',
      fileName: 'Smart_Halter_Log_Kalibrasi.pdf',
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (path != null) {
      await File(path).writeAsBytes(await pdf.save());
    }
  }
}
