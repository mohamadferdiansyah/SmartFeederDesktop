import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:input_quantity/input_quantity.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:smart_feeder_desktop/app/constants/app_colors.dart';
import 'package:smart_feeder_desktop/app/data/data_halter_device_calibration.dart';
import 'package:smart_feeder_desktop/app/data/data_halter_device_calibration_offset.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_biometric_rule_engine_model.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_calibration_log_model.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_device_calibration_model.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_device_calibration_offset_model.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_device_detail_model.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/data_logs/log_calibration/halter_calibration_log_controller.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/rule_engine/table/halter_table_rule_engine_controller.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_button.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_card.dart';
import 'halter_calibration_controller.dart';

class HalterCalibrationPage extends StatefulWidget {
  const HalterCalibrationPage({super.key});

  @override
  State<HalterCalibrationPage> createState() => _HalterCalibrationPageState();
}

class _HalterCalibrationPageState extends State<HalterCalibrationPage> {
  final HalterCalibrationController controller =
      Get.find<HalterCalibrationController>();

  // Tambahkan list log khusus
  List<DataRow> _logRows = [];
  final RxMap<String, bool> _isLoadingDevice = <String, bool>{}.obs;

  bool _isLatestLogExist(String? timestamp) {
    return _logRows.any(
      (row) =>
          row.cells.length > 1 &&
          (row.cells[1].child as Text).data == timestamp,
    );
  }

  Future<HalterDeviceDetailModel?> _waitForLatestDeviceData(
    String deviceId, {
    DateTime? lastTime,
    Duration timeout = const Duration(minutes: 1),
  }) async {
    print('[Polling] Menunggu data deviceId: $deviceId ...');
    final detailList = controller.dataController.detailHistory;
    final completer = Completer<HalterDeviceDetailModel?>();
    final start = DateTime.now();

    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      print('[Polling] Cek data deviceId: $deviceId');
      final latest = detailList.lastWhereOrNull(
        (d) =>
            d.deviceId == deviceId &&
            (lastTime == null || d.time.isAfter(lastTime)),
      );
      if (latest != null) {
        print('[Polling] Data BARU ditemukan untuk deviceId: $deviceId');
        timer.cancel();
        completer.complete(latest);
      } else if (DateTime.now().difference(start) > timeout) {
        print('[Polling] Timeout menunggu data deviceId: $deviceId');
        timer.cancel();
        completer.complete(null);
      }
    });

    return completer.future;
  }

  // Fungsi untuk generate log dari rawDetailHistoryList
  void _addLatestLogRow() {
    final calibration = controller.calibration.value;
    final rawDetailList = controller.rawDetailHistoryList;
    if (rawDetailList.isEmpty) return;

    final detail = rawDetailList.last;
    final timestamp = detail.time?.toString();
    if (_isLatestLogExist(timestamp)) return; // Prevent duplicate log

    final id = _logRows.length + 1;

    final newRows = [
      DataRow(
        cells: [
          DataCell(Text(id.toString())),
          DataCell(Text(timestamp.toString())),
          DataCell(Text('Suhu Badan')),
          DataCell(Text('${detail.temperature?.toStringAsFixed(2) ?? "-"} ')),
          DataCell(Text('${detail.temperature?.toStringAsFixed(2) ?? "-"} ')),
          DataCell(Text('${calibration.temperature.toStringAsFixed(2)} ')),
        ],
      ),
      DataRow(
        cells: [
          DataCell(Text(id.toString())),
          DataCell(Text(timestamp.toString())),
          DataCell(Text('Detak Jantung')),
          DataCell(Text('${detail.heartRate?.toStringAsFixed(2) ?? "-"}')),
          DataCell(Text('${detail.heartRate?.toStringAsFixed(2) ?? "-"}')),
          DataCell(Text('${calibration.heartRate.toStringAsFixed(2)}')),
        ],
      ),
      DataRow(
        cells: [
          DataCell(Text(id.toString())),
          DataCell(Text(timestamp.toString())),
          DataCell(Text('SPO')),
          DataCell(Text('${detail.spo?.toStringAsFixed(2) ?? "-"}')),
          DataCell(Text('${detail.spo?.toStringAsFixed(2) ?? "-"}')),
          DataCell(Text('${calibration.spo.toStringAsFixed(2)}')),
        ],
      ),
      DataRow(
        cells: [
          DataCell(Text(id.toString())),
          DataCell(Text(timestamp.toString())),
          DataCell(Text('Respirasi')),
          DataCell(
            Text('${detail.respiratoryRate?.toStringAsFixed(2) ?? "-"}'),
          ),
          DataCell(
            Text('${detail.respiratoryRate?.toStringAsFixed(2) ?? "-"}'),
          ),
          DataCell(Text('${calibration.respiration.toStringAsFixed(2)}')),
        ],
      ),
      // Node Room
      DataRow(
        cells: [
          DataCell(Text(id.toString())),
          DataCell(Text(timestamp.toString())),
          DataCell(Text('Suhu Ruangan')),
          DataCell(Text('Node Room')),
          DataCell(Text('${calibration.roomTemperature.toStringAsFixed(2)} ')),
          DataCell(Text('${calibration.roomTemperature.toStringAsFixed(2)} ')),
          DataCell(Text('${calibration.roomTemperature.toStringAsFixed(2)} ')),
        ],
      ),
      DataRow(
        cells: [
          DataCell(Text(id.toString())),
          DataCell(Text(timestamp.toString())),
          DataCell(Text('Kelembapan')),
          DataCell(Text('Node Room')),
          DataCell(Text('${calibration.humidity.toStringAsFixed(2)}')),
          DataCell(Text('${calibration.humidity.toStringAsFixed(2)}')),
          DataCell(Text('${calibration.humidity.toStringAsFixed(2)}')),
        ],
      ),
      DataRow(
        cells: [
          DataCell(Text(id.toString())),
          DataCell(Text(timestamp.toString())),
          DataCell(Text('Indeks Cahaya')),
          DataCell(Text('Node Room')),
          DataCell(
            Text('${calibration.lightIntensity.toStringAsFixed(2)} lux'),
          ),
          DataCell(
            Text('${calibration.lightIntensity.toStringAsFixed(2)} lux'),
          ),
          DataCell(
            Text('${calibration.lightIntensity.toStringAsFixed(2)} lux'),
          ),
        ],
      ),
    ];

    setState(() {
      _logRows.addAll(newRows);
    });
    controller.logRows.addAll(newRows);
  }

  Future<void> _kalibrasiDevice(
    String deviceId,
    HalterDeviceCalibrationModel referensi,
  ) async {
    print('[Kalibrasi] Mulai kalibrasi deviceId: $deviceId');
    final latest = await _waitForLatestDeviceData(deviceId);

    if (latest == null) {
      print(
        '[Kalibrasi] Data sensor tidak ditemukan untuk deviceId: $deviceId',
      );
      Get.snackbar(
        "Data Tidak Ditemukan",
        "Belum ada data sensor dari device $deviceId (timeout).",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    print('[Kalibrasi] Data sensor ditemukan, proses hitung offset...');
    final offset = HalterDeviceCalibrationOffsetModel(
      deviceId: deviceId,
      temperatureOffset: referensi.temperature - (latest.temperature ?? 0),
      heartRateOffset: referensi.heartRate - (latest.heartRate ?? 0),
      spoOffset: referensi.spo - (latest.spo ?? 0),
      respirationOffset: referensi.respiration - (latest.respiratoryRate ?? 0),
      updatedAt: DateTime.now(),
    );
    DataHalterDeviceCalibrationOffset.save(offset);

    print('[Kalibrasi] Offset tersimpan untuk deviceId: $deviceId');
    print(
      '[Kalibrasi] Suhu: ${offset.temperatureOffset}, BPM: ${offset.heartRateOffset}, SPO: ${offset.spoOffset}, Respirasi: ${offset.respirationOffset}',
    );

    Get.snackbar(
      "Kalibrasi Tersimpan",
      "Offset device $deviceId:\n"
          "Suhu: ${offset.temperatureOffset.toStringAsFixed(2)}, "
          "BPM: ${offset.heartRateOffset.toStringAsFixed(2)}, "
          "SPO: ${offset.spoOffset.toStringAsFixed(2)}, "
          "Respirasi: ${offset.respirationOffset.toStringAsFixed(2)}",
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  late TextEditingController suhuCtrl;
  late TextEditingController heartRateCtrl;
  late TextEditingController spoCtrl;
  late TextEditingController respirasiCtrl;
  late TextEditingController suhuRuanganCtrl;
  late TextEditingController kelembapanCtrl;
  late TextEditingController indeksCahayaCtrl;

  @override
  void initState() {
    super.initState();
    final c = controller.calibration.value;
    suhuCtrl = TextEditingController(text: c.temperature.toInt().toString());
    heartRateCtrl = TextEditingController(text: c.heartRate.toInt().toString());
    spoCtrl = TextEditingController(text: c.spo.toInt().toString());
    respirasiCtrl = TextEditingController(
      text: c.respiration.toInt().toString(),
    );
    suhuRuanganCtrl = TextEditingController(
      text: c.roomTemperature.toInt().toString(),
    );
    kelembapanCtrl = TextEditingController(text: c.humidity.toInt().toString());
    indeksCahayaCtrl = TextEditingController(
      text: c.lightIntensity.toInt().toString(),
    );
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
            length: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TabBar(
                  labelColor: AppColors.primary,
                  unselectedLabelColor: Colors.black54,
                  indicatorColor: AppColors.primary,
                  tabs: const [
                    // Tab(
                    //   text: "Kalibrasi Halter & Node Room",
                    //   icon: Icon(Icons.settings_rounded),
                    // ),
                    Tab(
                      text: "Kalibrasi Per Device",
                      icon: Icon(Icons.devices_other),
                    ),
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
                        // Padding(
                        //   padding: const EdgeInsets.all(6.0),
                        //   child: _buildKalibrasiHalterTab(context),
                        // ),
                        Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: _buildDeviceCalibrationTab(context),
                        ),
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

  // Widget _buildKalibrasiHalterTab(BuildContext context) {
  //   return Center(
  //     child: Column(
  //       children: [
  //         CustomCard(
  //           trailing: Icon(
  //             Icons.device_hub_rounded,
  //             color: Colors.white,
  //             size: 30,
  //           ),
  //           withExpanded: false,
  //           height: MediaQuery.of(context).size.height * 0.29,
  //           title: "Kalibrasi Sensor Halter",
  //           content: Column(
  //             children: [
  //               Wrap(
  //                 spacing: 18,
  //                 runSpacing: 18,
  //                 children: [
  //                   _inputCard(
  //                     title: 'Suhu Badan',
  //                     icon: Icons.thermostat_outlined,
  //                     controller: suhuCtrl,
  //                     onMinus: () {
  //                       final val = int.tryParse(suhuCtrl.text) ?? 0;
  //                       if (val > -1000) {
  //                         setState(() => suhuCtrl.text = (val - 1).toString());
  //                       }
  //                     },
  //                     onPlus: () {
  //                       final val = int.tryParse(suhuCtrl.text) ?? 0;
  //                       if (val < 1000) {
  //                         setState(() => suhuCtrl.text = (val + 1).toString());
  //                       }
  //                     },
  //                     width: MediaQuery.of(context).size.width * 0.18,
  //                     height: MediaQuery.of(context).size.height * 0.16,
  //                   ),
  //                   _inputCard(
  //                     title: 'Detak Jantung',
  //                     icon: Icons.monitor_heart,
  //                     controller: heartRateCtrl,
  //                     onMinus: () {
  //                       final val = int.tryParse(heartRateCtrl.text) ?? 0;
  //                       if (val > -1000) {
  //                         setState(
  //                           () => heartRateCtrl.text = (val - 1).toString(),
  //                         );
  //                       }
  //                     },
  //                     onPlus: () {
  //                       final val = int.tryParse(heartRateCtrl.text) ?? 0;
  //                       if (val < 1000) {
  //                         setState(
  //                           () => heartRateCtrl.text = (val + 1).toString(),
  //                         );
  //                       }
  //                     },
  //                     width: MediaQuery.of(context).size.width * 0.18,
  //                     height: MediaQuery.of(context).size.height * 0.16,
  //                   ),
  //                   _inputCard(
  //                     title: 'Kadar Oksigen',
  //                     icon: Icons.local_fire_department_outlined,
  //                     controller: spoCtrl,
  //                     onMinus: () {
  //                       final val = int.tryParse(spoCtrl.text) ?? 0;
  //                       if (val > -1000) {
  //                         setState(() => spoCtrl.text = (val - 1).toString());
  //                       }
  //                     },
  //                     onPlus: () {
  //                       final val = int.tryParse(spoCtrl.text) ?? 0;
  //                       if (val < 1000) {
  //                         setState(() => spoCtrl.text = (val + 1).toString());
  //                       }
  //                     },
  //                     width: MediaQuery.of(context).size.width * 0.18,
  //                     height: MediaQuery.of(context).size.height * 0.16,
  //                   ),
  //                   _inputCard(
  //                     title: 'Respirasi',
  //                     icon: Icons.air_outlined,
  //                     controller: respirasiCtrl,
  //                     onMinus: () {
  //                       final val = int.tryParse(respirasiCtrl.text) ?? 0;
  //                       if (val > -1000) {
  //                         setState(
  //                           () => respirasiCtrl.text = (val - 1).toString(),
  //                         );
  //                       }
  //                     },
  //                     onPlus: () {
  //                       final val = int.tryParse(respirasiCtrl.text) ?? 0;
  //                       if (val < 1000) {
  //                         setState(
  //                           () => respirasiCtrl.text = (val + 1).toString(),
  //                         );
  //                       }
  //                     },
  //                     width: MediaQuery.of(context).size.width * 0.18,
  //                     height: MediaQuery.of(context).size.height * 0.16,
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ),
  //         SizedBox(height: 16),
  //         CustomCard(
  //           withExpanded: false,
  //           height: MediaQuery.of(context).size.height * 0.29,
  //           trailing: Icon(
  //             Icons.house_siding_rounded,
  //             color: Colors.white,
  //             size: 30,
  //           ),
  //           title: "Kalibrasi Sensor Node Room",
  //           content: Column(
  //             children: [
  //               Wrap(
  //                 spacing: 18,
  //                 runSpacing: 18,
  //                 children: [
  //                   _inputCard(
  //                     title: 'Suhu Ruangan',
  //                     icon: Icons.thermostat_outlined,
  //                     controller: suhuRuanganCtrl,
  //                     onMinus: () {
  //                       final val = int.tryParse(suhuRuanganCtrl.text) ?? 0;
  //                       if (val > -1000) {
  //                         setState(
  //                           () => suhuRuanganCtrl.text = (val - 1).toString(),
  //                         );
  //                       }
  //                     },
  //                     onPlus: () {
  //                       final val = int.tryParse(suhuRuanganCtrl.text) ?? 0;
  //                       if (val < 1000) {
  //                         setState(
  //                           () => suhuRuanganCtrl.text = (val + 1).toString(),
  //                         );
  //                       }
  //                     },
  //                     width: MediaQuery.of(context).size.width * 0.24,
  //                     height: MediaQuery.of(context).size.height * 0.16,
  //                   ),
  //                   _inputCard(
  //                     title: 'Kelembapan',
  //                     icon: Icons.water_drop_outlined,
  //                     controller: kelembapanCtrl,
  //                     onMinus: () {
  //                       final val = int.tryParse(kelembapanCtrl.text) ?? 0;
  //                       if (val > -1000) {
  //                         setState(
  //                           () => kelembapanCtrl.text = (val - 1).toString(),
  //                         );
  //                       }
  //                     },
  //                     onPlus: () {
  //                       final val = int.tryParse(kelembapanCtrl.text) ?? 0;
  //                       if (val < 1000) {
  //                         setState(
  //                           () => kelembapanCtrl.text = (val + 1).toString(),
  //                         );
  //                       }
  //                     },
  //                     width: MediaQuery.of(context).size.width * 0.24,
  //                     height: MediaQuery.of(context).size.height * 0.16,
  //                   ),
  //                   _inputCard(
  //                     title: 'Indeks Cahaya',
  //                     icon: Icons.light_mode_outlined,
  //                     controller: indeksCahayaCtrl,
  //                     onMinus: () {
  //                       final val = int.tryParse(indeksCahayaCtrl.text) ?? 0;
  //                       if (val > -1000) {
  //                         setState(
  //                           () => indeksCahayaCtrl.text = (val - 1).toString(),
  //                         );
  //                       }
  //                     },
  //                     onPlus: () {
  //                       final val = int.tryParse(indeksCahayaCtrl.text) ?? 0;
  //                       if (val < 1000) {
  //                         setState(
  //                           () => indeksCahayaCtrl.text = (val + 1).toString(),
  //                         );
  //                       }
  //                     },
  //                     width: MediaQuery.of(context).size.width * 0.24,
  //                     height: MediaQuery.of(context).size.height * 0.16,
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ),
  //         SizedBox(height: 16),
  //         CustomButton(
  //           onPressed: () {
  //             controller.updateCalibration(
  //               temperature: double.tryParse(suhuCtrl.text) ?? 0,
  //               heartRate: double.tryParse(heartRateCtrl.text) ?? 0,
  //               spo: double.tryParse(spoCtrl.text) ?? 0,
  //               respiration: double.tryParse(respirasiCtrl.text) ?? 0,
  //               roomTemperature: double.tryParse(suhuRuanganCtrl.text) ?? 0,
  //               humidity: double.tryParse(kelembapanCtrl.text) ?? 0,
  //               lightIntensity: double.tryParse(indeksCahayaCtrl.text) ?? 0,
  //             );
  //             Get.snackbar(
  //               "Kalibrasi Tersimpan",
  //               "Nilai kalibrasi berhasil disimpan.",
  //               snackPosition: SnackPosition.TOP,
  //               backgroundColor: Colors.green,
  //               colorText: Colors.white,
  //             );
  //           },
  //           text: 'Simpan',
  //           iconTrailing: Icons.save,
  //           backgroundColor: AppColors.primary,
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _inputCard({
  //   required String title,
  //   required IconData icon,
  //   required TextEditingController controller,
  //   required VoidCallback onMinus,
  //   required VoidCallback onPlus,
  //   double? width,
  //   double? height,
  //   int min = -1000,
  //   int max = 1000,
  // }) {
  //   return CustomCard(
  //     title: title,
  //     withExpanded: false,
  //     trailing: Icon(icon, color: Colors.white, size: 24),
  //     headerColor: AppColors.primary,
  //     headerHeight: 50,
  //     titleFontSize: 18,
  //     width: width ?? 120,
  //     height: height ?? 100,
  //     borderRadius: 16,
  //     scrollable: false,
  //     content: Column(
  //       crossAxisAlignment: CrossAxisAlignment.stretch,
  //       children: [
  //         Expanded(
  //           child: Row(
  //             children: [
  //               Expanded(
  //                 child: TextField(
  //                   controller: controller,
  //                   keyboardType: TextInputType.number,
  //                   decoration: InputDecoration(
  //                     filled: true,
  //                     fillColor: Colors.grey[100],
  //                     border: OutlineInputBorder(
  //                       borderRadius: BorderRadius.circular(10),
  //                     ),
  //                     contentPadding: const EdgeInsets.symmetric(
  //                       horizontal: 12,
  //                       vertical: 8,
  //                     ),
  //                   ),
  //                   style: const TextStyle(fontSize: 18),
  //                   inputFormatters: [
  //                     // Only allow numbers and minus
  //                   ],
  //                 ),
  //               ),
  //               const SizedBox(width: 8),
  //               Column(
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 children: [
  //                   SizedBox(
  //                     width: 36,
  //                     height: 36,
  //                     child: ElevatedButton(
  //                       style: ElevatedButton.styleFrom(
  //                         backgroundColor: AppColors.primary,
  //                         shape: RoundedRectangleBorder(
  //                           borderRadius: BorderRadius.circular(10),
  //                         ),
  //                         padding: EdgeInsets.zero,
  //                       ),
  //                       onPressed: onPlus,
  //                       child: const Icon(
  //                         Icons.add,
  //                         color: Colors.white,
  //                         size: 22,
  //                       ),
  //                     ),
  //                   ),
  //                   const SizedBox(height: 6),
  //                   SizedBox(
  //                     width: 36,
  //                     height: 36,
  //                     child: ElevatedButton(
  //                       style: ElevatedButton.styleFrom(
  //                         backgroundColor: AppColors.primary,
  //                         shape: RoundedRectangleBorder(
  //                           borderRadius: BorderRadius.circular(10),
  //                         ),
  //                         padding: EdgeInsets.zero,
  //                       ),
  //                       onPressed: onMinus,
  //                       child: const Icon(
  //                         Icons.remove,
  //                         color: Colors.white,
  //                         size: 22,
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // ...existing code...
  Widget _buildDeviceCalibrationTab(BuildContext context) {
    final halterDeviceList = controller.dataController.halterDeviceList;
    final ruleList =
        Get.find<HalterTableRuleEngineController>().biometricClassificationList;
    final RxList<HalterDeviceCalibrationModel> deviceCalibrations =
        <HalterDeviceCalibrationModel>[].obs;

    // Inisialisasi RxList dari storage saat pertama kali build
    if (deviceCalibrations.isEmpty) {
      final all = DataHalterDeviceCalibration.getAll();
      deviceCalibrations.addAll(all);
    }

    // State untuk device yang dipilih
    final Rx<String?> selectedDeviceId =
        (halterDeviceList.isNotEmpty ? halterDeviceList.first.deviceId : null)
            .obs;
    final Map<String, Rx<HalterBiometricRuleEngineModel?>> selectedRuleMap = {
      for (final device in halterDeviceList)
        device.deviceId: Rx<HalterBiometricRuleEngineModel?>(null),
    };

    return Obx(() {
      final device = halterDeviceList.firstWhereOrNull(
        (d) => d.deviceId == selectedDeviceId.value,
      );
      final rxSelectedRule = device != null
          ? selectedRuleMap[device.deviceId]!
          : null;
      final lastCalibration = device != null
          ? deviceCalibrations.firstWhereOrNull(
              (c) => c.deviceId == device.deviceId,
            )
          : null;
      final isLoading =
          device != null && _isLoadingDevice[device.deviceId] == true;

      return CustomCard(
        title: 'Kalibrasi Halter',
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Device Halter',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedDeviceId.value,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: "Pilih Device Halter",
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
            const SizedBox(height: 8),
            if (device != null)
              Obx(
                () => DropdownButtonFormField<HalterBiometricRuleEngineModel>(
                  value: rxSelectedRule?.value,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: "Rule Kalibrasi",
                  ),
                  items: ruleList
                      .map(
                        (r) => DropdownMenuItem(value: r, child: Text(r.name)),
                      )
                      .toList(),
                  onChanged: (rule) {
                    rxSelectedRule?.value = rule;
                  },
                ),
              ),
            const SizedBox(height: 8),
            if (device != null)
              CustomButton(
                text: isLoading ? 'Menunggu Data...' : 'Kalibrasi',
                iconTrailing: isLoading ? null : Icons.save,
                backgroundColor: AppColors.primary,
                isDisabled: isLoading,
                onPressed: () async {
                  var referensi = DataHalterDeviceCalibration.getByDeviceId(
                    device.deviceId,
                  );

                  final rule = rxSelectedRule?.value;

                  if (rule == null) {
                    Get.snackbar(
                      "Pilih Rule",
                      "Silakan pilih rule kalibrasi terlebih dahulu.",
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: Colors.redAccent,
                      colorText: Colors.white,
                    );
                    return;
                  }

                  // Selalu update referensi dengan rule terbaru
                  referensi = HalterDeviceCalibrationModel(
                    deviceId: device.deviceId,
                    temperature: rule.suhuMin ?? rule.suhuMax ?? 0,
                    heartRate: (rule.heartRateMin ?? rule.heartRateMax ?? 0)
                        .toDouble(),
                    spo: rule.spoMin ?? rule.spoMax ?? 0,
                    respiration: (rule.respirasiMin ?? rule.respirasiMax ?? 0)
                        .toDouble(),
                    updatedAt: DateTime.now(),
                  );
                  DataHalterDeviceCalibration.save(referensi);

                  _isLoadingDevice[device.deviceId] = true;

                  final pollingStartTime = DateTime.now();
                  final latest = await _waitForLatestDeviceData(
                    device.deviceId,
                    lastTime: pollingStartTime,
                    timeout: const Duration(minutes: 1),
                  );

                  if (latest == null) {
                    Get.snackbar(
                      "Kalibrasi Gagal",
                      "Tidak ada data sensor baru dalam 1 menit.",
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: Colors.redAccent,
                      colorText: Colors.white,
                    );
                    _isLoadingDevice[device.deviceId] = false;
                    return;
                  }

                  // Hitung offset baru dari data sensor terbaru
                  final offset = HalterDeviceCalibrationOffsetModel(
                    deviceId: device.deviceId,
                    temperatureOffset:
                        referensi.temperature - (latest.temperature ?? 0),
                    heartRateOffset:
                        referensi.heartRate - (latest.heartRate ?? 0),
                    spoOffset: referensi.spo - (latest.spo ?? 0),
                    respirationOffset:
                        referensi.respiration - (latest.respiratoryRate ?? 0),
                    updatedAt: DateTime.now(),
                  );
                  DataHalterDeviceCalibrationOffset.save(offset);

                  // Update RxList deviceCalibrations dengan referensi terbaru
                  final idx = deviceCalibrations.indexWhere(
                    (c) => c.deviceId == device.deviceId,
                  );
                  if (idx != -1) {
                    deviceCalibrations[idx] = referensi;
                  } else {
                    deviceCalibrations.add(referensi);
                  }

                  _isLoadingDevice[device.deviceId] = false;

                  // Tambahkan log kalibrasi (jika perlu)
                  final logController =
                      Get.find<HalterCalibrationLogController>();
                  logController.addLog(
                    HalterCalibrationLogModel(
                      deviceId: device.deviceId,
                      timestamp: DateTime.now(),
                      sensorName: 'Suhu Badan (°C)',
                      referensi: referensi.temperature.toStringAsFixed(2),
                      sensorValue:
                          latest.temperature?.toStringAsFixed(2) ?? "-",
                      nilaiKalibrasi:
                          (referensi.temperature - (latest.temperature ?? 0))
                              .toStringAsFixed(2),
                    ),
                  );
                  logController.addLog(
                    HalterCalibrationLogModel(
                      deviceId: device.deviceId,
                      timestamp: DateTime.now(),
                      sensorName: 'Detak Jantung (bpm)',
                      referensi: referensi.heartRate.toStringAsFixed(2),
                      sensorValue: latest.heartRate?.toStringAsFixed(2) ?? "-",
                      nilaiKalibrasi:
                          (referensi.heartRate - (latest.heartRate ?? 0))
                              .toStringAsFixed(2),
                    ),
                  );
                  logController.addLog(
                    HalterCalibrationLogModel(
                      deviceId: device.deviceId,
                      timestamp: DateTime.now(),
                      sensorName: 'SpO₂ (%)',
                      referensi: referensi.spo.toStringAsFixed(2),
                      sensorValue: latest.spo?.toStringAsFixed(2) ?? "-",
                      nilaiKalibrasi: (referensi.spo - (latest.spo ?? 0))
                          .toStringAsFixed(2),
                    ),
                  );
                  logController.addLog(
                    HalterCalibrationLogModel(
                      deviceId: device.deviceId,
                      timestamp: DateTime.now(),
                      sensorName: 'Respirasi (nafas/menit)',
                      referensi: referensi.respiration.toStringAsFixed(2),
                      sensorValue:
                          latest.respiratoryRate?.toStringAsFixed(2) ?? "-",
                      nilaiKalibrasi:
                          (referensi.respiration -
                                  (latest.respiratoryRate ?? 0))
                              .toStringAsFixed(2),
                    ),
                  );
                  // ...tambahkan log untuk sensor lain jika perlu...
                },
              ),
            const SizedBox(height: 8),
            if (device != null)
              Text(
                'Terakhir Kalibrasi:',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            if (device != null)
              Obx(() {
                final lastCalibration = deviceCalibrations.firstWhereOrNull(
                  (c) => c.deviceId == device?.deviceId,
                );
                final offset = DataHalterDeviceCalibrationOffset.getByDeviceId(
                  device?.deviceId ?? '',
                );
                final latestSensor = controller.dataController.detailHistory
                    .lastWhereOrNull((d) => d.deviceId == device?.deviceId);

                print(latestSensor?.temperature);
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Timestamp')),
                      DataColumn(label: Text('Nama Sensor')),
                      DataColumn(label: Text('Data lookup (Referensi)')),
                      DataColumn(label: Text('Data Sensor')),
                      DataColumn(label: Text('Value Kalibrasi')),
                    ],
                    rows: [
                      if (lastCalibration != null)
                        ...() {
                          return [
                            DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    DateFormat(
                                      'dd-MM-yyyy HH:mm:ss',
                                    ).format(lastCalibration.updatedAt),
                                  ),
                                ),
                                DataCell(const Text('Suhu Badan (°C)')),
                                DataCell(
                                  Text(
                                    '${lastCalibration.temperature.toStringAsFixed(2)} ',
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    '${latestSensor?.temperature?.toStringAsFixed(2) ?? "-"} ',
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    offset?.temperatureOffset.toStringAsFixed(
                                          2,
                                        ) ??
                                        "-",
                                  ),
                                ),
                              ],
                            ),
                            DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    DateFormat(
                                      'dd-MM-yyyy HH:mm:ss',
                                    ).format(lastCalibration.updatedAt),
                                  ),
                                ),
                                DataCell(const Text('Detak Jantung (bpm)')),
                                DataCell(
                                  Text(
                                    '${lastCalibration.heartRate.toStringAsFixed(2)}',
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    '${latestSensor?.heartRate?.toStringAsFixed(2) ?? "-"}',
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    '${offset?.heartRateOffset.toStringAsFixed(2) ?? "-"}',
                                  ),
                                ),
                              ],
                            ),
                            DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    DateFormat(
                                      'dd-MM-yyyy HH:mm:ss',
                                    ).format(lastCalibration.updatedAt),
                                  ),
                                ),
                                DataCell(const Text('SpO₂ (%)')),
                                DataCell(
                                  Text(
                                    '${lastCalibration.spo.toStringAsFixed(2)}',
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    '${latestSensor?.spo?.toStringAsFixed(2) ?? "-"}',
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    '${offset?.spoOffset.toStringAsFixed(2) ?? "-"}',
                                  ),
                                ),
                              ],
                            ),
                            DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    DateFormat(
                                      'dd-MM-yyyy HH:mm:ss',
                                    ).format(lastCalibration.updatedAt),
                                  ),
                                ),
                                DataCell(const Text('Respirasi (nafas/menit)')),
                                DataCell(
                                  Text(
                                    '${lastCalibration.respiration.toStringAsFixed(2)}',
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    '${latestSensor?.respiratoryRate?.toStringAsFixed(2) ?? "-"}',
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    '${offset?.respirationOffset.toStringAsFixed(2) ?? "-"}',
                                  ),
                                ),
                              ],
                            ),
                          ];
                        }(),
                    ],
                  ),
                );
              }),
            if (device != null)
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: CustomButton(
                    text: 'Reset Kalibrasi',
                    icon: Icons.refresh,
                    backgroundColor: Colors.orange,
                    height: 40,
                    fontSize: 16,
                    onPressed: () {
                      DataHalterDeviceCalibrationOffset.save(
                        HalterDeviceCalibrationOffsetModel(
                          deviceId: device.deviceId,
                          temperatureOffset: 0,
                          heartRateOffset: 0,
                          spoOffset: 0,
                          respirationOffset: 0,
                          updatedAt: DateTime.now(),
                        ),
                      );
                      Get.snackbar(
                        "Kalibrasi Direset",
                        "Offset kalibrasi untuk device ${device.deviceId} sudah direset.",
                        snackPosition: SnackPosition.TOP,
                        backgroundColor: Colors.orange,
                        colorText: Colors.white,
                      );
                      setState(() {});
                    },
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildLogTableSection(BuildContext context) {
    return CustomCard(
      title: 'Log Kalibrasi',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomButton(
                width: 200,
                height: 50,
                backgroundColor: Colors.green,
                fontSize: 18,
                icon: Icons.table_view_rounded,
                text: 'Tampilkan Log',
                onPressed: _addLatestLogRow,
              ),
              const SizedBox(width: 12),
              CustomButton(
                width: 200,
                height: 50,
                backgroundColor: Colors.red,
                fontSize: 18,
                icon: Icons.clear,
                text: 'Clear Log',
                onPressed: () {
                  setState(() {
                    _logRows.clear();
                  });
                  controller.logRows.clear();
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Obx(
              () => DataTable(
                columns: const [
                  DataColumn(label: Text('ID')),
                  DataColumn(label: Text('Timestamp')),
                  DataColumn(label: Text('Nama Sensor')),
                  DataColumn(label: Text('Data lookup (Referensi)')),
                  DataColumn(label: Text('Data Sensor')),
                  DataColumn(label: Text('Nilai Kalibrasi')),
                ],
                rows: controller.logRows,
              ),
            ),
          ),
        ],
      ),
    );
  }
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

