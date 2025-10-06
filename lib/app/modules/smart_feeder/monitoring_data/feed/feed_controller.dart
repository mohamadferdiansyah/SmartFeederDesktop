import 'dart:io';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:smart_feeder_desktop/app/data/data_controller.dart';
import 'package:smart_feeder_desktop/app/models/feeder/feed_model.dart';

class FeedController extends GetxController {
  final DataController dataController = Get.find<DataController>();

  RxList<FeedModel> get feedList => dataController.feedList;

  // FeedController
  Future<void> loadFeeds() async {
    await dataController.loadFeedsFromDb();
  }

  Future<void> addFeed(FeedModel model) async {
    await dataController.addFeed(model);
    await loadFeeds();
  }

  Future<void> updateFeed(FeedModel model, String oldCode) async {
    await dataController.updateFeed(model, oldCode);
    await loadFeeds();
  }

  Future<void> deleteFeed(String code) async {
    await dataController.deleteFeed(code);
    await loadFeeds();
  }

  Future<bool> exportFeedExcel(List<FeedModel> data) async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];
    sheet.appendRow([
      TextCellValue('ID'),
      TextCellValue('Merk'),
      TextCellValue('Kapasitas (kg)'),
      TextCellValue('Tipe'),
    ]);
    for (var d in data) {
      sheet.appendRow([
        TextCellValue(d.code),
        TextCellValue(d.brand),
        TextCellValue(d.capacity.toString()),
        TextCellValue(d.type),
      ]);
    }
    final fileBytes = excel.encode();
    String? path = await FilePicker.platform.saveFile(
      dialogTitle: 'Simpan file Excel Data Pakan',
      fileName: 'Smart_Feeder_Daftar_Pakan.xlsx',
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

  /// Export data pakan ke PDF
  Future<bool> exportFeedPDF(List<FeedModel> data) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Table.fromTextArray(
          headers: ['ID', 'Merk', 'Kapasitas (kg)', 'Tipe'],
          data: data
              .map((d) => [d.code, d.brand, d.capacity.toString(), d.type])
              .toList(),
        ),
      ),
    );
    String? path = await FilePicker.platform.saveFile(
      dialogTitle: 'Simpan file PDF Data Pakan',
      fileName: 'Smart_Feeder_Daftar_Pakan.pdf',
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
