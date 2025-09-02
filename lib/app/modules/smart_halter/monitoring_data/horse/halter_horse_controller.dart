import 'dart:io';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:smart_feeder_desktop/app/data/data_controller.dart';
import 'package:smart_feeder_desktop/app/data/db/db_helper.dart';
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
        TextCellValue(horse.age.toString()),
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

    String? savePath = await FilePicker.platform.saveFile(
      dialogTitle: 'Simpan file PDF',
      fileName: 'Smart_Halter_Daftar_Kuda.pdf',
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (savePath != null) {
      final file = File(savePath);
      await file.writeAsBytes(await pdf.save());
    }
  }
}
