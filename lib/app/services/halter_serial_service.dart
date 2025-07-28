import 'dart:typed_data';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/models/halter_device_detail_model.dart';
import 'package:smart_feeder_desktop/app/models/halter_raw_data_model.dart';

class HalterSerialService extends GetxService {
  SerialPort? port;
  SerialPortReader? reader;

  // Data terakhir dari SHIPB...,* sudah diparse ke model
  final Rxn<HalterDeviceDetailModel> latestDetail =
      Rxn<HalterDeviceDetailModel>();

  final RxList<HalterDeviceDetailModel> detailHistory =
      <HalterDeviceDetailModel>[].obs;

  final RxList<HalterRawDataModel> rawData =
      <HalterRawDataModel>[].obs;

  // List available ports
  RxList<String> get availablePorts => RxList<String>(SerialPort.availablePorts);

  // Inisialisasi serial dan start listening
  void initSerial(String portName, int baudRate) {
    closeSerial(); // Pastikan port lama ditutup sebelum buka baru
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
    reader!.stream.listen((data) {
      final line = String.fromCharCodes(data).trim();
      if (line.startsWith('SHIPB') && line.endsWith('*')) {
        print('Serial Data: $line');
        try {
          final detail = HalterDeviceDetailModel.fromSerial(line);
          latestDetail.value = detail;
          detailHistory.add(detail);
          rawData.add(HalterRawDataModel(
            no: rawData.length + 1,
            data: line,
            tanggal: DateTime.now().toIso8601String().split('T')[0],
            waktu: DateTime.now().toIso8601String().split('T')[1].split('.')[0],
          ));
          print('Parsed detail: $detail');
        } catch (e) {
          print('Parsing error: $e');
        }
      }
    });
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
}
