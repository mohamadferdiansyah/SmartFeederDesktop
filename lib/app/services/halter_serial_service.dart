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
import 'package:smart_feeder_desktop/app/modules/smart_halter/rule_engine/halter_rule_engine_controller.dart';

class HalterSerialService extends GetxService {
  SerialPort? port;
  SerialPortReader? reader;

  final HalterRuleEngineController controller =
      Get.find<HalterRuleEngineController>();

  final DataController dataController = Get.find<DataController>();

  final Rxn<HalterDeviceDetailModel> latestDetail =
      Rxn<HalterDeviceDetailModel>();

  final Rxn<NodeRoomModel> latestNodeRoomData = Rxn<NodeRoomModel>();

  RxList<HalterDeviceDetailModel> get detailHistoryList =>
      dataController.detailHistory;

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
        const Duration(seconds: 10),
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
      const Duration(seconds: 30),
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

        // Proses per baris (\n)
        while (_serialBuffer.contains('\n')) {
          final idx = _serialBuffer.indexOf('\n');
          String line = _serialBuffer.substring(0, idx).trim();
          _serialBuffer = _serialBuffer.substring(idx + 1);
          // print('Line: $line');

          if (line.startsWith('=== RECEIVED DATA ===')) {
            _inBlock = true;
            _blockBuffer = "";
            continue;
          }
          if (_inBlock && line.startsWith('===================')) {
            // Selesai block, proses
            _processBlock(_blockBuffer);
            _inBlock = false;
            _blockBuffer = "";
            continue;
          }
          if (_inBlock) {
            _blockBuffer += line + '\n';
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
      if (line.startsWith('Data:')) {
        final d = line.substring(5).trim();
        if (d.startsWith('SHIPB')) {
          dataLine = d;
        }
      } else if (line.startsWith('RSSI:')) {
        final match = RegExp(r'RSSI:\s*([-+]?\d+)').firstMatch(line);
        if (match != null) {
          rssi = int.tryParse(match.group(1)!);
        }
      } else if (line.startsWith('SNR:')) {
        final match = RegExp(r'SNR:\s*([-+]?\d*\.?\d*)').firstMatch(line);
        if (match != null) {
          snr = double.tryParse(match.group(1)!);
        }
      }
    }

    if (dataLine != null) {
      try {
        final detail = HalterDeviceDetailModel.fromSerial(
          dataLine,
          rssi: rssi,
          snr: snr,
        );
        latestDetail.value = detail;

        final indexDevice = halterDeviceList.indexWhere(
          (d) => d.deviceId == detail.deviceId,
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

        if (_pairingDevices.contains(detail.deviceId)) {
          final idx = halterDeviceList.indexWhere(
            (d) => d.deviceId == detail.deviceId,
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
            _pairingDevices.remove(detail.deviceId);
            _devicePairingTimers[detail.deviceId]?.cancel();
          }
        }

        _resetDeviceTimeout(detail.deviceId);

        if (indexDevice == -1) {
          // halterDeviceList.add(
          //   HalterDeviceModel(
          //     deviceId: detail.deviceId,
          //     status: 'on',
          //     batteryPercent: _voltageToPercent(detail.voltage).round(),
          //   ),
          // );
          addHalterDevice(
            HalterDeviceModel(
              deviceId: detail.deviceId,
              status: 'on',
              batteryPercent: _voltageToPercent(detail.voltage).round(),
            ),
          );
        } else {
          // halterDeviceList[indexDevice] = HalterDeviceModel(
          //   deviceId: detail.deviceId,
          //   status: 'on',
          //   batteryPercent: _voltageToPercent(detail.voltage).round(),
          //   horseId: halterDeviceList[indexDevice].horseId,
          // );
          updateHalterDevice(
            HalterDeviceModel(
              deviceId: detail.deviceId,
              status: 'on',
              batteryPercent: _voltageToPercent(detail.voltage).round(),
              horseId: halterDeviceList[indexDevice].horseId,
            ),
          );
        }

        // final index = detailHistoryList.indexWhere(
        //   (d) => d.deviceId == detail.deviceId && d.time == detail.time,
        // );
        // if (index == -1) {
        //   dataController.addHalterDeviceDetail(detail);
        // } else {
        //   dataController.updateHalterDeviceDetail(detail);
        // }
        addHalterDeviceDetail(detail);

        controller.checkAndLogHalter(
          detail.deviceId,
          suhu: detail.temperature,
          spo: detail.spo,
          bpm: detail.heartRate,
          respirasi: detail.respiratoryRate,
          time: detail.time,
          battery: _voltageToPercent(detail.voltage).round(),
        );

        rawData.add(
          HalterRawDataModel(
            rawId: rawData.length + 1,
            data: dataLine,
            time: DateTime.now(),
          ),
        );

        print('Parsed detail (with RSSI/SNR): $detail');
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

  // Timer? _dummyTimer;

  // void startDummySerial() {
  //   final rnd = Random();
  //   _dummyTimer?.cancel();
  //   _dummyTimer = Timer.periodic(const Duration(seconds: 5), (_) {
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
  //       int bpm = randInt(28, 120);
  //       double spo = double.parse(randDouble(90, 100));
  //       double suhu = double.parse(randDouble(35, 40));
  //       double respirasi = double.parse(randDouble(8, 30));

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

  // void stopDummySerial() {
  //   _dummyTimer?.cancel();
  //   _dummyTimer = null;
  // }
}
