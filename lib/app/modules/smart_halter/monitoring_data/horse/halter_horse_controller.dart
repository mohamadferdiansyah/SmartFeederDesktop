import 'dart:io';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:smart_feeder_desktop/app/data/data_controller.dart';
import 'package:smart_feeder_desktop/app/models/horse_model.dart';

class HalterHorseController extends GetxController {
  final DataController dataController = Get.find<DataController>();

  List<HorseModel> get horseList => dataController.horseList;

  Future<void> exportToExcel(List<HorseModel> data) async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];
    sheet.appendRow([
      TextCellValue('ID'),
      TextCellValue('Nama'),
      TextCellValue('Jenis'),
      TextCellValue('Gender'),
      TextCellValue('Umur'),
      TextCellValue('Ruangan'),
    ]);
    for (var horse in data) {
      sheet.appendRow([
        TextCellValue(horse.horseId),
        TextCellValue(horse.name),
        TextCellValue(horse.type),
        TextCellValue(horse.gender),
        TextCellValue(horse.age as String),
        TextCellValue(horse.roomId ?? 'Tidak Digunakan'),
      ]);
    }

    final fileBytes = excel.encode();

    // Pilih lokasi simpan
    String? savePath = await FilePicker.platform.saveFile(
      dialogTitle: 'Simpan file Excel',
      fileName: 'Daftar_Kuda.xlsx',
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (savePath != null) {
      File(savePath).writeAsBytes(fileBytes!);
    }
  }

  Future<void> exportToPDF(List<HorseModel> data) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Table.fromTextArray(
          headers: ['ID', 'Nama', 'Jenis', 'Gender', 'Umur', 'Ruangan'],
          data: data
              .map(
                (horse) => [
                  horse.horseId,
                  horse.name,
                  horse.type,
                  horse.gender,
                  horse.age,
                  horse.roomId ?? 'Tidak Digunakan',
                ],
              )
              .toList(),
        ),
      ),
    );

    // Tampilkan dialog simpan file
    String? savePath = await FilePicker.platform.saveFile(
      dialogTitle: 'Simpan file PDF',
      fileName: 'Daftar_Kuda.pdf',
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (savePath != null) {
      final file = File(savePath);
      await file.writeAsBytes(await pdf.save());
      // Kamu bisa tambahkan notifikasi/snackbar di sini
    }
  }
}
