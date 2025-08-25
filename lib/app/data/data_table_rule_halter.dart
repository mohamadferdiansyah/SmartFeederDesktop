import 'package:get_storage/get_storage.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_biometric_rule_engine_model.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_position_rule_engine_model.dart';

class DataTableRuleHalter {
  static final _box = GetStorage();

  static List<HalterBiometricRuleEngineModel> getBiometricList() {
    final list = _box.read('horse_health_classification') as List?;
    if (list == null) return [];
    return list
        .map(
          (e) => HalterBiometricRuleEngineModel.fromJson(
            Map<String, dynamic>.from(e),
          ),
        )
        .toList();
  }

  static void saveBiometricList(List<HalterBiometricRuleEngineModel> list) {
    _box.write(
      'horse_health_classification',
      list.map((e) => e.toJson()).toList(),
    );
  }

  static List<HalterPositionRuleEngineModel> getPositionList() {
    final list = _box.read('head_position_rule_halter') as List?;
    if (list == null) return [];
    return list
        .map((e) => HalterPositionRuleEngineModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static void savePositionList(List<HalterPositionRuleEngineModel> list) {
    _box.write('head_position_rule_halter', list.map((e) => e.toJson()).toList());
  }
}
