import 'dart:io';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:smart_feeder_desktop/app/data/data_controller.dart';
import 'package:smart_feeder_desktop/app/models/halter/cctv_model.dart';
import 'package:smart_feeder_desktop/app/models/halter/node_room_model.dart';
import 'package:smart_feeder_desktop/app/models/horse_model.dart';
import 'package:smart_feeder_desktop/app/models/room_model.dart';
import 'package:smart_feeder_desktop/app/models/stable_model.dart';

class HalterRoomController extends GetxController {
  final DataController dataController = Get.find<DataController>();

  RxList<RoomModel> get roomList => dataController.roomList;

  RxList<HorseModel> get horseList => dataController.horseList;

  RxList<CctvModel> get cctvList => dataController.cctvList;

  RxList<StableModel> get stableList => dataController.stableList;

  RxList<NodeRoomModel> get nodeRoomList => dataController.nodeRoomList;

  // @override
  // void onInit() {
  //   super.onInit();
  //   DBHelper.database.then((db) {
  //     dataController.initRoomDao(db);
  //     loadRooms();
  //   });
  // }

  Future<void> loadRooms() async {
    await dataController.loadRoomsFromDb();
  }

  Future<void> addRoom(RoomModel model) async {
    await dataController.addRoom(model);
  }

  Future<void> updateRoom(RoomModel model) async {
    await dataController.updateRoom(model);
  }

  Future<void> deleteRoom(String roomId) async {
    await dataController.deleteRoom(roomId);
  }

  Future<String> getNextRoomId() async {
    return await dataController.getNextRoomId();
  }

  Future<void> lepasKudaDariRuangan(String roomId, String? horseId) async {
    if (horseId != null) {
      await dataController.roomDao.updateHorseId(roomId, null);
      final horse = await dataController.horseDao.getById(horseId);
      if (horse != null) {
        final editedHorse = HorseModel(
          horseId: horse.horseId,
          name: horse.name,
          type: horse.type,
          gender: horse.gender,
          age: horse.age,
          roomId: null,
          category: horse.category,
          birthPlace: horse.birthPlace,
          birthDate: horse.birthDate,
          settleDate: horse.settleDate,
          length: horse.length,
          weight: horse.weight,
          height: horse.height,
          chestCircum: horse.chestCircum,
          skinColor: horse.skinColor,
          markDesc: horse.markDesc,
          photos: horse.photos,
        );
        await dataController.horseDao.update(editedHorse);
      }
      await dataController.loadRoomsFromDb();
      await dataController.loadHorsesFromDb();
    }
  }

  Future<void> pilihKudaUntukRuangan(String roomId, String? horseId) async {
    if (horseId == null) {
      await dataController.roomDao.updateHorseId(roomId, null);
    } else {
      await dataController.assignHorseToRoom(horseId, roomId);
    }
    await dataController.loadRoomsFromDb();
    await dataController.loadHorsesFromDb();
  }

  Future<bool> exportRoomExcel(
    List<RoomModel> data,
    String Function(List<String>) getCctvNames,
  ) async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];
    sheet.appendRow([
      TextCellValue('ID'),
      TextCellValue('Nama'),
      TextCellValue('IoT Node Room'),
      TextCellValue('Status'),
      TextCellValue('CCTV'),
    ]);
    for (var d in data) {
      sheet.appendRow([
        TextCellValue(d.roomId),
        TextCellValue(d.name),
        TextCellValue(d.deviceSerial ?? 'Tidak ada'),
        TextCellValue(d.status == 'used' ? 'Aktif' : 'Tidak Aktif'),
        TextCellValue(getCctvNames(d.cctvId ?? [])),
      ]);
    }
    final fileBytes = excel.encode();
    String? path = await FilePicker.platform.saveFile(
      dialogTitle: 'Simpan file Excel Ruangan',
      fileName: 'Smart_Halter_Daftar_Ruangan.xlsx',
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

  /// Export tabel utama (Daftar Ruangan) ke PDF
  Future<bool> exportRoomPDF(
    List<RoomModel> data,
    String Function(List<String>) getCctvNames,
  ) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Table.fromTextArray(
          headers: ['ID', 'Nama', 'IoT Node Room', 'Status', 'CCTV'],
          data: data
              .map(
                (d) => [
                  d.roomId,
                  d.name,
                  d.deviceSerial,
                  d.status == 'used' ? 'Aktif' : 'Tidak Aktif',
                  getCctvNames(d.cctvId ?? []),
                ],
              )
              .toList(),
        ),
      ),
    );
    String? path = await FilePicker.platform.saveFile(
      dialogTitle: 'Simpan file PDF Ruangan',
      fileName: 'Smart_Halter_Daftar_Ruangan.pdf',
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

  String getCctvNames(List<String> cctvIds) {
    final names = cctvIds
        .map((id) {
          final cctv = cctvList.firstWhereOrNull((c) => c.cctvId == id);
          if (cctv != null) {
            return '${cctv.ipAddress} (${cctv.cctvId})';
          }
          return id;
        })
        .where((name) => name != 'kosong')
        .toList();

    if (names.isEmpty) return 'Tidak ada CCTV';
    if (names.length == 1) return names.first;
    return names.join(' / ');
  }
}
