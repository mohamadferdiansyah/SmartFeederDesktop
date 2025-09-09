import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/data/data_controller.dart';
import 'package:smart_feeder_desktop/app/data/data_rule_halter.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_log_model.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_alert_rule_engine_model.dart';

class HalterAlertRuleEngineController extends GetxController {
  var setting = HalterAlertRuleEngineModel.defaultValue().obs;
  final DataController dataController = Get.find<DataController>();

  RxList<HalterLogModel> get halterHorseLogList => dataController.halterLogList;

  @override
  void onInit() {
    setting.value = DataRuleHalter.getSetting();
    super.onInit();
  }

  void updateSetting(HalterAlertRuleEngineModel s) {
    setting.value = s;
    DataRuleHalter.saveSetting(s);
  }

  void setDefaultSetting() {
    setting.value = HalterAlertRuleEngineModel.defaultValue();
    DataRuleHalter.saveSetting(setting.value);
  }

  Future<void> addAlertLog(HalterLogModel model) async {
    await dataController.addHalterAlertLog(model);
  }

  void checkAndLogNode(
    String deviceId, {
    int? logId,
    double? temperature,
    double? humidity,
    double? lightIntensity,
    DateTime? time,
  }) async {
    final s = setting.value;
    final now = time ?? DateTime.now();
    if (temperature != null) {
      if (temperature < s.tempMin) {
        final log = HalterLogModel(
          deviceId: deviceId,
          message: 'Suhu Ruangan terlalu rendah: ($temperature°C)',
          time: now,
          type: 'room_temperature',
          isHigh: false,
        );
        await addAlertLog(log);
      } else if (temperature > s.tempMax) {
        final log = HalterLogModel(
          deviceId: deviceId,
          message: 'Suhu Ruangan terlalu tinggi: ($temperature°C)',
          time: now,
          type: 'room_temperature',
          isHigh: true,
        );
        await addAlertLog(log);
      }
    }

    if (humidity != null && humidity > s.humidityMax) {
      final log = HalterLogModel(
        deviceId: deviceId,
        message: 'Kelembapan Ruangan terlalu tinggi: ($humidity%)',
        time: now,
        type: 'humidity',
        isHigh: true,
      );
      await addAlertLog(log);
    }

    if (humidity != null && humidity < s.humidityMin) {
      final log = HalterLogModel(
        deviceId: deviceId,
        message: 'Kelembapan Ruangan terlalu rendah: ($humidity%)',
        time: now,
        type: 'humidity',
        isHigh: false,
      );
      await addAlertLog(log);
    }

    if (lightIntensity != null && lightIntensity > s.lightIntensityMax) {
      final log = HalterLogModel(
        deviceId: deviceId,
        message:
            'Intensitas cahaya Ruangan terlalu tinggi: ($lightIntensity lux)',
        time: now,
        type: 'light_intensity',
        isHigh: true,
      );
      await addAlertLog(log);
    }

    if (lightIntensity != null && lightIntensity < s.lightIntensityMin) {
      final log = HalterLogModel(
        deviceId: deviceId,
        message:
            'Intensitas cahaya Ruangan terlalu rendah: ($lightIntensity lux)',
        time: now,
        type: 'light_intensity',
        isHigh: false,
      );
      await addAlertLog(log);
    }
  }

  void checkAndLogHalter(
    String deviceId, {
    int? logId,
    double? suhu,
    double? spo,
    double? bpm,
    double? respirasi,
    int? battery,
    DateTime? time,
  }) async {
    final s = setting.value;
    final now = time ?? DateTime.now();
    if (suhu != null) {
      if (suhu < s.tempMin) {
        final log = HalterLogModel(
          deviceId: deviceId,
          message: 'Suhu kuda terlalu rendah: ($suhu°C)',
          time: now,
          type: 'temperature',
          isHigh: false,
        );
        await addAlertLog(log);
      } else if (suhu > s.tempMax) {
        final log = HalterLogModel(
          deviceId: deviceId,
          message: 'Suhu kuda terlalu tinggi: ($suhu°C)',
          time: now,
          type: 'temperature',
          isHigh: true,
        );
        await addAlertLog(log);
      }
    }

    if (spo != null) {
      if (spo < s.spoMin) {
        final log = HalterLogModel(
          deviceId: deviceId,
          message: 'Kadar oksigen terlalu rendah: ($spo%)',
          time: now,
          type: 'spo',
          isHigh: false,
        );
        await addAlertLog(log);
      } else if (spo > s.spoMax) {
        final log = HalterLogModel(
          deviceId: deviceId,
          message: 'Kadar oksigen terlalu tinggi: ($spo%)',
          time: now,
          type: 'spo',
          isHigh: true,
        );
        await addAlertLog(log);
      }
    }

    if (bpm != null) {
      if (bpm < s.heartRateMin) {
        final log = HalterLogModel(
          deviceId: deviceId,
          message: 'Detak jantung terlalu rendah: ($bpm bpm)',
          time: now,
          type: 'bpm',
          isHigh: false,
        );
        await addAlertLog(log);
      } else if (bpm > s.heartRateMax) {
        final log = HalterLogModel(
          deviceId: deviceId,
          message: 'Detak jantung terlalu tinggi: ($bpm bpm)',
          time: now,
          type: 'bpm',
          isHigh: true,
        );
        await addAlertLog(log);
      }
    }

    // Untuk respirasi, hanya jika lebih dari max
    if (respirasi != null && (respirasi > s.respiratoryMax)) {
      final log = HalterLogModel(
        deviceId: deviceId,
        message: 'Respirasi terlalu tinggi: ($respirasi)',
        time: now,
        type: 'respirasi',
        isHigh: true,
      );
      await addAlertLog(log);
    }

    if (battery != null && battery < s.batteryMin) {
      final log = HalterLogModel(
        deviceId: deviceId,
        message: 'Baterai Halter terlalu rendah: ($battery%)',
        time: now,
        type: 'battery',
        isHigh: true,
      );
      await addAlertLog(log);
    }
  }
}
