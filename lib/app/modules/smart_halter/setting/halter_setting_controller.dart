import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_setting_model.dart';
import 'package:smart_feeder_desktop/app/services/halter_serial_service.dart';

class HalterSettingController extends GetxController {
  final HalterSerialService serialService = Get.find<HalterSerialService>();
  
  // Observable state
  final Rx<HalterSettingModel> setting = HalterSettingModel(
    cloudUrl: 'https://smarthalter.ipb.ac.id',
    cloudConnected: true,
    loraPort: '',
    loraConnected: false,
    jenisPengiriman: 'LoRa',
  ).obs;

  RxList<String> get availablePorts => RxList<String>(SerialPort.availablePorts);

  // Update Cloud
  void updateCloud({required String url, required bool isConnected}) {
    setting.update((val) {
      if (val != null) {
        val.cloudUrl = url;
        val.cloudConnected = isConnected;
      }
    });
  }

  // Update Lora
  void updateLora({required String port, required bool isConnected}) {
    setting.update((val) {
      if (val != null) {
        val.loraPort = port;
        val.loraConnected = isConnected;
      }
    });
    serialService.initSerial(port, 115200);
  }

  // Update Jenis Pengiriman
  void updateJenisPengiriman(String jenis) {
    setting.update((val) {
      if (val != null) {
        val.jenisPengiriman = jenis;
      }
    });
  }
}
