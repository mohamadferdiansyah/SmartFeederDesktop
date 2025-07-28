import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/data/data_controller.dart';
import 'package:smart_feeder_desktop/app/models/halter_device_detail_model.dart';
import 'package:smart_feeder_desktop/app/models/halter_device_model.dart';
import 'package:smart_feeder_desktop/app/models/horse_health_model.dart';
import 'package:smart_feeder_desktop/app/models/horse_model.dart';
import 'package:smart_feeder_desktop/app/models/room_model.dart';
import 'package:smart_feeder_desktop/app/models/stable_model.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/setting/halter_setting_controller.dart';
import 'package:smart_feeder_desktop/app/services/halter_serial_service.dart';

class HalterDashboardController extends GetxController {
  RxInt selectedStableIndex = 0.obs;
  RxString selectedStableId = 'S1'.obs;
  RxInt selectedRoomIndex = 0.obs;
  RoomModel get selectedRoom => filteredRoomList.isNotEmpty
      ? filteredRoomList[selectedRoomIndex.value.clamp(
          0,
          filteredRoomList.length - 1,
        )]
      : roomList[0];



  List<RoomModel> get filteredRoomList => roomList
      .where((room) => room.stableId == selectedStableId.value)
      .toList();

  final serialService = Get.find<HalterSerialService>();

  final DataController dataController = Get.find<DataController>();

  final HalterSettingController settingController = Get.find<HalterSettingController>();

  List<StableModel> get stableList => dataController.stableList;

  List<RoomModel> get roomList => dataController.roomList;

  List<HorseModel> get horseList => dataController.horseList;

  List<HorseHealthModel> get horseHealthList => dataController.horseHealthList;

  List<HalterDeviceModel> get halterDeviceList =>
      dataController.halterDeviceList;

  RxList<HalterDeviceDetailModel> get halterDeviceDetailList =>
      serialService.detailHistory;

  int? getSelectedHorseBatteryPercent() {
  final selectedHorseId = selectedRoom.horseId;
  if (selectedHorseId == null) return null;

  final device = halterDeviceList.firstWhereOrNull(
    (d) => d.horseId == selectedHorseId,
  );
  return device?.batteryPercent;
}

  List<HalterDeviceDetailModel> getSelectedHorseDetailHistory() {
  final selectedHorseId = selectedRoom.horseId;
  if (selectedHorseId == null) return [];
  final device = halterDeviceList.firstWhereOrNull(
      (d) => d.horseId == selectedHorseId);
  if (device == null) return [];
  // Filter history sesuai deviceId
  return halterDeviceDetailList
      .where((detail) => detail.deviceId == device.deviceId)
      .toList();
}

  @override
  void onInit() {
    super.onInit();
    serialService.initSerial(settingController.setting.value.loraPort, 115200);
    ever<HalterDeviceDetailModel?>(serialService.latestDetail, (detail) {
      if (detail != null) {
        // Tambahkan data baru, batasi max 100
        halterDeviceDetailList.add(detail);
        if (halterDeviceDetailList.length > 100)
          halterDeviceDetailList.removeAt(0);
      }
    });
  }

  @override
  void onClose() {
    super.onClose();
    serialService.closeSerial();
  }

  void setSelectedStableId(String stableId) {
    selectedStableId.value = stableId;
    selectedRoomIndex.value = 0;
  }

  HalterDeviceModel getHalterDeviceByHorseId(String horseId) {
    return halterDeviceList.firstWhere((device) => device.horseId == horseId);
  }

  HorseModel getHorseById(String horseId) {
    return horseList.firstWhere((horse) => horse.horseId == horseId);
  }

  HalterDeviceDetailModel? getSelectedHorseDetail() {
    final selectedHorseId = selectedRoom.horseId;
    if (selectedHorseId == null) return null;

    final device = halterDeviceList.firstWhereOrNull(
      (d) => d.horseId == selectedHorseId,
    );
    if (device == null) return null;

    final list = halterDeviceDetailList.toList();
    return list.isNotEmpty
        ? list.lastWhere((detail) => detail.deviceId == device.deviceId)
        : null;
  }

  String getStableNameById(String stableId) {
    final stable = stableList.firstWhereOrNull((s) => s.stableId == stableId);
    return stable?.name ?? "Tidak diketahui";
  }

  String isHalterDeviceActive(String horseId) {
    final isActive = halterDeviceList.any(
      (device) => device.horseId == horseId && device.status == 'on',
    );
    return isActive ? "Aktif" : "Nonaktif";
  }

  bool isCctvActive(String roomId) {
    final room = roomList.firstWhereOrNull((r) => r.roomId == roomId);
    return room?.cctvIds.isNotEmpty ?? false;
  }

  String getHorseNameByRoomId(String roomId) {
    final room = roomList.firstWhereOrNull((r) => r.roomId == roomId);
    return room != null && room.horseId != null
        ? getHorseById(room.horseId!).name
        : "Tidak diketahui";
  }

  bool isRoomFilled(String roomId) {
    final room = roomList.firstWhereOrNull((r) => r.roomId == roomId);
    return room != null && room.horseId != null;
  }

  int getBatteryPercentByRoomId(String roomId) {
    final device = halterDeviceList.firstWhereOrNull(
      (d) =>
          d.horseId == roomList.firstWhere((r) => r.roomId == roomId).horseId,
    );
    return device?.batteryPercent ?? 0;
  }

  int getFilledRoomCount() {
    return filteredRoomList.where((room) => room.horseId != null).length;
  }

  int getEmptyRoomCount() {
    return filteredRoomList.where((room) => room.horseId == null).length;
  }

  int getHealthyHorseCount() {
    final filteredHorseIds = filteredRoomList
        .where((room) => room.horseId != null)
        .map((room) => room.horseId)
        .toSet();
    return horseHealthList
        .where(
          (health) =>
              filteredHorseIds.contains(health.horseId) &&
              health.bodyTemp <= 39.0 &&
              health.heartRate <= 44,
        )
        .length;
  }

  int getSickHorseCount() {
    final filteredHorseIds = filteredRoomList
        .where((room) => room.horseId != null)
        .map((room) => room.horseId)
        .toSet();
    return horseHealthList
        .where(
          (health) =>
              filteredHorseIds.contains(health.horseId) &&
              (health.bodyTemp > 39.0 || health.heartRate > 44),
        )
        .length;
  }

  int getDeviceOnCount() {
    final filteredHorseIds = filteredRoomList
        .where((room) => room.horseId != null)
        .map((room) => room.horseId)
        .toSet();
    return halterDeviceList
        .where(
          (device) =>
              device.status == 'on' &&
              device.horseId != null &&
              filteredHorseIds.contains(device.horseId),
        )
        .length;
  }

  int getDeviceOffCount() {
    final filteredHorseIds = filteredRoomList
        .where((room) => room.horseId != null)
        .map((room) => room.horseId)
        .toSet();
    return halterDeviceList
        .where(
          (device) =>
              device.status == 'off' &&
              device.horseId != null &&
              filteredHorseIds.contains(device.horseId),
        )
        .length;
  }

  String getHorseHealthStatusById(String horseId) {
    final health = horseHealthList.firstWhereOrNull(
      (h) => h.horseId == horseId,
    );
    if (health == null) return "Tidak Ada Data";

    // Threshold dummy: kalau suhu > 39 atau heartRate > 44, status = Sakit
    if (health.bodyTemp > 39.0 || health.heartRate > 44) {
      return "Sakit";
    }
    return "Sehat";
  }

  String getHorseHeadPosture(int roll, int pitch, int yaw) {
  // Threshold bisa kamu sesuaikan, ini contoh kasar:
  if (pitch < -30) return "Menunduk";
  if (pitch > 30) return "Mendongak";
  if (roll > 30) return "Miring kanan";
  if (roll < -30) return "Miring kiri";
  return "Tegak";
}
}
