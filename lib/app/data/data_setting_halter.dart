import 'package:get_storage/get_storage.dart';

class DataSettingHalter {
  static final _box = GetStorage();

  static String getDeviceHeader() {
    return _box.read('device_header') ?? 'SHIPB';
  }

  static void saveDeviceHeader(String header) {
    _box.write('device_header', header);
  }
}