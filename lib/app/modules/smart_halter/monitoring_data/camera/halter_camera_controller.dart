import 'dart:io';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:smart_feeder_desktop/app/data/data_controller.dart';
import 'package:smart_feeder_desktop/app/models/halter/cctv_model.dart';

class HalterCameraController extends GetxController {
  final DataController dataController = Get.find<DataController>();

  Future<void> exportCctvExcel(List<CctvModel> data) async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];
    sheet.appendRow([
      TextCellValue('ID'),
      TextCellValue('IP Address'),
      TextCellValue('Port'),
      TextCellValue('Username'),
      TextCellValue('Password'),
    ]);
    for (var d in data) {
      sheet.appendRow([
        TextCellValue(d.cctvId),
        TextCellValue(d.ipAddress),
        TextCellValue(d.port.toString()),
        TextCellValue(d.username),
        TextCellValue(d.password),
      ]);
    }
    final fileBytes = excel.encode();
    String? path = await FilePicker.platform.saveFile(
      dialogTitle: 'Simpan file Excel CCTV',
      fileName: 'Daftar_CCTV.xlsx',
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );
    if (path != null) {
      await File(path).writeAsBytes(fileBytes!);
    }
  }

  /// Export tabel utama (Daftar CCTV) ke PDF
  Future<void> exportCctvPDF(List<CctvModel> data) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Table.fromTextArray(
          headers: ['ID', 'IP Address', 'Port', 'Username', 'Password'],
          data: data.map((d) => [
            d.cctvId,
            d.ipAddress,
            d.port.toString(),
            d.username,
            d.password,
          ]).toList(),
        ),
      ),
    );
    String? path = await FilePicker.platform.saveFile(
      dialogTitle: 'Simpan file PDF CCTV',
      fileName: 'Daftar_CCTV.pdf',
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (path != null) {
      await File(path).writeAsBytes(await pdf.save());
    }
  }

  List<CctvModel> get cctvList => dataController.cctvList;
}
