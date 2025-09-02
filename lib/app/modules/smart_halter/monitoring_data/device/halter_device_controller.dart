import 'dart:io';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:smart_feeder_desktop/app/data/data_controller.dart';
import 'package:smart_feeder_desktop/app/data/data_halter_device_calibration_offset.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_device_detail_model.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_device_model.dart';
import 'package:smart_feeder_desktop/app/models/halter/test_team_model.dart';
import 'package:smart_feeder_desktop/app/models/horse_model.dart';

class HalterDeviceController extends GetxController {
  final DataController dataController = Get.find<DataController>();

  RxList<HalterDeviceModel> get halterDeviceList =>
      dataController.halterDeviceList;

  RxList<HorseModel> get horseList => dataController.horseList;

  RxList<HalterDeviceDetailModel> get detailHistoryList =>
      dataController.detailHistory;

  // @override
  // void onInit() {
  //   super.onInit();
  //   DBHelper.database.then((db) {
  //     dataController.initHalterDeviceDao(db);
  //     refreshDevices();
  //   });
  // }

  Future<void> addDevice(HalterDeviceModel model) async {
    await dataController.addHalterDevice(model);
  }

  Future<void> refreshDevices() async {
    await dataController.loadHalterDevicesFromDb();
  }

  Future<void> updateDevice(
    HalterDeviceModel newDevice, {
    String? oldDeviceId,
  }) async {
    if (oldDeviceId != null && oldDeviceId != newDevice.deviceId) {
      // Jika deviceId berubah, hapus device lama lalu tambah device baru
      await deleteDevice(oldDeviceId);
      await addDevice(newDevice);
    } else {
      await dataController.updateHalterDevice(newDevice);
    }
    await refreshDevices();
  }

  Future<void> deleteDevice(String deviceId) async {
    await dataController.deleteHalterDevice(deviceId);
  }

  Future<void> exportDeviceExcel(
    List<HalterDeviceModel> data,
    String Function(String?) getHorseName,
  ) async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];
    sheet.appendRow([
      TextCellValue('ID'),
      TextCellValue('Kuda'),
      TextCellValue('Status'),
    ]);
    for (var d in data) {
      sheet.appendRow([
        TextCellValue(d.deviceId),
        TextCellValue(getHorseName(d.horseId)),
        TextCellValue(d.status == 'on' ? 'Aktif' : 'Tidak Aktif'),
      ]);
    }
    final fileBytes = excel.encode();
    String? path = await FilePicker.platform.saveFile(
      dialogTitle: 'Simpan file Excel (Device)',
      fileName: 'Smart_Halter_Daftar_Halter_Device.xlsx',
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );
    if (path != null) {
      await File(path).writeAsBytes(fileBytes!);
    }
  }

  /// Export data device utama ke PDF
  Future<void> exportDevicePDF(
    List<HalterDeviceModel> data,
    String Function(String?) getHorseName,
  ) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Table.fromTextArray(
          headers: ['ID', 'Kuda', 'Status'],
          data: data
              .map(
                (d) => [
                  d.deviceId,
                  getHorseName(d.horseId),
                  d.status == 'on' ? 'Aktif' : 'Tidak Aktif',
                ],
              )
              .toList(),
        ),
      ),
    );
    String? path = await FilePicker.platform.saveFile(
      dialogTitle: 'Simpan file PDF (Device)',
      fileName: 'Smart_Halter_Daftar_Halter_Device.pdf',
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (path != null) {
      await File(path).writeAsBytes(await pdf.save());
    }
  }

  /// Export detail data raw device ke Excel
  Future<void> exportDetailExcel(
    List<HalterDeviceDetailModel> data,
    TestTeamModel? team,
  ) async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];

    final deviceName = (data.isNotEmpty) ? data.first.deviceId : '';
    final judul = 'DATA SMART HALTER DETAIL DEVICE ($deviceName)';
    final sensorHeaders = [
      'No',
      'Timestamp',
      'Device Id',
      'Latitude (°)',
      'Longitude (°)',
      'Altitude (m)',
      'Kecepatan (SoG km/jam)',
      'Arah (CoG °)',
      'Roll (°)',
      'Pitch (°)',
      'Yaw (°)',
      'Tegangan (mV)',
      'Detak Jantung (beat/m)',
      'SpO₂ (%)',
      'Suhu (°C)',
      'Respirasi (breath/m)',
    ];
    final offset = DataHalterDeviceCalibrationOffset.getByDeviceId(deviceName);
    final statusText = offset == null ? 'Tidak Terkalibrasi' : 'Terkalibrasi';

    // Baris 1: Judul (merge center)
    sheet.appendRow([
      TextCellValue(judul),
      ...List.generate(sensorHeaders.length - 1, (_) => TextCellValue('')),
    ]);
    try {
      sheet.merge(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
        CellIndex.indexByColumnRow(
          columnIndex: sensorHeaders.length - 1,
          rowIndex: 0,
        ),
      );
    } catch (e) {}

    // Baris 2-5: Data tim penguji
    sheet.appendRow([
      TextCellValue('Team Penguji'),
      TextCellValue(team?.teamName ?? '-'),
    ]);
    sheet.appendRow([
      TextCellValue('Lokasi Pengujian'),
      TextCellValue(team?.location ?? '-'),
    ]);
    sheet.appendRow([
      TextCellValue('Tanggal Pengujian'),
      TextCellValue(
        team?.date != null
            ? "${team!.date!.day} ${_bulan(team.date!.month)} ${team.date!.year}"
            : '-',
      ),
    ]);
    sheet.appendRow([
      TextCellValue('Anggota'),
      TextCellValue(team?.members?.join(', ') ?? '-'),
    ]);

    // Baris 6: Status Data
    sheet.appendRow([
      TextCellValue('Status Data:'),
      TextCellValue(statusText),
      ...List.generate(sensorHeaders.length - 2, (_) => TextCellValue('')),
    ]);

    // Baris 7: Header
    sheet.appendRow(sensorHeaders.map((e) => TextCellValue(e)).toList());

    // Data
    for (int i = 0; i < data.length; i++) {
      final d = data[i];
      sheet.appendRow([
        TextCellValue('${i + 1}'),
        TextCellValue(d.time != null ? d.time!.toIso8601String() : "-"),
        TextCellValue(d.deviceId),
        TextCellValue('${d.latitude ?? "-"}'),
        TextCellValue('${d.longitude ?? "-"}'),
        TextCellValue('${d.altitude ?? "-"}'),
        TextCellValue('${d.sog ?? "-"}'),
        TextCellValue('${d.cog ?? "-"}'),
        TextCellValue('${d.roll ?? "-"}'),
        TextCellValue('${d.pitch ?? "-"}'),
        TextCellValue('${d.yaw ?? "-"}'),
        TextCellValue('${d.voltage ?? "-"}'),
        TextCellValue('${d.heartRate ?? "-"}'),
        TextCellValue('${d.spo ?? "-"}'),
        TextCellValue('${d.temperature ?? "-"}'),
        TextCellValue('${d.respiratoryRate ?? "-"}'),
      ]);
    }

    final fileBytes = excel.encode();
    String? path = await FilePicker.platform.saveFile(
      dialogTitle: 'Simpan file Excel (Detail Raw)',
      fileName:
          'Smart_Halter_Detail_Device(${data.map((e) => e.deviceId).first}).xlsx',
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );
    if (path != null) {
      await File(path).writeAsBytes(fileBytes!);
    }
  }

  // Helper untuk format bulan ke string
  String _bulan(int m) {
    const bulanList = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return bulanList[m];
  }

  /// Export detail data raw device ke PDF
  Future<void> exportDetailPDF(List<HalterDeviceDetailModel> data) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Table.fromTextArray(
          headers: [
            'No',
            'Timestamp',
            'Device Id',
            'Latitude (°)',
            'Longitude (°)',
            'Altitude (m)',
            'Kecepatan (SoG km/jam)',
            'Arah (CoG °)',
            // 'Percepatan X (m/s²)',
            // 'Percepatan Y (m/s²)',
            // 'Percepatan Z (m/s²)',
            // 'Gyro X (°/s)',
            // 'Gyro Y (°/s)',
            // 'Gyro Z (°/s)',
            // 'Magnetik X (µT)',
            // 'Magnetik Y (µT)',
            // 'Magnetik Z (µT)',
            'Roll (°)',
            'Pitch (°)',
            'Yaw (°)',
            // 'Arus (A)',
            'Tegangan (mV)',
            'Detak Jantung (beat/m)',
            'SpO₂ (%)',
            'Suhu (°C)',
            'Respirasi (breath/m)',
          ],
          data: List.generate(data.length, (i) {
            final d = data[i];
            return [
              '${i + 1}',
              d.time != null ? d.time.toIso8601String() : "-",
              d.deviceId,
              '${d.latitude ?? "-"}',
              '${d.longitude ?? "-"}',
              '${d.altitude ?? "-"}',
              '${d.sog ?? "-"}',
              '${d.cog ?? "-"}',
              // '${d.acceX ?? "-"}',
              // '${d.acceY ?? "-"}',
              // '${d.acceZ ?? "-"}',
              // '${d.gyroX ?? "-"}',
              // '${d.gyroY ?? "-"}',
              // '${d.gyroZ ?? "-"}',
              // '${d.magX ?? "-"}',
              // '${d.magY ?? "-"}',
              // '${d.magZ ?? "-"}',
              '${d.roll ?? "-"}',
              '${d.pitch ?? "-"}',
              '${d.yaw ?? "-"}',
              // '${d.current ?? "-"}',
              '${d.voltage ?? "-"}',
              '${d.heartRate ?? "-"}',
              '${d.spo ?? "-"}',
              '${d.temperature ?? "-"}',
              '${d.respiratoryRate ?? "-"}',
            ];
          }),
        ),
      ),
    );
    String? path = await FilePicker.platform.saveFile(
      dialogTitle: 'Simpan file PDF (Detail Raw)',
      fileName:
          'Smart_Halter_Detail_Raw_Device(${data.map((e) => e.deviceId).first}).pdf',
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (path != null) {
      await File(path).writeAsBytes(await pdf.save());
    }
  }

  String getHorseNameById(String? horseId) {
    if (horseId == null) return '-';
    return horseList.firstWhereOrNull((h) => h.horseId == horseId)?.name ?? '-';
  }
}
