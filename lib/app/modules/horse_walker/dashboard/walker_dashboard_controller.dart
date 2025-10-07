import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:smart_feeder_desktop/app/services/mqtt_walker_service.dart';

class WalkerDashboardController extends GetxController {
  late MqttWalkerService _mqttWalkerService;

  // Form controllers
  final idDeviceCtrl = TextEditingController(text: '1');
  final speedCtrl = TextEditingController(text: '255');
  final durationCtrl = TextEditingController(text: '10');

  // Form state
  final controlMotor = true.obs;
  final rotation = false.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _mqttWalkerService = Get.find<MqttWalkerService>();
  }

  @override
  void onClose() {
    idDeviceCtrl.dispose();
    speedCtrl.dispose();
    durationCtrl.dispose();
    super.onClose();
  }

  void setControlMotor(bool value) {
    controlMotor.value = value;
  }

  void setRotation(bool value) {
    rotation.value = value;
  }

  Future<void> sendWalkerCommand() async {
    if (!_mqttWalkerService.isConnected) {
      Get.snackbar(
        'Error',
        'Walker MQTT tidak terhubung',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Validasi input
    final idDevice = int.tryParse(idDeviceCtrl.text.trim());
    final speed = int.tryParse(speedCtrl.text.trim());
    final duration = int.tryParse(durationCtrl.text.trim());

    if (idDevice == null || speed == null || duration == null) {
      Get.snackbar(
        'Error',
        'Pastikan semua field terisi dengan benar',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (speed < 1 || speed > 2000) {
      Get.snackbar(
        'Error',
        'Kecepatan harus antara 1-2000 RPM',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (duration < 1 || duration > 7200) {
      Get.snackbar(
        'Error',
        'Durasi harus antara 1-7200 detik',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      // Publish ke topic walker/control
      final payload = {
        'header': 'SHWIPB',
        'id_device': idDevice,
        'control_motor': controlMotor.value,
        'rotation': rotation.value,
        'speed': speed,
        'duration': duration,
      };

      _mqttWalkerService.client!.publishMessage(
        'walker/control',
        MqttQos.atLeastOnce,
        MqttClientPayloadBuilder()
            .addString(json.encode(payload))
            .payload!,
      );

      print('Walker Command Sent: $payload');

      Get.snackbar(
        'Berhasil',
        'Perintah walker berhasil dikirim',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error sending walker command: $e');
      Get.snackbar(
        'Error',
        'Gagal mengirim perintah walker: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void resetForm() {
    idDeviceCtrl.text = '1';
    speedCtrl.text = '255';
    durationCtrl.text = '10';
    controlMotor.value = true;
    rotation.value = false;
  }

  void stopWalker() {
    if (!_mqttWalkerService.isConnected) {
      Get.snackbar(
        'Error',
        'Walker MQTT tidak terhubung',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final idDevice = int.tryParse(idDeviceCtrl.text.trim()) ?? 1;

    try {
      final payload = {
        'header': 'SHWIPB',
        'id_device': idDevice,
        'control_motor': false,
        'rotation': false,
        'speed': 0,
        'duration': 0,
      };

      _mqttWalkerService.client!.publishMessage(
        'walker/control',
        MqttQos.atLeastOnce,
        MqttClientPayloadBuilder()
            .addString(json.encode(payload))
            .payload!,
      );

      print('Walker Stop Command Sent: $payload');

      Get.snackbar(
        'Berhasil',
        'Perintah stop walker berhasil dikirim',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error stopping walker: $e');
      Get.snackbar(
        'Error',
        'Gagal mengirim perintah stop: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}