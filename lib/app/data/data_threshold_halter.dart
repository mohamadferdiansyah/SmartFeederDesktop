import 'package:get_storage/get_storage.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_sensor_threshold_model.dart';

class DataSensorThreshold {
  static final _box = GetStorage();

  static List<HalterSensorThresholdModel> getThresholds(String key) {
    final list = _box.read(key) as List<dynamic>?;
    if (list == null) {
      // Default threshold jika belum ada di storage
      if (key == 'halter_thresholds') {
        return [
          HalterSensorThresholdModel(
            sensorName: 'temperature',
            minValue: 30,
            maxValue: 45,
          ),
          HalterSensorThresholdModel(
            sensorName: 'heartRate',
            minValue: 28,
            maxValue: 60,
          ),
          HalterSensorThresholdModel(
            sensorName: 'spo',
            minValue: 92,
            maxValue: 100,
          ),
          HalterSensorThresholdModel(
            sensorName: 'respiratoryRate',
            minValue: 10,
            maxValue: 35,
          ),
        ];
      }
      if (key == 'node_room_thresholds') {
        return [
          HalterSensorThresholdModel(
            sensorName: 'temperature',
            minValue: 18,
            maxValue: 40,
          ),
          HalterSensorThresholdModel(
            sensorName: 'humidity',
            minValue: 35,
            maxValue: 90,
          ),
          HalterSensorThresholdModel(
            sensorName: 'lightIntensity',
            minValue: 15,
            maxValue: 100,
          ),
        ];
      }
      return [];
    }
    return list.map((e) => HalterSensorThresholdModel.fromJson(e)).toList();
  }

  static void saveThresholds(
    String key,
    List<HalterSensorThresholdModel> thresholds,
  ) {
    _box.write(key, thresholds.map((e) => e.toJson()).toList());
  }

  static double defaultMin(String sensor) {
    switch (sensor) {
      case 'temperature':
        return 30;
      case 'heartRate':
        return 28;
      case 'spo':
        return 92;
      case 'respiratoryRate':
        return 10;
      default:
        return 0;
    }
  }

  static double defaultMax(String sensor) {
    switch (sensor) {
      case 'temperature':
        return 45;
      case 'heartRate':
        return 60;
      case 'spo':
        return 100;
      case 'respiratoryRate':
        return 35;
      default:
        return 999;
    }
  }
}
