import 'dart:io';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:smart_feeder_desktop/app/data/data_controller.dart';
import 'package:smart_feeder_desktop/app/data/db/db_helper.dart';
import 'package:smart_feeder_desktop/app/models/stable_model.dart';

class HalterStableController extends GetxController {
  final DataController dataController = Get.find<DataController>();

  // @override
  // void onInit() {
  //   super.onInit();
  //   DBHelper.database.then((db) {
  //     dataController.initStableDao(db);
  //     loadStables();
  //   });
  // }

  // Pastikan stableList di DataController adalah RxList<StableModel>
  RxList<StableModel> get stableList => dataController.stableList;

  /// Muat data dari database ke RxList stableList di DataController
  Future<void> loadStables() async {
    await dataController.loadStablesFromDb();
  }

  /// Tambah data stable ke database
  Future<void> addStable(StableModel model) async {
    await dataController.addStable(model);
  }

  /// Update data stable di database
  Future<void> updateStable(StableModel model) async {
    await dataController.updateStable(model);
  }

  /// Hapus data stable dari database
  Future<void> deleteStable(String stableId) async {
    await dataController.deleteStable(stableId);
  }

  Future<String> getNextStableId() async {
    // Ambil data stable terakhir dari DB
    final list = await dataController.stableDao.getAll();
    if (list.isEmpty) return "K001";
    // Ambil stableId terbesar, misal "R012"
    final lastIdNum = list
        .map(
          (s) => int.tryParse(s.stableId.replaceAll(RegExp('[^0-9]'), '')) ?? 0,
        )
        .fold<int>(0, (prev, el) => el > prev ? el : prev);
    final nextNum = lastIdNum + 1;
    return "K${nextNum.toString().padLeft(3, '0')}";
  }

  /// Export tabel utama (Daftar Stable) ke Excel
  Future<void> exportStableExcel(List<StableModel> data) async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];
    sheet.appendRow([
      TextCellValue('ID'),
      TextCellValue('Nama'),
      TextCellValue('Alamat'),
    ]);
    for (var d in data) {
      sheet.appendRow([
        TextCellValue(d.stableId),
        TextCellValue(d.name),
        TextCellValue(d.address),
      ]);
    }
    final fileBytes = excel.encode();
    String? path = await FilePicker.platform.saveFile(
      dialogTitle: 'Simpan file Excel Kandang',
      fileName: 'Smart_Halter_Daftar_Kandang.xlsx',
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );
    if (path != null) {
      await File(path).writeAsBytes(fileBytes!);
    }
  }

  /// Export tabel utama (Daftar Stable) ke PDF
  Future<void> exportStablePDF(List<StableModel> data) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Table.fromTextArray(
          headers: ['ID', 'Nama', 'Alamat'],
          data: data.map((d) => [d.stableId, d.name, d.address]).toList(),
        ),
      ),
    );
    String? path = await FilePicker.platform.saveFile(
      dialogTitle: 'Simpan file PDF Kandang',
      fileName: 'Smart_Halter_Daftar_Kandang.pdf',
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (path != null) {
      await File(path).writeAsBytes(await pdf.save());
    }
  }
}
