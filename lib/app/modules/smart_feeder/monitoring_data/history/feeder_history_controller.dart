import 'dart:io';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:smart_feeder_desktop/app/data/data_controller.dart';
import 'package:smart_feeder_desktop/app/models/history_entry_model.dart';
import 'package:smart_feeder_desktop/app/models/room_model.dart';
import 'package:smart_feeder_desktop/app/models/stable_model.dart';

class FeederHistoryController extends GetxController {

  final DataController dataController = Get.find<DataController>();

  List<StableModel> get stableList => dataController.stableList;

  List<HistoryEntryModel> get historyEntryList => dataController.historyEntryList;

  List<RoomModel> get roomList => dataController.roomList;

  String getStableName(String stableId) {
    return stableList.firstWhere((stable) => stable.stableId == stableId).name;
  }

  String getRoomName(String roomId) {
    return roomList.firstWhere((room) => room.roomId == roomId).name;
  }

  Future<void> exportHistoryExcel(List<HistoryEntryModel> data) async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];
    sheet.appendRow([
      TextCellValue('Kandang'),
      TextCellValue('Ruangan'),
      TextCellValue('Tanggal'),
      TextCellValue('Jadwal'),
      TextCellValue('Air (L)'),
      TextCellValue('Pakan (g)'),
    ]);
    for (var e in data) {
      sheet.appendRow([
        TextCellValue(getStableName(e.stableId)),
        TextCellValue(getRoomName(e.roomId)),
        TextCellValue(DateFormat('yyyy-MM-dd HH:mm').format(e.date)),
        TextCellValue(e.type.toString()),
        TextCellValue(e.water.toStringAsFixed(1)),
        TextCellValue(e.feed.toStringAsFixed(1)),
      ]);
    }
    final fileBytes = excel.encode();
    String? path = await FilePicker.platform.saveFile(
      dialogTitle: 'Simpan file Excel Riwayat Pengisian',
      fileName: 'Riwayat_Pengisian.xlsx',
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );
    if (path != null) {
      await File(path).writeAsBytes(fileBytes!);
    }
  }

  /// Export riwayat pengisian ke PDF
  Future<void> exportHistoryPDF(List<HistoryEntryModel> data) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Table.fromTextArray(
          headers: [
            'Kandang',
            'Ruangan',
            'Tanggal',
            'Jadwal',
            'Air (L)',
            'Pakan (g)',
          ],
          data: data.map((e) => [
            getStableName(e.stableId),
            getRoomName(e.roomId),
            DateFormat('yyyy-MM-dd HH:mm').format(e.date),
            e.type.toString(),
            e.water.toStringAsFixed(1),
            e.feed.toStringAsFixed(1),
          ]).toList(),
        ),
      ),
    );
    String? path = await FilePicker.platform.saveFile(
      dialogTitle: 'Simpan file PDF Riwayat Pengisian',
      fileName: 'Riwayat_Pengisian.pdf',
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (path != null) {
      await File(path).writeAsBytes(await pdf.save());
    }
  }
}
