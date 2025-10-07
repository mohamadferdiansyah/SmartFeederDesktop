import 'dart:io';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:smart_feeder_desktop/app/data/data_controller.dart';
import 'package:smart_feeder_desktop/app/models/feeder/feeder_device_detail_model.dart';
import 'package:smart_feeder_desktop/app/models/feeder/feeder_device_history_model.dart';
import 'package:smart_feeder_desktop/app/models/feeder/feeder_device_model.dart';
import 'package:smart_feeder_desktop/app/models/room_model.dart';
import 'package:smart_feeder_desktop/app/models/stable_model.dart';
import 'package:smart_feeder_desktop/app/services/mqtt_service.dart';

class FeederDeviceController extends GetxController {
  final DataController dataController = Get.find<DataController>();
  final MqttService mqtt = Get.find<MqttService>();

  RxList<RoomModel> get roomList => dataController.roomList;
  RxList<StableModel> get stableList => dataController.stableList;

  RxList<FeederDeviceModel> get feederDeviceList =>
      dataController.feederDeviceList;

  RxList<FeederDeviceDetailModel> get feederDeviceDetailList =>
      dataController.feederDeviceDetailList;

  RxList<FeederDeviceHistoryModel> get feederDeviceHistoryList =>
      dataController.feederDeviceHistoryList;

  String getRoomName(String? stableId) {
    if (stableId == null || stableId.isEmpty) return "-";
    final stable = stableList.firstWhereOrNull((s) => s.stableId == stableId);
    return stable?.name ?? "-";
  }

  Future<void> loadDevices() async {
    await dataController.loadFeederDevicesFromDb();
  }

  Future<void> addDevice(FeederDeviceModel model) async {
    await dataController.addFeederDevice(model);
    await loadDevices();
    mqtt.publishMode(deviceId: model.deviceId, mode: model.scheduleType);
  }

  Future<void> updateDevice(FeederDeviceModel model, String oldDeviceId) async {
    await dataController.updateFeederDevice(model, oldDeviceId);
    await loadDevices();
    mqtt.publishMode(deviceId: model.deviceId, mode: model.scheduleType);
  }

  Future<void> deleteDevice(String deviceId) async {
    await dataController.deleteFeederDevice(deviceId);
    await loadDevices();
  }

  /// Export data device ke Excel
  Future<bool> exportDeviceExcel(List<FeederDeviceModel> data) async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];
    sheet.appendRow([
      TextCellValue('ID'),
      TextCellValue('Kandang'),
      // TextCellValue('Status'),
      TextCellValue('Mode Penjadwalan'),
      TextCellValue('Versi'),
    ]);
    for (var d in data) {
      // Ambil detail dari deviceId
      final detail = feederDeviceDetailList.firstWhereOrNull(
        (det) => det.deviceId == d.deviceId,
      );
      sheet.appendRow([
        TextCellValue(d.deviceId),
        TextCellValue(
          d.stableId != null ? getRoomName(d.stableId!) : 'Tidak ada',
        ),
        // TextCellValue(detail?.status ?? '-'),
        TextCellValue(d.scheduleType == 'auto' ? 'Otomatis' : 'Manual'),
        TextCellValue(d.version),
      ]);
    }
    final fileBytes = excel.encode();
    String? path = await FilePicker.platform.saveFile(
      dialogTitle: 'Simpan file Excel Perangkat',
      fileName: 'Smart_Feeder_Daftar_IoT_Main_Feeder_Device.xlsx',
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

  /// Export data device ke PDF
  Future<bool> exportDevicePDF(List<FeederDeviceModel> data) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Table.fromTextArray(
          headers: ['ID', 'Kandang', 'Mode Penjadwalan', 'Versi'],
          data: data.map((d) {
            final detail = feederDeviceDetailList.firstWhereOrNull(
              (det) => det.deviceId == d.deviceId,
            );
            return [
              d.deviceId,
              d.stableId != null ? getRoomName(d.stableId!) : 'Tidak ada',
              d.scheduleType == 'auto' ? 'Otomatis' : 'Manual',
              d.version,
            ];
          }).toList(),
        ),
      ),
    );
    String? path = await FilePicker.platform.saveFile(
      dialogTitle: 'Simpan file PDF Perangkat',
      fileName: 'Smart_Feeder_Daftar_IoT_Main_Feeder_Device.pdf',
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

  /// Export riwayat detail device ke Excel
  Future<bool> exportDeviceHistoryExcel(
    List<FeederDeviceHistoryModel> data,
  ) async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];

    final deviceName = (data.isNotEmpty) ? data.first.deviceId : '';
    sheet.appendRow([
      TextCellValue('No'),
      TextCellValue('Timestamp'),
      TextCellValue('Device ID'),
      TextCellValue('Mode'),
      TextCellValue('Ruangan'),
      TextCellValue('Jumlah (g)'),
    ]);

    for (int i = 0; i < data.length; i++) {
      final d = data[i];
      sheet.appendRow([
        TextCellValue('${i + 1}'),
        TextCellValue(DateFormat('dd-MM-yyyy HH:mm:ss').format(d.timestamp)),
        TextCellValue(d.deviceId),
        TextCellValue(
          d.mode == 'penjadwalan'
              ? 'Penjadwalan'
              : d.mode == 'auto'
              ? 'Otomatis'
              : 'Manual',
        ),
        TextCellValue(d.roomId),
        TextCellValue(d.amount?.toString() ?? '-'),
      ]);
    }

    final fileBytes = excel.encode();
    String? path = await FilePicker.platform.saveFile(
      dialogTitle: 'Simpan file Excel Riwayat Device',
      fileName: 'Smart_Feeder_Riwayat_Device_${deviceName}.xlsx',
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

  /// Export riwayat detail device ke PDF
  Future<bool> exportDeviceHistoryPDF(
    List<FeederDeviceHistoryModel> data,
  ) async {
    final pdf = pw.Document();
    final deviceName = (data.isNotEmpty) ? data.first.deviceId : '';

    pdf.addPage(
      pw.Page(
        orientation: pw.PageOrientation.landscape,
        build: (context) => pw.Table.fromTextArray(
          headers: [
            'No',
            'Timestamp',
            'Device ID',
            'Mode',
            'Ruangan',
            'Jumlah (g)',
          ],
          data: List.generate(data.length, (i) {
            final d = data[i];
            return [
              '${i + 1}',
              DateFormat('dd-MM-yyyy HH:mm:ss').format(d.timestamp),
              d.deviceId,
              d.mode == 'penjadwalan'
                  ? 'Penjadwalan'
                  : d.mode == 'auto'
                  ? 'Otomatis'
                  : 'Manual',
              d.roomId,
              d.amount?.toString() ?? '-',
            ];
          }),
          cellStyle: pw.TextStyle(fontSize: 10),
          headerStyle: pw.TextStyle(
            fontSize: 11,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ),
    );

    String? path = await FilePicker.platform.saveFile(
      dialogTitle: 'Simpan file PDF Riwayat Device',
      fileName: 'Smart_Feeder_Riwayat_Device_${deviceName}.pdf',
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
