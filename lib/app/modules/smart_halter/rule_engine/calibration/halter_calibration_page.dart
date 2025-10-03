import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:smart_feeder_desktop/app/constants/app_colors.dart';
import 'package:smart_feeder_desktop/app/data/storage/halter/data_halter_device_calibration.dart';
import 'package:smart_feeder_desktop/app/data/storage/halter/data_halter_device_calibration_offset.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_biometric_rule_engine_model.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_calibration_log_model.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_device_calibration_model.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_device_calibration_offset_model.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_device_detail_model.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/data_logs/log_calibration/halter_calibration_log_controller.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/rule_engine/table/halter_table_rule_engine_controller.dart';
import 'package:smart_feeder_desktop/app/utils/toast_utils.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_button.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_card.dart';
import 'package:toastification/toastification.dart';
import 'halter_calibration_controller.dart';

class HalterCalibrationPage extends StatefulWidget {
  const HalterCalibrationPage({super.key});

  @override
  State<HalterCalibrationPage> createState() => _HalterCalibrationPageState();
}

class _HalterCalibrationPageState extends State<HalterCalibrationPage> {
  final HalterCalibrationController controller =
      Get.find<HalterCalibrationController>();

  final RxList<HalterDeviceCalibrationOffsetModel> offsetList =
      <HalterDeviceCalibrationOffsetModel>[].obs;
  final RxMap<String, HalterDeviceDetailModel> lastSensorMap =
      <String, HalterDeviceDetailModel>{}.obs;

  // Tambahkan list log khusus
  // List<DataRow> _logRows = [];
  final RxMap<String, bool> _isLoadingDevice = <String, bool>{}.obs;

  // bool _isLatestLogExist(String? timestamp) {
  //   return _logRows.any(
  //     (row) =>
  //         row.cells.length > 1 &&
  //         (row.cells[1].child as Text).data == timestamp,
  //   );
  // }

  Future<HalterDeviceDetailModel?> _waitForLatestRawDeviceData(
    String deviceId, {
    DateTime? lastTime,
    Duration timeout = const Duration(minutes: 1),
  }) async {
    print('[Polling RAW] Menunggu data deviceId: $deviceId ...');
    final detailList = controller.dataController.rawDetailHistoryList;
    final completer = Completer<HalterDeviceDetailModel?>();
    final start = DateTime.now();

    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      print('[Polling RAW] Cek data deviceId: $deviceId');
      final latest = detailList.lastWhereOrNull(
        (d) =>
            d.deviceId == deviceId &&
            (lastTime == null || d.time.isAfter(lastTime)),
      );
      if (latest != null) {
        print('[Polling RAW] Data BARU ditemukan untuk deviceId: $deviceId');
        timer.cancel();
        completer.complete(latest);
      } else if (DateTime.now().difference(start) > timeout) {
        print('[Polling RAW] Timeout menunggu data deviceId: $deviceId');
        timer.cancel();
        completer.complete(null);
      }
    });

    return completer.future;
  }

  // Fungsi untuk generate log dari rawDetailHistoryList
  // void _addLatestLogRow() {
  //   final calibration = controller.calibration.value;
  //   final rawDetailList = controller.rawDetailHistoryList;
  //   if (rawDetailList.isEmpty) return;

  //   final detail = rawDetailList.last;
  //   final timestamp = detail.time.toString();
  //   if (_isLatestLogExist(timestamp)) return; // Prevent duplicate log

  //   final id = _logRows.length + 1;

  //   final newRows = [
  //     DataRow(
  //       cells: [
  //         DataCell(Text(id.toString())),
  //         DataCell(Text(timestamp.toString())),
  //         DataCell(Text('Suhu Badan (°C)')),
  //         DataCell(Text('${detail.temperature?.toStringAsFixed(2) ?? "-"} ')),
  //         DataCell(Text('${detail.temperature?.toStringAsFixed(2) ?? "-"} ')),
  //         DataCell(Text('${calibration.temperature.toStringAsFixed(2)} ')),
  //       ],
  //     ),
  //     DataRow(
  //       cells: [
  //         DataCell(Text(id.toString())),
  //         DataCell(Text(timestamp.toString())),
  //         DataCell(Text('Detak Jantung (beat/m)')),
  //         DataCell(Text('${detail.heartRate?.toStringAsFixed(2) ?? "-"}')),
  //         DataCell(Text('${detail.heartRate?.toStringAsFixed(2) ?? "-"}')),
  //         DataCell(Text('${calibration.heartRate.toStringAsFixed(2)}')),
  //       ],
  //     ),
  //     DataRow(
  //       cells: [
  //         DataCell(Text(id.toString())),
  //         DataCell(Text(timestamp.toString())),
  //         DataCell(Text('SPO')),
  //         DataCell(Text('${detail.spo?.toStringAsFixed(2) ?? "-"}')),
  //         DataCell(Text('${detail.spo?.toStringAsFixed(2) ?? "-"}')),
  //         DataCell(Text('${calibration.spo.toStringAsFixed(2)}')),
  //       ],
  //     ),
  //     DataRow(
  //       cells: [
  //         DataCell(Text(id.toString())),
  //         DataCell(Text(timestamp.toString())),
  //         DataCell(Text('Respirasi (breath/m)')),
  //         DataCell(
  //           Text('${detail.respiratoryRate?.toStringAsFixed(2) ?? "-"}'),
  //         ),
  //         DataCell(
  //           Text('${detail.respiratoryRate?.toStringAsFixed(2) ?? "-"}'),
  //         ),
  //         DataCell(Text('${calibration.respiration.toStringAsFixed(2)}')),
  //       ],
  //     ),
  //     // Node Room
  //     DataRow(
  //       cells: [
  //         DataCell(Text(id.toString())),
  //         DataCell(Text(timestamp.toString())),
  //         DataCell(Text('Suhu Ruangan')),
  //         DataCell(Text('Node Room')),
  //         DataCell(Text('${calibration.roomTemperature.toStringAsFixed(2)} ')),
  //         DataCell(Text('${calibration.roomTemperature.toStringAsFixed(2)} ')),
  //         DataCell(Text('${calibration.roomTemperature.toStringAsFixed(2)} ')),
  //       ],
  //     ),
  //     DataRow(
  //       cells: [
  //         DataCell(Text(id.toString())),
  //         DataCell(Text(timestamp.toString())),
  //         DataCell(Text('Kelembapan')),
  //         DataCell(Text('Node Room')),
  //         DataCell(Text('${calibration.humidity.toStringAsFixed(2)}')),
  //         DataCell(Text('${calibration.humidity.toStringAsFixed(2)}')),
  //         DataCell(Text('${calibration.humidity.toStringAsFixed(2)}')),
  //       ],
  //     ),
  //     DataRow(
  //       cells: [
  //         DataCell(Text(id.toString())),
  //         DataCell(Text(timestamp.toString())),
  //         DataCell(Text('Indeks Cahaya')),
  //         DataCell(Text('Node Room')),
  //         DataCell(
  //           Text('${calibration.lightIntensity.toStringAsFixed(2)} lux'),
  //         ),
  //         DataCell(
  //           Text('${calibration.lightIntensity.toStringAsFixed(2)} lux'),
  //         ),
  //         DataCell(
  //           Text('${calibration.lightIntensity.toStringAsFixed(2)} lux'),
  //         ),
  //       ],
  //     ),
  //   ];

  //   setState(() {
  //     _logRows.addAll(newRows);
  //   });
  //   controller.logRows.addAll(newRows);
  // }

  // Future<void> _kalibrasiDevice(
  //   String deviceId,
  //   HalterDeviceCalibrationModel referensi,
  // ) async {
  //   print('[Kalibrasi] Mulai kalibrasi deviceId: $deviceId');
  //   final latest = await _waitForLatestRawDeviceData(deviceId);

  //   if (latest == null) {
  //     print(
  //       '[Kalibrasi] Data sensor tidak ditemukan untuk deviceId: $deviceId',
  //     );
  //     Get.snackbar(
  //       "Data Tidak Ditemukan",
  //       "Belum ada data sensor dari device $deviceId (timeout).",
  //       snackPosition: SnackPosition.TOP,
  //       backgroundColor: Colors.redAccent,
  //       colorText: Colors.white,
  //     );
  //     return;
  //   }

  //   print('[Kalibrasi] Data sensor ditemukan, proses hitung offset...');
  //   final offset = HalterDeviceCalibrationOffsetModel(
  //     deviceId: deviceId,
  //     temperatureOffset: referensi.temperature - (latest.temperature ?? 0),
  //     heartRateOffset: referensi.heartRate - (latest.heartRate ?? 0),
  //     spoOffset: referensi.spo - (latest.spo ?? 0),
  //     respirationOffset: referensi.respiration - (latest.respiratoryRate ?? 0),
  //     updatedAt: DateTime.now(),
  //   );
  //   DataHalterDeviceCalibrationOffset.save(offset);

  //   print('[Kalibrasi] Offset tersimpan untuk deviceId: $deviceId');
  //   print(
  //     '[Kalibrasi] Suhu: ${offset.temperatureOffset}, BPM: ${offset.heartRateOffset}, SPO: ${offset.spoOffset}, Respirasi (breath/m): ${offset.respirationOffset}',
  //   );

  //   Get.snackbar(
  //     "Kalibrasi Tersimpan",
  //     "Offset device $deviceId:\n"
  //         "Suhu: ${offset.temperatureOffset.toStringAsFixed(2)}, "
  //         "BPM: ${offset.heartRateOffset.toStringAsFixed(2)}, "
  //         "SPO: ${offset.spoOffset.toStringAsFixed(2)}, "
  //         "Respirasi (breath/m): ${offset.respirationOffset.toStringAsFixed(2)}",
  //     snackPosition: SnackPosition.TOP,
  //     backgroundColor: Colors.green,
  //     colorText: Colors.white,
  //   );
  // }

  late TextEditingController suhuSlopeCtrl,
      heartRateSlopeCtrl,
      respirationSlopeCtrl,
      suhuInterceptCtrl,
      heartRateInterceptCtrl,
      respirationInterceptCtrl;

  @override
  void initState() {
    super.initState();

    // Hapus bagian ini karena controller.calibration.value tidak ada
    // final c = controller.calibration.value;

    // Gunakan default values untuk initialization
    const defaultSlope = 1.0;
    const defaultIntercept = 0.0;

    // Initialize controllers for slopes
    suhuSlopeCtrl = TextEditingController(text: defaultSlope.toString());
    heartRateSlopeCtrl = TextEditingController(text: defaultSlope.toString());
    respirationSlopeCtrl = TextEditingController(text: defaultSlope.toString());

    // Initialize controllers for intercepts
    suhuInterceptCtrl = TextEditingController(
      text: defaultIntercept.toString(),
    );
    heartRateInterceptCtrl = TextEditingController(
      text: defaultIntercept.toString(),
    );
    respirationInterceptCtrl = TextEditingController(
      text: defaultIntercept.toString(),
    );

    // --- PATCH: load last calibration and raw data for each device ---
    final halterDeviceList = controller.dataController.halterDeviceList;
    for (final device in halterDeviceList) {
      // 1. Ambil offset kalibrasi terakhir
      final offset = DataHalterDeviceCalibrationOffset.getByDeviceId(
        device.deviceId,
      );
      if (offset != null) {
        final idx = offsetList.indexWhere((o) => o.deviceId == device.deviceId);
        if (idx >= 0)
          offsetList[idx] = offset;
        else
          offsetList.add(offset);
      }

      // 2. Ambil data RAW terakhir dari device
      final rawDetailList = controller.dataController.rawDetailHistoryList;
      final latestRaw = rawDetailList
          .where((d) => d.deviceId == device.deviceId)
          .sorted((a, b) => b.time.compareTo(a.time))
          .firstOrNull;
      if (latestRaw != null) {
        lastSensorMap[device.deviceId] = latestRaw;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: CustomCard(
          withExpanded: false,
          scrollable: false,
          title: 'Kalibrasi Sensor',
          content: DefaultTabController(
            length: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TabBar(
                  labelColor: AppColors.primary,
                  unselectedLabelColor: Colors.black54,
                  indicatorColor: AppColors.primary,
                  tabs: const [
                    Tab(
                      text: "Kalibrasi Halter & Node Room",
                      icon: Icon(Icons.settings_rounded),
                    ),
                    // Tab(
                    //   text: "Kalibrasi Per Device",
                    //   icon: Icon(Icons.devices_other),
                    // ),
                    // Tab(text: "Log Kalibrasi", icon: Icon(Icons.sensor_door)),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.76,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TabBarView(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: _buildKalibrasiHalterTab(context),
                        ),
                        // Padding(
                        //   padding: const EdgeInsets.all(6.0),
                        //   child: _buildDeviceCalibrationTab(context),
                        // ),
                        // Padding(
                        //   padding: const EdgeInsets.all(6.0),
                        //   child: _buildLogTableSection(context),
                        // ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKalibrasiHalterTab(BuildContext context) {
    final halterDeviceList = controller.dataController.halterDeviceList;
    final Rx<String?> selectedDeviceId =
        (halterDeviceList.isNotEmpty ? halterDeviceList.first.deviceId : null)
            .obs;

    // Controllers untuk device yang dipilih
    final Map<String, Map<String, TextEditingController>> deviceControllers =
        {};

    // Initialize controllers untuk semua device
    for (final device in halterDeviceList) {
      final calibration = controller.getCalibrationForDevice(device.deviceId);
      deviceControllers[device.deviceId] = {
        'temperatureSlope': TextEditingController(
          text: calibration.temperatureSlope.toString(),
        ),
        'temperatureIntercept': TextEditingController(
          text: calibration.temperatureIntercept.toString(),
        ),
        'heartRateSlope': TextEditingController(
          text: calibration.heartRateSlope.toString(),
        ),
        'heartRateIntercept': TextEditingController(
          text: calibration.heartRateIntercept.toString(),
        ),
        'respirationSlope': TextEditingController(
          text: calibration.respirationSlope.toString(),
        ),
        'respirationIntercept': TextEditingController(
          text: calibration.respirationIntercept.toString(),
        ),
      };
    }

    return Obx(() {
      final currentDeviceId = selectedDeviceId.value;
      final controllers = currentDeviceId != null
          ? deviceControllers[currentDeviceId]
          : null;

      return Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'IoT Node Halter',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            DropdownButtonFormField<String>(
              value: selectedDeviceId.value,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: "Pilih IoT Node Halter",
              ),
              items: halterDeviceList
                  .map(
                    (d) => DropdownMenuItem(
                      value: d.deviceId,
                      child: Text(d.deviceId),
                    ),
                  )
                  .toList(),
              onChanged: (id) => selectedDeviceId.value = id,
            ),
            SizedBox(height: 16),
            if (controllers != null) ...[
              CustomCard(
                trailing: Icon(
                  Icons.device_hub_rounded,
                  color: Colors.white,
                  size: 30,
                ),
                withExpanded: false,
                height: MediaQuery.of(context).size.height * 0.27,
                title: "Slope Sensor Halter - ${currentDeviceId}",
                content: Column(
                  children: [
                    Wrap(
                      spacing: 18,
                      runSpacing: 18,
                      children: [
                        _inputCard(
                          title: 'Suhu Badan (°C)',
                          icon: Icons.thermostat_outlined,
                          controller: controllers['temperatureSlope']!,
                          onMinus: () {
                            final val =
                                double.tryParse(
                                  controllers['temperatureSlope']!.text,
                                ) ??
                                0.0;
                            if (val > -1000) {
                              controllers['temperatureSlope']!.text =
                                  (val - 0.1).toStringAsFixed(1);
                            }
                          },
                          onPlus: () {
                            final val =
                                double.tryParse(
                                  controllers['temperatureSlope']!.text,
                                ) ??
                                0.0;
                            if (val < 1000) {
                              controllers['temperatureSlope']!.text =
                                  (val + 0.1).toStringAsFixed(1);
                            }
                          },
                          width: MediaQuery.of(context).size.width * 0.23,
                          height: MediaQuery.of(context).size.height * 0.16,
                        ),
                        _inputCard(
                          title: 'Detak Jantung (beat/m)',
                          icon: Icons.monitor_heart,
                          controller: controllers['heartRateSlope']!,
                          onMinus: () {
                            final val =
                                double.tryParse(
                                  controllers['heartRateSlope']!.text,
                                ) ??
                                0.0;
                            if (val > -1000) {
                              controllers['heartRateSlope']!.text = (val - 0.1)
                                  .toStringAsFixed(1);
                            }
                          },
                          onPlus: () {
                            final val =
                                double.tryParse(
                                  controllers['heartRateSlope']!.text,
                                ) ??
                                0.0;
                            if (val < 1000) {
                              controllers['heartRateSlope']!.text = (val + 0.1)
                                  .toStringAsFixed(1);
                            }
                          },
                          width: MediaQuery.of(context).size.width * 0.23,
                          height: MediaQuery.of(context).size.height * 0.16,
                        ),
                        _inputCard(
                          title: 'Respirasi (breath/m)',
                          icon: Icons.air,
                          controller: controllers['respirationSlope']!,
                          onMinus: () {
                            final val =
                                double.tryParse(
                                  controllers['respirationSlope']!.text,
                                ) ??
                                0.0;
                            if (val > -1000) {
                              controllers['respirationSlope']!.text =
                                  (val - 0.1).toStringAsFixed(1);
                            }
                          },
                          onPlus: () {
                            final val =
                                double.tryParse(
                                  controllers['respirationSlope']!.text,
                                ) ??
                                0.0;
                            if (val < 1000) {
                              controllers['respirationSlope']!.text =
                                  (val + 0.1).toStringAsFixed(1);
                            }
                          },
                          width: MediaQuery.of(context).size.width * 0.23,
                          height: MediaQuery.of(context).size.height * 0.16,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              CustomCard(
                trailing: Icon(
                  Icons.device_hub_rounded,
                  color: Colors.white,
                  size: 30,
                ),
                withExpanded: false,
                height: MediaQuery.of(context).size.height * 0.27,
                title: "Intercept Sensor Halter - ${currentDeviceId}",
                content: Column(
                  children: [
                    Wrap(
                      spacing: 18,
                      runSpacing: 18,
                      children: [
                        _inputCard(
                          title: 'Suhu Badan (°C)',
                          icon: Icons.thermostat_outlined,
                          controller: controllers['temperatureIntercept']!,
                          onMinus: () {
                            final val =
                                double.tryParse(
                                  controllers['temperatureIntercept']!.text,
                                ) ??
                                0.0;
                            if (val > -1000) {
                              controllers['temperatureIntercept']!.text =
                                  (val - 0.1).toStringAsFixed(1);
                            }
                          },
                          onPlus: () {
                            final val =
                                double.tryParse(
                                  controllers['temperatureIntercept']!.text,
                                ) ??
                                0.0;
                            if (val < 1000) {
                              controllers['temperatureIntercept']!.text =
                                  (val + 0.1).toStringAsFixed(1);
                            }
                          },
                          width: MediaQuery.of(context).size.width * 0.23,
                          height: MediaQuery.of(context).size.height * 0.16,
                        ),
                        _inputCard(
                          title: 'Detak Jantung (beat/m)',
                          icon: Icons.monitor_heart,
                          controller: controllers['heartRateIntercept']!,
                          onMinus: () {
                            final val =
                                double.tryParse(
                                  controllers['heartRateIntercept']!.text,
                                ) ??
                                0.0;
                            if (val > -1000) {
                              controllers['heartRateIntercept']!.text =
                                  (val - 0.1).toStringAsFixed(1);
                            }
                          },
                          onPlus: () {
                            final val =
                                double.tryParse(
                                  controllers['heartRateIntercept']!.text,
                                ) ??
                                0.0;
                            if (val < 1000) {
                              controllers['heartRateIntercept']!.text =
                                  (val + 0.1).toStringAsFixed(1);
                            }
                          },
                          width: MediaQuery.of(context).size.width * 0.23,
                          height: MediaQuery.of(context).size.height * 0.16,
                        ),
                        _inputCard(
                          title: 'Respirasi (breath/m)',
                          icon: Icons.air,
                          controller: controllers['respirationIntercept']!,
                          onMinus: () {
                            final val =
                                double.tryParse(
                                  controllers['respirationIntercept']!.text,
                                ) ??
                                0.0;
                            if (val > -1000) {
                              controllers['respirationIntercept']!.text =
                                  (val - 0.1).toStringAsFixed(1);
                            }
                          },
                          onPlus: () {
                            final val =
                                double.tryParse(
                                  controllers['respirationIntercept']!.text,
                                ) ??
                                0.0;
                            if (val < 1000) {
                              controllers['respirationIntercept']!.text =
                                  (val + 0.1).toStringAsFixed(1);
                            }
                          },
                          width: MediaQuery.of(context).size.width * 0.23,
                          height: MediaQuery.of(context).size.height * 0.16,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              CustomButton(
                onPressed: () {
                  if (currentDeviceId == null) return;

                  final temperatureSlope =
                      double.tryParse(controllers['temperatureSlope']!.text) ??
                      1.0;
                  final temperatureIntercept =
                      double.tryParse(
                        controllers['temperatureIntercept']!.text,
                      ) ??
                      0.0;
                  final heartRateSlope =
                      double.tryParse(controllers['heartRateSlope']!.text) ??
                      1.0;
                  final heartRateIntercept =
                      double.tryParse(
                        controllers['heartRateIntercept']!.text,
                      ) ??
                      0.0;
                  final respirationSlope =
                      double.tryParse(controllers['respirationSlope']!.text) ??
                      1.0;
                  final respirationIntercept =
                      double.tryParse(
                        controllers['respirationIntercept']!.text,
                      ) ??
                      0.0;

                  controller.updateDeviceCalibration(
                    deviceId: currentDeviceId,
                    temperatureSlope: temperatureSlope,
                    temperatureIntercept: temperatureIntercept,
                    heartRateSlope: heartRateSlope,
                    heartRateIntercept: heartRateIntercept,
                    respirationSlope: respirationSlope,
                    respirationIntercept: respirationIntercept,
                  );

                  showAppToast(
                    context: context,
                    type: ToastificationType.success,
                    title: 'Berhasil Disimpan!',
                    description:
                        'Kalibrasi sensor untuk $currentDeviceId berhasil diperbarui.',
                  );
                },
                text: 'Simpan Kalibrasi Device ${currentDeviceId}',
                iconTrailing: Icons.save,
                backgroundColor: AppColors.primary,
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _inputCard({
    required String title,
    required IconData icon,
    required TextEditingController controller,
    required VoidCallback onMinus,
    required VoidCallback onPlus,
    double? width,
    double? height,
    double min = -1000,
    double max = 1000,
    double step = 0.1, // Tambahkan parameter step
  }) {
    return CustomCard(
      title: title,
      withExpanded: false,
      trailing: Icon(icon, color: Colors.white, size: 24),
      headerColor: AppColors.primary,
      headerHeight: 50,
      titleFontSize: 18,
      width: width ?? 120,
      height: height ?? 100,
      borderRadius: 16,
      scrollable: false,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    style: const TextStyle(fontSize: 18),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 36,
                      height: 36,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        onPressed: () {
                          final currentVal =
                              double.tryParse(controller.text) ?? 0.0;
                          final newVal = currentVal + step;
                          if (newVal <= max) {
                            controller.text = newVal.toStringAsFixed(1);
                          }
                        },
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: 36,
                      height: 36,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        onPressed: () {
                          final currentVal =
                              double.tryParse(controller.text) ?? 0.0;
                          final newVal = currentVal - step;
                          if (newVal >= min) {
                            controller.text = newVal.toStringAsFixed(1);
                          }
                        },
                        child: const Icon(
                          Icons.remove,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  // ...existing code...
  // Widget _buildDeviceCalibrationTab(BuildContext context) {
  //   final halterDeviceList = controller.dataController.halterDeviceList;
  //   final ruleList =
  //       Get.find<HalterTableRuleEngineController>().biometricClassificationList;
  //   final RxList<HalterDeviceCalibrationModel> deviceCalibrations =
  //       <HalterDeviceCalibrationModel>[].obs;

  //   // Inisialisasi RxList dari storage saat pertama kali build
  //   if (deviceCalibrations.isEmpty) {
  //     final all = DataHalterDeviceCalibration.getAll();
  //     deviceCalibrations.addAll(all);
  //   }

  //   // State untuk device yang dipilih
  //   final Rx<String?> selectedDeviceId =
  //       (halterDeviceList.isNotEmpty ? halterDeviceList.first.deviceId : null)
  //           .obs;
  //   final Map<String, Rx<HalterBiometricRuleEngineModel?>> selectedRuleMap = {
  //     for (final device in halterDeviceList)
  //       device.deviceId: Rx<HalterBiometricRuleEngineModel?>(null),
  //   };

  //   return Obx(() {
  //     final device = halterDeviceList.firstWhereOrNull(
  //       (d) => d.deviceId == selectedDeviceId.value,
  //     );
  //     final rxSelectedRule = device != null
  //         ? selectedRuleMap[device.deviceId]!
  //         : null;
  //     // final lastCalibration = device != null
  //     //     ? deviceCalibrations.firstWhereOrNull(
  //     //         (c) => c.deviceId == device.deviceId,
  //     //       )
  //     //     : null;
  //     final isLoading =
  //         device != null && _isLoadingDevice[device.deviceId] == true;

  //     return CustomCard(
  //       title: 'Kalibrasi Halter',
  //       withExpanded: false,
  //       content: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  // Text(
  //   'IoT Node Halter',
  //   style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
  // ),
  //           const SizedBox(height: 8),
  //           DropdownButtonFormField<String>(
  //             value: selectedDeviceId.value,
  //             isExpanded: true,
  //             decoration: const InputDecoration(
  //               labelText: "Pilih IoT Node Halter",
  //             ),
  //             items: halterDeviceList
  //                 .map(
  //                   (d) => DropdownMenuItem(
  //                     value: d.deviceId,
  //                     child: Text(d.deviceId),
  //                   ),
  //                 )
  //                 .toList(),
  //             onChanged: (id) => selectedDeviceId.value = id,
  //           ),
  //           const SizedBox(height: 8),
  //           if (device != null)
  //             Obx(
  //               () => DropdownButtonFormField<HalterBiometricRuleEngineModel>(
  //                 value: rxSelectedRule?.value,
  //                 isExpanded: true,
  //                 decoration: const InputDecoration(
  //                   labelText: "Rule Kalibrasi",
  //                 ),
  //                 items: ruleList
  //                     .map(
  //                       (r) => DropdownMenuItem(value: r, child: Text(r.name)),
  //                     )
  //                     .toList(),
  //                 onChanged: (rule) {
  //                   rxSelectedRule?.value = rule;
  //                 },
  //               ),
  //             ),
  //           const SizedBox(height: 8),
  //           if (device != null)
  //             CustomButton(
  //               text: isLoading ? 'Menunggu Data...' : 'Kalibrasi',
  //               iconTrailing: isLoading ? null : Icons.save,
  //               backgroundColor: AppColors.primary,
  //               isDisabled: isLoading,
  //               onPressed: () async {
  //                 final rule = rxSelectedRule?.value;
  //                 if (rule == null) {
  //                   showAppToast(
  //                     context: context,
  //                     type: ToastificationType.error,
  //                     title: 'Data Tidak Valid!',
  //                     description: 'Pilih Rule Terlebih Dahulu.',
  //                   );
  //                   return;
  //                 }

  //                 // Buat referensi kalibrasi baru
  //                 final referensi = HalterDeviceCalibrationModel(
  //                   deviceId: device.deviceId,
  //                   temperature: rule.suhuMin ?? rule.suhuMax ?? 0,
  //                   heartRate: (rule.heartRateMin ?? rule.heartRateMax ?? 0)
  //                       .toDouble(),
  //                   spo: rule.spoMin ?? rule.spoMax ?? 0,
  //                   respiration: (rule.Respirasi (breath/m)Min ?? rule.Respirasi (breath/m)Max ?? 0)
  //                       .toDouble(),
  //                   updatedAt: DateTime.now(),
  //                 );
  //                 DataHalterDeviceCalibration.save(referensi);

  //                 _isLoadingDevice[device.deviceId] = true;

  //                 // Polling data RAW terbaru setelah tombol diklik
  //                 final pollingStartTime = DateTime.now();
  //                 final latestRaw = await _waitForLatestRawDeviceData(
  //                   device.deviceId,
  //                   lastTime: pollingStartTime,
  //                   timeout: const Duration(minutes: 1),
  //                 );

  //                 if (latestRaw == null) {
  //                   showAppToast(
  //                     context: context,
  //                     type: ToastificationType.error,
  //                     title: 'Kalibrasi Gagal!',
  //                     description: 'Tidak Ada Data Sensor Dalam 1 Menit.',
  //                   );
  //                   _isLoadingDevice[device.deviceId] = false;
  //                   return;
  //                 }

  //                 // Hitung offset baru dari data sensor terbaru
  //                 final offset = HalterDeviceCalibrationOffsetModel(
  //                   deviceId: device.deviceId,
  //                   temperatureOffset:
  //                       referensi.temperature - (latestRaw.temperature ?? 0),
  //                   heartRateOffset:
  //                       referensi.heartRate - (latestRaw.heartRate ?? 0),
  //                   spoOffset: referensi.spo - (latestRaw.spo ?? 0),
  //                   respirationOffset:
  //                       referensi.respiration -
  //                       (latestRaw.respiratoryRate ?? 0),
  //                   updatedAt: DateTime.now(),
  //                 );
  //                 DataHalterDeviceCalibrationOffset.save(offset);

  //                 // Update RxList offset & lastSensor
  //                 final idx = offsetList.indexWhere(
  //                   (o) => o.deviceId == device.deviceId,
  //                 );
  //                 if (idx >= 0)
  //                   offsetList[idx] = offset;
  //                 else
  //                   offsetList.add(offset);

  //                 lastSensorMap[device.deviceId] = latestRaw;

  //                 _isLoadingDevice[device.deviceId] = false;

  //                 // Tambahkan log kalibrasi (jika perlu)
  //                 final logController =
  //                     Get.find<HalterCalibrationLogController>();
  //                 logController.addLog(
  //                   HalterCalibrationLogModel(
  //                     deviceId: device.deviceId,
  //                     timestamp: DateTime.now(),
  //                     sensorName: 'Suhu Badan (°C) (°C)',
  //                     referensi: referensi.temperature.toStringAsFixed(2),
  //                     sensorValue:
  //                         latestRaw.temperature?.toStringAsFixed(2) ?? "-",
  //                     nilaiKalibrasi:
  //                         (referensi.temperature - (latestRaw.temperature ?? 0))
  //                             .toStringAsFixed(2),
  //                   ),
  //                 );
  //                 logController.addLog(
  //                   HalterCalibrationLogModel(
  //                     deviceId: device.deviceId,
  //                     timestamp: DateTime.now(),
  //                     sensorName: 'Detak Jantung (beat/m) (beat/m)',
  //                     referensi: referensi.heartRate.toStringAsFixed(2),
  //                     sensorValue:
  //                         latestRaw.heartRate?.toStringAsFixed(2) ?? "-",
  //                     nilaiKalibrasi:
  //                         (referensi.heartRate - (latestRaw.heartRate ?? 0))
  //                             .toStringAsFixed(2),
  //                   ),
  //                 );
  //                 logController.addLog(
  //                   HalterCalibrationLogModel(
  //                     deviceId: device.deviceId,
  //                     timestamp: DateTime.now(),
  //                     sensorName: 'SpO₂ (%)',
  //                     referensi: referensi.spo.toStringAsFixed(2),
  //                     sensorValue: latestRaw.spo?.toStringAsFixed(2) ?? "-",
  //                     nilaiKalibrasi: (referensi.spo - (latestRaw.spo ?? 0))
  //                         .toStringAsFixed(2),
  //                   ),
  //                 );
  //                 logController.addLog(
  //                   HalterCalibrationLogModel(
  //                     deviceId: device.deviceId,
  //                     timestamp: DateTime.now(),
  //                     sensorName: 'Respirasi (breath/m) (breath/m)',
  //                     referensi: referensi.respiration.toStringAsFixed(2),
  //                     sensorValue:
  //                         latestRaw.respiratoryRate?.toStringAsFixed(2) ?? "-",
  //                     nilaiKalibrasi:
  //                         (referensi.respiration -
  //                                 (latestRaw.respiratoryRate ?? 0))
  //                             .toStringAsFixed(2),
  //                   ),
  //                 );
  //                 showAppToast(
  //                   context: context,
  //                   type: ToastificationType.success,
  //                   title: 'Berhasil Kalibrasi!',
  //                   description: 'Halter Berhasil Terkalibrasi.',
  //                 );
  //               },
  //             ),
  //           const SizedBox(height: 8),
  //           if (device != null)
  //             Text(
  //               'Terakhir Kalibrasi:',
  //               style: const TextStyle(fontWeight: FontWeight.bold),
  //             ),
  //           if (device != null)
  //             Obx(() {
  //               final offset = offsetList.firstWhereOrNull(
  //                 (o) => o.deviceId == device.deviceId,
  //               );
  //               final latestRaw = lastSensorMap[device.deviceId];

  //               final lastCalibration = deviceCalibrations.firstWhereOrNull(
  //                 (c) => c.deviceId == device.deviceId,
  //               );

  //               return SingleChildScrollView(
  //                 scrollDirection: Axis.horizontal,
  //                 child: DataTable(
  //                   columns: const [
  //                     DataColumn(label: Text('Timestamp')),
  //                     DataColumn(label: Text('Nama Sensor')),
  //                     DataColumn(label: Text('Data lookup (Referensi)')),
  //                     DataColumn(label: Text('Data Sensor')),
  //                     DataColumn(label: Text('Nilai Kalibrasi')),
  //                   ],
  //                   rows: [
  //                     if (lastCalibration != null)
  //                       ...() {
  //                         return [
  //                           DataRow(
  //                             cells: [
  //                               DataCell(
  //                                 Text(
  //                                   DateFormat(
  //                                     'dd-MM-yyyy HH:mm:ss',
  //                                   ).format(lastCalibration.updatedAt),
  //                                 ),
  //                               ),
  //                               DataCell(const Text('Suhu Badan (°C) (°C)')),
  //                               DataCell(
  //                                 Text(
  //                                   '${lastCalibration.temperature.toStringAsFixed(2)}',
  //                                 ),
  //                               ),
  //                               DataCell(
  //                                 Text(
  //                                   '${latestRaw?.temperature?.toStringAsFixed(2) ?? "-"}',
  //                                 ),
  //                               ),
  //                               DataCell(
  //                                 Text(
  //                                   '${offset?.temperatureOffset.toStringAsFixed(2) ?? "-"}',
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                           DataRow(
  //                             cells: [
  //                               DataCell(
  //                                 Text(
  //                                   DateFormat(
  //                                     'dd-MM-yyyy HH:mm:ss',
  //                                   ).format(lastCalibration.updatedAt),
  //                                 ),
  //                               ),
  //                               DataCell(const Text('Detak Jantung (beat/m) (beat/m)')),
  //                               DataCell(
  //                                 Text(
  //                                   '${lastCalibration.heartRate.toStringAsFixed(2)}',
  //                                 ),
  //                               ),
  //                               DataCell(
  //                                 Text(
  //                                   '${latestRaw?.heartRate?.toStringAsFixed(2) ?? "-"}',
  //                                 ),
  //                               ),
  //                               DataCell(
  //                                 Text(
  //                                   '${offset?.heartRateOffset.toStringAsFixed(2) ?? "-"}',
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                           DataRow(
  //                             cells: [
  //                               DataCell(
  //                                 Text(
  //                                   DateFormat(
  //                                     'dd-MM-yyyy HH:mm:ss',
  //                                   ).format(lastCalibration.updatedAt),
  //                                 ),
  //                               ),
  //                               DataCell(const Text('SpO₂ (%)')),
  //                               DataCell(
  //                                 Text(
  //                                   '${lastCalibration.spo.toStringAsFixed(2)}',
  //                                 ),
  //                               ),
  //                               DataCell(
  //                                 Text(
  //                                   '${latestRaw?.spo?.toStringAsFixed(2) ?? "-"}',
  //                                 ),
  //                               ),
  //                               DataCell(
  //                                 Text(
  //                                   '${offset?.spoOffset.toStringAsFixed(2) ?? "-"}',
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                           DataRow(
  //                             cells: [
  //                               DataCell(
  //                                 Text(
  //                                   DateFormat(
  //                                     'dd-MM-yyyy HH:mm:ss',
  //                                   ).format(lastCalibration.updatedAt),
  //                                 ),
  //                               ),
  //                               DataCell(const Text('Respirasi (breath/m) (breath/m)')),
  //                               DataCell(
  //                                 Text(
  //                                   '${lastCalibration.respiration.toStringAsFixed(2)}',
  //                                 ),
  //                               ),
  //                               DataCell(
  //                                 Text(
  //                                   '${latestRaw?.respiratoryRate?.toStringAsFixed(2) ?? "-"}',
  //                                 ),
  //                               ),
  //                               DataCell(
  //                                 Text(
  //                                   '${offset?.respirationOffset.toStringAsFixed(2) ?? "-"}',
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                         ];
  //                       }(),
  //                   ],
  //                 ),
  //               );
  //             }),
  //           if (device != null)
  //             Align(
  //               alignment: Alignment.bottomRight,
  //               child: Padding(
  //                 padding: const EdgeInsets.only(top: 12),
  //                 child: CustomButton(
  //                   text: 'Reset Kalibrasi',
  //                   icon: Icons.refresh,
  //                   backgroundColor: Colors.orange,
  //                   height: 40,
  //                   fontSize: 16,
  //                   onPressed: () {
  //                     DataHalterDeviceCalibrationOffset.save(
  //                       HalterDeviceCalibrationOffsetModel(
  //                         deviceId: device.deviceId,
  //                         temperatureOffset: 0,
  //                         heartRateOffset: 0,
  //                         spoOffset: 0,
  //                         respirationOffset: 0,
  //                         updatedAt: DateTime.now(),
  //                       ),
  //                     );
  //                     Get.snackbar(
  //                       "Kalibrasi Direset",
  //                       "Offset kalibrasi untuk device ${device.deviceId} sudah direset.",
  //                       snackPosition: SnackPosition.TOP,
  //                       backgroundColor: Colors.orange,
  //                       colorText: Colors.white,
  //                     );
  //                     setState(() {});
  //                   },
  //                 ),
  //               ),
  //             ),
  //         ],
  //       ),
  //     );
  //   });
  // }

  // Widget _buildLogTableSection(BuildContext context) {
  //   return CustomCard(
  //     title: 'Log Kalibrasi',
  //     content: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           children: [
  //             CustomButton(
  //               width: 200,
  //               height: 50,
  //               backgroundColor: Colors.green,
  //               fontSize: 18,
  //               icon: Icons.table_view_rounded,
  //               text: 'Tampilkan Log',
  //               onPressed: _addLatestLogRow,
  //             ),
  //             const SizedBox(width: 12),
  //             CustomButton(
  //               width: 200,
  //               height: 50,
  //               backgroundColor: Colors.red,
  //               fontSize: 18,
  //               icon: Icons.clear,
  //               text: 'Clear Log',
  //               onPressed: () {
  //                 setState(() {
  //                   _logRows.clear();
  //                 });
  //                 controller.logRows.clear();
  //               },
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 12),
  //         SingleChildScrollView(
  //           scrollDirection: Axis.horizontal,
  //           child: Obx(
  //             () => DataTable(
  //               columns: const [
  //                 DataColumn(label: Text('ID')),
  //                 DataColumn(label: Text('Timestamp')),
  //                 DataColumn(label: Text('Nama Sensor')),
  //                 DataColumn(label: Text('Data lookup (Referensi)')),
  //                 DataColumn(label: Text('Data Sensor')),
  //                 DataColumn(label: Text('Nilai Kalibrasi')),
  //               ],
  //               rows: controller.logRows,
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}


  // Widget _buildKalibrasiNodeRoomTab(BuildContext context) {
  // double suhuRuangan = controller.suhuRuangan.value;
  // double kelembapan = controller.kelembapan.value;
  // double indeksCahaya = controller.indeksCahaya.value;

  //   return Padding(
  //     padding: const EdgeInsets.all(8.0),
  //     child: Center(
  //       child: CustomCard(
  //         withExpanded: false,
  //         title: "Kalibrasi Sensor Node Room",
  //         content: Column(
  //           children: [
  //             Wrap(
  //               spacing: 18,
  //               runSpacing: 18,
  //               children: [
  //                 _inputCard(
  //                   title: 'Suhu Ruangan',
  //                   icon: Icons.thermostat_outlined,
  //                   value: controller.suhu.value.toInt(),
  //                   width: MediaQuery.of(context).size.width * 0.24,
  //                   height: MediaQuery.of(context).size.height * 0.16,
  //                   onChanged: (val) => controller.suhu.value = val.toDouble(),
  //                 ),
  //                 _inputCard(
  //                   title: 'Kelembapan',
  //                   icon: Icons.monitor_heart,
  //                   value: controller.heartRate.value.toInt(),
  //                   width: MediaQuery.of(context).size.width * 0.24,
  //                   height: MediaQuery.of(context).size.height * 0.16,
  //                   onChanged: (val) =>
  //                       controller.heartRate.value = val.toDouble(),
  //                 ),
  //                 _inputCard(
  //                   title: 'Indeks Cahaya',
  //                   icon: Icons.local_fire_department_outlined,
  //                   value: controller.spo.value.toInt(),
  //                   width: MediaQuery.of(context).size.width * 0.24,
  //                   height: MediaQuery.of(context).size.height * 0.16,
  //                   onChanged: (val) => controller.spo.value = val.toDouble(),
  //                 ),
  //               ],
  //             ),
  //             SizedBox(height: 16),
  //             CustomButton(
  //               onPressed: () {},
  //               text: 'Simpan',
  //               iconTrailing: Icons.save,
  //               backgroundColor: AppColors.primary,
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

