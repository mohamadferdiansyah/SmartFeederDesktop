import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/data/storage/walker/data_setting_walker.dart';
import 'package:smart_feeder_desktop/app/services/mqtt_walker_service.dart';

class WalkerSettingController extends GetxController {
  final mqttHost = DataSettingWalker.getMqttHost().obs;
  final mqttPort = DataSettingWalker.getMqttPort().obs;
  final mqttConnected = false.obs;
  final mqttLoading = false.obs;

  late MqttWalkerService _mqttWalkerService;

  @override
  void onInit() {
    super.onInit();
    _mqttWalkerService = Get.find<MqttWalkerService>();

    // Check initial connection status
    _updateConnectionStatus();

    // Setup periodic check untuk memastikan status selalu sinkron
    ever(mqttConnected, (bool connected) {
      print('Walker MQTT Connection status changed: $connected');
    });
  }

  void _updateConnectionStatus() {
    mqttConnected.value = _mqttWalkerService.isConnected;
  }

  void setMqttHost(String host) {
    mqttHost.value = host;
    DataSettingWalker.saveMqttHost(host);
  }

  void setMqttPort(int port) {
    mqttPort.value = port;
    DataSettingWalker.saveMqttPort(port);
  }

  Future<bool> connectMqtt() async {
    mqttLoading.value = true;
    try {
      print(
        'Walker attempting to connect to MQTT: ${mqttHost.value}:${mqttPort.value}',
      );

      final result = await _mqttWalkerService.init(
        host: mqttHost.value,
        port: mqttPort.value,
      );

      // Update status berdasarkan hasil koneksi
      mqttConnected.value = result;

      print('Walker MQTT connection result: $result');
      return result;
    } catch (e) {
      print('Error connecting Walker to MQTT: $e');
      mqttConnected.value = false;
      return false;
    } finally {
      mqttLoading.value = false;
    }
  }

  void disconnectMqtt() {
    try {
      _mqttWalkerService.disconnect();
      mqttConnected.value = false;
      print('Walker MQTT disconnected successfully');
    } catch (e) {
      print('Error disconnecting Walker MQTT: $e');
    }
  }

  // Method untuk refresh status koneksi
  void refreshConnectionStatus() {
    _updateConnectionStatus();
  }

  @override
  void onClose() {
    // Cleanup jika perlu
    super.onClose();
  }
}