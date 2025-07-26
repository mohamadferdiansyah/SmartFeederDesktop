import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/data/data_controller.dart';
import 'package:smart_feeder_desktop/app/models/halter_device_model.dart';
import 'package:smart_feeder_desktop/app/models/horse_health_model.dart';
import 'package:smart_feeder_desktop/app/models/horse_model.dart';
import 'package:smart_feeder_desktop/app/models/room_model.dart';
import 'package:smart_feeder_desktop/app/models/stable_model.dart';

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

  final DataController dataController = Get.find<DataController>();

  List<StableModel> get stableList => dataController.stableList;

  List<RoomModel> get roomList => dataController.roomList;

  List<HorseModel> get horseList => dataController.horseList;

  List<HorseHealthModel> get horseHealthList => dataController.horseHealthList;

  List<HalterDeviceModel> get halterDeviceList => dataController.halterDeviceList;

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
}
