import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:input_quantity/input_quantity.dart';
import 'package:smart_feeder_desktop/app/constants/app_colors.dart';
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

  bool _isLatestLogExist(String? timestamp) {
    return _logRows.any(
      (row) =>
          row.cells.length > 1 &&
          (row.cells[1].child as Text).data == timestamp,
    );
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
          DataCell(Text('Halter')),
          DataCell(Text('${detail.temperature?.toStringAsFixed(2) ?? "-"} °C')),
          DataCell(Text('${detail.temperature?.toStringAsFixed(2) ?? "-"} °C')),
          DataCell(Text('${calibration.temperature.toStringAsFixed(2)} °C')),
        ],
      ),
      DataRow(
        cells: [
          DataCell(Text(id.toString())),
          DataCell(Text(timestamp.toString())),
          DataCell(Text('Detak Jantung')),
          DataCell(Text('Halter')),
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
          DataCell(Text('Halter')),
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
          DataCell(Text('Halter')),
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
          DataCell(
            Text('${calibration.roomTemperature.toStringAsFixed(2)} °C'),
          ),
          DataCell(
            Text('${calibration.roomTemperature.toStringAsFixed(2)} °C'),
          ),
          DataCell(
            Text('${calibration.roomTemperature.toStringAsFixed(2)} °C'),
          ),
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
                    Tab(text: "Log Kalibrasi", icon: Icon(Icons.sensor_door)),
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
                        Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: _buildLogTableSection(context),
                        ),
                        // _buildKalibrasiNodeRoomTab(context),
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
    return Center(
      child: Column(
        children: [
          CustomCard(
            trailing: Icon(
              Icons.device_hub_rounded,
              color: Colors.white,
              size: 30,
            ),
            withExpanded: false,
            height: MediaQuery.of(context).size.height * 0.29,
            title: "Kalibrasi Sensor Halter",
            content: Column(
              children: [
                Wrap(
                  spacing: 18,
                  runSpacing: 18,
                  children: [
                    _inputCard(
                      title: 'Suhu Badan',
                      icon: Icons.thermostat_outlined,
                      controller: suhuCtrl,
                      onMinus: () {
                        final val = int.tryParse(suhuCtrl.text) ?? 0;
                        if (val > -1000) {
                          setState(() => suhuCtrl.text = (val - 1).toString());
                        }
                      },
                      onPlus: () {
                        final val = int.tryParse(suhuCtrl.text) ?? 0;
                        if (val < 1000) {
                          setState(() => suhuCtrl.text = (val + 1).toString());
                        }
                      },
                      width: MediaQuery.of(context).size.width * 0.18,
                      height: MediaQuery.of(context).size.height * 0.16,
                    ),
                    _inputCard(
                      title: 'Detak Jantung',
                      icon: Icons.monitor_heart,
                      controller: heartRateCtrl,
                      onMinus: () {
                        final val = int.tryParse(heartRateCtrl.text) ?? 0;
                        if (val > -1000) {
                          setState(
                            () => heartRateCtrl.text = (val - 1).toString(),
                          );
                        }
                      },
                      onPlus: () {
                        final val = int.tryParse(heartRateCtrl.text) ?? 0;
                        if (val < 1000) {
                          setState(
                            () => heartRateCtrl.text = (val + 1).toString(),
                          );
                        }
                      },
                      width: MediaQuery.of(context).size.width * 0.18,
                      height: MediaQuery.of(context).size.height * 0.16,
                    ),
                    _inputCard(
                      title: 'Kadar Oksigen',
                      icon: Icons.local_fire_department_outlined,
                      controller: spoCtrl,
                      onMinus: () {
                        final val = int.tryParse(spoCtrl.text) ?? 0;
                        if (val > -1000) {
                          setState(() => spoCtrl.text = (val - 1).toString());
                        }
                      },
                      onPlus: () {
                        final val = int.tryParse(spoCtrl.text) ?? 0;
                        if (val < 1000) {
                          setState(() => spoCtrl.text = (val + 1).toString());
                        }
                      },
                      width: MediaQuery.of(context).size.width * 0.18,
                      height: MediaQuery.of(context).size.height * 0.16,
                    ),
                    _inputCard(
                      title: 'Respirasi',
                      icon: Icons.air_outlined,
                      controller: respirasiCtrl,
                      onMinus: () {
                        final val = int.tryParse(respirasiCtrl.text) ?? 0;
                        if (val > -1000) {
                          setState(
                            () => respirasiCtrl.text = (val - 1).toString(),
                          );
                        }
                      },
                      onPlus: () {
                        final val = int.tryParse(respirasiCtrl.text) ?? 0;
                        if (val < 1000) {
                          setState(
                            () => respirasiCtrl.text = (val + 1).toString(),
                          );
                        }
                      },
                      width: MediaQuery.of(context).size.width * 0.18,
                      height: MediaQuery.of(context).size.height * 0.16,
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          CustomCard(
            withExpanded: false,
            height: MediaQuery.of(context).size.height * 0.29,
            trailing: Icon(
              Icons.house_siding_rounded,
              color: Colors.white,
              size: 30,
            ),
            title: "Kalibrasi Sensor Node Room",
            content: Column(
              children: [
                Wrap(
                  spacing: 18,
                  runSpacing: 18,
                  children: [
                    _inputCard(
                      title: 'Suhu Ruangan',
                      icon: Icons.thermostat_outlined,
                      controller: suhuRuanganCtrl,
                      onMinus: () {
                        final val = int.tryParse(suhuRuanganCtrl.text) ?? 0;
                        if (val > -1000) {
                          setState(
                            () => suhuRuanganCtrl.text = (val - 1).toString(),
                          );
                        }
                      },
                      onPlus: () {
                        final val = int.tryParse(suhuRuanganCtrl.text) ?? 0;
                        if (val < 1000) {
                          setState(
                            () => suhuRuanganCtrl.text = (val + 1).toString(),
                          );
                        }
                      },
                      width: MediaQuery.of(context).size.width * 0.24,
                      height: MediaQuery.of(context).size.height * 0.16,
                    ),
                    _inputCard(
                      title: 'Kelembapan',
                      icon: Icons.water_drop_outlined,
                      controller: kelembapanCtrl,
                      onMinus: () {
                        final val = int.tryParse(kelembapanCtrl.text) ?? 0;
                        if (val > -1000) {
                          setState(
                            () => kelembapanCtrl.text = (val - 1).toString(),
                          );
                        }
                      },
                      onPlus: () {
                        final val = int.tryParse(kelembapanCtrl.text) ?? 0;
                        if (val < 1000) {
                          setState(
                            () => kelembapanCtrl.text = (val + 1).toString(),
                          );
                        }
                      },
                      width: MediaQuery.of(context).size.width * 0.24,
                      height: MediaQuery.of(context).size.height * 0.16,
                    ),
                    _inputCard(
                      title: 'Indeks Cahaya',
                      icon: Icons.light_mode_outlined,
                      controller: indeksCahayaCtrl,
                      onMinus: () {
                        final val = int.tryParse(indeksCahayaCtrl.text) ?? 0;
                        if (val > -1000) {
                          setState(
                            () => indeksCahayaCtrl.text = (val - 1).toString(),
                          );
                        }
                      },
                      onPlus: () {
                        final val = int.tryParse(indeksCahayaCtrl.text) ?? 0;
                        if (val < 1000) {
                          setState(
                            () => indeksCahayaCtrl.text = (val + 1).toString(),
                          );
                        }
                      },
                      width: MediaQuery.of(context).size.width * 0.24,
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
              controller.updateCalibration(
                temperature: double.tryParse(suhuCtrl.text) ?? 0,
                heartRate: double.tryParse(heartRateCtrl.text) ?? 0,
                spo: double.tryParse(spoCtrl.text) ?? 0,
                respiration: double.tryParse(respirasiCtrl.text) ?? 0,
                roomTemperature: double.tryParse(suhuRuanganCtrl.text) ?? 0,
                humidity: double.tryParse(kelembapanCtrl.text) ?? 0,
                lightIntensity: double.tryParse(indeksCahayaCtrl.text) ?? 0,
              );
              Get.snackbar(
                "Kalibrasi Tersimpan",
                "Nilai kalibrasi berhasil disimpan.",
                snackPosition: SnackPosition.TOP,
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            text: 'Simpan',
            iconTrailing: Icons.save,
            backgroundColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _inputCard({
    required String title,
    required IconData icon,
    required TextEditingController controller,
    required VoidCallback onMinus,
    required VoidCallback onPlus,
    double? width,
    double? height,
    int min = -1000,
    int max = 1000,
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
                    keyboardType: TextInputType.number,
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
                      // Only allow numbers and minus
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
                        onPressed: onPlus,
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
                        onPressed: onMinus,
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
                  DataColumn(label: Text('Category Lokasi')),
                  DataColumn(label: Text('Data lookup (Referensi)')),
                  DataColumn(label: Text('Data Sensor')),
                  DataColumn(label: Text('Value Kalibrasi')),
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

