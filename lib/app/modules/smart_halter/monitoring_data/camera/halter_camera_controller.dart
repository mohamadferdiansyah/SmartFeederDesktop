import 'dart:io';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:smart_feeder_desktop/app/data/data_controller.dart';
import 'package:smart_feeder_desktop/app/models/halter/cctv_model.dart';

class HalterCameraController extends GetxController {
  final DataController dataController = Get.find<DataController>();

  RxList<CctvModel> get cctvList => dataController.cctvList;

  Future<void> loadCctvs() async {
    await dataController.loadCctvsFromDb();
  }

  Future<void> addCctv(CctvModel model) async {
    await dataController.addCctv(model);
    await loadCctvs();
  }

  Future<void> updateCctv(CctvModel model) async {
    await dataController.updateCctv(model);
    await loadCctvs();
  }

  Future<void> deleteCctv(String cctvId) async {
    await dataController.deleteCctv(cctvId);
    await loadCctvs();
  }

  Future<String> getNextCctvId() async {
    final list = await dataController.cctvDao.getAll();
    if (list.isEmpty) return "CCTV1";
    final lastNum = list
        .map(
          (c) => int.tryParse(c.cctvId.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
        )
        .fold<int>(0, (prev, el) => el > prev ? el : prev);
    return "CCTV${lastNum + 1}";
  }

  Future<bool> exportCctvExcel(List<CctvModel> data) async {
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
      fileName: 'Smart_Halter_Daftar_CCTV.xlsx',
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

  /// Export tabel utama (Daftar CCTV) ke PDF
  Future<bool> exportCctvPDF(List<CctvModel> data) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Table.fromTextArray(
          headers: ['ID', 'IP Address', 'Port', 'Username', 'Password'],
          data: data
              .map(
                (d) => [
                  d.cctvId,
                  d.ipAddress,
                  d.port.toString(),
                  d.username,
                  d.password,
                ],
              )
              .toList(),
        ),
      ),
    );
    String? path = await FilePicker.platform.saveFile(
      dialogTitle: 'Simpan file PDF CCTV',
      fileName: 'Smart_Halter_Daftar_CCTV.pdf',
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
