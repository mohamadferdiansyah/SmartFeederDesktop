import 'package:get_storage/get_storage.dart';

class DataSettingWalker {
  static final _box = GetStorage();

  static String getMqttHost() {
    return _box.read('walker_mqtt_host') ?? '103.49.238.216';
  }

  static void saveMqttHost(String host) {
    _box.write('walker_mqtt_host', host);
  }

  static int getMqttPort() {
    return _box.read('walker_mqtt_port') ?? 1883;
  }

  static void saveMqttPort(int port) {
    _box.write('walker_mqtt_port', port);
  }
}