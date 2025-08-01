import 'dart:io';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:smart_feeder_desktop/app/data/data_controller.dart';
import 'package:smart_feeder_desktop/app/models/water_model.dart';

class WaterContorller extends GetxController {
  final DataController dataController = Get.find<DataController>();

  List<WaterModel> get waterList => dataController.waterList;

  Future<void> exportWaterExcel(List<WaterModel> data) async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];
    sheet.appendRow([
      TextCellValue('ID'),
      TextCellValue('Nama'),
      TextCellValue('Volume (L)'),
    ]);
    for (var d in data) {
      sheet.appendRow([
        TextCellValue(d.waterId),
        TextCellValue(d.name),
        TextCellValue(d.stock.toString()),
      ]);
    }
    final fileBytes = excel.encode();
    String? path = await FilePicker.platform.saveFile(
      dialogTitle: 'Simpan file Excel Data Air',
      fileName: 'Data_Air.xlsx',
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );
    if (path != null) {
      await File(path).writeAsBytes(fileBytes!);
    }
  }

  /// Export data air ke PDF
  Future<void> exportWaterPDF(List<WaterModel> data) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Table.fromTextArray(
          headers: ['ID', 'Nama', 'Volume (L)'],
          data: data.map((d) => [
            d.waterId,
            d.name,
            d.stock.toString(),
          ]).toList(),
        ),
      ),
    );
    String? path = await FilePicker.platform.saveFile(
      dialogTitle: 'Simpan file PDF Data Air',
      fileName: 'Data_Air.pdf',
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (path != null) {
      await File(path).writeAsBytes(await pdf.save());
    }
  }

}
  