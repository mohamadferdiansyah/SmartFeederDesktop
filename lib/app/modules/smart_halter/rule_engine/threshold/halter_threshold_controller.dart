import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:smart_feeder_desktop/app/data/data_threshold_halter.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_sensor_threshold_model.dart';

class HalterThresholdController extends GetxController {
  var halterThresholds = <String, HalterSensorThresholdModel>{}.obs;
  var nodeRoomThresholds = <String, HalterSensorThresholdModel>{}.obs;

  @override
  void onInit() {
    halterThresholds.value = {
      for (var t in DataSensorThreshold.getThresholds('halter_thresholds'))
        t.sensorName: t
    };
    nodeRoomThresholds.value = {
      for (var t in DataSensorThreshold.getThresholds('node_room_thresholds'))
        t.sensorName: t
    };
    super.onInit();
  }

  void saveHalterThreshold(String sensor, double min, double max) {
    halterThresholds[sensor] = HalterSensorThresholdModel(
      sensorName: sensor,
      minValue: min,
      maxValue: max,
    );
    DataSensorThreshold.saveThresholds(
      'halter_thresholds',
      halterThresholds.values.toList(),
    );
  }

  void saveNodeRoomThreshold(String sensor, double min, double max) {
    nodeRoomThresholds[sensor] = HalterSensorThresholdModel(
      sensorName: sensor,
      minValue: min,
      maxValue: max,
    );
    DataSensorThreshold.saveThresholds(
      'node_room_thresholds',
      nodeRoomThresholds.values.toList(),
    );
  }
}