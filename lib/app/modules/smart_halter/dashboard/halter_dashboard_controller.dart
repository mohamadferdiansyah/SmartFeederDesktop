import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/data/data_controller.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_device_detail_model.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_device_model.dart';
import 'package:collection/collection.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_log_model.dart';
import 'package:smart_feeder_desktop/app/models/halter/horse_health_model.dart';
import 'package:smart_feeder_desktop/app/models/halter/node_room_detail_model.dart';
import 'package:smart_feeder_desktop/app/models/horse_model.dart';
import 'package:smart_feeder_desktop/app/models/halter/node_room_model.dart';
import 'package:smart_feeder_desktop/app/models/room_model.dart';
import 'package:smart_feeder_desktop/app/models/stable_model.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/rule_engine/table/halter_table_rule_engine_controller.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/setting/halter_setting_controller.dart';
import 'package:smart_feeder_desktop/app/services/halter_serial_service.dart';

class HalterDashboardController extends GetxController {
  RxInt selectedStableIndex = 0.obs;
  RxString selectedStableId = ''.obs;
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

  final HalterTableRuleEngineController tableRuleEngineController =
      Get.find<HalterTableRuleEngineController>();

  final HalterSettingController settingController =
      Get.find<HalterSettingController>();

  RxList<StableModel> get stableList => dataController.stableList;

  RxList<RoomModel> get roomList => dataController.roomList;

  List<HorseModel> get horseList => dataController.horseList;

  List<HorseHealthModel> get horseHealthList => dataController.horseHealthList;

  RxList<HalterDeviceModel> get halterDeviceList =>
      dataController.halterDeviceList;

  RxList<HalterDeviceDetailModel> get halterDeviceDetailList =>
      dataController.detailHistory;

  RxList<NodeRoomDetailModel> get nodeRoomDetailList =>
      dataController.nodeRoomDetailHistory;

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

  List<NodeRoomDetailModel> getSelectedNodeRoomHistory() {
    final selectedSerialId = selectedRoom.deviceSerial;
    // Filter history sesuai deviceId
    return nodeRoomDetailList
        .where((node) => node.deviceId == selectedSerialId)
        .toList();
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

  Future<void> refreshRoomList() async {
    await dataController.loadRoomsFromDb();
  }

  /// Refresh data stable dari database
  Future<void> refreshStableList() async {
    await dataController.loadStablesFromDb();
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

  HalterDeviceDetailModel? getSelectedHorseDetail(String horseId) {
    final device = halterDeviceList.firstWhereOrNull(
      (d) => d.horseId == horseId,
    );
    if (device == null) return null;

    // Ambil detail terbaru dari serial/MQTT
    return halterDeviceDetailList
        .where((d) => d.deviceId == device.deviceId)
        .sorted((a, b) => b.time.compareTo(a.time))
        .firstOrNull;
  }

  NodeRoomDetailModel? getSelectedNodeRoomDetail(String serialId) {
    // Ambil detail terbaru dari nodeRoomDetailList berdasarkan deviceSerial
    return nodeRoomDetailList
        .where((detail) => detail.deviceId == serialId)
        .sorted((a, b) => b.time.compareTo(a.time))
        .firstOrNull;
  }

  StableModel? getStableByRoomId(String roomId) {
    final room = roomList.firstWhereOrNull((r) => r.roomId == roomId);
    if (room == null) return null;
    return stableList.firstWhereOrNull((s) => s.stableId == room.stableId);
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
    final cctvIds = room?.cctvId;
    if (cctvIds == null || cctvIds.isEmpty) return false;
    // Return true jika ada minimal satu cctvId yang bukan 'kosong'
    return cctvIds.any((id) => id.toLowerCase() != 'kosong');
  }

  String getHorseNameByRoomId(String roomId) {
    final room = roomList.firstWhereOrNull((r) => r.roomId == roomId);
    return room != null && room.horseId != null
        ? getHorseById(room.horseId!).name
        : "-";
  }

  bool isRoomFilled(String roomId) {
    // Cek apakah ada horse yang roomId-nya sama dengan roomId yang dicek
    return horseList.any((horse) => horse.roomId == roomId);
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
    return filteredRoomList.where((room) => room.horseId != null).where((room) {
      final horse = horseList.firstWhereOrNull(
        (h) => h.horseId == room.horseId,
      );
      if (horse == null) return false;
      final detail = halterDeviceDetailList.lastWhereOrNull(
        (d) => getHalterDeviceByHorseId(horse.horseId)?.deviceId == d.deviceId,
      );
      if (detail == null) return false;
      final status = getHorseHealth(
        suhu: detail.temperature,
        heartRate: detail.heartRate?.toDouble(),
        spo: detail.spo?.toDouble(),
        respirasi: detail.respiratoryRate?.toDouble(),
      );
      return status == "Sehat";
    }).length;
  }

  int getSickHorseCount() {
    return filteredRoomList.where((room) => room.horseId != null).where((room) {
      final horse = horseList.firstWhereOrNull(
        (h) => h.horseId == room.horseId,
      );
      if (horse == null) return false;
      final detail = halterDeviceDetailList.lastWhereOrNull(
        (d) => getHalterDeviceByHorseId(horse.horseId)?.deviceId == d.deviceId,
      );
      if (detail == null) return false;
      final status = getHorseHealth(
        suhu: detail.temperature,
        heartRate: detail.heartRate?.toDouble(),
        spo: detail.spo?.toDouble(),
        respirasi: detail.respiratoryRate?.toDouble(),
      );
      return status != "Sehat";
    }).length;
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

  // String getHorsePosture({
  //   required num? roll,
  //   required num? pitch,
  //   required num? yaw,
  // }) {
  //   // Jika semua null atau tidak ada data sama sekali
  //   if (roll == null && pitch == null && yaw == null) {
  //     return "Tidak Terklasifikasi";
  //   }

  //   // 16. Rebah penuh / jatuh
  //   if ((pitch != null && (pitch < -30 || pitch > 30)) &&
  //       (yaw != null && yaw >= -30 && yaw <= 30) &&
  //       (roll != null && (roll > 45 || roll < -45))) {
  //     return "Rebah penuh / jatuh";
  //   }

  //   // 8. Menunduk + menoleh kanan
  //   if ((pitch != null && pitch < -15) &&
  //       (yaw != null && yaw > 15) &&
  //       (roll != null && roll >= -10 && roll <= 10)) {
  //     return "Menunduk Ke Kanan";
  //   }

  //   // 9. Menunduk + menoleh kiri
  //   if ((pitch != null && pitch < -15) &&
  //       (yaw != null && yaw < -15) &&
  //       (roll != null && roll >= -10 && roll <= 10)) {
  //     return "Menunduk Ke Kiri";
  //   }

  //   // 10. Menunduk + rebah kanan
  //   if ((pitch != null && pitch < -15) &&
  //       (yaw != null && yaw >= -10 && yaw <= 10) &&
  //       (roll != null && roll > 15)) {
  //     return "Menunduk Rebah Kanan";
  //   }

  //   // 11. Menunduk + rebah kiri
  //   if ((pitch != null && pitch < -15) &&
  //       (yaw != null && yaw >= -10 && yaw <= 10) &&
  //       (roll != null && roll < -15)) {
  //     return "Menunduk Rebah Kiri";
  //   }

  //   // 12. Menengadah + menoleh kanan
  //   if ((pitch != null && pitch > 15) &&
  //       (yaw != null && yaw > 15) &&
  //       (roll != null && roll >= -10 && roll <= 10)) {
  //     return "Menengadah Ke Kanan";
  //   }

  //   // 13. Menengadah + menoleh kiri
  //   if ((pitch != null && pitch > 15) &&
  //       (yaw != null && yaw < -15) &&
  //       (roll != null && roll >= -10 && roll <= 10)) {
  //     return "Menengadah Ke Kiri";
  //   }

  //   // 14. Menengadah + rebah kanan
  //   if ((pitch != null && pitch > 15) &&
  //       (yaw != null && yaw >= -10 && yaw <= 10) &&
  //       (roll != null && roll > 15)) {
  //     return "Menengadah Rebah Kanan";
  //   }

  //   // 15. Menengadah + rebah kiri
  //   if ((pitch != null && pitch > 15) &&
  //       (yaw != null && yaw >= -10 && yaw <= 10) &&
  //       (roll != null && roll < -15)) {
  //     return "Menengadah Rebah Kiri";
  //   }

  //   // 2. Menunduk makan/minum
  //   if ((pitch != null && pitch < -15) &&
  //       (yaw != null && yaw >= -10 && yaw <= 10) &&
  //       (roll != null && roll >= -10 && roll <= 10)) {
  //     return "Menunduk";
  //   }

  //   // 3. Menengadah (lihat atas)
  //   if ((pitch != null && pitch > 15) &&
  //       (yaw != null && yaw >= -10 && yaw <= 10) &&
  //       (roll != null && roll >= -10 && roll <= 10)) {
  //     return "Menengadah";
  //   }

  //   // 4. Menoleh ke kanan
  //   if ((pitch != null && pitch >= -10 && pitch <= 10) &&
  //       (yaw != null && yaw > 15) &&
  //       (roll != null && roll >= -10 && roll <= 10)) {
  //     return "Menoleh Ke Kanan";
  //   }

  //   // 5. Menoleh ke kiri
  //   if ((pitch != null && pitch >= -10 && pitch <= 10) &&
  //       (yaw != null && yaw < -15) &&
  //       (roll != null && roll >= -10 && roll <= 10)) {
  //     return "Menoleh Ke Kiri";
  //   }

  //   // 6. Miring kanan (rebah kanan)
  //   if ((pitch != null && pitch >= -10 && pitch <= 10) &&
  //       (yaw != null && yaw >= -10 && yaw <= 10) &&
  //       (roll != null && roll > 15)) {
  //     return "Miring Kanan";
  //   }

  //   // 7. Miring kiri (rebah kiri)
  //   if ((pitch != null && pitch >= -10 && pitch <= 10) &&
  //       (yaw != null && yaw >= -10 && yaw <= 10) &&
  //       (roll != null && roll < -15)) {
  //     return "Miring Kiri";
  //   }

  //   // 1. Berdiri normal
  //   if ((pitch != null && pitch >= -10 && pitch <= 10) &&
  //       (yaw != null && yaw >= -10 && yaw <= 10) &&
  //       (roll != null && roll >= -10 && roll <= 10)) {
  //     return "Berdiri Normal";
  //   }

  //   // Jika tidak memenuhi semua syarat di atas
  //   return "Postur tidak dikenali";
  // }

  // String getHorsePosture(double ax, double ay, double az) {
  //   // hitung pitch & roll dari accelerometer
  //   double pitch = atan2(-ax, sqrt(ay * ay + az * az)) * 180 / pi;
  //   double roll = atan2(ay, az) * 180 / pi;

  //   // klasifikasi sederhana
  //   if (pitch.abs() < 20 && roll.abs() < 20) {
  //     return "Berdiri Normal";
  //   } else if (pitch > 45) {
  //     return "Mendongak (kepala ke atas)";
  //   } else if (pitch < -45) {
  //     return "Menunduk / Makan";
  //   } else if (roll > 40) {
  //     return "Miring Kanan";
  //   } else if (roll < -40) {
  //     return "Mendongak (kepala ke bawah)";
  //   } else if (pitch.abs() > 70 && roll.abs() > 70) {
  //     return "Berbaring";
  //   } else {
  //     return "Postur Tidak Dikenali";
  //   }
  // }

  // String getHorsePosture(num pitch, num roll, num yaw) {
  //   const double pitchThreshold = 15; // derajat
  //   const double rollThreshold = 15;
  //   const double yawThreshold = 20;

  //   // Pitch (atas-bawah)
  //   if (pitch > pitchThreshold) {
  //     return "Kepala Menengadah (Head Up)";
  //   } else if (pitch < -pitchThreshold) {
  //     return "Kepala Menunduk (Head Down)";
  //   }

  //   // Roll (miring kiri/kanan)
  //   if (roll > rollThreshold) {
  //     return "Kepala Miring Kiri";
  //   } else if (roll < -rollThreshold) {
  //     return "Kepala Miring Kanan";
  //   }

  //   // Yaw (geleng kiri/kanan)
  //   if (yaw > yawThreshold) {
  //     return "Kepala Menoleh Kanan";
  //   } else if (yaw < -yawThreshold) {
  //     return "Kepala Menoleh Kiri";
  //   }

  //   // Kalau masih dalam batas normal
  //   return "Kepala Tegak";
  // }

  String getHorseHealth({
    required double? suhu,
    required double? heartRate,
    required double? spo,
    required double? respirasi,
  }) {
    return tableRuleEngineController.biometricClassify(
      suhu: suhu,
      heartRate: heartRate?.toInt(),
      spo: spo,
      respirasi: respirasi?.toInt(),
    );
  }

  String getHorsePosition({
    required double? pitch,
    required double? roll,
    required double? yaw,
  }) {
    return tableRuleEngineController.positionClassify(
      pitch: pitch,
      roll: roll,
      yaw: yaw,
    );
  }

  // String getHorseHealth({
  //   required double? suhu,
  //   required double? heartRate,
  //   required double? spo,
  //   required double? respirasi,
  // }) {
  //   // Check nulls
  //   if (suhu == null || heartRate == null || spo == null || respirasi == null) {
  //     return "Data Tidak Lengkap";
  //   }

  //   // 4. Hipotermia
  //   if (suhu < 37.0 || heartRate < 28 || spo < 90 || respirasi < 8) {
  //     return "Hipotermia";
  //   }

  //   // 3. Tidak Sehat (Demam/Stres Berat)
  //   if (suhu > 39.0 || heartRate > 60 || spo < 93 || respirasi > 24) {
  //     return "Tidak Sehat";
  //   }

  //   // 2. Waspada
  //   if ((suhu >= 38.4 && suhu <= 39.0) ||
  //       (heartRate >= 45 && heartRate <= 60) ||
  //       (spo >= 93 && spo <= 94) ||
  //       (respirasi >= 17 && respirasi <= 24)) {
  //     return "Waspada";
  //   }

  //   // 5. Overexertion (kelelahan)
  //   if ((suhu >= 37.2 && suhu <= 38.3) &&
  //       (heartRate > 60) &&
  //       (spo >= 95 && spo <= 100) &&
  //       (respirasi > 24)) {
  //     return "Overexertion";
  //   }

  //   // 6. Gangguan Oksigenasi
  //   if ((suhu >= 37.2 && suhu <= 38.3) &&
  //       (heartRate >= 28 && heartRate <= 44) &&
  //       (spo < 93) &&
  //       (respirasi >= 8 && respirasi <= 16)) {
  //     return "Gangguan Oksigenasi";
  //   }

  //   // 7. Demam Ringan
  //   if ((suhu > 38.3) &&
  //       (heartRate >= 28 && heartRate <= 44) &&
  //       (spo >= 95 && spo <= 100) &&
  //       (respirasi >= 8 && respirasi <= 16)) {
  //     return "Demam Ringan";
  //   }

  //   // 1. Normal
  //   if ((suhu >= 37.2 && suhu <= 38.3) &&
  //       (heartRate >= 28 && heartRate <= 44) &&
  //       (spo >= 95 && spo <= 100) &&
  //       (respirasi >= 8 && respirasi <= 16)) {
  //     return "Sehat";
  //   }

  //   return "Tidak Terklasifikasi";
  // }
}
