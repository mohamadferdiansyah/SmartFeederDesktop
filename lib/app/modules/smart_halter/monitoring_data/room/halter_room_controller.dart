import 'dart:io';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:smart_feeder_desktop/app/data/data_controller.dart';
import 'package:smart_feeder_desktop/app/models/halter/cctv_model.dart';
import 'package:smart_feeder_desktop/app/models/halter/node_room_model.dart';
import 'package:smart_feeder_desktop/app/models/room_model.dart';
import 'package:smart_feeder_desktop/app/services/halter_serial_service.dart';

class HalterRoomController extends GetxController {
  final DataController dataController = Get.find<DataController>();
  final HalterSerialService halterSerialService =
      Get.find<HalterSerialService>();

  List<RoomModel> get roomList => dataController.roomList;

  List<CctvModel> get cctvList => dataController.cctvList;

  RxList<NodeRoomModel> get nodeRoomList => halterSerialService.nodeRoomList;

  Future<void> exportRoomExcel(
    List<RoomModel> data,
    String Function(List<String>) getCctvNames,
  ) async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];
    sheet.appendRow([
      TextCellValue('ID'),
      TextCellValue('Nama'),
      TextCellValue('Device Serial'),
      TextCellValue('Status'),
      TextCellValue('CCTV'),
    ]);
    for (var d in data) {
      sheet.appendRow([
        TextCellValue(d.roomId),
        TextCellValue(d.name),
        TextCellValue(d.deviceSerial),
        TextCellValue(d.status == 'used' ? 'Aktif' : 'Tidak Aktif'),
        TextCellValue(getCctvNames(d.cctvId)),
      ]);
    }
    final fileBytes = excel.encode();
    String? path = await FilePicker.platform.saveFile(
      dialogTitle: 'Simpan file Excel Ruangan',
      fileName: 'Daftar_Ruangan.xlsx',
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );
    if (path != null) {
      await File(path).writeAsBytes(fileBytes!);
    }
  }

  /// Export tabel utama (Daftar Ruangan) ke PDF
  Future<void> exportRoomPDF(
    List<RoomModel> data,
    String Function(List<String>) getCctvNames,
  ) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Table.fromTextArray(
          headers: ['ID', 'Nama', 'Device Serial', 'Status', 'CCTV'],
          data: data
              .map(
                (d) => [
                  d.roomId,
                  d.name,
                  d.deviceSerial,
                  d.status == 'used' ? 'Aktif' : 'Tidak Aktif',
                  getCctvNames(d.cctvId),
                ],
              )
              .toList(),
        ),
      ),
    );
    String? path = await FilePicker.platform.saveFile(
      dialogTitle: 'Simpan file PDF Ruangan',
      fileName: 'Daftar_Ruangan.pdf',
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (path != null) {
      await File(path).writeAsBytes(await pdf.save());
    }
  }

  /// Export detail node ruangan ke Excel
  Future<void> exportNodeRoomExcel(List<NodeRoomModel> data) async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];
    sheet.appendRow([
      TextCellValue('No'),
      TextCellValue('Device Id'),
      TextCellValue('Temperature (°C)'),
      TextCellValue('Humidity (%)'),
      TextCellValue('Light Intensity'),
      TextCellValue('Time'),
    ]);
    for (int i = 0; i < data.length; i++) {
      final d = data[i];
      sheet.appendRow([
        TextCellValue('${i + 1}'),
        TextCellValue(d.deviceId),
        TextCellValue(d.temperature.toStringAsFixed(2)),
        TextCellValue(d.humidity.toStringAsFixed(2)),
        TextCellValue(d.lightIntensity.toStringAsFixed(2)),
        TextCellValue(
          d.time != null
              ? d.time!.toIso8601String().split('T')[1].split('.')[0]
              : '-',
        ),
      ]);
    }
    final fileBytes = excel.encode();
    String? path = await FilePicker.platform.saveFile(
      dialogTitle: 'Simpan file Excel Detail Node',
      fileName: 'Detail_Node_Ruangan.xlsx',
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );
    if (path != null) {
      await File(path).writeAsBytes(fileBytes!);
    }
  }

  /// Export detail node ruangan ke PDF
  Future<void> exportNodeRoomPDF(List<NodeRoomModel> data) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Table.fromTextArray(
          headers: [
            'No',
            'Device Id',
            'Temperature (°C)',
            'Humidity (%)',
            'Light Intensity',
            'Time',
          ],
          data: List.generate(data.length, (i) {
            final d = data[i];
            return [
              '${i + 1}',
              d.deviceId,
              d.temperature.toStringAsFixed(2),
              d.humidity.toStringAsFixed(2),
              d.lightIntensity.toStringAsFixed(2),
              d.time != null
                  ? d.time!.toIso8601String().split('T')[1].split('.')[0]
                  : '-',
            ];
          }),
        ),
      ),
    );
    String? path = await FilePicker.platform.saveFile(
      dialogTitle: 'Simpan file PDF Detail Node',
      fileName: 'Detail_Node_Ruangan.pdf',
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (path != null) {
      await File(path).writeAsBytes(await pdf.save());
    }
  }

  String getCctvNames(List<String> cctvIds) {
    final names = cctvIds.map((id) {
      final cctv = cctvList.firstWhereOrNull((c) => c.cctvId == id);
      if (cctv != null) {
        return '${cctv.ipAddress} (${cctv.cctvId})';
      }
      return id;
    }).toList();
    return names.join(' / ');
  }
}
