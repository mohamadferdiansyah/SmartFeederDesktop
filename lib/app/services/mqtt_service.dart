// import 'dart:async';

// import 'package:get/get.dart';
// import 'package:mqtt_client/mqtt_client.dart';
// import 'package:mqtt_client/mqtt_server_client.dart';
// import 'package:smart_feeder_desktop/app/data/data_controller.dart';
// import '../models/feeder/feeder_device_model.dart';

// class MqttService extends GetxService {
//   late MqttServerClient client;

//   final DataController dataController = Get.find<DataController>();

// RxList<FeederDeviceDetailModel> get feederCarDeviceList =>
//     dataController.feederCarDeviceList;

//   final Map<String, Timer> _deviceTimeoutTimers = {};

//   void _resetDeviceTimeout(String deviceId) {
//     _deviceTimeoutTimers[deviceId]?.cancel();
//     _deviceTimeoutTimers[deviceId] = Timer(const Duration(minutes: 5), () {
//       final index = feederCarDeviceList.indexWhere((d) => d.deviceId == deviceId);
//       if (index != -1) {
//         final old = feederCarDeviceList[index];
//         feederCarDeviceList[index] = FeederDeviceDetailModel(
//           deviceId: old.deviceId,
//           status: 'off',
//           batteryPercent: old.batteryPercent,
//           voltage: old.voltage,
//           current: old.current,
//           power: old.power,
//         );
//       }
//     });
//   }

//   Future<MqttService> init() async {
//     client = MqttServerClient(
//       'broker.emqx.io',
//       'flutter_client_${DateTime.now().millisecondsSinceEpoch}',
//     );
//     client.port = 1883;
//     client.keepAlivePeriod = 60;
//     client.logging(on: false);

//     client.onConnected = () => print('MQTT: Connected');
//     client.onDisconnected = () => print('MQTT: Disconnected');

//     try {
//       await client.connect();
//       print('MQTT: Connected to broker.emqx.io');
//       client.subscribe('feeder/status', MqttQos.atMostOnce);
//       client.subscribe('feeder/ina219', MqttQos.atMostOnce);
//       client.subscribe('feeder/baterai', MqttQos.atMostOnce);

//       client.updates?.listen((events) {
//         final recMess = events[0].payload as MqttPublishMessage;
//         final payload = MqttPublishPayload.bytesToStringAsString(
//           recMess.payload.message,
//         );
//         print('MQTT Payload: ${events[0].topic} $payload');

//         if (events[0].topic == 'feeder/status') {
//           // _handleStatusPayload(payload);
//           // Uncomment if you want to handle status payloads
//           print('MQTT: Status payload received: $payload');
//         }

//         if (events[0].topic == 'feeder/ina219') {
//           _handleIna219Payload(payload);
//         }

//         if (events[0].topic == 'feeder/baterai') {
//           _handleBateraiPayload(payload);
//           print('MQTT: Baterai payload received: $payload');
//         }
//       });
//     } catch (e) {
//       print('MQTT: Connection error: $e');
//       client.disconnect();
//     }
//     return this;
//   }

//   // void _handleStatusPayload(String payload) {
//   //   _resetDeviceTimeout('feeder1');
//   //       // Update status ke 'on'
//   //       final index = feederCarDeviceList.indexWhere((d) => d.deviceId == 'feeder1');
//   //       if (index == -1) {
//   //         feederCarDeviceList.add(
//   //           FeederDeviceDetailModel(
//   //             deviceId: 'feeder1',
//   //             status: 'on',
//   //             batteryPercent: 0,
//   //           ),
//   //         );
//   //       } else {
//   //         final old = feederCarDeviceList[index];
//   //         feederCarDeviceList[index] = FeederDeviceDetailModel(
//   //           deviceId: old.deviceId,
//   //           status: 'on',
//   //           batteryPercent: old.batteryPercent,
//   //           voltage: old.voltage,
//   //           current: old.current,
//   //           power: old.power,
//   //         );
//   //       }
//   // }

//   void _handleBateraiPayload(String payload) {
//     // Contoh: "Tegangan: 9.53 V, Arus: 100.10 mA, Daya: 954.00 mW, Persen: 100%"
//     final regex = RegExp(
//       r'Tegangan: ([\d.]+) V, Arus: ([\d.]+) mA, Daya: ([\d.]+) mW, Persen: ([\d.]+)%',
//     );
//     final match = regex.firstMatch(payload);
//     if (match != null) {
//       final volt = double.tryParse(match.group(1) ?? '0.0') ?? 0.0;
//       final current = double.tryParse(match.group(2) ?? '0.0') ?? 0.0;
//       final power = double.tryParse(match.group(3) ?? '0.0') ?? 0.0;
//       final percent = double.tryParse(match.group(4) ?? '0.0') ?? 0.0;

//       final deviceId = 'feeder1'; // Ubah jika ada multi-device
//       final index = feederCarDeviceList.indexWhere((d) => d.deviceId == deviceId);

//       if (index == -1) {
//         feederCarDeviceList.add(
//           FeederDeviceDetailModel(
//             deviceId: deviceId,
//             status: 'ready',
//             batteryPercent: percent.round(),
//             voltage: volt,
//             current: current,
//             power: power,
//           ),
//         );
//       } else {
//         final old = feederCarDeviceList[index];
//         feederCarDeviceList[index] = FeederDeviceDetailModel(
//           deviceId: deviceId,
//           status: old.status,
//           batteryPercent: percent.round(),
//           voltage: volt,
//           current: current,
//           power: power,
//         );
//       }
//     } else {
//       print('MQTT: Baterai payload tidak sesuai format!');
//     }
//   }

//   void _handleIna219Payload(String payload) {
//     // Format: V=8.19V I=0.0mA P=0.0mW
//     final regex = RegExp(r'V=([\d\.]+)V I=([\d\.]+)mA P=([\d\.]+)mW');
//     final match = regex.firstMatch(payload);
//     if (match != null) {
//       final volt = double.tryParse(match.group(1) ?? '0') ?? 0.0;
//       print('MqttService: Voltase = $volt');
//       final current = double.tryParse(match.group(2) ?? '0') ?? 0.0;
//       final power = double.tryParse(match.group(3) ?? '0') ?? 0.0;

//       // Konversi voltase ke persen baterai (misal: 6V = 0%, 8.4V = 100%)
//       final batteryPercent = _voltToPercent(volt, minVolt: 3.0, maxVolt: 12.0);

//       final deviceId = 'feeder1'; // kamu bisa ganti jika ada multiple device
//       final index = feederCarDeviceList.indexWhere((d) => d.deviceId == deviceId);
//       if (index == -1) {
//         feederCarDeviceList.add(
//           FeederDeviceDetailModel(
//             deviceId: deviceId,
//             status: 'ready',
//             batteryPercent: batteryPercent,
//             voltage: volt,
//             current: current,
//             power: power,
//           ),
//         );
//       } else {
//         final old = feederCarDeviceList[index];
//         feederCarDeviceList[index] = FeederDeviceDetailModel(
//           deviceId: old.deviceId,
//           status: old.status,
//           batteryPercent: batteryPercent,
//           voltage: volt,
//           current: current,
//           power: power,
//         );
//       }
//     }
//   }

//   int _voltToPercent(
//     double volt, {
//     double minVolt = 3.0,
//     double maxVolt = 12.0,
//   }) {
//     // Linear interpolasi, clamp 0-100
//     double percent = ((volt - minVolt) / (maxVolt - minVolt)) * 100.0;
//     percent = percent.clamp(0, 100);
//     return percent.round();
//   }

//   void activateDevice(String roomId) {
//     publish('feeder/control', 'ISI $roomId');
//     print('MQTT: Published "ISI $roomId" to feeder/control');

//     final index = feederCarDeviceList.indexWhere((d) => d.deviceId == 'feeder1');
//     if (index != -1) {
//       final old = feederCarDeviceList[index];
//       feederCarDeviceList[index] = FeederDeviceDetailModel(
//         deviceId: old.deviceId,
//         status: 'process',
//         batteryPercent: old.batteryPercent,
//         voltage: old.voltage,
//         current: old.current,
//         power: old.power,
//       );
//     }
//   }

//   void publish(String topic, String payload) {
//     final builder = MqttClientPayloadBuilder();
//     builder.addString(payload);
//     client.publishMessage(topic, MqttQos.atMostOnce, builder.payload!);
//     print('MQTT: Published "$payload" to $topic');
//   }

//   void disconnect() {
//     client.disconnect();
//     print('MQTT: Disconnected');
//   }
// }

import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:smart_feeder_desktop/app/data/data_controller.dart';
import '../models/feeder/feeder_device_detail_model.dart';

class MqttService extends GetxService {
  late MqttServerClient client;

  final DataController dataController = Get.find<DataController>();

  RxList<FeederDeviceDetailModel> get feederCarDeviceList =>
      dataController.feederCarDeviceList;
  // Untuk heartbeat timeout
  final Map<String, Timer> _deviceTimeoutTimers = {};

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
      client.subscribe('feeder/status', MqttQos.atMostOnce);
      client.subscribe('feeder/baterai', MqttQos.atMostOnce);

      client.updates?.listen((events) {
        final topic = events[0].topic;
        final recMess = events[0].payload as MqttPublishMessage;
        final payloadStr = MqttPublishPayload.bytesToStringAsString(
          recMess.payload.message,
        );

        print('MQTT Payload: $topic $payloadStr');
        try {
          final payload = json.decode(payloadStr);
          if (topic == 'feeder/status') {
            _handleStatusPayload(payload);
          }
          if (topic == 'feeder/baterai') {
            _handleBateraiPayload(payload);
          }
        } catch (e) {
          print('MQTT: Error parsing JSON: $e');
        }
      });
    } catch (e) {
      print('MQTT: Connection error: $e');
      client.disconnect();
    }
    return this;
  }

  void _handleStatusPayload(Map<String, dynamic> json) {
    final deviceId = json['device_id'] ?? 'Unknown';
    final timestamp = json['timestamp'] ?? DateTime.now().toIso8601String();

    // Cari device di list, update status/destination/amount
    final index = feederCarDeviceList.indexWhere((d) => d.deviceId == deviceId);
    final model = FeederDeviceDetailModel.fromStatusJson(json);

    if (index == -1) {
      feederCarDeviceList.add(model);
    } else {
      feederCarDeviceList[index] = feederCarDeviceList[index].copyWith(
        status: model.status,
        destination: model.destination,
        amount: model.amount,
        lastUpdate: DateTime.parse(timestamp),
      );
    }

    // Reset timeout setiap ada status baru
    _resetDeviceTimeout(deviceId);
  }

  void _handleBateraiPayload(Map<String, dynamic> json) {
    final deviceId = json['device_id'] ?? 'Unknown';
    final index = feederCarDeviceList.indexWhere((d) => d.deviceId == deviceId);
    if (index == -1) {
      // Tambahkan baru, status langsung 'ready'
      feederCarDeviceList.add(
        FeederDeviceDetailModel.fromBateraiJson(
          json,
          null,
        ).copyWith(status: 'ready'),
      );
    } else {
      final old = feederCarDeviceList[index];
      feederCarDeviceList[index] = FeederDeviceDetailModel.fromBateraiJson(
        json,
        old,
      );
    }
    _resetDeviceTimeout(deviceId);
  }

  void _resetDeviceTimeout(String deviceId) {
    _deviceTimeoutTimers[deviceId]?.cancel();
    _deviceTimeoutTimers[deviceId] = Timer(const Duration(minutes: 1), () {
      final index = feederCarDeviceList.indexWhere(
        (d) => d.deviceId == deviceId,
      );
      if (index != -1) {
        final old = feederCarDeviceList[index];
        feederCarDeviceList[index] = old.copyWith(
          status: 'off',
          lastUpdate: DateTime.now(),
        );
      }
    });
  }

  void sendDeliveryRequest({
    required String destination,
    required double amount,
  }) {
    final jsonPayload = json.encode({
      "destination": destination,
      "amount": amount,
    });
    publish('feeder/control', jsonPayload);
    print('MQTT: Published delivery request: $jsonPayload');
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
