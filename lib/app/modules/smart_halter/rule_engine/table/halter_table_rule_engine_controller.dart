import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/data/data_controller.dart';
import 'package:smart_feeder_desktop/app/data/data_table_rule_halter.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_biometric_rule_engine_model.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_position_rule_engine_model.dart';

class HalterTableRuleEngineController extends GetxController {
  final DataController dataController = Get.find<DataController>();

  RxList<HalterBiometricRuleEngineModel> get biometricClassificationList =>
      dataController.biometricClassificationList;

  RxList<HalterPositionRuleEngineModel> get positionClassificationList =>
      dataController.positionClassificationList;

  @override
  void onInit() {
    biometricClassificationList.assignAll(DataTableRuleHalter.getBiometricList());
    positionClassificationList.assignAll(DataTableRuleHalter.getPositionList());
    loadDefaultIfEmpty();
    super.onInit();
  }

  void loadDefaultIfEmpty() {
    if (biometricClassificationList.isEmpty) {
      biometricClassificationList.assignAll([
        HalterBiometricRuleEngineModel(
          name: "Normal",
          suhuMin: 37.2,
          suhuMax: 38.3,
          heartRateMin: 28,
          heartRateMax: 44,
          spoMin: 95,
          spoMax: 100,
          respirasiMin: 8,
          respirasiMax: 16,
        ),
        HalterBiometricRuleEngineModel(
          name: "Waspada",
          suhuMin: 38.4,
          suhuMax: 39.0,
          heartRateMin: 45,
          heartRateMax: 60,
          spoMin: 93,
          spoMax: 94,
          respirasiMin: 17,
          respirasiMax: 24,
        ),
        HalterBiometricRuleEngineModel(
          name: "Demam",
          suhuMin: 39.1,
          suhuMax: null,
          heartRateMin: 61,
          heartRateMax: null,
          spoMin: null,
          spoMax: 92,
          respirasiMin: 25,
          respirasiMax: null,
        ),
        HalterBiometricRuleEngineModel(
          name: "Hipotermia",
          suhuMin: null,
          suhuMax: 36.9,
          heartRateMin: null,
          heartRateMax: 27,
          spoMin: null,
          spoMax: 89,
          respirasiMin: null,
          respirasiMax: 7,
        ),
        HalterBiometricRuleEngineModel(
          name: "Overexertion",
          suhuMin: 37.2,
          suhuMax: 38.3,
          heartRateMin: 45,
          heartRateMax: null,
          spoMin: 95,
          spoMax: 100,
          respirasiMin: 17,
          respirasiMax: null,
        ),
        HalterBiometricRuleEngineModel(
          name: "Gangguan Oksigenasi",
          suhuMin: 37.2,
          suhuMax: 38.3,
          heartRateMin: 28,
          heartRateMax: 44,
          spoMin: null,
          spoMax: 92,
          respirasiMin: 8,
          respirasiMax: 16,
        ),
        HalterBiometricRuleEngineModel(
          name: "Demam Ringan",
          suhuMin: 38.4,
          suhuMax: null,
          heartRateMin: 28,
          heartRateMax: 44,
          spoMin: 95,
          spoMax: 100,
          respirasiMin: 8,
          respirasiMax: 16,
        ),
      ]);
      DataTableRuleHalter.saveBiometricList(biometricClassificationList);
    }

    if (positionClassificationList.isEmpty) {
      positionClassificationList.assignAll([
        HalterPositionRuleEngineModel(
          name: "Kepala Normal",
          pitchMin: -10,
          pitchMax: 10,
          rollMin: -10,
          rollMax: 10,
          yawMin: -20,
          yawMax: 20,
        ),
        HalterPositionRuleEngineModel(
          name: "Kepala Menunduk",
          pitchMin: 20,
          pitchMax: 90,
        ),
        HalterPositionRuleEngineModel(
          name: "Kepala Menengadah",
          pitchMin: -90,
          pitchMax: -20,
        ),
        HalterPositionRuleEngineModel(
          name: "Kepala Miring Kanan",
          rollMin: 15,
          rollMax: 90,
        ),
        HalterPositionRuleEngineModel(
          name: "Kepala Miring Kiri",
          rollMin: -90,
          rollMax: -15,
        ),
      ]);
      DataTableRuleHalter.savePositionList(positionClassificationList);
    }
  }

  void addBiometricClassification(HalterBiometricRuleEngineModel model) {
    biometricClassificationList.add(model);
    DataTableRuleHalter.saveBiometricList(biometricClassificationList);
  }

  void updateBiometricClassification(int index, HalterBiometricRuleEngineModel model) {
    biometricClassificationList[index] = model;
    DataTableRuleHalter.saveBiometricList(biometricClassificationList);
  }

  void deleteBiometricClassification(int index) {
    biometricClassificationList.removeAt(index);
    DataTableRuleHalter.saveBiometricList(biometricClassificationList);
  }
  
  void addPositionClassification(HalterPositionRuleEngineModel model) {
    positionClassificationList.add(model);
    DataTableRuleHalter.savePositionList(positionClassificationList);
  }

  void updatePositionClassification(int index, HalterPositionRuleEngineModel model) {
    positionClassificationList[index] = model;
    DataTableRuleHalter.savePositionList(positionClassificationList);
  }

  void deletePositionClassification(int index) {
    positionClassificationList.removeAt(index);
    DataTableRuleHalter.savePositionList(positionClassificationList);
  }

  String biometricClassify({
    required double? suhu,
    required int? heartRate,
    required double? spo,
    required int? respirasi,
  }) {
    HalterBiometricRuleEngineModel? bestMatch;
    int bestMatchedCount = -1;
    int bestCheckedCount = 0;

    for (final c in biometricClassificationList) {
      int checked = 0;
      int matched = 0;

      if (c.suhuMin != null || c.suhuMax != null) {
        checked++;
        if ((c.suhuMin == null || (suhu != null && suhu >= c.suhuMin!)) &&
            (c.suhuMax == null || (suhu != null && suhu <= c.suhuMax!))) {
          matched++;
        }
      }
      if (c.heartRateMin != null || c.heartRateMax != null) {
        checked++;
        if ((c.heartRateMin == null ||
                (heartRate != null && heartRate >= c.heartRateMin!)) &&
            (c.heartRateMax == null ||
                (heartRate != null && heartRate <= c.heartRateMax!))) {
          matched++;
        }
      }
      if (c.spoMin != null || c.spoMax != null) {
        checked++;
        if ((c.spoMin == null || (spo != null && spo >= c.spoMin!)) &&
            (c.spoMax == null || (spo != null && spo <= c.spoMax!))) {
          matched++;
        }
      }
      if (c.respirasiMin != null || c.respirasiMax != null) {
        checked++;
        if ((c.respirasiMin == null ||
                (respirasi != null && respirasi >= c.respirasiMin!)) &&
            (c.respirasiMax == null ||
                (respirasi != null && respirasi <= c.respirasiMax!))) {
          matched++;
        }
      }

      // Cari bestMatch: prioritas 1 = semua match, prioritas 2 = terbanyak match
      if (checked > 0 && matched == checked) {
        // Kalau ada yang match semua, langsung ambil (paling ideal)
        return c.name;
      } else if (matched > bestMatchedCount ||
          (matched == bestMatchedCount && checked > bestCheckedCount)) {
        // Simpan yang match terbanyak, jika tie ambil yang checked paling banyak (paling spesifik)
        bestMatch = c;
        bestMatchedCount = matched;
        bestCheckedCount = checked;
      }
    }

    // Kalau ga ada yang perfect match, return yang paling mendekati
    return bestMatch?.name ?? "Tidak Terklasifikasi";
  }

  String positionClassify({
    required int? pitch,
    required int? roll,
    required int? yaw,
  }) {
    HalterPositionRuleEngineModel? bestMatch;
    int bestScore = -1;

    for (final c in positionClassificationList) {
      int checked = 0;
      int matched = 0;

      if (c.pitchMin != null || c.pitchMax != null) {
        checked++;
        if ((c.pitchMin == null || (pitch != null && pitch >= c.pitchMin!)) &&
            (c.pitchMax == null || (pitch != null && pitch <= c.pitchMax!))) {
          matched++;
        }
      }
      if (c.rollMin != null || c.rollMax != null) {
        checked++;
        if ((c.rollMin == null || (roll != null && roll >= c.rollMin!)) &&
            (c.rollMax == null || (roll != null && roll <= c.rollMax!))) {
          matched++;
        }
      }
      if (c.yawMin != null || c.yawMax != null) {
        checked++;
        if ((c.yawMin == null || (yaw != null && yaw >= c.yawMin!)) &&
            (c.yawMax == null || (yaw != null && yaw <= c.yawMax!))) {
          matched++;
        }
      }

      if (checked > 0 && matched == checked) {
        if (checked > bestScore) {
          bestMatch = c;
          bestScore = checked;
        }
      }
    }

    return bestMatch?.name ?? "Tidak Terklasifikasi";
  }
}
