import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/data/data_controller.dart';
import 'package:smart_feeder_desktop/app/data/data_halter_setting.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_log_model.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_rule_engine_model.dart';

class HalterRuleEngineController extends GetxController {
  var setting = HalterRuleEngineModel.defaultValue().obs;
  final DataController dataController = Get.find<DataController>();

  RxList<HalterLogModel> get halterHorseLogList => dataController.halterLogList;

  @override
  void onInit() {
    setting.value = DataHalterSetting.getSetting();
    super.onInit();
  }

  void updateSetting(HalterRuleEngineModel s) {
    setting.value = s;
    DataHalterSetting.saveSetting(s);
  }

  void checkAndLogNode(
    String deviceId, {
    int? logId,
    double? temperature,
    double? humidity,
    double? lightIntensity,
    DateTime? time,
  }) {
    final s = setting.value;
    final now = time ?? DateTime.now();
    if (temperature != null) {
      if (temperature < s.tempMin) {
        halterHorseLogList.add(
          HalterLogModel(
            logId: logId ?? 0,
            deviceId: deviceId,
            message: 'Suhu Ruangan terlalu rendah: ($temperature°C)',
            time: now,
            type: 'room_temperature',
            isHigh: false,
          ),
        );
      } else if (temperature > s.tempMax) {
        halterHorseLogList.add(
          HalterLogModel(
            logId: logId ?? 0,
            deviceId: deviceId,
            message: 'Suhu Ruangan terlalu tinggi: ($temperature°C)',
            time: now,
            type: 'room_temperature',
            isHigh: true,
          ),
        );
      }
    }

    if (humidity != null && humidity > s.humidityMax) {
      halterHorseLogList.add(
        HalterLogModel(
          logId: logId ?? 0,
          deviceId: deviceId,
          message: 'Kelembapan Ruangan terlalu tinggi: ($humidity%)',
          time: now,
          type: 'humidity',
          isHigh: true,
        ),
      );
    }

    if (humidity != null && humidity < s.humidityMin) {
      halterHorseLogList.add(
        HalterLogModel(
          logId: logId ?? 0,
          deviceId: deviceId,
          message: 'Kelembapan Ruangan terlalu rendah: ($humidity%)',
          time: now,
          type: 'humidity',
          isHigh: false,
        ),
      );
    }

    if (lightIntensity != null && lightIntensity > s.lightIntensityMax) {
      halterHorseLogList.add(
        HalterLogModel(
          logId: logId ?? 0,
          deviceId: deviceId,
          message:
              'Intensitas cahaya Ruangan terlalu tinggi: ($lightIntensity lux)',
          time: now,
          type: 'light_intensity',
          isHigh: true,
        ),
      );
    }

    if (lightIntensity != null && lightIntensity < s.lightIntensityMin) {
      halterHorseLogList.add(
        HalterLogModel(
          logId: logId ?? 0,
          deviceId: deviceId,
          message:
              'Intensitas cahaya Ruangan terlalu rendah: ($lightIntensity lux)',
          time: now,
          type: 'light_intensity',
          isHigh: false,
        ),
      );
    }
  }

  void checkAndLogHalter(
    String deviceId, {
    int? logId,
    double? suhu,
    double? spo,
    int? bpm,
    double? respirasi,
    int? battery,
    DateTime? time,
  }) {
    final s = setting.value;
    final now = time ?? DateTime.now();
    if (suhu != null) {
      if (suhu < s.tempMin) {
        halterHorseLogList.add(
          HalterLogModel(
            logId: logId ?? 0,
            deviceId: deviceId,
            message: 'Suhu kuda terlalu rendah: ($suhu°C)',
            time: now,
            type: 'temperature',
            isHigh: false,
          ),
        );
      } else if (suhu > s.tempMax) {
        halterHorseLogList.add(
          HalterLogModel(
            logId: logId ?? 0,
            deviceId: deviceId,
            message: 'Suhu kuda terlalu tinggi: ($suhu°C)',
            time: now,
            type: 'temperature',
            isHigh: true,
          ),
        );
      }
    }

    if (spo != null) {
      if (spo < s.spoMin) {
        halterHorseLogList.add(
          HalterLogModel(
            logId: logId ?? 0,
            deviceId: deviceId,
            message: 'Kadar oksigen terlalu rendah: ($spo%)',
            time: now,
            type: 'spo',
            isHigh: false,
          ),
        );
      } else if (spo > s.spoMax) {
        halterHorseLogList.add(
          HalterLogModel(
            logId: logId ?? 0,
            deviceId: deviceId,
            message: 'Kadar oksigen terlalu tinggi: ($spo%)',
            time: now,
            type: 'spo',
            isHigh: true,
          ),
        );
      }
    }

    if (bpm != null) {
      if (bpm < s.heartRateMin) {
        halterHorseLogList.add(
          HalterLogModel(
            logId: logId ?? 0,
            deviceId: deviceId,
            message: 'Detak jantung terlalu rendah: ($bpm bpm)',
            time: now,
            type: 'bpm',
            isHigh: false,
          ),
        );
      } else if (bpm > s.heartRateMax) {
        halterHorseLogList.add(
          HalterLogModel(
            logId: logId ?? 0,
            deviceId: deviceId,
            message: 'Detak jantung terlalu tinggi: ($bpm bpm)',
            time: now,
            type: 'bpm',
            isHigh: true,
          ),
        );
      }
    }

    // Untuk respirasi, hanya jika lebih dari max
    if (respirasi != null && (respirasi > s.respiratoryMax)) {
      halterHorseLogList.add(
        HalterLogModel(
          logId: logId ?? 0,
          deviceId: deviceId,
          message: 'Respirasi terlalu tinggi: ($respirasi)',
          time: now,
          type: 'respirasi',
          isHigh: true,
        ),
      );
    }

    if (battery != null && battery < s.batteryMin) {
      halterHorseLogList.add(
        HalterLogModel(
          logId: logId ?? 0,
          deviceId: deviceId,
          message: 'Baterai Halter terlalu rendah: ($battery%)',
          time: now,
          type: 'battery',
          isHigh: true,
        ),
      );
    }
  }
}
