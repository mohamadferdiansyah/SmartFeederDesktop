import 'dart:io';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:smart_feeder_desktop/app/data/data_controller.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_device_detail_model.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_device_model.dart';
import 'package:smart_feeder_desktop/app/models/horse_model.dart';
import 'package:smart_feeder_desktop/app/services/halter_serial_service.dart';

class HalterDeviceController extends GetxController {
  final DataController dataController = Get.find<DataController>();
  final HalterSerialService halterSerialService = Get.find<HalterSerialService>();

  List<HalterDeviceModel> get halterDeviceList => dataController.halterDeviceList;

  List<HorseModel> get horseList => dataController.horseList;

  RxList<HalterDeviceDetailModel> get detailHistory => halterSerialService.detailHistory;

  Future<void> exportDeviceExcel(List<HalterDeviceModel> data, String Function(String?) getHorseName) async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];
    sheet.appendRow([
      TextCellValue('ID'),
      TextCellValue('Kuda'),
      TextCellValue('Status'),
    ]);
    for (var d in data) {
      sheet.appendRow([
        TextCellValue(d.deviceId),
        TextCellValue(getHorseName(d.horseId)),
        TextCellValue(d.status == 'on' ? 'Aktif' : 'Tidak Aktif'),
      ]);
    }
    final fileBytes = excel.encode();
    String? path = await FilePicker.platform.saveFile(
      dialogTitle: 'Simpan file Excel (Device)',
      fileName: 'Daftar_Halter_Device.xlsx',
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );
    if (path != null) {
      await File(path).writeAsBytes(fileBytes!);
    }
  }

  /// Export data device utama ke PDF
  Future<void> exportDevicePDF(List<HalterDeviceModel> data, String Function(String?) getHorseName) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Table.fromTextArray(
          headers: ['ID', 'Kuda', 'Status'],
          data: data.map((d) => [
            d.deviceId,
            getHorseName(d.horseId),
            d.status == 'on' ? 'Aktif' : 'Tidak Aktif',
          ]).toList(),
        ),
      ),
    );
    String? path = await FilePicker.platform.saveFile(
      dialogTitle: 'Simpan file PDF (Device)',
      fileName: 'Daftar_Halter_Device.pdf',
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (path != null) {
      await File(path).writeAsBytes(await pdf.save());
    }
  }

  /// Export detail data raw device ke Excel
  Future<void> exportDetailExcel(List<HalterDeviceDetailModel> data) async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];
    // Header
    sheet.appendRow([
      TextCellValue('No'),
      TextCellValue('Device Id'),
      TextCellValue('Latitude'),
      TextCellValue('Longitude'),
      TextCellValue('Altitude'),
      TextCellValue('SoG'),
      TextCellValue('CoG'),
      TextCellValue('AcceX'),
      TextCellValue('AcceY'),
      TextCellValue('AcceZ'),
      TextCellValue('gyroX'),
      TextCellValue('gyroY'),
      TextCellValue('gyroZ'),
      TextCellValue('magX'),
      TextCellValue('magY'),
      TextCellValue('magZ'),
      TextCellValue('Roll'),
      TextCellValue('Pitch'),
      TextCellValue('Yaw'),
      TextCellValue('Arus'),
      TextCellValue('Voltase'),
      TextCellValue('BPM'),
      TextCellValue('SPO'),
      TextCellValue('Suhu'),
      TextCellValue('Respirasi'),
      TextCellValue('Time'),
    ]);
    for (int i = 0; i < data.length; i++) {
      final d = data[i];
      sheet.appendRow([
        TextCellValue('${i + 1}'),
        TextCellValue(d.deviceId),
        TextCellValue('${d.latitude ?? "-"}'),
        TextCellValue('${d.longitude ?? "-"}'),
        TextCellValue('${d.altitude ?? "-"}'),
        TextCellValue('${d.sog ?? "-"}'),
        TextCellValue('${d.cog ?? "-"}'),
        TextCellValue('${d.acceX ?? "-"}'),
        TextCellValue('${d.acceY ?? "-"}'),
        TextCellValue('${d.acceZ ?? "-"}'),
        TextCellValue('${d.gyroX ?? "-"}'),
        TextCellValue('${d.gyroY ?? "-"}'),
        TextCellValue('${d.gyroZ ?? "-"}'),
        TextCellValue('${d.magX ?? "-"}'),
        TextCellValue('${d.magY ?? "-"}'),
        TextCellValue('${d.magZ ?? "-"}'),
        TextCellValue('${d.roll ?? "-"}'),
        TextCellValue('${d.pitch ?? "-"}'),
        TextCellValue('${d.yaw ?? "-"}'),
        TextCellValue('${d.current ?? "-"}'),
        TextCellValue('${d.voltage ?? "-"}'),
        TextCellValue('${d.heartRate ?? "-"}'),
        TextCellValue('${d.spo ?? "-"}'),
        TextCellValue('${d.temperature ?? "-"}'),
        TextCellValue('${d.respiratoryRate ?? "-"}'),
        TextCellValue(d.time != null ? d.time!.toIso8601String() : "-"),
      ]);
    }
    final fileBytes = excel.encode();
    String? path = await FilePicker.platform.saveFile(
      dialogTitle: 'Simpan file Excel (Detail Raw)',
      fileName: 'Detail_Raw_Device.xlsx',
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );
    if (path != null) {
      await File(path).writeAsBytes(fileBytes!);
    }
  }

  /// Export detail data raw device ke PDF
  Future<void> exportDetailPDF(List<HalterDeviceDetailModel> data) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Table.fromTextArray(
          headers: [
            'No',
            'Device Id',
            'Latitude',
            'Longitude',
            'Altitude',
            'SoG',
            'CoG',
            'AcceX',
            'AcceY',
            'AcceZ',
            'gyroX',
            'gyroY',
            'gyroZ',
            'magX',
            'magY',
            'magZ',
            'Roll',
            'Pitch',
            'Yaw',
            'Arus',
            'Voltase',
            'BPM',
            'SPO',
            'Suhu',
            'Respirasi',
            'Time',
          ],
          data: List.generate(data.length, (i) {
            final d = data[i];
            return [
              '${i + 1}',
              d.deviceId,
              '${d.latitude ?? "-"}',
              '${d.longitude ?? "-"}',
              '${d.altitude ?? "-"}',
              '${d.sog ?? "-"}',
              '${d.cog ?? "-"}',
              '${d.acceX ?? "-"}',
              '${d.acceY ?? "-"}',
              '${d.acceZ ?? "-"}',
              '${d.gyroX ?? "-"}',
              '${d.gyroY ?? "-"}',
              '${d.gyroZ ?? "-"}',
              '${d.magX ?? "-"}',
              '${d.magY ?? "-"}',
              '${d.magZ ?? "-"}',
              '${d.roll ?? "-"}',
              '${d.pitch ?? "-"}',
              '${d.yaw ?? "-"}',
              '${d.current ?? "-"}',
              '${d.voltage ?? "-"}',
              '${d.heartRate ?? "-"}',
              '${d.spo ?? "-"}',
              '${d.temperature ?? "-"}',
              '${d.respiratoryRate ?? "-"}',
              d.time != null ? d.time.toIso8601String() : "-",
            ];
          }),
        ),
      ),
    );
    String? path = await FilePicker.platform.saveFile(
      dialogTitle: 'Simpan file PDF (Detail Raw)',
      fileName: 'Detail_Raw_Device.pdf',
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (path != null) {
      await File(path).writeAsBytes(await pdf.save());
    }
  }

  String getHorseNameById(String? horseId) {
    if (horseId == null) return "Tidak Digunakan";
    return horseList.firstWhereOrNull((h) => h.horseId == horseId)?.name ??
        "Tidak Diketahui";
  }
}
