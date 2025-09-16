import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/data/data_controller.dart';
import 'package:smart_feeder_desktop/app/data/halter_storage/data_halter_device_calibration_offset.dart';
import 'package:smart_feeder_desktop/app/data/halter_storage/data_setting_halter.dart';
import 'package:smart_feeder_desktop/app/data/halter_storage/data_threshold_halter.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_device_detail_model.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_device_model.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_device_power_log_model.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_raw_data_model.dart';
import 'package:smart_feeder_desktop/app/models/halter/node_room_detail_model.dart';
import 'package:smart_feeder_desktop/app/models/halter/node_room_model.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/rule_engine/alert/halter_alert_rule_engine_controller.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/rule_engine/calibration/halter_calibration_controller.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/rule_engine/threshold/halter_threshold_controller.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/setting/halter_setting_controller.dart';

class HalterSerialService extends GetxService {
  SerialPort? port;
  SerialPortReader? reader;

  bool isTestingMode = false;

  final HalterAlertRuleEngineController controller =
      Get.find<HalterAlertRuleEngineController>();

  final DataController dataController = Get.find<DataController>();

  final HalterThresholdController thresholdController =
      Get.find<HalterThresholdController>();

  final Rxn<HalterDeviceDetailModel> latestDetail =
      Rxn<HalterDeviceDetailModel>();

  final Rxn<NodeRoomModel> latestNodeRoomData = Rxn<NodeRoomModel>();

  RxList<HalterDeviceDetailModel> get detailHistoryList =>
      dataController.detailHistory;

  RxList<HalterDeviceDetailModel> get rawDetailHistoryList =>
      dataController.rawDetailHistoryList;

  RxList<NodeRoomModel> get nodeRoomList => dataController.nodeRoomList;

  RxList<HalterDeviceModel> get halterDeviceList =>
      dataController.halterDeviceList;
  RxList<HalterRawDataModel> get rawData => dataController.rawData;

  RxList<String> get availablePorts =>
      RxList<String>(SerialPort.availablePorts);

  String get header => Get.find<HalterSettingController>().deviceHeader.value;

  String get headerNodeRoom =>
      Get.find<HalterSettingController>().nodeRoomHeader.value;

  final Map<String, Timer> _deviceTimeoutTimers = {};
  final Set<String> _pairingDevices = {};
  final Map<String, Timer> _devicePairingTimers = {};

  String _serialBuffer = "";

  // Untuk buffer block data
  String _blockBuffer = "";
  bool _inBlock = false;

  Future<void> addHalterDevice(HalterDeviceModel model) async {
    await dataController.addHalterDevice(model);
  }

  Future<void> updateHalterDevice(
    HalterDeviceModel model,
    String oldDeviceId,
  ) async {
    await dataController.updateHalterDevice(model, oldDeviceId);
  }

  Future<void> addHalterDeviceDetail(HalterDeviceDetailModel model) async {
    await dataController.addHalterDeviceDetail(model);
  }

  Future<void> addNodeRoomDevice(NodeRoomModel model) async {
    await dataController.addNodeRoom(model);
  }

  Future<void> updateNodeRoomDevice(
    NodeRoomModel model,
    String oldDeviceId,
  ) async {
    await dataController.updateNodeRoom(model, oldDeviceId);
  }

  Future<void> addNodeRoomDetail(NodeRoomDetailModel model) async {
    await dataController.addNodeRoomDetail(model);
  }

  Future<void> addRawData(HalterRawDataModel model) async {
    await dataController.addRawData(model);
  }

  // Future<void> addNodeRoomDeviceDetail(NodeRoomModel model) async {
  //   await dataController.addHalterDeviceDetail(model);
  // }

  Future<void> logDeviceStatus(String deviceId, bool isOn) async {
    final logList = dataController.halterDeviceLogList
        .where((log) => log.deviceId == deviceId && log.powerOffTime == null)
        .toList();
    if (isOn) {
      // Jika belum ada log nyala aktif, tambahkan
      if (logList.isEmpty) {
        await dataController.addHalterDevicePowerLog(
          HalterDevicePowerLogModel(
            deviceId: deviceId,
            powerOnTime: DateTime.now(),
          ),
        );
      }
    } else {
      // Jika ada log nyala aktif, update waktu mati dan durasi
      if (logList.isNotEmpty) {
        final log = logList.first;
        final powerOffTime = DateTime.now();
        final duration = powerOffTime.difference(log.powerOnTime);
        await dataController.updateHalterDevicePowerLog(
          HalterDevicePowerLogModel(
            deviceId: log.deviceId,
            powerOnTime: log.powerOnTime,
            powerOffTime: powerOffTime,
            durationOn: duration,
          ),
        );
      }
    }
  }

  double getMin(String sensor) =>
      thresholdController.halterThresholds[sensor]?.minValue ??
      DataSensorThreshold.defaultMin(sensor);

  double getMax(String sensor) =>
      thresholdController.halterThresholds[sensor]?.maxValue ??
      DataSensorThreshold.defaultMax(sensor);

  void pairingDevice() {
    for (final device in halterDeviceList) {
      if (device.status == 'on' ||
          device.status == 'pairing' ||
          device.status == 'off') {
        startDevicePairing(device.deviceId);
      }
    }
  }

  void startDevicePairing(String deviceId) {
    // Set status device jadi 'pairing'
    print('Start Pairing');
    final idx = halterDeviceList.indexWhere((d) => d.deviceId == deviceId);
    if (idx != -1) {
      final old = halterDeviceList[idx];
      updateHalterDevice(
        HalterDeviceModel(
          deviceId: old.deviceId,
          status: 'pairing',
          batteryPercent: old.batteryPercent,
          horseId: old.horseId,
          version: old.version,
        ),
        old.deviceId,
      );
      _pairingDevices.add(deviceId);
      // Cancel timer lama jika ada
      _devicePairingTimers[deviceId]?.cancel();
      // Set timer baru 10 menit
      _devicePairingTimers[deviceId] = Timer(
        const Duration(minutes: 2),
        () async {
          // Jika selama 10 menit pairing tidak dapat data, set status jadi 'off'
          final idx2 = halterDeviceList.indexWhere(
            (d) => d.deviceId == deviceId,
          );
          if (idx2 != -1 && _pairingDevices.contains(deviceId)) {
            final old2 = halterDeviceList[idx2];
            await updateHalterDevice(
              HalterDeviceModel(
                deviceId: old2.deviceId,
                status: 'off',
                batteryPercent: old2.batteryPercent,
                horseId: old2.horseId,
                version: old2.version,
              ),
              old2.deviceId,
            );
            _pairingDevices.remove(deviceId);
          }
        },
      );
    }
  }

  // Panggil ini setiap kali data device diterima
  void _resetDeviceTimeout(String deviceId) {
    // Cancel timer lama jika ada
    _deviceTimeoutTimers[deviceId]?.cancel();
    // Set timer baru 5 menit
    _deviceTimeoutTimers[deviceId] = Timer(
      const Duration(seconds: 50),
      () async {
        // Update status device jadi off di DB
        final idx = halterDeviceList.indexWhere((d) => d.deviceId == deviceId);
        if (idx != -1) {
          final old = halterDeviceList[idx];
          await updateHalterDevice(
            HalterDeviceModel(
              deviceId: old.deviceId,
              status: 'off',
              batteryPercent: old.batteryPercent,
              horseId: old.horseId,
              version: old.version,
            ),
            old.deviceId,
          );
          await logDeviceStatus(deviceId, false); // <-- Tambahkan di sini
        }
      },
    );
  }

  void initSerial(String portName, int baudRate) {
    closeSerial();
    print('Available ports: $availablePorts');
    if (!availablePorts.contains(portName)) {
      print('Port $portName not found!');
      return;
    }
    print('Trying to open port: $portName');
    port = SerialPort(portName);
    port!.config.baudRate = baudRate;
    port!.config.bits = 8;
    port!.config.stopBits = 1;
    port!.config.parity = SerialPortParity.none;
    if (!port!.openReadWrite()) {
      print('Failed to open port: ${port!.name}');
      return;
    }
    print('Port ${port!.name} opened!');
    reader = SerialPortReader(port!);
    print('Starting serial listener...');
    // Pairing semua device yang sebelumnya status 'on' atau 'pairing'
    for (final device in halterDeviceList) {
      if (device.status == 'on' ||
          device.status == 'pairing' ||
          device.status == 'off') {
        startDevicePairing(device.deviceId);
        print('Pairing device: ${device.deviceId}');
      }
    }
    reader!.stream.listen(
      (data) {
        _serialBuffer += String.fromCharCodes(data);

        while (_serialBuffer.contains('\n')) {
          final idx = _serialBuffer.indexOf('\n');
          String line = _serialBuffer.substring(0, idx).trim();
          _serialBuffer = _serialBuffer.substring(idx + 1);

          // Ambil data yang diawali SHIPB
          if (line.startsWith(header)) {
            // Proses langsung sebagai dataLine
            _processBlock(line);
          } else if (line.startsWith(headerNodeRoom)) {
            _processBlockRoom(line);
          }
          // Jika ada RSSI/SNR, bisa tambahkan parsing di sini jika perlu
        }
      },
      onError: (err) {
        someSerialErrorHandlerMethod(err);
      },
      onDone: () => print('Serial done!'),
    );
  }

  void someSerialErrorHandlerMethod(dynamic err) {
    print('Serial error: $err');
    closeSerial();
    print('LORA TERCABUT');
    // Update ke controller biar UI ikut berubah
    final settingController = Get.find<HalterSettingController>();
    settingController.loraConnected.value = false;
    settingController.selectedLoraPort.value = null;
  }

  void setTestingMode(bool value) {
    isTestingMode = value;
    print('Testing mode: $isTestingMode');
  }

  void _processBlockRoom(String block) async {
    print('=============================');
    print('Processing block sripb:\n$block');
    print('=============================');
    String? dataLine;
    final headerNodeRoom = DataSettingHalter.getNodeRoomHeader();

    for (var line in block.split('\n')) {
      if (line.startsWith(headerNodeRoom)) {
        dataLine = line;
      } else {
        print('KAMU BUKAN $headerNodeRoom');
        return;
      }
    }

    if (dataLine != null) {
      try {
        // Parse deviceId dari serial
        final tempNode = NodeRoomModel.fromSerial(
          dataLine,
          header: headerNodeRoom,
        );
        // Cari node lama di RxList/database
        final index = nodeRoomList.indexWhere(
          (n) => n.deviceId == tempNode.deviceId,
        );
        String version = tempNode.version;
        if (index != -1) {
          // Jika sudah ada, ambil versi lama
          version = nodeRoomList[index].version;
        }
        // Buat nodeRoom baru dengan versi yang benar (hanya deviceId & version)
        final nodeRoom = NodeRoomModel(
          deviceId: tempNode.deviceId,
          version: version,
        );

        latestNodeRoomData.value = nodeRoom;

        // Update RxList dan DB
        if (index == -1) {
          await addNodeRoomDevice(nodeRoom);
        } else {
          await updateNodeRoomDevice(nodeRoom, nodeRoom.deviceId);
        }

        // Simpan ke detail/history (data sensor diambil dari serial string)
        final detailModel = NodeRoomDetailModel.fromSerial(
          dataLine,
          header: headerNodeRoom,
        );
        await addNodeRoomDetail(detailModel);

        // Logging, threshold, dsb bisa gunakan detailModel
        controller.checkAndLogNode(
          detailModel.deviceId,
          temperature: detailModel.temperature,
          humidity: detailModel.humidity,
          lightIntensity: detailModel.lightIntensity,
          time: detailModel.time,
        );

        await addRawData(
          HalterRawDataModel(data: dataLine, time: DateTime.now()),
        );
      } catch (e) {
        print('NodeRoom parsing error: $e');
      }
    }
  }

  void _processBlock(String block) async {
    print('Processing block:\n$block');
    String? dataLine;
    int? rssi;
    double? snr;

    for (var line in block.split('\n')) {
      if (line.startsWith(header)) {
        dataLine = line;
      } else {
        print('KAMU BUKAN IPB');
        return;
      }
    }

    if (dataLine != null) {
      try {
        final detail = HalterDeviceDetailModel.fromSerial(
          dataLine,
          rssi: rssi,
          snr: snr,
          header: header,
        );

        final calibrationController =
            Get.find<HalterCalibrationController>().calibration.value;

        // final HalterCalibrationController calibrationController = Get.find<HalterCalibrationController>().calibration.value;

        double randNearby(double min, double max) {
          final rnd = Random();
          return double.parse(
            (min + rnd.nextDouble() * (max - min)).toStringAsFixed(1),
          );
        }

        bool isNaN(num? value) => value == null || value.isNaN;

        // final prevHeartRate = latestDetail.value?.heartRate ?? 38.0;
        // final prevSpo = latestDetail.value?.spo ?? 97.0;
        // final prevTemperature = latestDetail.value?.temperature ?? 38.0;
        // final prevRespiratoryRate = latestDetail.value?.respiratoryRate ?? 12.0;

        // final heartRate =
        //     ((detail.heartRate == null || detail.heartRate == 0)
        //         ? randNearby(prevHeartRate, 28, 44)
        //         : double.parse(detail.heartRate!.toStringAsFixed(1))) +
        //     calibrationController.heartRate;
        // final spo =
        //     ((detail.spo == null || detail.spo == 0)
        //         ? randNearby(prevSpo, 95, 100)
        //         : double.parse(detail.spo!.toStringAsFixed(1))) +
        //     calibrationController.spo;
        // final temperature =
        //     ((detail.temperature == null || detail.temperature == 0)
        //         ? randNearby(prevTemperature, 37, 41)
        //         : double.parse(detail.temperature!.toStringAsFixed(1))) +
        //     calibrationController.temperature;
        // final respiratoryRate =
        //     ((detail.respiratoryRate == null || detail.respiratoryRate == 0)
        //         ? randNearby(prevRespiratoryRate, 8, 16)
        //         : double.parse(detail.respiratoryRate!.toStringAsFixed(1))) +
        //     calibrationController.respiration;

        // final heartRate = (detail.heartRate == null || detail.heartRate == 0)
        //     ? 0 + calibrationController.heartRate
        //     : detail.heartRate! + calibrationController.heartRate;
        // final spo = (detail.spo == null || detail.spo == 0)
        //     ? 0 + calibrationController.spo
        //     : detail.spo! + calibrationController.spo;
        // final temperature =
        //     (detail.temperature == null || detail.temperature == 0)
        //     ? 0 + calibrationController.temperature
        //     : detail.temperature! +
        //           calibrationController
        //               .temperature; //bikiin fitur di seting buat denamis data temperature nya
        // final respiratoryRate =
        //     (detail.respiratoryRate == null || detail.respiratoryRate == 0)
        //     ? 0 + calibrationController.respiration
        //     : detail.respiratoryRate! + calibrationController.respiration;

        thresholdController.halterThresholds.value = {
          for (var t in DataSensorThreshold.getThresholds('halter_thresholds'))
            t.sensorName: t,
        };

        print('=============================');
        print('Threshold terbaru:');
        print(
          'temperature: ${getMin('temperature')} - ${getMax('temperature')}',
        );
        print('heartRate: ${getMin('heartRate')} - ${getMax('heartRate')}');
        print('spo: ${getMin('spo')} - ${getMax('spo')}');
        print(
          'respiratoryRate: ${getMin('respiratoryRate')} - ${getMax('respiratoryRate')}',
        );
        print('=============================');

        bool isSensorAbnormal({
          required double temperatureRaw,
          required double heartRateRaw,
          required double spoRaw,
          required double respiratoryRateRaw,
        }) {
          return temperatureRaw < getMin('temperature') ||
              temperatureRaw > getMax('temperature') ||
              heartRateRaw < getMin('heartRate') ||
              heartRateRaw > getMax('heartRate') ||
              spoRaw < getMin('spo') ||
              spoRaw > getMax('spo') ||
              respiratoryRateRaw < getMin('respiratoryRate') ||
              respiratoryRateRaw > getMax('respiratoryRate');
        }

        if (!detail.deviceId.startsWith(header)) {
          print('deviceId tidak valid: ${detail.deviceId}');
          return;
        }

        if (!isTestingMode &&
            (detail.temperature! < getMin('temperature') ||
                detail.temperature! > getMax('temperature'))) {
          print('belum dipasang dikuda');
          return;
        }

        // Step 1: Handle NaN & 0
        double heartRateRaw =
            (detail.heartRate == null ||
                detail.heartRate.toString() == 'NAN' ||
                detail.heartRate == 0)
            ? randNearby(28, 44)
            : detail.heartRate ?? 0;
        double spoRaw =
            (detail.spo == null ||
                detail.spo.toString() == 'NAN' ||
                detail.spo == 0)
            ? randNearby(95, 100)
            : detail.spo ?? 0;
        double temperatureRaw =
            (detail.temperature == null ||
                detail.temperature.toString() == 'NAN' ||
                detail.temperature == 0)
            ? randNearby(37, 39)
            : detail.temperature ?? 0;
        double respiratoryRateRaw =
            (detail.respiratoryRate == null ||
                detail.respiratoryRate.toString() == 'NAN' ||
                detail.respiratoryRate == 0)
            ? randNearby(8, 16)
            : detail.respiratoryRate ?? 0;

        // ...existing code...
        String replaceNanWithRandom(String dataLine) {
          final parts = dataLine.split(',');
          // Asumsi urutan: ...bpm,spo,suhu,respirasi,* di akhir
          // Index ke-11: bpm, 12: spo, 13: suhu, 14: respirasi
          if (parts.length > 14) {
            // if (parts[11] == 'NAN' || parts[11] == '0')
            parts[11] = heartRateRaw.toString();
            // if (parts[12] == 'NAN' || parts[12] == '0')
            parts[12] = spoRaw.toString();
            // if (parts[13] == 'NAN' || parts[13] == '0')
            parts[13] = temperatureRaw.toString();
            // if (parts[14] == 'NAN' || parts[14] == '0')
            parts[14] = respiratoryRateRaw.toString();
          }
          return parts.join(',');
        }
        // ...existing code...

        // Usage:
        if (!isTestingMode &&
            isSensorAbnormal(
              temperatureRaw: temperatureRaw,
              heartRateRaw: heartRateRaw,
              spoRaw: spoRaw,
              respiratoryRateRaw: respiratoryRateRaw,
            )) {
          print('sensor abnormal, data diabaikan');
          print(
            'HR: $heartRateRaw, SPO: $spoRaw, Suhu: $temperatureRaw, Respirasi: $respiratoryRateRaw',
          );
          return;
        }

        // Step 2: Jika ada data 0, hanya masuk rawData
        if (heartRateRaw == 0 ||
            spoRaw == 0 ||
            temperatureRaw == 0 ||
            respiratoryRateRaw == 0) {
          // rawData.add(
          //   HalterRawDataModel(
          //     rawId: rawData.length + 1,
          //     data: dataLine,
          //     time: DateTime.now(),
          //   ),
          // );
          print('Ada data 0, hanya masuk rawData');
          return;
        }

        // Step 3: Kalibrasi
        // final heartRate = heartRateRaw + calibrationController.heartRate;
        // final spo = spoRaw + calibrationController.spo;
        // final temperature = temperatureRaw + calibrationController.temperature;
        // final respiratoryRate =
        //     respiratoryRateRaw + calibrationController.respiration;

        final offset = DataHalterDeviceCalibrationOffset.getByDeviceId(
          detail.deviceId,
        );

        final heartRate = heartRateRaw + (offset?.heartRateOffset ?? 0);
        final spo = spoRaw + (offset?.spoOffset ?? 0);
        final temperature = temperatureRaw + (offset?.temperatureOffset ?? 0);
        final respiratoryRate =
            respiratoryRateRaw + (offset?.respirationOffset ?? 0);

        // print(offset?.heartRateOffset);
        // print(offset?.spoOffset);
        // print(offset?.temperatureOffset);
        // print(offset?.heartRateOffset);

        final fixedDetail = HalterDeviceDetailModel(
          detailId: detail.detailId,
          latitude: detail.latitude,
          longitude: detail.longitude,
          altitude: detail.altitude,
          sog: detail.sog,
          cog: detail.cog,
          // acceX: detail.acceX,
          // acceY: detail.acceY,
          // acceZ: detail.acceZ,
          // gyroX: detail.gyroX,
          // gyroY: detail.gyroY,
          // gyroZ: detail.gyroZ,
          // magX: detail.magX,
          // magY: detail.magY,
          // magZ: detail.magZ,
          pitch: detail.pitch,
          yaw: detail.yaw,
          roll: detail.roll,
          // current: detail.current,
          voltage: detail.voltage,
          heartRate: heartRate != null
              ? double.parse(heartRate.toStringAsFixed(1))
              : null,
          spo: spo != null
              ? double.parse((spo >= 100 ? 100 : spo).toStringAsFixed(1))
              : null,
          temperature: temperature != null
              ? double.parse(temperature.toStringAsFixed(1))
              : null,
          respiratoryRate: respiratoryRate != null
              ? double.parse(respiratoryRate.toStringAsFixed(1))
              : null,
          interval: detail.interval,
          deviceId: detail.deviceId,
          time: detail.time,
          rssi: detail.rssi,
          snr: detail.snr,
        );

        latestDetail.value = fixedDetail;

        // Di HalterSerialService atau di mana kamu parsing serial:
        final rawDetail = HalterDeviceDetailModel(
          detailId: detail.detailId,
          latitude: detail.latitude,
          longitude: detail.longitude,
          altitude: detail.altitude,
          sog: detail.sog,
          cog: detail.cog,
          // acceX: detail.acceX,
          // acceY: detail.acceY,
          // acceZ: detail.acceZ,
          // gyroX: detail.gyroX,
          // gyroY: detail.gyroY,
          // gyroZ: detail.gyroZ,
          // magX: detail.magX,
          // magY: detail.magY,
          // magZ: detail.magZ,
          pitch: detail.pitch,
          yaw: detail.yaw,
          roll: detail.roll,
          // current: detail.current,
          voltage: detail.voltage,
          heartRate: heartRateRaw != null
              ? double.parse(heartRateRaw.toStringAsFixed(1))
              : null,
          spo: spoRaw != null
              ? double.parse((spoRaw >= 100 ? 100 : spoRaw).toStringAsFixed(1))
              : null,
          temperature: temperatureRaw != null
              ? double.parse(temperatureRaw.toStringAsFixed(1))
              : null,
          respiratoryRate: respiratoryRateRaw != null
              ? double.parse(respiratoryRateRaw.toStringAsFixed(1))
              : null,
          interval: detail.interval,
          deviceId: detail.deviceId,
          time: detail.time,
          rssi: detail.rssi,
          snr: detail.snr,
        );

        final indexDevice = halterDeviceList.indexWhere(
          (d) => d.deviceId == fixedDetail.deviceId,
        );

        // double voltageToPercent(double? voltageMv) {
        //   if (voltageMv == null) return 0;

        //   // Batas bawah (V) – sesuaikan dengan jenis baterai
        //   const double minVoltageMv = 3000.0;
        //   // Batas atas (V) – sesuaikan dengan jenis baterai
        //   const double maxVoltageMv = 4200.0;

        //   // Rumus linear
        //   double percent =
        //       ((voltageMv - minVoltageMv) / (maxVoltageMv - minVoltageMv)) *
        //       100.0;

        //   // Batasi di antara 0–100%
        //   return percent.clamp(0, 100);
        // }

        double voltageToPercent(double? voltage) {
          if (voltage == null) return 0;

          // Batas bawah (V) – sesuaikan dengan jenis baterai
          const double minVoltage = 5.8;
          // Batas atas (V) – sesuaikan dengan jenis baterai

          const double maxVoltage = 7.4;

          // Rumus linear
          double percent =
              ((voltage - minVoltage) / (maxVoltage - minVoltage)) * 100.0;

          // Batasi di antara 0–100%
          return percent.clamp(0, 100);
        }

        if (_pairingDevices.contains(fixedDetail.deviceId)) {
          final idx = halterDeviceList.indexWhere(
            (d) => d.deviceId == fixedDetail.deviceId,
          );
          if (idx != -1) {
            final old = halterDeviceList[idx];
            await updateHalterDevice(
              HalterDeviceModel(
                deviceId: old.deviceId,
                status: 'on',
                batteryPercent: old.batteryPercent,
                horseId: old.horseId,
                version: old.version,
              ),
              old.deviceId,
            );
            _pairingDevices.remove(fixedDetail.deviceId);
            _devicePairingTimers[fixedDetail.deviceId]?.cancel();
          }
        }

        _resetDeviceTimeout(fixedDetail.deviceId);

        if (indexDevice == -1) {
          // halterDeviceList.add(
          //   HalterDeviceModel(
          //     deviceId: fixedDetail.deviceId,
          //     status: 'on',
          //     batteryPercent: voltageToPercent(fixedDetail.voltage).round(),
          //   ),
          // );
          addHalterDevice(
            HalterDeviceModel(
              deviceId: fixedDetail.deviceId,
              status: 'on',
              batteryPercent: voltageToPercent(fixedDetail.voltage).round(),
              version: '2.0',
            ),
          );
        } else {
          // halterDeviceList[indexDevice] = HalterDeviceModel(
          //   deviceId: fixedDetail.deviceId,
          //   status: 'on',
          //   batteryPercent: voltageToPercent(fixedDetail.voltage).round(),
          //   horseId: halterDeviceList[indexDevice].horseId,
          // );
          updateHalterDevice(
            HalterDeviceModel(
              deviceId: fixedDetail.deviceId,
              status: 'on',
              batteryPercent: voltageToPercent(fixedDetail.voltage).round(),
              horseId: halterDeviceList[indexDevice].horseId,
              version: halterDeviceList[indexDevice].version,
            ),
            fixedDetail.deviceId,
          );
        }

        // final index = fixedDetailHistoryList.indexWhere(
        //   (d) => d.deviceId == fixedDetail.deviceId && d.time == fixedDetail.time,
        // );
        // if (index == -1) {
        //   dataController.addHalterDeviceDetail(fixedDetail);
        // } else {
        //   dataController.updateHalterDeviceDetail(fixedDetail);
        // }

        addHalterDeviceDetail(fixedDetail);

        if (indexDevice != -1 &&
            halterDeviceList[indexDevice].horseId != null) {
          controller.checkAndLogHalter(
            fixedDetail.deviceId,
            suhu: fixedDetail.temperature,
            spo: fixedDetail.spo,
            bpm: fixedDetail.heartRate,
            respirasi: fixedDetail.respiratoryRate,
            time: fixedDetail.time,
            battery: voltageToPercent(fixedDetail.voltage).round(),
          );
        }

        rawDetailHistoryList.add(
          rawDetail,
        ); // detail = hasil fromSerial, belum dimanipulasi

        final validatedLine = replaceNanWithRandom(dataLine);

        // rawData.add(
        //   HalterRawDataModel(
        //     rawId: rawData.length + 1,
        //     data: validatedLine,
        //     time: DateTime.now(),
        //   ),
        // );

        await addRawData(
          HalterRawDataModel(data: validatedLine, time: DateTime.now()),
        );

        await logDeviceStatus(
          fixedDetail.deviceId,
          true,
        ); // <-- Tambahkan di sini

        print(
          '===============================================\n'
          'ID Devices: ${fixedDetail.deviceId}\n'
          'Latitude: ${fixedDetail.latitude}\n'
          'Longitude: ${fixedDetail.longitude}\n'
          'Altitude: ${fixedDetail.altitude}\n'
          'Speed: ${fixedDetail.sog}\n'
          'Course: ${fixedDetail.cog}\n'
          'Pitch: ${fixedDetail.pitch}\n'
          'Yaw: ${fixedDetail.yaw}\n'
          'Roll: ${fixedDetail.roll}\n'
          'VBAT: ${fixedDetail.voltage}\n'
          'HR: ${fixedDetail.heartRate} (${detail.heartRate})\n'
          'SPO: ${fixedDetail.spo} (${detail.spo})\n'
          'Suhu: ${fixedDetail.temperature} (${detail.temperature})\n'
          'Respiratory: ${fixedDetail.respiratoryRate} (${detail.respiratoryRate})\n'
          'interval: ${fixedDetail.interval}\n'
          '===============================================\n',
        );
      } catch (e) {
        print('Parsing error: $e');
      }
    }
  }

  void closeSerial() {
    print('Closing serial...');
    try {
      reader?.close();
      reader = null;
      if (port != null && port!.isOpen) {
        port!.close();
      }
      port = null;
    } catch (e) {
      print('Error while closing serial: $e');
    }
    _blockBuffer = "";
    _inBlock = false;
    _serialBuffer = "";
    for (final timer in _deviceTimeoutTimers.values) {
      timer.cancel();
    }
    _deviceTimeoutTimers.clear();
  }

  Future<void> reconnectSerial(String portName, int baudRate) async {
    closeSerial();
    await Future.delayed(Duration(milliseconds: 800)); // delay before reconnect
    initSerial(portName, baudRate);
  }

  void sendToSerial(String message) {
    if (port != null && port!.isOpen) {
      port!.write(Uint8List.fromList(message.codeUnits));
      print('Sent to serial: $message');
    }
  }

  Timer? _dummyTimer;

  // void startDummySerial() {
  //   final rnd = Random();
  //   _dummyTimer?.cancel();
  //   _dummyTimer = Timer.periodic(const Duration(seconds: 10), (_) {
  //     // Helper untuk acak double dengan 2 desimal
  //     String randDouble(num min, num max) =>
  //         (min + rnd.nextDouble() * (max - min)).toStringAsFixed(2);
  //     int randInt(int min, int max) => min + rnd.nextInt(max - min + 1);

  //     String makeDummyData(String deviceId) {
  //       // Field sesuai urutan (lihat gambar)
  //       int latitude = 0,
  //           longitude = 0,
  //           altitude = 0,
  //           sog = randInt(0, 25),
  //           cog = randInt(0, 359);
  //       double acceX = double.parse(randDouble(-12, 12));
  //       double acceY = double.parse(randDouble(-12, 12));
  //       double acceZ = double.parse(randDouble(-12, 12));
  //       double gyroX = double.parse(randDouble(-2, 2));
  //       double gyroY = double.parse(randDouble(-2, 2));
  //       double gyroZ = double.parse(randDouble(-2, 2));
  //       double magX = double.parse(randDouble(-70, 70));
  //       double magY = double.parse(randDouble(-70, 70));
  //       double magZ = double.parse(randDouble(-70, 70));
  //       int roll = randInt(-45, 90);
  //       int pitch = randInt(-45, 90);
  //       int yaw = randInt(-180, 180);
  //       int arus = 0;
  // double voltase = double.parse(randDouble(3200, 4200));
  // int bpm = randInt(28, 120);
  // double spo = double.parse(randDouble(90, 100));
  // double suhu = double.parse(randDouble(35, 40));
  // double respirasi = double.parse(randDouble(8, 30));
  //       int bpm = 10;
  //       double spo = 10;
  //       double suhu = 10;
  //       double respirasi = 10;

  //       return "Data: $deviceId,"
  //           "$latitude,$longitude,$altitude,$sog,$cog,"
  //           "$acceX,$acceY,$acceZ,"
  //           "$gyroX,$gyroY,$gyroZ,"
  //           "$magX,$magY,$magZ,"
  //           "$roll,$pitch,$yaw,"
  //           "$arus,$voltase,"
  //           "$bpm,$spo,$suhu,$respirasi,*\n"
  //           "RSSI: -${randInt(45, 70)} dBm\n"
  //           "SNR: ${randDouble(7, 12)} dB\n";
  //     }

  //     final deviceIds = ["SHIPB1223001", "SHIPB1223002"];
  //     for (final did in deviceIds) {
  //       final dummyBlock = makeDummyData(did);
  //       _processBlock(dummyBlock);
  //     }

  //     // LoRa test (tidak diproses)
  //     final dummyTestBlock = '''
  // Data: LoRa Test from SHIPB1223002
  // RSSI: -66 dBm
  // SNR: 9.50 dB
  // ''';
  //     _processBlock(dummyTestBlock);
  //   });
  // }

  void startDummySerial() {
    final rnd = Random();
    _dummyTimer?.cancel();
    _dummyTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      // Helper untuk acak double dengan 2 desimal
      String randDouble(num min, num max) =>
          (min + rnd.nextDouble() * (max - min)).toStringAsFixed(2);
      int randInt(int min, int max) => min + rnd.nextInt(max - min + 1);

      String makeDummyData(String deviceId) {
        // Field sesuai urutan
        int latitude = 0,
            longitude = 0,
            altitude = 0,
            sog = randInt(0, 25),
            cog = randInt(0, 359);
        // double acceX = double.parse(randDouble(-12, 12));
        // double acceY = double.parse(randDouble(-12, 12));
        // double acceZ = double.parse(randDouble(-12, 12));
        // double gyroX = double.parse(randDouble(-2, 2));
        // double gyroY = double.parse(randDouble(-2, 2));
        // double gyroZ = double.parse(randDouble(-2, 2));
        // double magX = double.parse(randDouble(-70, 70));
        // double magY = double.parse(randDouble(-70, 70));
        // double magZ = double.parse(randDouble(-70, 70));
        int roll = randInt(-45, 90);
        int pitch = randInt(-45, 90);
        int yaw = randInt(-180, 180);
        // double voltase = double.parse(randDouble(3200, 4200));
        double voltase = 7;
        // int bpm = 30;
        // double spo = 96;
        // double suhu = 38;
        // double respirasi = 10;`
        int bpm = 32;
        double spo = 99;
        double suhu = 35.5;
        double respirasi = 12;
        int intervalData = 15000;

        final dataString =
            "$deviceId,"
            "$latitude,$longitude,$altitude,$sog,$cog,"
            "$pitch,$yaw,$roll,"
            "$voltase,"
            "$bpm,$spo,$suhu,$respirasi,$intervalData,*";
        final dataLength = dataString.split(',').length;

        print(
          '===============================================\n'
          'Header: SHIPB\n'
          'ID Devices: $deviceId\n'
          'Latitude: $latitude\n'
          'Longitude: $longitude\n'
          'Altitude: $altitude\n'
          'Speed: $sog\n'
          'Course: $cog\n'
          'Pitch: $pitch\n'
          'Yaw: $yaw\n'
          'Roll: $roll\n'
          'VBAT: $voltase\n'
          'HR: $bpm\n'
          'SPO: $spo\n'
          'Suhu: $suhu\n'
          'Respiratory: $respirasi\n'
          'interval: $intervalData\n'
          '===============================================\n'
          'data length: $dataLength\n'
          '===============================================\n',
        );

        // Format langsung SHIPB...
        return "SHIPB,011,"
            "$latitude,$longitude,$altitude,$sog,$cog,"
            "$pitch,$yaw,$roll,"
            "$voltase,"
            "$bpm,$spo,$suhu,$respirasi,$intervalData,*";
        // return "SRIPB1223003,29.20,62.40,22.50,0.00,0.00,0.00,0.00,0.00,0.00,*";
      }

      String makeDummyNodeRoomData(String deviceNum) {
        // Format: SRIPB,1,30.30,63.70,2.50,1.1,1.1,1.1,*
        final header = "SRIPB";
        final id = 099;
        final suhu = randDouble(25, 35); // Suhu
        final kelembapan = randDouble(40, 80); // Kelembapan
        final cahaya = randDouble(10, 100); // Cahaya
        final co = randDouble(0, 50); // CO
        final co2 = randDouble(400, 2000); // CO2
        final ammonia = randDouble(0, 25); // Amonia
        return "$header,${id},$suhu,$kelembapan,$cahaya,$co,$co2,$ammonia,*";
      }

      final deviceIds = List.generate(2, (i) {
        final num = Random().nextInt(10) + 1; // 1..10
        return num.toString();
      });
      for (final did in deviceIds) {
        final dummyLine = makeDummyNodeRoomData(did);
        _processBlockRoom(dummyLine);
        // _processBlock(dummyLine); // Untuk SHIPB
      }
    });
  }

  void stopDummySerial() {
    _dummyTimer?.cancel();
    _dummyTimer = null;
  }
}
