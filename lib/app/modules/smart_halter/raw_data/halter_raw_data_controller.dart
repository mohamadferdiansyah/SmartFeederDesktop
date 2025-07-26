import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/data/data_controller.dart';
import 'package:smart_feeder_desktop/app/models/data_serial_model.dart';

class HalterRawDataController extends GetxController {
  // RxList<DataSerialModel> dataSerialList = <DataSerialModel>[
  //   DataSerialModel(
  //     no: 1,
  //     data: "SHIPB1223004,-6.967736500,107.659127167,683.50,0.00,211.00,1.79,-0.40,10.20,-0.00,0.00,0.00,-15.62,45.94,17.79,-10,-177,-66,NAN,0.00,0.00,0.00,29.77,*",
  //     tanggal: "2025-07-23",
  //     waktu: "18:26:00",
  //   ),
  //   DataSerialModel(
  //     no: 2,
  //     data: "SHIPB1223005,-6.967800,107.659200,700.12,1.00,205.00,1.81,-0.30,15.30,-0.10,0.10,0.00,-12.62,48.94,14.79,-12,-150,-60,NAN,1.00,1.00,1.00,28.77,*",
  //     tanggal: "2025-07-23",
  //     waktu: "18:27:01",
  //   ),
  //   DataSerialModel(
  //     no: 3,
  //     data: "SHIPB1223006,-6.968000,107.659300,710.00,2.00,220.00,2.00,-0.20,11.20,-0.20,0.20,0.10,-14.00,46.00,18.00,-14,-160,-70,NAN,2.00,2.00,2.00,30.00,*",
  //     tanggal: "2025-07-24",
  //     waktu: "08:10:15",
  //   ),
  // ].obs;

  final DataController dataController = Get.find<DataController>();

  List<DataSerialModel> get dataSerialList => dataController.dataSerialList;
  
  RxString searchText = ''.obs;
  RxString selectedDate = ''.obs;

  List<DataSerialModel> get filteredList {
    return dataSerialList.where((item) {
      final matchSearch = searchText.value.isEmpty ||
          item.data.toLowerCase().contains(searchText.value.toLowerCase());
      final matchDate = selectedDate.value.isEmpty ||
          item.tanggal == selectedDate.value;
      return matchSearch && matchDate;
    }).toList();
  }

  get dataList => null;

  void setSearchText(String text) {
    searchText.value = text;
  }

  void setSelectedDate(String date) {
    selectedDate.value = date;
  }
}