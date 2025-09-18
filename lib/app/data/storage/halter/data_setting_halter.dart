import 'package:get_storage/get_storage.dart';

class DataSettingHalter {
  static final _box = GetStorage();

  static String getNodeHalterHeader() {
    return _box.read('device_header') ?? 'SHIPB';
  }

  static void saveNodeHalterHeader(String header) {
    _box.write('device_header', header);
  }

  static String getNodeRoomHeader() {
    return _box.read('node_room_header') ?? 'SRIPB';
  }

  static void saveNodeRoomHeader(String header) {
    _box.write('node_room_header', header);
  }
}