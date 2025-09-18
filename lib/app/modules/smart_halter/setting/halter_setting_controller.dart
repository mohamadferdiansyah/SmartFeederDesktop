import 'package:flutter/widgets.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/data/storage/halter/data_setting_halter.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_setting_model.dart';
import 'package:smart_feeder_desktop/app/services/halter_serial_service.dart';
import 'package:toastification/toastification.dart';

class HalterSettingController extends GetxController {
  final RxString deviceHeader = DataSettingHalter.getNodeHalterHeader().obs;
  final RxString nodeRoomHeader = DataSettingHalter.getNodeRoomHeader().obs;
  var loraConnected = false.obs;
  var selectedLoraPort = RxnString();

  // Observable state
  final Rx<HalterSettingModel> setting = HalterSettingModel(
    settingId: 1,
    cloudUrl: 'https://smarthalter.ipb.ac.id',
    loraPort: '',
    type: 'LoRa',
  ).obs;

  RxList<String> get availablePorts =>
      RxList<String>(SerialPort.availablePorts);

  void setDeviceHeader(String header) {
    deviceHeader.value = header;
    DataSettingHalter.saveNodeHalterHeader(header);
  }

  void setNodeRoomHeader(String header) {
    nodeRoomHeader.value = header;
    DataSettingHalter.saveNodeRoomHeader(header);
  }

  Future<void> refreshAvailablePorts() async {
    availablePorts.value = List<String>.from(SerialPort.availablePorts);
  }

  // Update Cloud
  void updateCloud({required String url}) {
    setting.value = HalterSettingModel(
      settingId: setting.value.settingId,
      cloudUrl: url,
      loraPort: setting.value.loraPort,
      type: setting.value.type,
    );
  }

  // Update Lora
  void updateLora({required String port, BuildContext? context}) {
    final HalterSerialService serialService = Get.find<HalterSerialService>();
    // Cek apakah port ada di availablePorts
    if (!availablePorts.contains(port)) {
      loraConnected.value = false;
      selectedLoraPort.value = null;
      // Tampilkan alert/toast
      toastification.show(
        context: context,
        title: const Text('Port Tidak Ditemukan'),
        type: ToastificationType.error,
        description: Text(
          'Port $port tidak tersedia! Pastikan perangkat LoRa sudah terpasang.',
        ),
        alignment: Alignment.topCenter,
        autoCloseDuration: const Duration(seconds: 2),
      );
      return;
    }
    // Jika port tersedia, lanjutkan koneksi
    setting.value = HalterSettingModel(
      settingId: setting.value.settingId,
      cloudUrl: setting.value.cloudUrl,
      loraPort: port,
      type: setting.value.type,
    );
    // serialService.initSerial(port, 115200);  
    serialService.reconnectSerial(port, 115200);
    serialService.pairingDevice();
    loraConnected.value = true;
  }

  // Update Jenis Pengiriman (Type)
  void updateJenisPengiriman(String jenis) {
    setting.value = HalterSettingModel(
      settingId: setting.value.settingId,
      cloudUrl: setting.value.cloudUrl,
      loraPort: setting.value.loraPort,
      type: jenis,
    );
  }

  void disconnectSerial() {
    final HalterSerialService serialService = Get.find<HalterSerialService>();
    serialService.closeSerial();
  }
}
