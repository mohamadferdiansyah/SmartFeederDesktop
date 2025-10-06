import 'dart:io';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:smart_feeder_desktop/app/data/data_controller.dart';
import 'package:smart_feeder_desktop/app/models/horse_model.dart';
import 'package:smart_feeder_desktop/app/models/room_model.dart';

class HalterHorseController extends GetxController {
  final DataController dataController = Get.find<DataController>();

  // Gunakan RxList agar selalu auto-refresh di Obx
  RxList<HorseModel> get horseList => dataController.horseList;
  RxList<RoomModel> get roomList => dataController.roomList;

  // RxList<RoomModel> filteredRoomList = <RoomModel>[].obs;

  // // Panggil setiap kali roomList/horses berubah, atau sebelum buka modal
  // void updateFilteredRoomList({String? currentRoomId}) {
  //   filteredRoomList.value = roomList
  //       .where((r) =>
  //           r.horseId == null ||
  //           r.horseId == '' ||
  //           (currentRoomId != null && r.roomId == currentRoomId))
  //       .toList();
  // }

  // @override
  // void onInit() {
  //   super.onInit();
  //   DBHelper.database.then((db) {
  //     dataController.initHorseDao(db);
  //     loadHorses();
  //   });
  // }

  Future<void> loadHorses() async {
    await dataController.loadHorsesFromDb();
  }

  Future<void> addHorse(HorseModel model) async {
    await dataController.addHorse(model);
  }

  Future<void> updateHorse(HorseModel model) async {
    await dataController.updateHorse(model);
  }

  Future<void> deleteHorse(String horseId) async {
    await dataController.deleteHorse(horseId);
  }

  Future<void> pilihRuanganUntukKuda(String horseId, String? roomId) async {
    if (roomId == null) {
      // Lepas kuda dari semua ruangan
      await dataController.detachHorseFromRoom(horseId);
    } else {
      await dataController.assignHorseToRoom(horseId, roomId);
    }
    // Setelah assign/clear, refresh list
    await dataController.loadRoomsFromDb();
  }

  Future<void> keluarkanKudaDariKandang(String horseId) async {
    await dataController.keluarkanKudaDariKandang(horseId);
  }

  /// Generate next HorseId (misal "H001")
  Future<String> getNextHorseId() async {
    final list = await dataController.getAllHorses();
    if (list.isEmpty) return "H001";
    final lastIdNum = list
        .map(
          (h) => int.tryParse(h.horseId.replaceAll(RegExp('[^0-9]'), '')) ?? 0,
        )
        .fold<int>(0, (prev, el) => el > prev ? el : prev);
    final nextNum = lastIdNum + 1;
    return "H${nextNum.toString().padLeft(3, '0')}";
  }

  Future<bool> exportToExcel(List<HorseModel> data) async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];
    sheet.appendRow([
      TextCellValue('ID'),
      TextCellValue('Nama'),
      TextCellValue('Jenis'),
      TextCellValue('Kategori'),
      TextCellValue('Gender'),
      TextCellValue('Umur (tahun)'),
      TextCellValue('Tempat Lahir'),
      TextCellValue('Tanggal Lahir'),
      TextCellValue('Tanggal Menetap'),
      TextCellValue('Panjang (cm)'),
      TextCellValue('Berat (kg)'),
      TextCellValue('Tinggi (cm)'),
      TextCellValue('Lingkar Dada (cm)'),
      TextCellValue('Warna Kulit'),
      TextCellValue('Deskripsi Tanda'),
      TextCellValue('Ruangan'),
    ]);
    for (var horse in data) {
      sheet.appendRow([
        TextCellValue(horse.horseId),
        TextCellValue(horse.name),
        TextCellValue(horse.type == 'lokal' ? 'Lokal' : 'Crossbred'),
        TextCellValue(horse.category ?? '-'),
        TextCellValue(horse.gender),
        TextCellValue(horse.age.toString()),
        TextCellValue(horse.birthPlace ?? '-'),
        TextCellValue(
          horse.birthDate != null
              ? horse.birthDate!.toIso8601String().split('T').first
              : '-',
        ),
        TextCellValue(
          horse.settleDate != null
              ? horse.settleDate!.toIso8601String().split('T').first
              : '-',
        ),
        TextCellValue(horse.length != null ? horse.length.toString() : '-'),
        TextCellValue(horse.weight != null ? horse.weight.toString() : '-'),
        TextCellValue(horse.height != null ? horse.height.toString() : '-'),
        TextCellValue(
          horse.chestCircum != null ? horse.chestCircum.toString() : '-',
        ),
        TextCellValue(horse.skinColor ?? '-'),
        TextCellValue(horse.markDesc ?? '-'),
        TextCellValue(horse.roomId ?? 'Tidak Digunakan'),
      ]);
    }

    final fileBytes = excel.encode();

    String? savePath = await FilePicker.platform.saveFile(
      dialogTitle: 'Simpan file Excel',
      fileName: 'Smart_Halter_Daftar_Kuda.xlsx',
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (savePath != null) {
      // Pastikan file berekstensi .xlsx
      if (!savePath.toLowerCase().endsWith('.xlsx')) {
        savePath = '$savePath.xlsx';
      }
      await File(savePath).writeAsBytes(fileBytes!);
      return true;
    }
    return false;
  }

  Future<bool> exportToPDF(List<HorseModel> data) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        orientation:
            pw.PageOrientation.landscape, // Landscape karena banyak kolom
        build: (context) => pw.Table.fromTextArray(
          headers: [
            'ID',
            'Nama',
            'Jenis',
            'Kategori',
            'Gender',
            'Umur',
            'Tempat Lahir',
            'Tgl Lahir',
            'Tgl Menetap',
            'Panjang',
            'Berat',
            'Tinggi',
            'Lingkar Dada',
            'Warna Kulit',
            'Deskripsi Tanda',
            'Ruangan',
          ],
          data: data
              .map(
                (horse) => [
                  horse.horseId,
                  horse.name,
                  horse.type == 'lokal' ? 'Lokal' : 'Crossbred',
                  horse.category ?? '-',
                  horse.gender,
                  horse.age.toString(),
                  horse.birthPlace ?? '-',
                  horse.birthDate != null
                      ? horse.birthDate!.toIso8601String().split('T').first
                      : '-',
                  horse.settleDate != null
                      ? horse.settleDate!.toIso8601String().split('T').first
                      : '-',
                  horse.length != null ? '${horse.length} cm' : '-',
                  horse.weight != null ? '${horse.weight} kg' : '-',
                  horse.height != null ? '${horse.height} cm' : '-',
                  horse.chestCircum != null ? '${horse.chestCircum} cm' : '-',
                  horse.skinColor ?? '-',
                  horse.markDesc ?? '-',
                  horse.roomId ?? 'Tidak Digunakan',
                ],
              )
              .toList(),
          cellStyle: pw.TextStyle(
            fontSize: 8,
          ), // Font kecil karena banyak kolom
          headerStyle: pw.TextStyle(
            fontSize: 9,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ),
    );

    String? savePath = await FilePicker.platform.saveFile(
      dialogTitle: 'Simpan file PDF',
      fileName: 'Smart_Halter_Daftar_Kuda.pdf',
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (savePath != null) {
      // Pastikan file berekstensi .pdf
      if (!savePath.toLowerCase().endsWith('.pdf')) {
        savePath = '$savePath.pdf';
      }
      final file = File(savePath);
      await file.writeAsBytes(await pdf.save());
      return true;
    }
    return false;
  }
}
