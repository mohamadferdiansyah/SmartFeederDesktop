import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smart_feeder_desktop/app/data/data_controller.dart';
import 'package:smart_feeder_desktop/app/models/halter/horse_health_model.dart';
import 'package:smart_feeder_desktop/app/models/horse_model.dart';
import 'package:smart_feeder_desktop/app/models/room_model.dart';
import 'package:smart_feeder_desktop/app/modules/smart_feeder/dashboard/feeder_dashboard_controller.dart';

class ControlScheduleController extends GetxController {
  RxInt selectedRoomIndex = 0.obs;
  int maxWater = 5;
  int maxFeed = 50;

  final FeederDashboardController feederController = Get.find();

  List<RoomModel> get filteredRoomList => roomList
      .where((room) => room.stableId == feederController.selectedStableId.value)
      .toList();

  RoomModel get selectedRoom => filteredRoomList.isNotEmpty
      ? filteredRoomList[selectedRoomIndex.value.clamp(
          0,
          filteredRoomList.length - 1,
        )]
      : roomList[0];

  final DataController dataController = Get.find<DataController>();

  List<RoomModel> get roomList => dataController.roomList;

  List<HorseModel> get horseList => dataController.horseList;

  List<HorseHealthModel> get horseHealthList => dataController.horseHealthList;

  HorseModel getHorseById(String horseId) {
    return horseList.firstWhere((horse) => horse.horseId == horseId);
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

  String getLastFeedText(RoomModel room) {
    final lastFeed = room.lastFeedText.value;
    if (lastFeed == null) return 'Belum ada pengisian';
    return DateFormat('dd-MM-yyyy HH:mm').format(lastFeed);
  }

  /// FIX: Update field final hanya dengan membuat objek baru, lalu replace di list!
  void updateRoomSchedule({
    required RoomModel room,
    required bool isWater,
    required String scheduleType,
    required int? intervalJam,
  }) {
    final index = roomList.indexWhere((r) => r.roomId == room.roomId);
    if (index == -1) return;

    final newRoom = RoomModel(
      roomId: room.roomId,
      name: room.name,
      deviceSerial: room.deviceSerial,
      status: room.status,
      cctvId: room.cctvId,
      stableId: room.stableId,
      horseId: room.horseId,
      remainingWater: room.remainingWater,
      remainingFeed: room.remainingFeed,
      waterScheduleType: isWater ? scheduleType.toLowerCase() : room.waterScheduleType,
      feedScheduleType: !isWater ? scheduleType.toLowerCase() : room.feedScheduleType,
      lastFeedText: room.lastFeedText.value,
      waterScheduleIntervalHour: isWater
          ? (scheduleType == "Penjadwalan" && intervalJam != null)
              ? intervalJam
              : (scheduleType == "Manual"
                  ? 0
                  : (scheduleType == "Otomatis" && intervalJam != null ? intervalJam : room.waterScheduleIntervalHour.value))
          : room.waterScheduleIntervalHour.value,
      feedScheduleIntervalHour: !isWater
          ? (scheduleType == "Penjadwalan" && intervalJam != null)
              ? intervalJam
              : (scheduleType == "Manual"
                  ? 0
                  : (scheduleType == "Otomatis" && intervalJam != null ? intervalJam : room.feedScheduleIntervalHour.value))
          : room.feedScheduleIntervalHour.value,
    );

    roomList[index] = newRoom;
  }
}