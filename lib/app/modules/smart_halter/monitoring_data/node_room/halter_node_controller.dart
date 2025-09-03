import 'dart:io';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:smart_feeder_desktop/app/data/data_controller.dart';
import 'package:smart_feeder_desktop/app/data/db/db_helper.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_device_model.dart';
import 'package:smart_feeder_desktop/app/models/halter/node_room_model.dart';
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

  Future<void> updateNode(NodeRoomModel model) async {
    await dataController.updateNodeRoom(model);
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
  Future<void> exportNodeRoomExcel(List<NodeRoomModel> data) async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];
    sheet.appendRow([
      TextCellValue('No'),
      TextCellValue('Time'),
      TextCellValue('Device Id'),
      TextCellValue('Suhu (°C)'),
      TextCellValue('Kelembapan (%)'),
      TextCellValue('Cahaya (lux)'),
    ]);
    for (int i = 0; i < data.length; i++) {
      final d = data[i];
      sheet.appendRow([
        TextCellValue('${i + 1}'),
        TextCellValue(
          d.time != null
              ? DateFormat('dd-MM-yyyy HH:mm:ss').format(d.time!)
              : '-',
        ),
        TextCellValue(d.deviceId),
        TextCellValue(d.temperature.toStringAsFixed(2)),
        TextCellValue(d.humidity.toStringAsFixed(2)),
        TextCellValue(d.lightIntensity.toStringAsFixed(2)),
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
            'Time',
            'Device Id',
            'Suhu (°C)',
            'Kelembapan (%)',
            'Cahaya (lux)',
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
      dialogTitle: 'Simpan file PDF Node',
      fileName: 'Smart_Halter_Node_Device.pdf',
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (path != null) {
      await File(path).writeAsBytes(await pdf.save());
    }
  }

  Future<void> exportNodeRoomDetailExcel(List<NodeRoomModel> data) async {
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
      fileName:
          'Smart_Halter_Node_Device_Detail(${data.map((e) => e.deviceId)}).xlsx',
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );
    if (path != null) {
      await File(path).writeAsBytes(fileBytes!);
    }
  }

  /// Export detail node ruangan ke PDF
  Future<void> exportNodeRoomDetailPDF(List<NodeRoomModel> data) async {
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
      fileName:
          'Smart_Halter_Node_Device_Detail(${data.map((e) => e.deviceId)}).pdf',
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (path != null) {
      await File(path).writeAsBytes(await pdf.save());
    }
  }

  // bool isRoomHaveNode(String deviceSerial) {
  //   return dataController.roomList.any((node) => node.deviceSerial == deviceSerial);
  // }

  RoomModel? getRoomByNodeId(String deviceId) {
    return roomList.firstWhereOrNull((room) => room.deviceSerial == deviceId);
  }
}
