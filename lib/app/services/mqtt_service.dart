import 'package:get/get.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import '../models/feeder_device_model.dart';

class MqttService extends GetxService {
  late MqttServerClient client;
  final RxList<FeederDeviceModel> feederDeviceList = <FeederDeviceModel>[].obs;

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
      // Subscribe ke topic status (misal: feeder/status)
      client.subscribe('feeder/status', MqttQos.atMostOnce);

      client.updates?.listen((events) {
        final recMess = events[0].payload as MqttPublishMessage;
        final payload = MqttPublishPayload.bytesToStringAsString(
          recMess.payload.message,
        );
        print('MQTT Payload: $payload');

        // Contoh payload: "status ready battery 80"
        if (events[0].topic == 'feeder/status') {
          _handleStatusPayload(payload);
        }
      });
    } catch (e) {
      print('MQTT: Connection error: $e');
      client.disconnect();
    }
    return this;
  }

  void _handleStatusPayload(String payload) {
    // Parsing sederhana, kamu bisa ganti sesuai format alat
    // Misal: "status ready battery 80"
    final regex = RegExp(r'status (\w+) battery (\d+)');
    final match = regex.firstMatch(payload);
    if (match != null) {
      final status = match.group(1) ?? 'unknown';
      final battery = int.tryParse(match.group(2) ?? '0') ?? 0;

      // Asumsikan cuma ada 1 alat, id = 'feeder1' (bisa diubah kalau nanti ada id)
      final deviceId = 'feeder1';
      final existing = feederDeviceList.firstWhereOrNull(
        (d) => d.deviceId == deviceId,
      );
      if (existing == null) {
        feederDeviceList.add(
          FeederDeviceModel(
            deviceId: deviceId,
            status: status,
            batteryPercent: battery,
          ),
        );
      } else {
        existing.status.value = status;
        existing.batteryPercent.value = battery;
        feederDeviceList.refresh();
      }
    }
  }

  /// Kalau mau aktifkan device
  void activateDevice(String roomId) {
    // final builder = MqttClientPayloadBuilder();
    // builder.addString('ISI $roomId');
    // client.publishMessage('feeder/control', MqttQos.atMostOnce, builder.payload!);

    publish('feeder/control', 'ISI $roomId');
    print('MQTT: Published "ISI $roomId" to feeder/control');

    // Set status process (asumsi: deviceId 'feeder1')
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
