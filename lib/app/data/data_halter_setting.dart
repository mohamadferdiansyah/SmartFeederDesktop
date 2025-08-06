import 'package:get_storage/get_storage.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_rule_engine_model.dart';

// Inisialisasi di main.dart: await GetStorage.init();

class DataHalterSetting {
  static final _box = GetStorage();

  static HalterRuleEngineModel getSetting() {
    final map = _box.read('halter_rule_setting');
    if (map == null) return HalterRuleEngineModel.defaultValue();
    return HalterRuleEngineModel(
      tempMin: map['tempMin'],
      tempMax: map['tempMax'],
      spoMin: map['spoMin'],
      spoMax: map['spoMax'],
      heartRateMin: map['heartRateMin'],
      heartRateMax: map['heartRateMax'],
      respiratoryMax: map['respiratoryMax'],
      batteryMin: map['batteryMin'],
      tempRoomMin: map['tempRoomMin'],
      tempRoomMax: map['tempRoomMax'],
      humidityMin: map['humidityMin'],
      humidityMax: map['humidityMax'],
      lightIntensityMin: map['lightIntensityMin'],
      lightIntensityMax: map['lightIntensityMax'],
      ruleId: 1,
    );
  }

  static void saveSetting(HalterRuleEngineModel setting) {
    _box.write('halter_rule_setting', {
      'tempMin': setting.tempMin,
      'tempMax': setting.tempMax,
      'spoMin': setting.spoMin,
      'spoMax': setting.spoMax,
      'heartRateMin': setting.heartRateMin,
      'heartRateMax': setting.heartRateMax,
      'respiratoryMax': setting.respiratoryMax,
      'batteryMin': setting.batteryMin,
      'tempRoomMin': setting.tempRoomMin,
      'tempRoomMax': setting.tempRoomMax,
      'humidityMin': setting.humidityMin,
      'humidityMax': setting.humidityMax,
      'lightIntensityMin': setting.lightIntensityMin,
      'lightIntensityMax': setting.lightIntensityMax,
    });
  }
}
