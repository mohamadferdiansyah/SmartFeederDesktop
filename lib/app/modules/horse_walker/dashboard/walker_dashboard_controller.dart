import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:smart_feeder_desktop/app/data/data_controller.dart';
import 'package:smart_feeder_desktop/app/models/horse_model.dart';
import 'package:smart_feeder_desktop/app/models/walker/walker_device_model.dart';
import 'package:smart_feeder_desktop/app/models/walker/walker_history_model.dart';
import 'package:smart_feeder_desktop/app/modules/horse_walker/history/walker_history_controller.dart';
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

  final selectedHorse1 = ''.obs;
  final selectedHorse2 = ''.obs;
  final selectedHorse3 = ''.obs;
  final selectedHorse4 = ''.obs;

  // Tambahkan property ini
  final operationMode = 'duration'.obs; // 'duration' atau 'rotation'

  // Callback untuk animation control dari page
  Function()? onStartAnimation;
  Function()? onStopAnimation;

  // Worker untuk listening status changes
  Worker? _statusWorker;

  void setOperationMode(String mode) {
    operationMode.value = mode;
    durationCtrl.text = mode == 'duration' ? '10' : '5';
  }

  void setAnimationCallbacks({Function()? onStart, Function()? onStop}) {
    onStartAnimation = onStart;
    onStopAnimation = onStop;
  }

  final DataController dataController = Get.find<DataController>();

  // Tambahkan di dalam class WalkerDashboardController
  final WalkerHistoryController historyController = Get.put(WalkerHistoryController());

  RxList<HorseModel> get horseList => dataController.horseList;
  RxList<WalkerDeviceModel> get walkerStatusList =>
      dataController.walkerStatusList;

  @override
  void onInit() {
    super.onInit();
    _mqttWalkerService = Get.find<MqttWalkerService>();

    // Listen untuk perubahan status walker
    _setupWalkerStatusListener();
  }

  void _setupWalkerStatusListener() {
    // Store worker reference untuk proper disposal
    _statusWorker = ever(walkerStatusList, (
      List<WalkerDeviceModel> statusList,
    ) {
      // Dapatkan device ID yang sedang dipilih
      final currentDeviceId = int.tryParse(idDeviceCtrl.text.trim()) ?? 1;
      final deviceFullId = 'SHWIPB$currentDeviceId';

      // Cari status device yang sedang dipilih
      final deviceStatus = statusList.firstWhereOrNull(
        (device) => device.deviceId == deviceFullId,
      );

      if (deviceStatus != null) {
        final status = deviceStatus.status.toUpperCase();

        print('Walker Status Changed for $deviceFullId: $status');

        // Handle animation berdasarkan status dengan safety checks
        switch (status) {
          case 'START':
            // Mulai animasi jika status START
            try {
              if (onStartAnimation != null) {
                onStartAnimation!();
                print('Starting walker animation for $deviceFullId');
              }
            } catch (e) {
              print('Error calling start animation: $e');
            }
            break;
          case 'STOP':
          case 'OFF':
          case 'ON':
            // Stop animasi jika status STOP, OFF, atau ON
            try {
              if (onStopAnimation != null) {
                onStopAnimation!();
                print('Stopping walker animation for $deviceFullId');
              }
            } catch (e) {
              print('Error calling stop animation: $e');
            }
            break;
        }
      }
    });
  }

  @override
  void onClose() {
    // Dispose worker first
    _statusWorker?.dispose();
    _statusWorker = null;

    // Reset callbacks
    onStartAnimation = null;
    onStopAnimation = null;

    // Dispose text controllers
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

  // Method untuk mendapatkan status walker berdasarkan device ID
  String getWalkerStatus(String deviceId) {
    final status = _mqttWalkerService.getWalkerStatusByDeviceId(deviceId);
    return status?.status ?? 'OFF';
  }

  // Method untuk mengecek apakah walker sedang aktif
  bool isWalkerActive(String deviceId) {
    final status = getWalkerStatus(deviceId);
    return status == 'ON' || status == 'START';
  }

  // Method untuk mendapatkan waktu update terakhir
  DateTime? getLastUpdateTime(String deviceId) {
    final status = _mqttWalkerService.getWalkerStatusByDeviceId(deviceId);
    return status?.lastUpdate;
  }

  // Method untuk mendapatkan status berdasarkan header + id
  String getWalkerStatusById(int idDevice) {
    return _mqttWalkerService.getWalkerStatusById(idDevice);
  }

  // Method untuk mendapatkan walker yang aktif
  List<WalkerDeviceModel> getActiveWalkers() {
    return _mqttWalkerService.getActiveWalkers();
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
  final durationValue = int.tryParse(durationCtrl.text.trim());

  if (idDevice == null || speed == null || durationValue == null) {
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

  if (operationMode.value == 'duration') {
    if (durationValue < 1 || durationValue > 7200) {
      Get.snackbar(
        'Error',
        'Durasi harus antara 1-7200 menit',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
  } else {
    if (durationValue < 1 || durationValue > 1000) {
      Get.snackbar(
        'Error',
        'Jumlah putaran harus antara 1-1000',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
  }

  isLoading.value = true;

  try {
    final deviceFullId = 'SHWIPB$idDevice';
    
    // Kumpulkan kuda yang dipilih
    final selectedHorses = <String>[];
    if (selectedHorse1.value.isNotEmpty) selectedHorses.add(selectedHorse1.value);
    if (selectedHorse2.value.isNotEmpty) selectedHorses.add(selectedHorse2.value);
    if (selectedHorse3.value.isNotEmpty) selectedHorses.add(selectedHorse3.value);
    if (selectedHorse4.value.isNotEmpty) selectedHorses.add(selectedHorse4.value);

    // Publish ke topic walker/control
    final payload = {
      'header': 'SHWIPB',
      'id_device': idDevice,
      'control_motor': controlMotor.value,
      'rotation': rotation.value,
      'speed': speed,
      'operation_mode': operationMode.value,
      'duration': operationMode.value == 'duration' ? durationValue : null,
      'rotation_count': operationMode.value == 'rotation' ? durationValue : null,
    };

    _mqttWalkerService.client!.publishMessage(
      'walker/control',
      MqttQos.atLeastOnce,
      MqttClientPayloadBuilder().addString(json.encode(payload)).payload!,
    );

    print('Walker Command Sent: $payload');

    // Record history - simpan sebagai status START dengan timeStart
    final history = WalkerHistoryModel(
      deviceId: deviceFullId,
      status: 'START',
      horseIds: selectedHorses,
      mode: operationMode.value,
      duration: operationMode.value == 'duration' ? durationValue : null,
      rotation: operationMode.value == 'rotation' ? durationValue : null,
      speed: speed,
      timeStart: DateTime.now(),
      timeStop: null, // Akan diisi saat status STOP
    );
    
    await historyController.addHistory(history);

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
    operationMode.value = 'duration';
  }

  // Update method stopWalker untuk manual stop
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
  final deviceFullId = 'SHWIPB$idDevice';

  try {
    final payload = {
      'header': 'SHWIPB',
      'id_device': idDevice,
      'control_motor': false,
      'rotation': false,
      'speed': 0,
      'duration': 0,
      'manual_stop': true, // Tambahkan flag manual stop
    };

    _mqttWalkerService.client!.publishMessage(
      'walker/control',
      MqttQos.atLeastOnce,
      MqttClientPayloadBuilder().addString(json.encode(payload)).payload!,
    );

    print('Walker Stop Command Sent: $payload');

    // Update history yang sedang berjalan dengan timeStop dan status DIHENTIKAN
    final runningHistory = historyController.getRunningHistoryByDevice(deviceFullId);
    if (runningHistory != null) {
      final updatedHistory = WalkerHistoryModel(
        id: runningHistory.id,
        deviceId: runningHistory.deviceId,
        status: 'DIHENTIKAN', // Manual stop = DIHENTIKAN
        horseIds: runningHistory.horseIds,
        mode: runningHistory.mode,
        duration: runningHistory.duration,
        rotation: runningHistory.rotation,
        speed: runningHistory.speed,
        timeStart: runningHistory.timeStart,
        timeStop: DateTime.now(),
      );
      
      historyController.updateHistory(updatedHistory);
    }

    Get.snackbar(
      'Berhasil',
      'Walker dihentikan secara manual',
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
  void setSelectedHorse1(String horseId) {
    selectedHorse1.value = horseId;
  }

  void setSelectedHorse2(String horseId) {
    selectedHorse2.value = horseId;
  }

  void setSelectedHorse3(String horseId) {
    selectedHorse3.value = horseId;
  }

  void setSelectedHorse4(String horseId) {
    selectedHorse4.value = horseId;
  }

  void clearAllHorses() {
    selectedHorse1.value = '';
    selectedHorse2.value = '';
    selectedHorse3.value = '';
    selectedHorse4.value = '';

    Get.snackbar(
      'Clear Berhasil',
      'Semua pilihan kuda telah dikosongkan',
      backgroundColor: Colors.orange,
      colorText: Colors.white,
    );
  }

  void confirmHorseSelection() {
    final selectedHorses = [
      selectedHorse1.value,
      selectedHorse2.value,
      selectedHorse3.value,
      selectedHorse4.value,
    ].where((id) => id.isNotEmpty).toList();

    if (selectedHorses.isEmpty) {
      Get.snackbar(
        'Peringatan',
        'Belum ada kuda yang dipilih',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    // Cek apakah ada kuda yang duplikat
    final uniqueHorses = selectedHorses.toSet();
    if (uniqueHorses.length != selectedHorses.length) {
      Get.snackbar(
        'Error',
        'Tidak boleh memilih kuda yang sama',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    Get.snackbar(
      'Berhasil',
      'Pilihan kuda dikonfirmasi untuk ${selectedHorses.length} posisi',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );

    print('Selected horses: $selectedHorses');
  }
}
