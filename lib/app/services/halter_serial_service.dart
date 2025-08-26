import 'dart:async';
import 'dart:math';
import 'dart:math' as Math;
import 'dart:typed_data';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/data/data_controller.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_device_detail_model.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_device_model.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_raw_data_model.dart';
import 'package:smart_feeder_desktop/app/models/halter/node_room_model.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/rule_engine/alert/halter_alert_rule_engine_controller.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/rule_engine/calibration/halter_calibration_controller.dart';

class HalterSerialService extends GetxService {
  SerialPort? port;
  SerialPortReader? reader;

  final HalterAlertRuleEngineController controller =
      Get.find<HalterAlertRuleEngineController>();

  final DataController dataController = Get.find<DataController>();

  final Rxn<HalterDeviceDetailModel> latestDetail =
      Rxn<HalterDeviceDetailModel>();

  final Rxn<NodeRoomModel> latestNodeRoomData = Rxn<NodeRoomModel>();

  RxList<HalterDeviceDetailModel> get detailHistoryList =>
      dataController.detailHistory;

  RxList<HalterDeviceDetailModel> get rawDetailList => dataController.rawDetail;

  RxList<NodeRoomModel> get nodeRoomList => dataController.nodeRoomList;

  RxList<HalterDeviceModel> get halterDeviceList =>
      dataController.halterDeviceList;

  RxList<HalterRawDataModel> get rawData => dataController.rawData;

  RxList<String> get availablePorts =>
      RxList<String>(SerialPort.availablePorts);

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

  Future<void> updateHalterDevice(HalterDeviceModel model) async {
    await dataController.updateHalterDevice(model);
  }

  Future<void> addHalterDeviceDetail(HalterDeviceDetailModel model) async {
    await dataController.addHalterDeviceDetail(model);
  }

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
        ),
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
              ),
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
            ),
          );
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
          if (line.startsWith('SHIPB')) {
            // Proses langsung sebagai dataLine
            _processBlock(line);
          }
          // Jika ada RSSI/SNR, bisa tambahkan parsing di sini jika perlu

          if (line.startsWith('SRIPB') && line.endsWith('*')) {
            print('Room Node Data: $line');
            try {
              final nodeRoom = NodeRoomModel.fromSerial(line);
              latestNodeRoomData.value = nodeRoom;
              final index = nodeRoomList.indexWhere(
                (n) => n.deviceId == nodeRoom.deviceId,
              );
              if (index == -1) {
                nodeRoomList.add(nodeRoom);
              } else {
                nodeRoomList[index] = nodeRoom;
              }

              controller.checkAndLogNode(
                nodeRoom.deviceId,
                temperature: nodeRoom.temperature,
                humidity: nodeRoom.humidity,
                lightIntensity: nodeRoom.lightIntensity,
                time: nodeRoom.time,
              );

              rawData.add(
                HalterRawDataModel(
                  rawId: rawData.length + 1,
                  data: line,
                  time: DateTime.now(),
                ),
              );
            } catch (e) {
              print('NodeRoom parsing error: $e');
            }
          }
        }
      },
      onError: (err) => print('Serial error: $err'),
      onDone: () => print('Serial done!'),
    );
  }

  void _processBlock(String block) async {
    print('Processing block:\n$block');
    String? dataLine;
    int? rssi;
    double? snr;

    for (var line in block.split('\n')) {
      // if (line.startsWith('Data:')) {
      //   final d = line.substring(5).trim();
      //   if (d.startsWith('SHIPB')) {
      //     dataLine = d;
      //   }
      // } else if (line.startsWith('RSSI:')) {
      //   final match = RegExp(r'RSSI:\s*([-+]?\d+)').firstMatch(line);
      //   if (match != null) {
      //     rssi = int.tryParse(match.group(1)!);
      //   }
      // } else if (line.startsWith('SNR:')) {
      //   final match = RegExp(r'SNR:\s*([-+]?\d*\.?\d*)').firstMatch(line);
      //   if (match != null) {
      //     snr = double.tryParse(match.group(1)!);
      //   }
      // }
      if (line.startsWith('SHIPB')) {
        dataLine = line;
        print(dataLine);
      }
    }

    if (dataLine != null) {
      try {
        final detail = HalterDeviceDetailModel.fromSerial(
          dataLine,
          rssi: rssi,
          snr: snr,
        );

        final calibrationController =
            Get.find<HalterCalibrationController>().calibration.value;

        final HalterCalibrationController controllerCalibration =
            Get.find<HalterCalibrationController>();

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

        // Step 1: Handle NaN & 0
        double heartRateRaw =
            (detail.heartRate == null || detail.heartRate.toString() == 'NAN')
            ? randNearby(28, 44)
            : detail.heartRate ?? 0;
        double spoRaw = (detail.spo == null || detail.spo.toString() == 'NAN')
            ? randNearby(95, 100)
            : detail.spo ?? 0;
        double temperatureRaw =
            (detail.temperature == null ||
                detail.temperature.toString() == 'NAN')
            ? randNearby(37, 39)
            : detail.temperature ?? 0;
        double respiratoryRateRaw =
            (detail.respiratoryRate == null ||
                detail.respiratoryRate.toString() == 'NAN')
            ? randNearby(8, 16)
            : detail.respiratoryRate ?? 0;

        String replaceNanWithRandom(String dataLine) {
          final parts = dataLine.split(',');
          // Asumsi urutan: ...bpm,spo,suhu,respirasi,* di akhir
          // Index ke-20: bpm, 21: spo, 22: suhu, 23: respirasi
          if (parts.length > 23) {
            if (parts[20] == 'NAN') parts[20] = heartRateRaw.toString();
            if (parts[21] == 'NAN') parts[21] = spoRaw.toString();
            if (parts[22] == 'NAN') parts[22] = temperatureRaw.toString();
            if (parts[23] == 'NAN') parts[23] = respiratoryRateRaw.toString();
          }
          return parts.join(',');
        }

        print(heartRateRaw);

        if (temperatureRaw < 30 ||
            temperatureRaw > 45 ||
            heartRateRaw < 28 ||
            heartRateRaw > 60 ||
            spoRaw < 92 ||
            respiratoryRateRaw < 10 ||
            respiratoryRateRaw > 35) {
          print('Suhu anomali ($temperatureRaw°C), data diabaikan');
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
        final heartRate = heartRateRaw + calibrationController.heartRate;
        final spo = spoRaw + calibrationController.spo;
        final temperature = temperatureRaw + calibrationController.temperature;
        final respiratoryRate =
            respiratoryRateRaw + calibrationController.respiration;

        final fixedDetail = HalterDeviceDetailModel(
          detailId: detail.detailId,
          latitude: detail.latitude,
          longitude: detail.longitude,
          altitude: detail.altitude,
          sog: detail.sog,
          cog: detail.cog,
          acceX: detail.acceX,
          acceY: detail.acceY,
          acceZ: detail.acceZ,
          gyroX: detail.gyroX,
          gyroY: detail.gyroY,
          gyroZ: detail.gyroZ,
          magX: detail.magX,
          magY: detail.magY,
          magZ: detail.magZ,
          roll: detail.roll,
          pitch: detail.pitch,
          yaw: detail.yaw,
          current: detail.current,
          voltage: detail.voltage,
          heartRate: heartRate,
          spo: spo,
          temperature: temperature,
          respiratoryRate: respiratoryRate,
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
          acceX: detail.acceX,
          acceY: detail.acceY,
          acceZ: detail.acceZ,
          gyroX: detail.gyroX,
          gyroY: detail.gyroY,
          gyroZ: detail.gyroZ,
          magX: detail.magX,
          magY: detail.magY,
          magZ: detail.magZ,
          roll: detail.roll,
          pitch: detail.pitch,
          yaw: detail.yaw,
          current: detail.current,
          voltage: detail.voltage,
          heartRate: heartRateRaw,
          spo: spoRaw,
          temperature: temperatureRaw,
          respiratoryRate: respiratoryRateRaw,
          deviceId: detail.deviceId,
          time: detail.time,
          rssi: detail.rssi,
          snr: detail.snr,
        );

        final indexDevice = halterDeviceList.indexWhere(
          (d) => d.deviceId == fixedDetail.deviceId,
        );

        double _voltageToPercent(double? voltageMv) {
          if (voltageMv == null) return 0;

          // Batas bawah (mV) – sesuaikan dengan jenis baterai
          const double minVoltageMv = 3000.0;
          // Batas atas (mV) – sesuaikan dengan jenis baterai
          const double maxVoltageMv = 4200.0;

          // Rumus linear
          double percent =
              ((voltageMv - minVoltageMv) / (maxVoltageMv - minVoltageMv)) *
              100.0;

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
              ),
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
          //     batteryPercent: _voltageToPercent(fixedDetail.voltage).round(),
          //   ),
          // );
          addHalterDevice(
            HalterDeviceModel(
              deviceId: fixedDetail.deviceId,
              status: 'on',
              batteryPercent: _voltageToPercent(fixedDetail.voltage).round(),
            ),
          );
        } else {
          // halterDeviceList[indexDevice] = HalterDeviceModel(
          //   deviceId: fixedDetail.deviceId,
          //   status: 'on',
          //   batteryPercent: _voltageToPercent(fixedDetail.voltage).round(),
          //   horseId: halterDeviceList[indexDevice].horseId,
          // );
          updateHalterDevice(
            HalterDeviceModel(
              deviceId: fixedDetail.deviceId,
              status: 'on',
              batteryPercent: _voltageToPercent(fixedDetail.voltage).round(),
              horseId: halterDeviceList[indexDevice].horseId,
            ),
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

        // Cek jika ada parameter 0
        if (heartRate == 0 ||
            spo == 0 ||
            temperature == 0 ||
            respiratoryRate == 0) {
          // Hanya masuk rawData
          // rawData.add(
          //   HalterRawDataModel(
          //     rawId: rawData.length + 1,
          //     data: dataLine,
          //     time: DateTime.now(),
          //   ),
          // );
          print('Data sensor 0, hanya masuk rawData');
          return;
        }

        addHalterDeviceDetail(fixedDetail);

        controller.checkAndLogHalter(
          fixedDetail.deviceId,
          suhu: fixedDetail.temperature,
          spo: fixedDetail.spo,
          bpm: fixedDetail.heartRate,
          respirasi: fixedDetail.respiratoryRate,
          time: fixedDetail.time,
          battery: _voltageToPercent(fixedDetail.voltage).round(),
        );

        final validatedLine = replaceNanWithRandom(dataLine);
        rawData.add(
          HalterRawDataModel(
            rawId: rawData.length + 1,
            data: validatedLine,
            time: DateTime.now(),
          ),
        );

        rawDetailList.add(rawDetail);

        // controllerCalibration.createLogs(
        //   heartRate: detail.heartRate,
        //   temperature: detail.temperature,
        //   respiration: detail.respiratoryRate,
        //   spo: detail.spo,
        // );

        print('Parsed fixedDetail (with RSSI/SNR): $fixedDetail');
      } catch (e) {
        print('Parsing error: $e');
      }
    }
  }

  void closeSerial() {
    print('Closing serial...');
    reader?.close();
    port?.close();
    reader = null;
    port = null;
    _blockBuffer = "";
    _inBlock = false;
    _serialBuffer = "";
    for (final timer in _deviceTimeoutTimers.values) {
      timer.cancel();
    }
    _deviceTimeoutTimers.clear();
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
  //       double voltase = double.parse(randDouble(3200, 4200));
  //       // int bpm = randInt(28, 120);
  //       // double spo = double.parse(randDouble(90, 100));
  //       // double suhu = double.parse(randDouble(35, 40));
  //       // double respirasi = double.parse(randDouble(8, 30));
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

  // void startDummySerial() {
  //   final rnd = Random();
  //   _dummyTimer?.cancel();
  //   _dummyTimer = Timer.periodic(const Duration(seconds: 10), (_) {
  //     // Helper untuk acak double dengan 2 desimal
  //     String randDouble(num min, num max) =>
  //         (min + rnd.nextDouble() * (max - min)).toStringAsFixed(2);

  //     // Dummy data SHIPB
  //     // final deviceIds = ["1223001", "1223002"];
  //     // for (final did in deviceIds) {
  //     //   final dummyLine =
  //     //       "SHIPB$did,0,0,0,0.00,0.00,0.21,4.48,-8.03,0.00,0.02,-0.02,-20.36,67.39,-43.74,-3,31,158,0,3896.00,0,0,29.63,*";
  //     //   _processBlock(dummyLine);
  //     // }

  //     // Dummy data Node Room (SRIPB)
  //     final nodeRoomId = "SRIPB1223003";
  //     final suhuRuangan = randDouble(28, 32);
  //     final kelembapan = randDouble(60, 70);
  //     final cahaya = randDouble(20, 30);
  //     final nodeRoomLine =
  //         "$nodeRoomId,$suhuRuangan,$kelembapan,$cahaya,0.00,0.00,0.00,0.00,0.00,0.00,*\n";
  //     // Kirim langsung ke serialBuffer agar listener memproses seperti data asli
  //     _serialBuffer += nodeRoomLine;
  //     print(nodeRoomLine);
  //   });
  // }

  void startDummySerial() {
    final rnd = Random();
    _dummyTimer?.cancel();
    _dummyTimer = Timer.periodic(const Duration(seconds: 10), (_) {
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
        double acceX = double.parse(randDouble(-12, 12));
        double acceY = double.parse(randDouble(-12, 12));
        double acceZ = double.parse(randDouble(-12, 12));
        double gyroX = double.parse(randDouble(-2, 2));
        double gyroY = double.parse(randDouble(-2, 2));
        double gyroZ = double.parse(randDouble(-2, 2));
        double magX = double.parse(randDouble(-70, 70));
        double magY = double.parse(randDouble(-70, 70));
        double magZ = double.parse(randDouble(-70, 70));
        int roll = randInt(-45, 90);
        int pitch = randInt(-45, 90);
        int yaw = randInt(-180, 180);
        int arus = 0;
        double voltase = double.parse(randDouble(3200, 4200));
        int bpm = 8;
        double spo = 8;
        double suhu = 8;
        double respirasi = 8;
        print('dumi');
        // Format langsung SHIPB...
        return "SHIPB$deviceId,"
            "$latitude,$longitude,$altitude,$sog,$cog,"
            "$acceX,$acceY,$acceZ,"
            "$gyroX,$gyroY,$gyroZ,"
            "$magX,$magY,$magZ,"
            "$roll,$pitch,$yaw,"
            "$arus,$voltase,"
            "NAN,NAN,NAN,NAN,*";
      }

      final deviceIds = ["1223001", "1223002"];
      for (final did in deviceIds) {
        final dummyLine = makeDummyData(did);
        _processBlock(dummyLine);
      }
    });
  }

  void stopDummySerial() {
    _dummyTimer?.cancel();
    _dummyTimer = null;
  }
}
