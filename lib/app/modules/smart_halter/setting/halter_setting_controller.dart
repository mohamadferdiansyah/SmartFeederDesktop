import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/models/halter_setting_model.dart';

class HalterSettingController extends GetxController {
  // Observable state
  final Rx<HalterSettingModel> setting = HalterSettingModel(
    cloudUrl: 'https://smarthalter.ipb.ac.id',
    cloudConnected: true,
    loraPort: '',
    loraConnected: false,
    jenisPengiriman: 'LoRa',
  ).obs;

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
