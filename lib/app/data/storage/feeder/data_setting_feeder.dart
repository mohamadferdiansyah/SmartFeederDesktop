import 'package:get_storage/get_storage.dart';

class DataSettingFeeder {
  static final _box = GetStorage();

  static String getMqttHost() {
    return _box.read('feeder_mqtt_host') ?? 'broker.emqx.io';
  }

  static void saveMqttHost(String host) {
    _box.write('feeder_mqtt_host', host);
  }

  static int getMqttPort() {
    return _box.read('feeder_mqtt_port') ?? 1883;
  }

  static void saveMqttPort(int port) {
    _box.write('feeder_mqtt_port', port);
  }
}