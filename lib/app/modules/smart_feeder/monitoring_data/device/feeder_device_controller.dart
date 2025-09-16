import 'dart:io';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:smart_feeder_desktop/app/data/data_controller.dart';
import 'package:smart_feeder_desktop/app/models/feeder/feeder_device_detail_model.dart';
import 'package:smart_feeder_desktop/app/models/feeder/feeder_device_model.dart';
import 'package:smart_feeder_desktop/app/models/room_model.dart';
import 'package:smart_feeder_desktop/app/models/stable_model.dart';

class FeederDeviceController extends GetxController {
  final DataController dataController = Get.find<DataController>();

  RxList<RoomModel> get roomList => dataController.roomList;
  RxList<StableModel> get stableList => dataController.stableList;

  RxList<FeederDeviceModel> get feederDeviceList =>
      dataController.feederDeviceList;

  RxList<FeederDeviceDetailModel> get feederDeviceDetailList =>
      dataController.feederDeviceDetailList;

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
  }

  Future<void> updateDevice(FeederDeviceModel model, String oldDeviceId) async {
    await dataController.updateFeederDevice(model, oldDeviceId);
    await loadDevices();
    print(model.stableId);
  }

  Future<void> deleteDevice(String deviceId) async {
    await dataController.deleteFeederDevice(deviceId);
    await loadDevices();
  }

  /// Export data device ke Excel
  Future<void> exportDeviceExcel(List<FeederDeviceModel> data) async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];
    sheet.appendRow([
      TextCellValue('ID'),
      TextCellValue('Kandang'),
      TextCellValue('Status'),
      TextCellValue('Versi'),
      TextCellValue('Baterai'),
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
        TextCellValue(detail?.status ?? '-'),
        TextCellValue(d.version),
        TextCellValue(detail?.batteryPercent.toString() ?? '-'),
      ]);
    }
    final fileBytes = excel.encode();
    String? path = await FilePicker.platform.saveFile(
      dialogTitle: 'Simpan file Excel Perangkat',
      fileName: 'Daftar_Perangkat.xlsx',
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );
    if (path != null) {
      await File(path).writeAsBytes(fileBytes!);
    }
  }

  /// Export data device ke PDF
  Future<void> exportDevicePDF(List<FeederDeviceModel> data) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Table.fromTextArray(
          headers: ['ID', 'Kandang', 'Status', 'Versi', 'Baterai'],
          data: data.map((d) {
            final detail = feederDeviceDetailList.firstWhereOrNull(
              (det) => det.deviceId == d.deviceId,
            );
            return [
              d.deviceId,
              d.stableId != null ? getRoomName(d.stableId!) : 'Tidak ada',
              detail?.status ?? '-',
              d.version,
              detail?.batteryPercent ?? '-',
            ];
          }).toList(),
        ),
      ),
    );
    String? path = await FilePicker.platform.saveFile(
      dialogTitle: 'Simpan file PDF Perangkat',
      fileName: 'Daftar_Perangkat.pdf',
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (path != null) {
      await File(path).writeAsBytes(await pdf.save());
    }
  }
}
