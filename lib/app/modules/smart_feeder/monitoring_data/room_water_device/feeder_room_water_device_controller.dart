import 'dart:io';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:smart_feeder_desktop/app/data/data_controller.dart';
import 'package:smart_feeder_desktop/app/models/feeder/feeder_device_history_model.dart';
import 'package:smart_feeder_desktop/app/models/feeder/feeder_room_water_device_model.dart';
import 'package:smart_feeder_desktop/app/models/room_model.dart';

class FeederRoomWaterDeviceController extends GetxController {
  final DataController dataController = Get.find<DataController>();

  List<RoomModel> get roomList => dataController.roomList;

  RxList<FeederRoomWaterDeviceModel> get feederRoomDeviceList =>
      dataController.feederRoomDeviceList;
      
  RxList<FeederDeviceHistoryModel> get feederDeviceHistoryList =>
      dataController.feederDeviceHistoryList;

  String getRoomName(String roomId) {
    return roomList.firstWhere((room) => room.roomId == roomId).name;
  }

  Future<void> loadDevices() async {
    await dataController.loadFeederRoomDevicesFromDb();
  }

  Future<void> addDevice(FeederRoomWaterDeviceModel model) async {
    await dataController.addFeederRoomDevice(model);
    await loadDevices();
  }

  Future<void> updateDevice(
    FeederRoomWaterDeviceModel model,
    String? oldDeviceId,
  ) async {
    await dataController.updateFeederRoomDevice(model, oldDeviceId);
    await loadDevices();
  }

  Future<void> deleteDevice(String deviceId) async {
    await dataController.deleteFeederRoomDevice(deviceId);
    await loadDevices();
  }

  Future<void> exportDeviceExcel(List<FeederRoomWaterDeviceModel> data) async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];
    sheet.appendRow([
      TextCellValue('ID'),
      TextCellValue('Di Ruangan'),
      TextCellValue('Tipe'),
      TextCellValue('Status'),
    ]);
    for (var d in data) {
      sheet.appendRow([
        TextCellValue(d.deviceId),
        TextCellValue(d.roomId != null ? getRoomName(d.roomId!) : 'Tidak ada'),
        TextCellValue(d.status),
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
  Future<void> exportDevicePDF(List<FeederRoomWaterDeviceModel> data) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Table.fromTextArray(
          headers: ['ID', 'Di Ruangan', 'Tipe', 'Status'],
          data: data
              .map(
                (d) => [
                  d.deviceId,
                  d.roomId != null ? getRoomName(d.roomId!) : 'Tidak ada',
                  d.status,
                ],
              )
              .toList(),
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
