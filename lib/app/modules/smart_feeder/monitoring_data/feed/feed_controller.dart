import 'dart:io';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:smart_feeder_desktop/app/data/data_controller.dart';
import 'package:smart_feeder_desktop/app/models/feeder/feed_model.dart';

class FeedController extends GetxController {
  final DataController dataController = Get.find<DataController>();

  List<FeedModel> get feedList => dataController.feedList;

  Future<void> exportFeedExcel(List<FeedModel> data) async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];
    sheet.appendRow([
      TextCellValue('ID'),
      TextCellValue('Nama Pakan'),
      TextCellValue('Jumlah (Kg)'),
      TextCellValue('Tipe'),
    ]);
    for (var d in data) {
      sheet.appendRow([
        TextCellValue(d.feedId),
        TextCellValue(d.name),
        TextCellValue(d.stock.toString()),
        TextCellValue(d.type.toString()),
      ]);
    }
    final fileBytes = excel.encode();
    String? path = await FilePicker.platform.saveFile(
      dialogTitle: 'Simpan file Excel Data Pakan',
      fileName: 'Data_Pakan.xlsx',
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );
    if (path != null) {
      await File(path).writeAsBytes(fileBytes!);
    }
  }

  /// Export data pakan ke PDF
  Future<void> exportFeedPDF(List<FeedModel> data) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Table.fromTextArray(
          headers: ['ID', 'Nama Pakan', 'Jumlah (Kg)', 'Tipe'],
          data: data.map((d) => [
            d.feedId,
            d.name,
            d.stock.toString(),
            d.type.toString(),
          ]).toList(),
        ),
      ),
    );
    String? path = await FilePicker.platform.saveFile(
      dialogTitle: 'Simpan file PDF Data Pakan',
      fileName: 'Data_Pakan.pdf',
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (path != null) {
      await File(path).writeAsBytes(await pdf.save());
    }
  }
}

