import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:smart_feeder_desktop/app/data/data_controller.dart';
import 'package:smart_feeder_desktop/app/models/walker/walker_device_model.dart';
import 'package:smart_feeder_desktop/app/modules/horse_walker/setting/walker_setting_controller.dart';

class MqttWalkerService extends GetxService {
  MqttServerClient? client;

  // Untuk heartbeat timeout
  final Map<String, Timer> _deviceTimeoutTimers = {};

  // Data controller
  final DataController dataController = Get.find<DataController>();

  // Getter untuk walker status list
  RxList<WalkerDeviceModel> get walkerStatusList =>
      dataController.walkerStatusList;

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
      print(
        'MqttWalkerService: Error updating WalkerSettingController status: $e',
      );
    }
  }

  // Handle walker status langsung di service
  Future<void> addOrUpdateWalkerStatus(WalkerDeviceModel status) async {
    final index = walkerStatusList.indexWhere(
      (w) => w.deviceId == status.deviceId,
    );

    if (index != -1) {
      walkerStatusList[index] = status;
    } else {
      walkerStatusList.add(status);
    }

    print('Walker Status Updated: ${status.toString()}');
  }

  // Helper method untuk mendapatkan status berdasarkan device ID
  WalkerDeviceModel? getWalkerStatusByDeviceId(String deviceId) {
    try {
      return walkerStatusList.firstWhere((w) => w.deviceId == deviceId);
    } catch (e) {
      return null;
    }
  }

  // Helper method untuk mendapatkan walker yang aktif
  List<WalkerDeviceModel> getActiveWalkers() {
    return walkerStatusList.where((w) => w.status != 'OFF').toList();
  }

  // Helper method untuk mendapatkan status berdasarkan header + id
  String getWalkerStatusById(int idDevice) {
    final deviceId = 'SHWIPB$idDevice';
    final status = getWalkerStatusByDeviceId(deviceId);
    return status?.status ?? 'OFF';
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
    try {
      // Validasi format data
      if (json['header'] != 'SHWIPB') {
        print('Walker MQTT: Invalid header: ${json['header']}');
        return;
      }

      final header = json['header'];
      final idDevice = json['id_device']?.toString();
      final status = json['status']?.toString().toUpperCase();

      if (idDevice == null || idDevice.isEmpty || status == null) {
        print('Walker MQTT: Missing id_device or status');
        return;
      }

      // Gabungkan header dengan id_device
      final deviceId = '$header$idDevice';

      // Buat model walker status
      final walkerStatus = WalkerDeviceModel(
        deviceId: deviceId,
        status: status,
        lastUpdate: DateTime.now(),
      );

      // Update langsung di service
      addOrUpdateWalkerStatus(walkerStatus);

      // Reset timeout timer untuk device ini
      _resetDeviceTimeout(deviceId);

      print('Walker Status Updated: Device $deviceId is $status');

      // Handle status khusus
      switch (status) {
        case 'ON':
          print('Walker Device $deviceId is online');
          break;
        case 'START':
          print('Walker Device $deviceId started walking');
          break;
        case 'STOP':
          print('Walker Device $deviceId stopped walking');
          break;
        default:
          print('Walker Device $deviceId unknown status: $status');
      }
    } catch (e) {
      print('Walker MQTT: Error handling status payload: $e');
    }
  }

  void _handleControlPayload(Map<String, dynamic> json) {
    try {
      final header = json['header'] ?? 'SHWIPB';
      final idDevice = json['id_device']?.toString() ?? 'Unknown';
      final deviceId = '$header$idDevice';

      print('Walker MQTT: Received control confirmation from device $deviceId');
      print('Walker MQTT: Control payload: $json');
    } catch (e) {
      print('Walker MQTT: Error handling control payload: $e');
    }
  }

  void _resetDeviceTimeout(String deviceId) {
    // Cancel timer lama jika ada
    _deviceTimeoutTimers[deviceId]?.cancel();

    // Set timer baru untuk 2 menit
    _deviceTimeoutTimers[deviceId] = Timer(
      const Duration(seconds: 20),
      () async {
        // Set status device jadi OFF jika tidak ada heartbeat
        final offlineStatus = WalkerDeviceModel(
          deviceId: deviceId,
          status: 'OFF',
          lastUpdate: DateTime.now(),
        );

        await addOrUpdateWalkerStatus(offlineStatus);
        print('Walker Device $deviceId set to OFFLINE due to timeout');
      },
    );
  }

  void checkDeviceTimeoutOnStartup({
    Duration timeout = const Duration(minutes: 2),
  }) {
    print('Walker MQTT: Setting up device timeout monitoring');

    // Cek semua device yang ada dan set timeout
    for (final walkerStatus in walkerStatusList) {
      if (walkerStatus.status != 'OFF') {
        final timeSinceUpdate = DateTime.now().difference(
          walkerStatus.lastUpdate,
        );

        if (timeSinceUpdate > timeout) {
          // Device sudah timeout, set jadi OFF
          final offlineStatus = walkerStatus.copyWith(
            status: 'OFF',
            lastUpdate: DateTime.now(),
          );
          addOrUpdateWalkerStatus(offlineStatus);
        } else {
          // Device masih valid, set timer untuk sisa waktu
          final remainingTime = timeout - timeSinceUpdate;
          _deviceTimeoutTimers[walkerStatus
              .deviceId] = Timer(remainingTime, () async {
            final offlineStatus = walkerStatus.copyWith(
              status: 'OFF',
              lastUpdate: DateTime.now(),
            );
            await addOrUpdateWalkerStatus(offlineStatus);
            print(
              'Walker Device ${walkerStatus.deviceId} set to OFFLINE due to timeout',
            );
          });
        }
      }
    }
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
      MqttClientPayloadBuilder().addString(json.encode(payload)).payload!,
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
