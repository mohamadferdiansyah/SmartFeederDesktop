import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:smart_feeder_desktop/app/modules/horse_walker/setting/walker_setting_controller.dart';

class MqttWalkerService extends GetxService {
  MqttServerClient? client;

  // Untuk heartbeat timeout
  final Map<String, Timer> _deviceTimeoutTimers = {};

  // Safe method untuk update status ke WalkerSettingController
  void _updateSettingControllerStatus(bool connected) {
    try {
      if (Get.isRegistered<WalkerSettingController>()) {
        final settingController = Get.find<WalkerSettingController>();
        settingController.mqttConnected.value = connected;
        print(
          'MqttWalkerService: Updated WalkerSettingController status to $connected',
        );
      } else {
        print(
          'MqttWalkerService: WalkerSettingController not registered, skipping status update',
        );
      }
    } catch (e) {
      print('MqttWalkerService: Error updating WalkerSettingController status: $e');
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
        'walker_client_${DateTime.now().millisecondsSinceEpoch}',
      );
      client!.port = port;
      client!.keepAlivePeriod = 60;
      client!.logging(on: false);

      client!.onConnected = () {
        print('Walker MQTT: Connected to $host:$port');
        _updateSettingControllerStatus(true);
      };

      client!.onDisconnected = () {
        print('Walker MQTT: Disconnected from $host:$port');
        _updateSettingControllerStatus(false);
      };

      client!.onUnsubscribed = (topic) {
        print('Walker MQTT: Unsubscribed from $topic');
      };

      client!.onSubscribed = (topic) {
        print('Walker MQTT: Subscribed to $topic');
      };

      client!.onSubscribeFail = (topic) {
        print('Walker MQTT: Failed to subscribe to $topic');
        _updateSettingControllerStatus(false);
      };

      await client!.connect();

      // Tunggu sampai benar-benar connected
      if (client!.connectionStatus?.state == MqttConnectionState.connected) {
        print('Walker MQTT: Successfully connected to $host:$port');
        client!.subscribe('walker/status', MqttQos.atMostOnce);
        client!.subscribe('walker/control', MqttQos.atMostOnce);

        client!.updates?.listen((events) {
          final topic = events[0].topic;
          final recMess = events[0].payload as MqttPublishMessage;
          final payloadStr = MqttPublishPayload.bytesToStringAsString(
            recMess.payload.message,
          );

          print('Walker MQTT Payload: $topic $payloadStr');
          try {
            final payload = json.decode(payloadStr);
            if (topic == 'walker/status') {
              _handleStatusPayload(payload);
            }
            if (topic == 'walker/control') {
              _handleControlPayload(payload);
            }
          } catch (e) {
            print('Walker MQTT: Error parsing JSON: $e');
          }
        });

        // Update status setelah berhasil connect dan subscribe
        _updateSettingControllerStatus(true);
        return true;
      } else {
        print(
          'Walker MQTT: Connection failed, status: ${client!.connectionStatus?.state}',
        );
        client?.disconnect();
        _updateSettingControllerStatus(false);
        return false;
      }
    } catch (e) {
      print('Walker MQTT: Connection error: $e');
      client?.disconnect();
      _updateSettingControllerStatus(false);
      return false;
    }
  }

  bool get isConnected =>
      client?.connectionStatus?.state == MqttConnectionState.connected;

  void _handleStatusPayload(Map<String, dynamic> json) {
    // final deviceId = json['device_id'] ?? 'Unknown';
    // final timestamp = json['timestamp'] ?? DateTime.now().toIso8601String();
    
    print('MASUK DATA STATUS NYA JIR');
    // Handle walker status logic here
  }

  void _handleControlPayload(Map<String, dynamic> json) {
    // final deviceId = json['device_id'] ?? 'Unknown';
    // final timestamp = json['timestamp'] ?? DateTime.now().toIso8601String();
    
    print('MASUK DATA CONTROL NYA JIR');
    // Handle walker data logic here
  }

  void checkDeviceTimeoutOnStartup({required Duration timeout}) {
    print('Walker MQTT: Setting up device timeout monitoring');
    // Implementation for device timeout monitoring
  }

  void publishWalkerCommand({
    required String deviceId,
    required String command,
    Map<String, dynamic>? parameters,
  }) {
    if (!isConnected) {
      print('Walker MQTT: Not connected, cannot publish command');
      return;
    }

    final payload = {
      'device_id': deviceId,
      'command': command,
      'parameters': parameters ?? {},
      'timestamp': DateTime.now().toIso8601String(),
    };

    final topic = 'walker/command/$deviceId';
    client!.publishMessage(
      topic,
      MqttQos.atLeastOnce,
      MqttClientPayloadBuilder()
          .addString(json.encode(payload))
          .payload!,
    );

    print('Walker MQTT: Published command to $topic: $payload');
  }

  void disconnect() {
    try {
      // Cancel all device timeout timers
      for (final timer in _deviceTimeoutTimers.values) {
        timer.cancel();
      }
      _deviceTimeoutTimers.clear();

      client?.disconnect();
      _updateSettingControllerStatus(false);
      print('Walker MQTT: Disconnected successfully');
    } catch (e) {
      print('Walker MQTT: Error during disconnect: $e');
    }
  }
}