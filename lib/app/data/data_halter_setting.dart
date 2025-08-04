import 'package:get_storage/get_storage.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_rule_engine_model.dart';

// Inisialisasi di main.dart: await GetStorage.init();

class DataHalterSetting {
  static final _box = GetStorage();

  static HalterRuleEngineModel getSetting() {
    final map = _box.read('halter_rule_setting');
    if (map == null) return HalterRuleEngineModel.defaultValue();
    return HalterRuleEngineModel(
      suhuMin: map['suhuMin'],
      suhuMax: map['suhuMax'],
      spoMin: map['spoMin'],
      spoMax: map['spoMax'],
      bpmMin: map['bpmMin'],
      bpmMax: map['bpmMax'],
      respirasiMax: map['respirasiMax'],
    );
  }

  static void saveSetting(HalterRuleEngineModel setting) {
    _box.write('halter_rule_setting', {
      'suhuMin': setting.suhuMin,
      'suhuMax': setting.suhuMax,
      'spoMin': setting.spoMin,
      'spoMax': setting.spoMax,
      'bpmMin': setting.bpmMin,
      'bpmMax': setting.bpmMax,
      'respirasiMax': setting.respirasiMax,
    });
  }
}
