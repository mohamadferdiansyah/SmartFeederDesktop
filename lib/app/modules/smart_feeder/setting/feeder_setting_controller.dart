import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/services/mqtt_service.dart';

class FeederSettingController extends GetxController {
  final mqttHost = 'broker.emqx.io'.obs;
  final mqttPort = 1883.obs;
  final mqttConnected = false.obs;
  final mqttLoading = false.obs;

  late MqttService _mqttService;

  @override
  void onInit() {
    super.onInit();
    _mqttService = Get.find<MqttService>();
    
    // Check initial connection status
    _updateConnectionStatus();
    
    // Setup periodic check untuk memastikan status selalu sinkron
    ever(mqttConnected, (bool connected) {
      print('MQTT Connection status changed: $connected');
    });
  }

  void _updateConnectionStatus() {
    mqttConnected.value = _mqttService.isConnected;
  }

  void setMqttHost(String host) => mqttHost.value = host;
  void setMqttPort(int port) => mqttPort.value = port;

  Future<bool> connectMqtt() async {
    mqttLoading.value = true;
    try {
      print('Attempting to connect to MQTT: ${mqttHost.value}:${mqttPort.value}');
      
      final result = await _mqttService.init(
        host: mqttHost.value,
        port: mqttPort.value,
      );
      
      // Update status berdasarkan hasil koneksi
      mqttConnected.value = result;
      
      print('MQTT connection result: $result');
      return result;
    } catch (e) {
      print('Error connecting to MQTT: $e');
      mqttConnected.value = false;
      return false;
    } finally {
      mqttLoading.value = false;
    }
  }

  void disconnectMqtt() {
    try {
      _mqttService.disconnect();
      mqttConnected.value = false;
      print('MQTT disconnected successfully');
    } catch (e) {
      print('Error disconnecting MQTT: $e');
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