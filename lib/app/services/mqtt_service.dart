import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:smart_feeder_desktop/app/data/data_controller.dart';
import 'package:smart_feeder_desktop/app/models/feeder/feeder_device_history_model.dart';
import 'package:smart_feeder_desktop/app/modules/smart_feeder/setting/feeder_setting_controller.dart';
import '../models/feeder/feeder_device_detail_model.dart';

class MqttService extends GetxService {
  MqttServerClient? client;

  final DataController dataController = Get.find<DataController>();

  RxList<FeederDeviceDetailModel> get feederDeviceDetailList =>
      dataController.feederDeviceDetailList;

  // Untuk heartbeat timeout
  final Map<String, Timer> _deviceTimeoutTimers = {};

  _PendingFill? _pendingFill;

  Future<void> checkDeviceTimeoutOnStartup({
    Duration timeout = const Duration(seconds: 20),
  }) async {
    final now = DateTime.now();
    for (int i = 0; i < feederDeviceDetailList.length; i++) {
      final detail = feederDeviceDetailList[i];
      if (detail.status != 'off' &&
          now.difference(detail.lastUpdate) > timeout) {
        feederDeviceDetailList[i] = detail.copyWith(
          status: 'off',
          lastUpdate: now,
        );
        print('Tidak Ada Data Masuk');
      }
    }
  }

  // Safe method untuk update status ke FeederSettingController
  void _updateSettingControllerStatus(bool connected) {
    try {
      if (Get.isRegistered<FeederSettingController>()) {
        final settingController = Get.find<FeederSettingController>();
        settingController.mqttConnected.value = connected;
        print(
          'MqttService: Updated FeederSettingController status to $connected',
        );
      } else {
        print(
          'MqttService: FeederSettingController not registered, skipping status update',
        );
      }
    } catch (e) {
      print('MqttService: Error updating FeederSettingController status: $e');
    }
  }

  Future<bool> init({required String host, required int port}) async {
    try {
      // Disconnect existing connection jika ada
      if (client?.connectionStatus?.state == MqttConnectionState.connected) {
        client?.disconnect();
      }

      client = MqttServerClient(
        host,
        'flutter_client_${DateTime.now().millisecondsSinceEpoch}',
      );
      client!.port = port;
      client!.keepAlivePeriod = 60;
      client!.logging(on: false);

      client!.onConnected = () {
        print('MQTT: Connected to $host:$port');
        _updateSettingControllerStatus(true);
      };

      client!.onDisconnected = () {
        print('MQTT: Disconnected from $host:$port');
        _updateSettingControllerStatus(false);
      };

      await client!.connect();

      // Tunggu sampai benar-benar connected
      if (client!.connectionStatus?.state == MqttConnectionState.connected) {
        print('MQTT: Successfully connected to $host:$port');
        client!.subscribe('feeder/status', MqttQos.atMostOnce);
        client!.subscribe('feeder/baterai', MqttQos.atMostOnce);

        client!.updates?.listen((events) {
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

        // Update status setelah berhasil connect dan subscribe
        _updateSettingControllerStatus(true);
        return true;
      } else {
        print(
          'MQTT: Connection failed, status: ${client!.connectionStatus?.state}',
        );
        client?.disconnect();
        _updateSettingControllerStatus(false);
        return false;
      }
    } catch (e) {
      print('MQTT: Connection error: $e');
      client?.disconnect();
      _updateSettingControllerStatus(false);
      return false;
    }
  }

  bool get isConnected =>
      client?.connectionStatus?.state == MqttConnectionState.connected;

  void _handleStatusPayload(Map<String, dynamic> json) {
    final deviceId = json['device_id'] ?? 'Unknown';
    final status = json['status'];
    final destination = json['destination'];
    final amount = json['amount'];
    final timestamp = DateTime.now();

    // Cari device di list, update status/destination/amount
    final index = feederDeviceDetailList.indexWhere(
      (d) => d.deviceId == deviceId,
    );
    final model = FeederDeviceDetailModel.fromStatusJson(json);

    if (index == -1) {
      feederDeviceDetailList.add(model);
    } else {
      feederDeviceDetailList[index] = feederDeviceDetailList[index].copyWith(
        status: model.status,
        destination: model.destination,
        amount: model.amount,
        lastUpdate: timestamp,
      );
    }

    // Logic pengisian
    // if (status == 'delivery' && destination != null && amount != null) {
    //   // Simpan pending fill
    //   final device = dataController.feederDeviceList.firstWhereOrNull(
    //     (d) => d.deviceId == deviceId,
    //   );
    //   final mode = device?.scheduleType ?? 'manual';
    //   _pendingFill = _PendingFill(
    //     deviceId: deviceId,
    //     mode: mode,
    //     roomId: destination,
    //     amount: (amount is num)
    //         ? amount.toDouble()
    //         : double.tryParse(amount.toString()) ?? 0.0,
    //     timestamp: timestamp,
    //   );
    // } else if (status == 'done' &&
    //     destination != null &&
    //     _pendingFill != null) {
    //   // Jika status done dan destination sama dengan pending, tambahkan ke history
    //   if (_pendingFill!.deviceId == deviceId &&
    //       _pendingFill!.roomId == destination) {
    //     dataController.addFillHistory(
    //       FeederDeviceHistoryModel(
    //         timestamp: _pendingFill!.timestamp,
    //         deviceId: _pendingFill!.deviceId,
    //         mode: _pendingFill!.mode,
    //         roomId: _pendingFill!.roomId,
    //         amount: _pendingFill!.amount,
    //       ),
    //     );
    //     _pendingFill = null;
    //   }
    // }

    if (status == 'done') {
      final device = dataController.feederDeviceList.firstWhereOrNull(
        (d) => d.deviceId == deviceId,
      );
      final mode = device?.scheduleType ?? 'manual';
      dataController.addFillHistory(
        FeederDeviceHistoryModel(
          timestamp: timestamp,
          deviceId: deviceId,
          mode: mode,
          roomId: destination,
          amount: (amount is num)
              ? amount.toDouble()
              : double.tryParse(amount.toString()) ?? 0.0,
        ),
      );
      dataController.updateRemainingFeed(
        destination,
        (amount is num)
            ? amount.toDouble()
            : double.tryParse(amount.toString()) ?? 0.0,
      );
    }

    // Reset timeout setiap ada status baru
    _resetDeviceTimeout(deviceId);
  }

  void _handleBateraiPayload(Map<String, dynamic> json) {
    final deviceId = json['device_id'] ?? 'Unknown';
    final index = feederDeviceDetailList.indexWhere(
      (d) => d.deviceId == deviceId,
    );

    if (index == -1) {
      // Jika device belum ada, tambahkan baru dengan data baterai
      feederDeviceDetailList.add(
        FeederDeviceDetailModel(
          detailId: null,
          deviceId: deviceId,
          status: 'ready',
          destination: null,
          amount: null,
          batteryPercent: json['battery_percent'] ?? 0,
          voltage: (json['voltage'] ?? 0.0).toDouble(),
          current: (json['current_mA'] ?? 0.0).toDouble(),
          power: 0.0,
          lastUpdate: DateTime.now(),
        ),
      );
      print('INI baru');
      print(feederDeviceDetailList[index].deviceId);
      print(feederDeviceDetailList[index].batteryPercent);
    } else {
      // Jika sudah ada, update hanya field baterai, voltage, current, lastUpdate
      final old = feederDeviceDetailList[index];
      feederDeviceDetailList[index] = old.copyWith(
        batteryPercent: json['battery_percent'] ?? old.batteryPercent,
        voltage: (json['voltage'] ?? old.voltage).toDouble(),
        current: (json['current_mA'] ?? old.current).toDouble(),
        lastUpdate: DateTime.now(),
        status: old.status == 'off' ? 'ready' : old.status, // <-- tambahkan ini
      );
      print('INI BATRE');
      print(feederDeviceDetailList[index].deviceId);
      print(feederDeviceDetailList[index].status);
      print(feederDeviceDetailList[index].batteryPercent);
    }
    _resetDeviceTimeout(deviceId);
  }

  void _resetDeviceTimeout(String deviceId) {
    _deviceTimeoutTimers[deviceId]?.cancel();
    _deviceTimeoutTimers[deviceId] = Timer(const Duration(seconds: 20), () {
      final index = feederDeviceDetailList.indexWhere(
        (d) => d.deviceId == deviceId,
      );
      if (index != -1) {
        final old = feederDeviceDetailList[index];
        feederDeviceDetailList[index] = old.copyWith(
          status: 'off',
          lastUpdate: DateTime.now(),
        );
      }
    });
  }

  void publishDeliveryRequest({
    required String deviceId,
    required String destination,
    required double amount,
  }) {
    if (!isConnected) {
      print('MQTT: Not connected, cannot send delivery request');
      return;
    }

    final jsonPayload = json.encode({
      "device_id": deviceId,
      "destination": destination,
      "amount": amount,
    });
    publish('feeder/manual', jsonPayload);
    print('MQTT: Published delivery request: $jsonPayload');
  }

  void publishMode({required String deviceId, required String mode}) {
    if (!isConnected) {
      print('MQTT: Not connected, cannot publish mode');
      return;
    }
    final payload = json.encode({"device_id": deviceId, "mode": mode});
    publish('feeder/mode', payload);
    print('MQTT: Published mode "$mode" for $deviceId');
  }

  void publish(String topic, String payload) {
    if (!isConnected) {
      print('MQTT: Not connected, cannot publish');
      return;
    }

    final builder = MqttClientPayloadBuilder();
    builder.addString(payload);
    client!.publishMessage(topic, MqttQos.atMostOnce, builder.payload!);
    print('MQTT: Published "$payload" to $topic');
  }

  void disconnect() {
    if (client?.connectionStatus?.state == MqttConnectionState.connected) {
      client!.disconnect();
      print('MQTT: Disconnected');
    }
    _updateSettingControllerStatus(false);
  }

  @override
  void onClose() {
    // Cleanup timers
    for (final timer in _deviceTimeoutTimers.values) {
      timer.cancel();
    }
    _deviceTimeoutTimers.clear();

    // Disconnect MQTT
    disconnect();
    super.onClose();
  }
}

class _PendingFill {
  final String deviceId;
  final String mode;
  final String roomId;
  final double amount;
  final DateTime timestamp;

  _PendingFill({
    required this.deviceId,
    required this.mode,
    required this.roomId,
    required this.amount,
    required this.timestamp,
  });
}
