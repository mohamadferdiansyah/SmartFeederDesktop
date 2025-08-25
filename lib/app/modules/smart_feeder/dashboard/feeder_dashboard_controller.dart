import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smart_feeder_desktop/app/data/data_controller.dart';
import 'package:smart_feeder_desktop/app/models/feeder/feeder_device_model.dart';
import 'package:smart_feeder_desktop/app/models/feeder/feeder_room_device_model.dart';
import 'package:smart_feeder_desktop/app/models/feeder/history_entry_model.dart';
import 'package:smart_feeder_desktop/app/models/room_model.dart';
import 'dart:async';
import 'package:smart_feeder_desktop/app/models/stable_model.dart';
import 'package:smart_feeder_desktop/app/services/mqtt_service.dart';

class FeederDashboardController extends GetxController {
  RxInt nowTick = DateTime.now().millisecondsSinceEpoch.obs;

  Timer? _timer;

  var airTankCurrent = 512.3.obs; // RxDouble
  var phCurrent = 7.2.obs; // RxDouble
  var feedTankCurrent = 150.5.obs; // RxDouble

  RxString selectedStableId = 'S1'.obs;
  RxInt selectedRoomIndex = 0.obs;

  RoomModel get selectedRoom => filteredRoomList.isNotEmpty
      ? filteredRoomList[selectedRoomIndex.value.clamp(
          0,
          filteredRoomList.length - 1,
        )]
      : roomList[0];

  final double tankMax = 600;

  List<RoomModel> get filteredRoomList => roomList
      .where((room) => room.stableId == selectedStableId.value)
      .toList();

  final DataController dataController = Get.find<DataController>();
  final mqttService = Get.find<MqttService>();

  RxList<RoomModel> get roomList => dataController.roomList;
  RxList<StableModel> get stableList => dataController.stableList;
  RxList<FeederDeviceModel> get feederDeviceList =>
      dataController.feederDeviceList;
  List<FeederRoomDeviceModel> get feederRoomDeviceList =>
      dataController.feederRoomDeviceList;
  List<HistoryEntryModel> get historyEntryList =>
      dataController.historyEntryList;

  @override
  void onInit() {
    super.onInit();
    mqttService.init();
    Timer.periodic(Duration(seconds: 1), (timer) {
      nowTick.value = DateTime.now().millisecondsSinceEpoch;
    });
    // Simulasi update isi tanki tiap detik untuk demo realtime
    Timer.periodic(Duration(seconds: 10), (timer) {
      phCurrent.value = (phCurrent.value + 0.01).clamp(6.5, 8.5);
      airTankCurrent.value = (airTankCurrent.value - 5).clamp(0, tankMax);
      feedTankCurrent.value = (feedTankCurrent.value + 5).clamp(0, tankMax);
    });

    // FIX: update remainingWater dan remainingFeed dengan cara replace objek RoomModel
    Timer.periodic(Duration(seconds: 10), (timer) {
      for (int i = 0; i < roomList.length; i++) {
        final room = roomList[i];
        final newRoom = RoomModel(
          roomId: room.roomId,
          name: room.name,
          deviceSerial: room.deviceSerial,
          status: room.status,
          cctvId: room.cctvId,
          stableId: room.stableId,
          horseId: room.horseId,
          remainingWater: (room.remainingWater - 0.1).clamp(0, 5),
          remainingFeed: (room.remainingFeed - 0.5).clamp(0, 50),
          waterScheduleType: room.waterScheduleType,
          feedScheduleType: room.feedScheduleType,
          lastFeedText: room.lastFeedText.value,
          waterScheduleIntervalHour: room.waterScheduleIntervalHour.value,
          feedScheduleIntervalHour: room.feedScheduleIntervalHour.value,
        );
        roomList[i] = newRoom;
      }
    });
  }

  void setSelectedStableId(String stableId) {
    selectedStableId.value = stableId;
    selectedRoomIndex.value = 0;
  }

  @override
  void onClose() {
    mqttService.disconnect();
    _timer?.cancel();
    super.onClose();
  }

  String formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final secs = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$secs';
  }

  String getTankImageAsset({
    required double current,
    required double max,
    required bool isWater,
  }) {
    final folder = isWater ? "water_tank" : "feed_tank";
    if (current <= 0) return "assets/images/$folder/fill_0.png";
    int level = (current / (max / 6)).ceil().clamp(1, 6);
    return "assets/images/$folder/fill_$level.png";
  }

  String getStableTankImageAsset(double current, double max, bool isWater) {
    final folder = isWater ? "stable_water" : "stable_feed";
    int level = 0;
    if (max > 0) {
      level = ((current / max) * 5).clamp(0, 5).round();
    }
    return "assets/images/$folder/fill_$level.png";
  }

  String getAirTankCurrentText() {
    return "${airTankCurrent.value.toStringAsFixed(1)}L";
  }

  String getAirTankMaxText() {
    return "${tankMax.toStringAsFixed(1)}L";
  }

  String getAirTankPercentText() {
    final percent = (tankMax > 0) ? (airTankCurrent.value / tankMax * 100) : 0;
    return "${percent.toStringAsFixed(0)}%";
  }

  String getFeedTankCurrentText() {
    return "${feedTankCurrent.value.toStringAsFixed(1)}Kg";
  }

  String getFeedTankMaxText() {
    return "${tankMax.toStringAsFixed(1)}Kg";
  }

  String getFeedTankPercentText() {
    final percent = (tankMax > 0) ? (feedTankCurrent.value / tankMax * 100) : 0;
    return "${percent.toStringAsFixed(0)}%";
  }

  String getDeviceStatusByRoom(String roomId) {
    final device = feederRoomDeviceList.firstWhereOrNull(
      (d) => d.roomId == roomId,
    );
    if (device == null) return "Tidak ada perangkat";
    return device.status == 'on' ? "Aktif" : "Nonaktif";
  }

  String getStableNameById(String stableId) {
    final stable = stableList.firstWhereOrNull((s) => s.stableId == stableId);
    return stable?.name ?? "Tidak diketahui";
  }

  int getWaterSecondsUntilNextAutoFeed(RoomModel room) {
    if (!(room.waterScheduleType == "penjadwalan" ||
        room.waterScheduleType == "otomatis")) {
      return 0;
    }
    final lastFeed = room.lastFeedText.value;
    if (lastFeed == null)
      return (room.waterScheduleIntervalHour.value ?? 0) * 3600;
    final nextFeedTime = lastFeed.add(
      Duration(hours: room.waterScheduleIntervalHour.value ?? 0),
    );
    final now = DateTime.now();
    final diff = nextFeedTime.difference(now).inSeconds;
    return diff > 0 ? diff : 0;
  }

  int getFeedSecondsUntilNextAutoFeed(RoomModel room) {
    if (!(room.feedScheduleType == "penjadwalan" ||
        room.feedScheduleType == "otomatis")) {
      return 0;
    }
    final lastFeed = room.lastFeedText.value;
    if (lastFeed == null)
      return (room.feedScheduleIntervalHour.value ?? 0) * 3600;
    final nextFeedTime = lastFeed.add(
      Duration(hours: room.feedScheduleIntervalHour.value ?? 0),
    );
    final now = DateTime.now();
    final diff = nextFeedTime.difference(now).inSeconds;
    return diff > 0 ? diff : 0;
  }

  String getAutoFeedTimeText(RoomModel room) {
    final seconds = getFeedSecondsUntilNextAutoFeed(room);
    return formatDuration(seconds);
  }

  String getAutoWaterTimeText(RoomModel room) {
    final seconds = getWaterSecondsUntilNextAutoFeed(room);
    return formatDuration(seconds);
  }

  String getLastFeedText(RoomModel room) {
    final lastFeed = room.lastFeedText.value;
    if (lastFeed == null) return 'Belum ada pengisian';
    return DateFormat('dd-MM-yyyy HH:mm').format(lastFeed);
  }

  int getFeederDeviceBatteryPercent(String deviceId) {
    final device = feederDeviceList.firstWhereOrNull(
      (d) => d.deviceId == deviceId,
    );
    return device?.batteryPercent ?? 0;
  }

  String getFeederDeviceStatus(String deviceId) {
    final device = feederDeviceList.firstWhereOrNull(
      (d) => d.deviceId == deviceId,
    );
    return device?.status ?? 'unknown';
  }

  FeederDeviceModel? getFeederDeviceById(String deviceId){
    return feederDeviceList.firstWhereOrNull(
      (d) => d.deviceId == deviceId,
    );
  }
}
