import 'package:get/get.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:smart_feeder_desktop/app/data/data_controller.dart';
import '../models/feeder_device_model.dart';

class MqttService extends GetxService {
  late MqttServerClient client;

  final DataController dataController = Get.find<DataController>();

  RxList<FeederDeviceModel> get feederDeviceList =>
      dataController.feederDeviceList;

  Future<MqttService> init() async {
    client = MqttServerClient(
      'broker.emqx.io',
      'flutter_client_${DateTime.now().millisecondsSinceEpoch}',
    );
    client.port = 1883;
    client.keepAlivePeriod = 60;
    client.logging(on: false);

    client.onConnected = () => print('MQTT: Connected');
    client.onDisconnected = () => print('MQTT: Disconnected');

    try {
      await client.connect();
      print('MQTT: Connected to broker.emqx.io');
      // client.subscribe('feeder/status', MqttQos.atMostOnce);
      client.subscribe('feeder/ina219', MqttQos.atMostOnce);

      client.updates?.listen((events) {
        final recMess = events[0].payload as MqttPublishMessage;
        final payload = MqttPublishPayload.bytesToStringAsString(
          recMess.payload.message,
        );
        print('MQTT Payload: ${events[0].topic} $payload');

        // if (events[0].topic == 'feeder/status') {
        //   _handleStatusPayload(payload);
        // } else if (events[0].topic == 'feeder/ina219') {
        //   _handleIna219Payload(payload);
        // }

        if (events[0].topic == 'feeder/ina219') {
          _handleIna219Payload(payload);
        }
      });
    } catch (e) {
      print('MQTT: Connection error: $e');
      client.disconnect();
    }
    return this;
  }

  // void _handleStatusPayload(String payload) {
  //   final regex = RegExp(r'status (\w+) battery (\d+)');
  //   final match = regex.firstMatch(payload);
  //   if (match != null) {
  //     final status = match.group(1) ?? 'unknown';
  //     final battery = int.tryParse(match.group(2) ?? '0') ?? 0;
  //     final deviceId = 'feeder1';
  //     final existing = feederDeviceList.firstWhereOrNull(
  //       (d) => d.deviceId == deviceId,
  //     );
  //     if (existing == null) {
  //       feederDeviceList.add(
  //         FeederDeviceModel(
  //           deviceId: deviceId,
  //           status: status,
  //           batteryPercent: battery,
  //         ),
  //       );
  //     } else {
  //       existing.status.value = status;
  //       existing.batteryPercent.value = battery;
  //       feederDeviceList.refresh();
  //     }
  //   }
  // }

  void _handleIna219Payload(String payload) {
    // Format: V=8.19V I=0.0mA P=0.0mW
    final regex = RegExp(r'V=([\d\.]+)V I=([\d\.]+)mA P=([\d\.]+)mW');
    final match = regex.firstMatch(payload);
    if (match != null) {
      final volt = double.tryParse(match.group(1) ?? '0') ?? 0.0;
      print('MqttService: Voltase = $volt');
      final current = double.tryParse(match.group(2) ?? '0') ?? 0.0;
      final power = double.tryParse(match.group(3) ?? '0') ?? 0.0;

      // Konversi voltase ke persen baterai (misal: 6V = 0%, 8.4V = 100%)
      final batteryPercent = _voltToPercent(volt, minVolt: 3.0, maxVolt: 12.0);

      final deviceId = 'feeder1'; // kamu bisa ganti jika ada multiple device
      final existing = feederDeviceList.firstWhereOrNull(
        (d) => d.deviceId == deviceId,
      );
      if (existing == null) {
        feederDeviceList.add(
          FeederDeviceModel(
            deviceId: deviceId,
            status: 'ready',
            batteryPercent: batteryPercent,
            voltase: volt,
            current: current,
            power: power,
          ),
        );
      } else {
        existing.voltase.value = volt;
        existing.current.value = current;
        existing.power.value = power;
        existing.batteryPercent.value = batteryPercent;
        feederDeviceList.refresh();
      }
    }
  }

  int _voltToPercent(
    double volt, {
    double minVolt = 3.0,
    double maxVolt = 12.0,
  }) {
    // Linear interpolasi, clamp 0-100
    double percent = ((volt - minVolt) / (maxVolt - minVolt)) * 100.0;
    percent = percent.clamp(0, 100);
    return percent.round();
  }

  void activateDevice(String roomId) {
    publish('feeder/control', 'ISI $roomId');
    print('MQTT: Published "ISI $roomId" to feeder/control');

    final device = feederDeviceList.firstWhereOrNull(
      (d) => d.deviceId == 'feeder1',
    );

    if (device != null) {
      device.status.value = 'process';
      feederDeviceList.refresh();
    }
  }

  void publish(String topic, String payload) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(payload);
    client.publishMessage(topic, MqttQos.atMostOnce, builder.payload!);
    print('MQTT: Published "$payload" to $topic');
  }

  void disconnect() {
    client.disconnect();
    print('MQTT: Disconnected');
  }
}
