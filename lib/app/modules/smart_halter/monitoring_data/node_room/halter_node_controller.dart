import 'dart:io';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:smart_feeder_desktop/app/data/data_controller.dart';
import 'package:smart_feeder_desktop/app/models/halter/node_room_detail_model.dart';
import 'package:smart_feeder_desktop/app/models/halter/node_room_model.dart';
import 'package:smart_feeder_desktop/app/models/halter/test_team_model.dart';
import 'package:smart_feeder_desktop/app/models/room_model.dart';

class HalterNodeController extends GetxController {
  final DataController dataController = Get.find<DataController>();

  RxList<NodeRoomModel> get nodeRoomList => dataController.nodeRoomList;

  RxList<RoomModel> get roomList => dataController.roomList;

  // @override
  // void onInit() {
  //   super.onInit();
  //   DBHelper.database.then((db) {
  //     dataController.initNodeRoomDao(db);
  //     loadNode();
  //   });
  // }

  Future<void> loadNode() async {
    await dataController.loadNodeRoomsFromDb();
  }

  Future<void> addNode(NodeRoomModel model) async {
    await dataController.addNodeRoom(model);
  }

  Future<void> updateNode(NodeRoomModel model, String oldDeviceId) async {
    await dataController.updateNodeRoom(model, oldDeviceId);
  }

  Future<void> deleteNode(String deviceId) async {
    await dataController.deleteNodeRoom(deviceId);
  }

  Future<void> pilihRuanganUntukNode(
    String nodeDeviceId,
    String? roomId,
  ) async {
    if (roomId == null) {
      // Lepas node dari semua ruangan
      await dataController.detachNodeFromRoom(nodeDeviceId);
    } else {
      await dataController.assignNodeToRoom(nodeDeviceId, roomId);
    }
    // Setelah assign/clear, refresh list
    await dataController.loadRoomsFromDb();
  }

  /// Export detail node ruangan ke Excel
  Future<bool> exportNodeRoomExcel(List<NodeRoomModel> data) async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];
    sheet.appendRow([
      TextCellValue('No'),
      TextCellValue('Device Id'),
      TextCellValue('Versi'),
    ]);
    for (int i = 0; i < data.length; i++) {
      final d = data[i];
      sheet.appendRow([
        TextCellValue('${i + 1}'),
        TextCellValue(d.deviceId),
        TextCellValue(d.version),
      ]);
    }
    final fileBytes = excel.encode();
    String? path = await FilePicker.platform.saveFile(
      dialogTitle: 'Simpan file Excel Node',
      fileName: 'Smart_Halter_Node_Device.xlsx',
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

  /// Export detail node ruangan ke PDF
  Future<bool> exportNodeRoomPDF(List<NodeRoomModel> data) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Table.fromTextArray(
          headers: ['No', 'Device Id', 'Versi'],
          data: List.generate(data.length, (i) {
            final d = data[i];
            return ['${i + 1}', d.deviceId, d.version];
          }),
        ),
      ),
    );
    String? path = await FilePicker.platform.saveFile(
      dialogTitle: 'Simpan file PDF Node',
      fileName: 'Smart_Halter_Node_Device.pdf',
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

  Future<bool> exportNodeRoomDetailExcel(
    List<NodeRoomDetailModel> data,
    TestTeamModel? team,
  ) async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];

    final deviceName = (data.isNotEmpty) ? data.first.deviceId : '';
    final judul = 'DATA SMART HALTER DETAIL NODE DEVICE ($deviceName)';
    final sensorHeaders = [
      'No',
      'Time',
      'Device Id',
      'Suhu (°C)',
      'Kelembapan (%)',
      'Cahaya (lux)',
      'CO (ppm)',
      'CO2 (ppm)',
      'Amonia (ppm)',
    ];

    // Baris 1: Judul (merge center)
    sheet.appendRow([
      TextCellValue(judul),
      ...List.generate(sensorHeaders.length - 1, (_) => TextCellValue('')),
    ]);
    try {
      sheet.merge(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
        CellIndex.indexByColumnRow(
          columnIndex: sensorHeaders.length - 1,
          rowIndex: 0,
        ),
      );
    } catch (e) {}

    // Baris 2-5: Data tim penguji
    sheet.appendRow([
      TextCellValue('Team Penguji'),
      TextCellValue(team?.teamName ?? '-'),
    ]);
    sheet.appendRow([
      TextCellValue('Lokasi Pengujian'),
      TextCellValue(team?.location ?? '-'),
    ]);
    sheet.appendRow([
      TextCellValue('Tanggal Pengujian'),
      TextCellValue(
        team?.date != null
            ? "${team!.date!.day} ${_bulan(team.date!.month)} ${team.date!.year}"
            : '-',
      ),
    ]);
    sheet.appendRow([
      TextCellValue('Anggota'),
      TextCellValue(team?.members?.join(', ') ?? '-'),
    ]);

    // Baris 7: Header
    sheet.appendRow(sensorHeaders.map((e) => TextCellValue(e)).toList());

    // Data
    for (int i = 0; i < data.length; i++) {
      final d = data[i];
      sheet.appendRow([
        TextCellValue('${i + 1}'),
        TextCellValue(DateFormat('dd-MM-yyyy HH:mm:ss').format(d.time)),
        TextCellValue(d.deviceId),
        TextCellValue(d.temperature.toStringAsFixed(2)),
        TextCellValue(d.humidity.toStringAsFixed(2)),
        TextCellValue(d.lightIntensity.toStringAsFixed(2)),
        TextCellValue(d.co.toStringAsFixed(2)),
        TextCellValue(d.co2.toStringAsFixed(2)),
        TextCellValue(d.ammonia.toStringAsFixed(2)),
      ]);
    }

    final fileBytes = excel.encode();
    String? path = await FilePicker.platform.saveFile(
      dialogTitle: 'Simpan file Excel Detail Node',
      fileName:
          'Smart_Halter_Node_Device_Detail(${data.map((e) => e.deviceId).first}).xlsx',
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

  // Helper untuk format bulan ke string
  String _bulan(int m) {
    const bulanList = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return bulanList[m];
  }

  Future<bool> exportNodeRoomDetailPDF(List<NodeRoomDetailModel> data) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Table.fromTextArray(
          headers: [
            'No',
            'Time',
            'Device Id',
            'Suhu (°C)',
            'Kelembapan (%)',
            'Cahaya (lux)',
            'CO (ppm)',
            'CO2 (ppm)',
            'Amonia (ppm)',
          ],
          data: List.generate(data.length, (i) {
            final d = data[i];
            return [
              '${i + 1}',
              d.deviceId,
              DateFormat('dd-MM-yyyy HH:mm:ss').format(d.time),
              d.temperature.toStringAsFixed(2),
              d.humidity.toStringAsFixed(2),
              d.lightIntensity.toStringAsFixed(2),
              d.co.toStringAsFixed(2),
              d.co2.toStringAsFixed(2),
              d.ammonia.toStringAsFixed(2),
            ];
          }),
        ),
      ),
    );
    String? path = await FilePicker.platform.saveFile(
      dialogTitle: 'Simpan file PDF Detail Node',
      fileName:
          'Smart_Halter_Node_Device_Detail(${data.map((e) => e.deviceId).first}).pdf',
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

  // bool isRoomHaveNode(String deviceSerial) {
  //   return dataController.roomList.any((node) => node.deviceSerial == deviceSerial);
  // }

  RoomModel? getRoomByNodeId(String deviceId) {
    return roomList.firstWhereOrNull((room) => room.deviceSerial == deviceId);
  }
}
