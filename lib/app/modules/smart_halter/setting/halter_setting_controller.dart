import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/data/data_setting_halter.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_setting_model.dart';
import 'package:smart_feeder_desktop/app/services/halter_serial_service.dart';

class HalterSettingController extends GetxController {
  final HalterSerialService serialService = Get.find<HalterSerialService>();
  final RxString deviceHeader = DataSettingHalter.getNodeHalterHeader().obs;
  final RxString nodeRoomHeader = DataSettingHalter.getNodeRoomHeader().obs;

  // Observable state
  final Rx<HalterSettingModel> setting = HalterSettingModel(
    settingId: 1,
    cloudUrl: 'https://smarthalter.ipb.ac.id',
    loraPort: '',
    type: 'LoRa',
  ).obs;

  RxList<String> get availablePorts => RxList<String>(SerialPort.availablePorts);

  void setDeviceHeader(String header) {
    deviceHeader.value = header;
    DataSettingHalter.saveNodeHalterHeader(header);
  }

  void setNodeRoomHeader(String header) {
    nodeRoomHeader.value = header;
    DataSettingHalter.saveNodeRoomHeader(header);
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
  void updateLora({required String port}) {
    setting.value = HalterSettingModel(
      settingId: setting.value.settingId,
      cloudUrl: setting.value.cloudUrl,
      loraPort: port,
      type: setting.value.type,
    );
    serialService.initSerial(port, 115200);
    serialService.pairingDevice();
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
    serialService.closeSerial();
  }
}