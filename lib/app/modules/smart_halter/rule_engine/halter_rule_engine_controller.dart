import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/data/data_controller.dart';
import 'package:smart_feeder_desktop/app/data/data_halter_setting.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_horse_log_model.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_rule_engine_model.dart';

class HalterRuleEngineController extends GetxController {
  var setting = HalterRuleEngineModel.defaultValue().obs;
  final DataController dataController = Get.find<DataController>();

  RxList<HalterHorseLogModel> get halterHorseLogList =>
      dataController.halterLogList;

  @override
  void onInit() {
    setting.value = DataHalterSetting.getSetting();
    super.onInit();
  }

  void updateSetting(HalterRuleEngineModel s) {
    setting.value = s;
    DataHalterSetting.saveSetting(s);
  }

  void checkAndLog(
    String deviceId, {
    int? logId,
    double? suhu,
    double? spo,
    int? bpm,
    double? respirasi,
    DateTime? time,
  }) {
    final s = setting.value;
    final now = time ?? DateTime.now();
    if (suhu != null && (suhu < s.tempMin || suhu > s.tempMax)) {
      halterHorseLogList.add(
        HalterHorseLogModel(
          logId: logId ?? 0,
          deviceId: deviceId,
          message: 'Suhu kuda tidak normal ($suhu°C)',
          time: now,
          type: 'temperature',
        ),
      );
    }
    if (spo != null && (spo < s.spoMin || spo > s.spoMax)) {
      halterHorseLogList.add(
        HalterHorseLogModel(
          logId: logId ?? 0,
          deviceId: deviceId,
          message: 'Kadar oksigen tidak normal ($spo%)',
          time: now,
          type: 'spo',
        ),
      );
    }
    if (bpm != null && (bpm < s.heartRateMin || bpm > s.heartRateMax)) {
      halterHorseLogList.add(
        HalterHorseLogModel(
          logId: logId ?? 0,
          deviceId: deviceId,
          message: 'Detak jantung tidak normal ($bpm bpm)',
          time: now,
          type: 'bpm',
        ),
      );
    }
    if (respirasi != null && (respirasi > s.respiratoryMax)) {
      halterHorseLogList.add(
        HalterHorseLogModel(
          logId: logId ?? 0,
          deviceId: deviceId,
          message: 'Respirasi tinggi ($respirasi)',
          time: now,
          type: 'respirasi',
        ),
      );
    }
  }
}
