import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smart_feeder_desktop/app/data/data_controller.dart';
import 'package:smart_feeder_desktop/app/models/halter/horse_health_model.dart';
import 'package:smart_feeder_desktop/app/models/horse_model.dart';
import 'package:smart_feeder_desktop/app/models/room_model.dart';
import 'package:smart_feeder_desktop/app/modules/smart_feeder/dashboard/feeder_dashboard_controller.dart';

// ...existing imports...

class ControlScheduleController extends GetxController {
  RxInt selectedRoomIndex = 0.obs;
  RxInt selectedTab = 0.obs;
  RxString selectedMode = "Penjadwalan".obs;
  RxInt intervalJam = 2.obs;

  int maxWater = 5;
  int maxFeed = 50;

  final FeederDashboardController feederController = Get.find();

  List<RoomModel> get filteredRoomList => roomList
      .where((room) => room.stableId == feederController.selectedStableId.value)
      .toList();

  RoomModel? get selectedRoom =>
      (filteredRoomList.isNotEmpty &&
          selectedRoomIndex.value >= 0 &&
          selectedRoomIndex.value < filteredRoomList.length)
      ? filteredRoomList[selectedRoomIndex.value]
      : null;

  final DataController dataController = Get.find<DataController>();

  RxList<RoomModel> get roomList => dataController.roomList;
  RxList<HorseModel> get horseList => dataController.horseList;
  RxList<HorseHealthModel> get horseHealthList =>
      dataController.horseHealthList;

  void setSelectedRoom(RoomModel? room) {
    if (room != null) {
      final idx = filteredRoomList.indexOf(room);
      selectedRoomIndex.value = idx >= 0 ? idx : 0;
    }
  }

  void setSelectedTab(int tab) {
    selectedTab.value = tab;
  }

  void setSelectedMode(String? mode) {
    selectedMode.value = mode ?? "Penjadwalan";
  }

  void setIntervalJam(int? jam) {
    intervalJam.value = jam ?? 2;
  }

  Future<void> updateRoomScheduleFlexible(
    RoomModel room, {
    bool isWater = false,
    String? scheduleType,
    int? intervalJam,
  }) async {
    if (isWater) {
      await dataController.updateRoomScheduleFlexible(
        room.roomId,
        waterScheduleType: scheduleType,
        waterScheduleIntervalHour: intervalJam,
      );
    } else {
      await dataController.updateRoomScheduleFlexible(
        room.roomId,
        feedScheduleType: scheduleType,
        feedScheduleIntervalHour: intervalJam,
      );
    }
  }

  HorseModel getHorseById(String horseId) {
    return horseList.firstWhere((horse) => horse.horseId == horseId);
  }

  String getHorseHealthStatusById(String horseId) {
    final health = horseHealthList.firstWhereOrNull(
      (h) => h.horseId == horseId,
    );
    if (health == null) return "Tidak Ada Data";
    if (health.bodyTemp > 39.0 || health.heartRate > 44) {
      return "Sakit";
    }
    return "Sehat";
  }

  String getLastFeedText(RoomModel room) {
    final lastFeed = room.lastFeedText.value;
    if (lastFeed == null) return 'Belum ada pengisian';
    return DateFormat('dd-MM-yyyy HH:mm').format(lastFeed);
  }
}
