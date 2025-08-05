import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_device_detail_model.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_raw_data_model.dart';
import 'package:smart_feeder_desktop/app/models/halter/node_room_model.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/rule_engine/halter_rule_engine_controller.dart'; // import model baru

class HalterSerialService extends GetxService {
  SerialPort? port;
  SerialPortReader? reader;

  final HalterRuleEngineController controller =
      Get.find<HalterRuleEngineController>();

  final Rxn<HalterDeviceDetailModel> latestDetail =
      Rxn<HalterDeviceDetailModel>();

  final Rxn<NodeRoomModel> latestNodeRoomData = Rxn<NodeRoomModel>();

  final RxList<HalterDeviceDetailModel> detailHistory =
      <HalterDeviceDetailModel>[
        // HalterDeviceDetailModel(
        //   detailId: 1,
        //   heartRate: 40,
        //   temperature: 37.5,
        //   spo: 97.5,
        //   respiratoryRate: 12,
        //   time: DateTime.now().subtract(Duration(minutes: 4)),
        //   deviceId: 'SHIPB1223002',
        // ),
        // HalterDeviceDetailModel(
        //   detailId: 2,
        //   heartRate: 42,
        //   temperature: 37.6,
        //   spo: 98.2,
        //   respiratoryRate: 13,
        //   time: DateTime.now().subtract(Duration(minutes: 3)),
        //   deviceId: 'SHIPB1223002',
        // ),
        // HalterDeviceDetailModel(
        //   detailId: 3,
        //   heartRate: 41,
        //   temperature: 37.7,
        //   spo: 97.9,
        //   respiratoryRate: 14,
        //   time: DateTime.now().subtract(Duration(minutes: 2)),
        //   deviceId: 'SHIPB1223002',
        // ),
        // HalterDeviceDetailModel(
        //   detailId: 4,
        //   heartRate: 43,
        //   temperature: 37.8,
        //   spo: 98.5,
        //   respiratoryRate: 13,
        //   time: DateTime.now().subtract(Duration(minutes: 1)),
        //   deviceId: 'SHIPB1223002',
        // ),
        // HalterDeviceDetailModel(
        //   detailId: 5,
        //   heartRate: 44,
        //   temperature: 37.9,
        //   spo: 98.1,
        //   respiratoryRate: 12,
        //   time: DateTime.now(),
        //   deviceId: 'SHIPB1223002',
        // ),
      ].obs;

  final RxList<HalterRawDataModel> rawData = <HalterRawDataModel>[].obs;

  final RxList<NodeRoomModel> nodeRoomList = <NodeRoomModel>[
    // NodeRoomModel(
    //   deviceId: 'SRIPB1223003',
    //   temperature: 25.0,
    //   humidity: 60.0,
    //   lightIntensity: 300.0,
    //   time: DateTime.now().subtract(Duration(minutes: 4)),
    // ),
    // NodeRoomModel(
    //   deviceId: 'SRIPB1223003',
    //   temperature: 35.0,
    //   humidity: 49.0,
    //   lightIntensity: 291.0,
    //   time: DateTime.now().subtract(Duration(minutes: 4)),
    // ),
    // NodeRoomModel(
    //   deviceId: 'SRIPB1223003',
    //   temperature: 31.0,
    //   humidity: 45.0,
    //   lightIntensity: 210.0,
    //   time: DateTime.now().subtract(Duration(minutes: 4)),
    // ),
    // NodeRoomModel(
    //   deviceId: 'SRIPB1223003',
    //   temperature: 25.0,
    //   humidity: 60.0,
    //   lightIntensity: 300.0,
    //   time: DateTime.now().subtract(Duration(minutes: 4)),
    // ),
    // NodeRoomModel(
    //   deviceId: 'SRIPB1223003',
    //   temperature: 35.0,
    //   humidity: 49.0,
    //   lightIntensity: 291.0,
    //   time: DateTime.now().subtract(Duration(minutes: 4)),
    // ),
  ].obs; // Tambah list untuk node room

  RxList<String> get availablePorts =>
      RxList<String>(SerialPort.availablePorts);

  String _serialBuffer = "";

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
    reader!.stream.listen(
      (data) {
        // Gabungkan data ke buffer
        _serialBuffer += String.fromCharCodes(data);

        // Proses semua baris utuh (yang berakhiran *)
        while (_serialBuffer.contains('*')) {
          final endIdx = _serialBuffer.indexOf('*');
          final line = _serialBuffer.substring(0, endIdx + 1).trim();
          _serialBuffer = _serialBuffer.substring(endIdx + 1);

          print('Received full line: $line');

          // --- PROSES SEPERTI SEBELUMNYA ---
          if (line.startsWith('SHIPB') && line.endsWith('*')) {
            print('Serial Data: $line');
            try {
              final detail = HalterDeviceDetailModel.fromSerial(line);
              latestDetail.value = detail;

              // Ganti dengan pattern replace, bukan edit field
              final index = detailHistory.indexWhere(
                (d) => d.deviceId == detail.deviceId,
              );
              if (index == -1) {
                detailHistory.add(detail);
              } else {
                detailHistory[index] = detail;
              }

              controller.checkAndLog(
                detail.deviceId,
                suhu: detail.temperature,
                spo: detail.spo,
                bpm: detail.heartRate,
                respirasi: detail.respiratoryRate,
                time: detail.time,
              );

              rawData.add(
                HalterRawDataModel(
                  rawId: rawData.length + 1,
                  data: line,
                  time: DateTime.now(),
                ),
              );

              print('Parsed detail: $detail');
            } catch (e) {
              print('Parsing error: $e');
            }
          }

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

  void closeSerial() {
    print('Closing serial...');
    reader?.close();
    port?.close();
    reader = null;
    port = null;
  }

  void sendToSerial(String message) {
    if (port != null && port!.isOpen) {
      port!.write(Uint8List.fromList(message.codeUnits));
      print('Sent to serial: $message');
    }
  }

  // Tambahkan di class HalterSerialService:
  // Timer? _dummyTimer;

  // void startDummyData() {
  //   _dummyTimer?.cancel(); // jika sudah ada, matikan dulu
  //   _dummyTimer = Timer.periodic(const Duration(seconds: 5), (_) {
  //     // Simulasi detail baru
  //     final newDetail = HalterDeviceDetailModel(
  //       detailId: detailHistory.length + 1,
  //       heartRate: 40 + detailHistory.length % 10,
  //       temperature: 37.5 + (detailHistory.length % 5) * 0.1,
  //       spo: 96.0 + (detailHistory.length % 5),
  //       respiratoryRate: 12 + (detailHistory.length % 3),
  //       time: DateTime.now(),
  //       deviceId: 'SHIPB1223002',
  //     );
  //     latestDetail.value = newDetail;
  //     detailHistory.add(newDetail);

  //     // Simulasi node room baru
  //     final newNodeRoom = NodeRoomModel(
  //       deviceId: 'SRIPB1223003',
  //       temperature: 25 + (nodeRoomList.length % 10) * 0.5,
  //       humidity: 50 + (nodeRoomList.length % 10) * 1.1,
  //       lightIntensity: 200 + (nodeRoomList.length % 10) * 5.0,
  //       time: DateTime.now(),
  //     );
  //     latestNodeRoomData.value = newNodeRoom;
  //     nodeRoomList.add(newNodeRoom);

  //     print('Dummy data injected!');
  //   });
  // }

  // void stopDummyData() {
  //   _dummyTimer?.cancel();
  //   _dummyTimer = null;
  // }
}
