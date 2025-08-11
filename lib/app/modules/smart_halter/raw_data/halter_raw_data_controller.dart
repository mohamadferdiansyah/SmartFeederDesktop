import 'dart:io';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:smart_feeder_desktop/app/data/data_controller.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_raw_data_model.dart';
import 'package:smart_feeder_desktop/app/services/halter_serial_service.dart';

class HalterRawDataController extends GetxController {
  // RxList<HalterRawDataModel> dataSerialList = <HalterRawDataModel>[
  // HalterRawDataModel(
  //   no: 1,
  //   data: "SHIPB1223004,-6.967736500,107.659127167,683.50,0.00,211.00,1.79,-0.40,10.20,-0.00,0.00,0.00,-15.62,45.94,17.79,-10,-177,-66,NAN,0.00,0.00,0.00,29.77,*",
  //   tanggal: "2025-07-23",
  //   waktu: "18:26:00",
  // ),
  //   HalterRawDataModel(
  //     no: 2,
  //     data: "SHIPB1223005,-6.967800,107.659200,700.12,1.00,205.00,1.81,-0.30,15.30,-0.10,0.10,0.00,-12.62,48.94,14.79,-12,-150,-60,NAN,1.00,1.00,1.00,28.77,*",
  //     tanggal: "2025-07-23",
  //     waktu: "18:27:01",
  //   ),
  //   HalterRawDataModel(
  //     no: 3,
  //     data: "SHIPB1223006,-6.968000,107.659300,710.00,2.00,220.00,2.00,-0.20,11.20,-0.20,0.20,0.10,-14.00,46.00,18.00,-14,-160,-70,NAN,2.00,2.00,2.00,30.00,*",
  //     tanggal: "2025-07-24",
  //     waktu: "08:10:15",
  //   ),
  // ].obs;

  // final DataController dataController = Get.find<DataController>();

  // List<HalterRawDataModel> get dataSerialList => dataController.dataSerialList;

  // final serialService = Get.find<HalterSerialService>();
  final DataController dataController = Get.find<DataController>();
  final HalterSerialService serialService = Get.find<HalterSerialService>();

  RxList<HalterRawDataModel> get dataSerialList => dataController.rawData;

  RxString searchText = ''.obs;
  RxString selectedDate = ''.obs;

  List<HalterRawDataModel> get filteredList {
    return dataSerialList.where((item) {
      final matchSearch =
          searchText.value.isEmpty ||
          item.data.toLowerCase().contains(searchText.value.toLowerCase());
      final matchDate =
          selectedDate.value.isEmpty || item.time == selectedDate.value;
      return matchSearch && matchDate;
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    // Jika ingin langsung start dummy:
    serialService.startDummySerial();
  }

  get dataList => null;

  void setSearchText(String text) {
    searchText.value = text;
  }

  void setSelectedDate(String date) {
    selectedDate.value = date;
  }

  Future<void> exportRawExcel(List<HalterRawDataModel> data) async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];
    sheet.appendRow([
      TextCellValue('No'),
      TextCellValue('Data'),
      TextCellValue('Tanggal'),
    ]);
    for (var d in data) {
      sheet.appendRow([
        TextCellValue(d.rawId.toString()),
        TextCellValue(d.data),
        TextCellValue(d.time as String),
      ]);
    }
    final fileBytes = excel.encode();
    String? path = await FilePicker.platform.saveFile(
      dialogTitle: 'Simpan file Excel Data Serial',
      fileName: 'Data_Serial_Monitor.xlsx',
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );
    if (path != null) {
      await File(path).writeAsBytes(fileBytes!);
    }
  }

  /// Export data raw ke PDF
  Future<void> exportRawPDF(List<HalterRawDataModel> data) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Table.fromTextArray(
          headers: ['No', 'Data', 'Tanggal', 'Waktu'],
          data: data.map((d) => [d.rawId.toString(), d.data, d.time]).toList(),
        ),
      ),
    );
    String? path = await FilePicker.platform.saveFile(
      dialogTitle: 'Simpan file PDF Data Serial',
      fileName: 'Data_Serial_Monitor.pdf',
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (path != null) {
      await File(path).writeAsBytes(await pdf.save());
    }
  }

  void deleteRawDataById(int rawId) {
    dataSerialList.removeWhere((item) => item.rawId == rawId);
  }
}
