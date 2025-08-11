import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/data/data_controller.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_device_detail_model.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_device_model.dart';
import 'package:collection/collection.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_log_model.dart';
import 'package:smart_feeder_desktop/app/models/halter/horse_health_model.dart';
import 'package:smart_feeder_desktop/app/models/horse_model.dart';
import 'package:smart_feeder_desktop/app/models/halter/node_room_model.dart';
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

  final HalterSettingController settingController =
      Get.find<HalterSettingController>();

  List<StableModel> get stableList => dataController.stableList;

  RxList<RoomModel> get roomList => dataController.roomList;

  List<HorseModel> get horseList => dataController.horseList;

  List<HorseHealthModel> get horseHealthList => dataController.horseHealthList;

  RxList<HalterDeviceModel> get halterDeviceList =>
      dataController.halterDeviceList;

  RxList<HalterDeviceDetailModel> get halterDeviceDetailList =>
      serialService.detailHistory;

  RxList<NodeRoomModel> get nodeRoomList => serialService.nodeRoomList;

  RxList<HalterLogModel> get halterHorseLogList => dataController.halterLogList;

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
      (d) => d.horseId == selectedHorseId,
    );
    if (device == null) return [];
    // Filter history sesuai deviceId
    return halterDeviceDetailList
        .where((detail) => detail.deviceId == device.deviceId)
        .toList();
  }

  List<NodeRoomModel> getSelectedNodeRoomHistory() {
    final selectedSerialId = selectedRoom.deviceSerial;
    // Filter history sesuai deviceId
    return nodeRoomList
        .where((node) => node.deviceId == selectedSerialId)
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    // serialService.initSerial(settingController.setting.value.loraPort, 115200);
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

  StableModel getSelectedStableById(String stableId) {
    return stableList.firstWhere((stable) => stable.stableId == stableId);
  }

  HalterDeviceModel? getHalterDeviceByHorseId(String horseId) {
    return halterDeviceList.firstWhereOrNull((d) => d.horseId == horseId);
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
        ? list.lastWhereOrNull((detail) => detail.deviceId == device.deviceId)
        : null;
  }

  NodeRoomModel? getSelectedNodeRoom(String serialId) {
    return nodeRoomList
        .where((node) => node.deviceId == serialId)
        .toList()
        .sorted(
          (a, b) => (a.time ?? DateTime(0)).compareTo(b.time ?? DateTime(0)),
        )
        .lastOrNull;
  }

  String getRoomNameForLog(HalterLogModel log) {
    // Tipe log untuk ruangan
    final isRoomType =
        log.type == 'room_temperature' ||
        log.type == 'humidity' ||
        log.type == 'light_intensity';

    if (isRoomType) {
      // deviceId pada log = deviceSerial pada room
      final room = roomList.firstWhereOrNull(
        (room) => room.deviceSerial == log.deviceId,
      );
      return room?.name ?? "-";
    } else {
      // deviceId pada log = deviceId halter pada halterDeviceList
      // cari room yang horseId == halterDevice.horseId
      final halter = halterDeviceList.firstWhereOrNull(
        (h) => h.deviceId == log.deviceId,
      );
      if (halter == null) return "-";
      final room = roomList.firstWhereOrNull(
        (room) => room.horseId == halter.horseId,
      );
      return room?.name ?? "-";
    }
  }

  String getStableNameById(String stableId) {
    final stable = stableList.firstWhereOrNull((s) => s.stableId == stableId);
    return stable?.name ?? "Tidak diketahui";
  }

  String isHalterDeviceActive(String horseId) {
    final isActive = halterDeviceList.any(
      (device) => device.horseId == horseId && device.status == 'on',
    );
    return isActive ? "Aktif" : "Mati";
  }

  bool isCctvActive(String roomId) {
    final room = roomList.firstWhereOrNull((r) => r.roomId == roomId);
    return room?.cctvId?.isNotEmpty ?? false;
  }

  String getHorseNameByRoomId(String roomId) {
    final room = roomList.firstWhereOrNull((r) => r.roomId == roomId);
    return room != null && room.horseId != null
        ? getHorseById(room.horseId!).name
        : "-";
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

  String getHorsePosture({
    required num? roll,
    required num? pitch,
    required num? yaw,
  }) {
    // Jika semua null atau tidak ada data sama sekali
    if (roll == null && pitch == null && yaw == null) {
      return "Tidak Terklasifikasi";
    }

    // 16. Rebah penuh / jatuh
    if ((pitch != null && (pitch < -30 || pitch > 30)) &&
        (yaw != null && yaw >= -30 && yaw <= 30) &&
        (roll != null && (roll > 45 || roll < -45))) {
      return "Rebah penuh / jatuh";
    }

    // 8. Menunduk + menoleh kanan
    if ((pitch != null && pitch < -15) &&
        (yaw != null && yaw > 15) &&
        (roll != null && roll >= -10 && roll <= 10)) {
      return "Menunduk + menoleh kanan";
    }

    // 9. Menunduk + menoleh kiri
    if ((pitch != null && pitch < -15) &&
        (yaw != null && yaw < -15) &&
        (roll != null && roll >= -10 && roll <= 10)) {
      return "Menunduk + menoleh kiri";
    }

    // 10. Menunduk + rebah kanan
    if ((pitch != null && pitch < -15) &&
        (yaw != null && yaw >= -10 && yaw <= 10) &&
        (roll != null && roll > 15)) {
      return "Menunduk + rebah kanan";
    }

    // 11. Menunduk + rebah kiri
    if ((pitch != null && pitch < -15) &&
        (yaw != null && yaw >= -10 && yaw <= 10) &&
        (roll != null && roll < -15)) {
      return "Menunduk + rebah kiri";
    }

    // 12. Menengadah + menoleh kanan
    if ((pitch != null && pitch > 15) &&
        (yaw != null && yaw > 15) &&
        (roll != null && roll >= -10 && roll <= 10)) {
      return "Menengadah + menoleh kanan";
    }

    // 13. Menengadah + menoleh kiri
    if ((pitch != null && pitch > 15) &&
        (yaw != null && yaw < -15) &&
        (roll != null && roll >= -10 && roll <= 10)) {
      return "Menengadah + menoleh kiri";
    }

    // 14. Menengadah + rebah kanan
    if ((pitch != null && pitch > 15) &&
        (yaw != null && yaw >= -10 && yaw <= 10) &&
        (roll != null && roll > 15)) {
      return "Menengadah + rebah kanan";
    }

    // 15. Menengadah + rebah kiri
    if ((pitch != null && pitch > 15) &&
        (yaw != null && yaw >= -10 && yaw <= 10) &&
        (roll != null && roll < -15)) {
      return "Menengadah + rebah kiri";
    }

    // 2. Menunduk makan/minum
    if ((pitch != null && pitch < -15) &&
        (yaw != null && yaw >= -10 && yaw <= 10) &&
        (roll != null && roll >= -10 && roll <= 10)) {
      return "Menunduk makan/minum";
    }

    // 3. Menengadah (lihat atas)
    if ((pitch != null && pitch > 15) &&
        (yaw != null && yaw >= -10 && yaw <= 10) &&
        (roll != null && roll >= -10 && roll <= 10)) {
      return "Menengadah (lihat atas)";
    }

    // 4. Menoleh ke kanan
    if ((pitch != null && pitch >= -10 && pitch <= 10) &&
        (yaw != null && yaw > 15) &&
        (roll != null && roll >= -10 && roll <= 10)) {
      return "Menoleh ke kanan";
    }

    // 5. Menoleh ke kiri
    if ((pitch != null && pitch >= -10 && pitch <= 10) &&
        (yaw != null && yaw < -15) &&
        (roll != null && roll >= -10 && roll <= 10)) {
      return "Menoleh ke kiri";
    }

    // 6. Miring kanan (rebah kanan)
    if ((pitch != null && pitch >= -10 && pitch <= 10) &&
        (yaw != null && yaw >= -10 && yaw <= 10) &&
        (roll != null && roll > 15)) {
      return "Miring kanan (rebah kanan)";
    }

    // 7. Miring kiri (rebah kiri)
    if ((pitch != null && pitch >= -10 && pitch <= 10) &&
        (yaw != null && yaw >= -10 && yaw <= 10) &&
        (roll != null && roll < -15)) {
      return "Miring kiri (rebah kiri)";
    }

    // 1. Berdiri normal
    if ((pitch != null && pitch >= -10 && pitch <= 10) &&
        (yaw != null && yaw >= -10 && yaw <= 10) &&
        (roll != null && roll >= -10 && roll <= 10)) {
      return "Berdiri normal";
    }

    // Jika tidak memenuhi semua syarat di atas
    return "Postur tidak dikenali";
  }

  String getHorseHealth({
    required double? suhu,
    required double? heartRate,
    required double? spo,
    required double? respirasi,
  }) {
    // Check nulls
    if (suhu == null || heartRate == null || spo == null || respirasi == null) {
      return "Data Tidak Lengkap";
    }

    // 4. Hipotermia
    if (suhu < 37.0 || heartRate < 28 || spo < 90 || respirasi < 8) {
      return "Hipotermia";
    }

    // 3. Tidak Sehat (Demam/Stres Berat)
    if (suhu > 39.0 || heartRate > 60 || spo < 93 || respirasi > 24) {
      return "Tidak Sehat";
    }

    // 2. Waspada
    if ((suhu >= 38.4 && suhu <= 39.0) ||
        (heartRate >= 45 && heartRate <= 60) ||
        (spo >= 93 && spo <= 94) ||
        (respirasi >= 17 && respirasi <= 24)) {
      return "Waspada";
    }

    // 5. Overexertion (kelelahan)
    if ((suhu >= 37.2 && suhu <= 38.3) &&
        (heartRate > 60) &&
        (spo >= 95 && spo <= 100) &&
        (respirasi > 24)) {
      return "Overexertion";
    }

    // 6. Gangguan Oksigenasi
    if ((suhu >= 37.2 && suhu <= 38.3) &&
        (heartRate >= 28 && heartRate <= 44) &&
        (spo < 93) &&
        (respirasi >= 8 && respirasi <= 16)) {
      return "Gangguan Oksigenasi";
    }

    // 7. Demam Ringan
    if ((suhu > 38.3) &&
        (heartRate >= 28 && heartRate <= 44) &&
        (spo >= 95 && spo <= 100) &&
        (respirasi >= 8 && respirasi <= 16)) {
      return "Demam Ringan";
    }

    // 1. Normal
    if ((suhu >= 37.2 && suhu <= 38.3) &&
        (heartRate >= 28 && heartRate <= 44) &&
        (spo >= 95 && spo <= 100) &&
        (respirasi >= 8 && respirasi <= 16)) {
      return "Sehat";
    }

    return "Tidak Terklasifikasi";
  }
}
