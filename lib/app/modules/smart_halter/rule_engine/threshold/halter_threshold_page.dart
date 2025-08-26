import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:smart_feeder_desktop/app/constants/app_colors.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_sensor_threshold_model.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/rule_engine/threshold/halter_threshold_controller.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_button.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_card.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_dropdown.dart';

class HalterSensorThresholdPage extends StatefulWidget {
  const HalterSensorThresholdPage({super.key});
  @override
  State<HalterSensorThresholdPage> createState() =>
      _HalterSensorThresholdPageState();
}

class _HalterSensorThresholdPageState extends State<HalterSensorThresholdPage> {
  final HalterThresholdController controller =
      Get.find<HalterThresholdController>();

  final List<String> halterSensors = [
    "temperature",
    "heartRate",
    "spo",
    "respiratoryRate",
  ];
  final List<String> nodeRoomSensors = [
    "temperature",
    "humidity",
    "lightIntensity",
  ];

  String selectedSensor = "temperature";
  String selectedNodeSensor = "temperature";

  final minCtrl = TextEditingController();
  final maxCtrl = TextEditingController();
  final minNodeCtrl = TextEditingController();
  final maxNodeCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _updateFields();
  }

  void _updateFields() {
    final t = controller.halterThresholds[selectedSensor];
    minCtrl.text = t?.minValue.toString() ?? "";
    maxCtrl.text = t?.maxValue.toString() ?? "";
    final tn = controller.nodeRoomThresholds[selectedNodeSensor];
    minNodeCtrl.text = tn?.minValue.toString() ?? "";
    maxNodeCtrl.text = tn?.maxValue.toString() ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: CustomCard(
        scrollable: false,
        withExpanded: false,
        title: 'Threshold Sensor',
        content: DefaultTabController(
          length: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TabBar(
                labelColor: AppColors.primary,
                unselectedLabelColor: Colors.black54,
                indicatorColor: AppColors.primary,
                tabs: const [
                  Tab(text: "Halter", icon: Icon(Icons.device_hub_rounded)),
                  Tab(
                    text: "Node Room",
                    icon: Icon(Icons.house_siding_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.76,
                child: TabBarView(
                  children: [
                    _buildThresholdTab(
                      sensors: halterSensors,
                      selectedSensor: selectedSensor,
                      minCtrl: minCtrl,
                      maxCtrl: maxCtrl,
                      onSensorChanged: (v) {
                        setState(() {
                          selectedSensor = v!;
                          _updateFields();
                        });
                      },
                      onSave: () {
                        final min = double.tryParse(minCtrl.text) ?? 0;
                        final max = double.tryParse(maxCtrl.text) ?? 0;
                        controller.saveHalterThreshold(
                          selectedSensor,
                          min,
                          max,
                        );
                        _updateFields();
                        Get.snackbar(
                          "Berhasil",
                          "Threshold sensor tersimpan",
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                        );
                      },
                      thresholds: controller.halterThresholds,
                    ),
                    _buildThresholdTab(
                      sensors: nodeRoomSensors,
                      selectedSensor: selectedNodeSensor,
                      minCtrl: minNodeCtrl,
                      maxCtrl: maxNodeCtrl,
                      onSensorChanged: (v) {
                        setState(() {
                          selectedNodeSensor = v!;
                          _updateFields();
                        });
                      },
                      onSave: () {
                        final min = double.tryParse(minNodeCtrl.text) ?? 0;
                        final max = double.tryParse(maxNodeCtrl.text) ?? 0;
                        controller.saveNodeRoomThreshold(
                          selectedNodeSensor,
                          min,
                          max,
                        );
                        _updateFields();
                        Get.snackbar(
                          "Berhasil",
                          "Threshold node room tersimpan",
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                        );
                      },
                      thresholds: controller.nodeRoomThresholds,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThresholdTab({
    required List<String> sensors,
    required String selectedSensor,
    required TextEditingController minCtrl,
    required TextEditingController maxCtrl,
    required void Function(String?) onSensorChanged,
    required VoidCallback onSave,
    required Map<String, HalterSensorThresholdModel> thresholds,
  }) {
    String labelMin = "Batas Bawah";
    String labelMax = "Batas Atas";
    IconData icon = Icons.device_hub_rounded;
    String title = "Pengaturan ${selectedSensor.capitalizeFirst}";
    if (selectedSensor == "temperature") {
      icon = Icons.thermostat_outlined;
      title = "Pengaturan Suhu";
    } else if (selectedSensor == "heartRate") {
      icon = Icons.monitor_heart;
      title = "Pengaturan BPM";
    } else if (selectedSensor == "spo") {
      icon = Icons.local_fire_department_outlined;
      title = "Pengaturan SPO";
    } else if (selectedSensor == "respiratoryRate") {
      icon = Icons.air_outlined;
      title = "Pengaturan Respirasi";
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CustomDropdownCard(
                      label: "Sensor",
                      value: selectedSensor,
                      items: sensors,
                      hint: "Pilih Sensor",
                      onChanged: onSensorChanged,
                    ),
                    buildThresholdList(thresholds),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                flex: 4,
                child: buildThresholdCard(
                  title: title,
                  minLabel: labelMin,
                  maxLabel: labelMax,
                  minCtrl: minCtrl,
                  maxCtrl: maxCtrl,
                  onSave: onSave,
                  icon: icon,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildThresholdCard({
    required String title,
    required String minLabel,
    required String maxLabel,
    required TextEditingController minCtrl,
    required TextEditingController maxCtrl,
    required VoidCallback onSave,
    required IconData icon,
  }) {
    return CustomCard(
      title: title,
      withExpanded: false,
      trailing: Icon(icon, color: Colors.white, size: 24),
      headerColor: AppColors.primary,
      headerHeight: 50,
      titleFontSize: 18,
      width: 500, // Atur lebar sesuai kebutuhan
      height: 320,
      borderRadius: 16,
      scrollable: false,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          Text(minLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
          TextField(
            controller: minCtrl,
            decoration: const InputDecoration(),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          Text(maxLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
          TextField(
            controller: maxCtrl,
            decoration: const InputDecoration(),
            keyboardType: TextInputType.number,
          ),
          const Spacer(),
          CustomButton(
            onPressed: onSave,
            text: 'Simpan',
            iconTrailing: Icons.save,
            backgroundColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  // Widget threshold list, masukkan ke dalam Column bersama dropdown
  Widget buildThresholdList(
    Map<String, HalterSensorThresholdModel> thresholds,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: thresholds.values.map((t) {
        return Card(
          elevation: 0,
          margin: const EdgeInsets.symmetric(vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
            child: Row(
              children: [
                Icon(
                  _getSensorIcon(t.sensorName),
                  color: AppColors.primary,
                  size: 28,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    t.sensorName.capitalizeFirst ?? t.sensorName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: "Min: ",
                        style: TextStyle(color: Colors.black54),
                      ),
                      TextSpan(
                        text: "${t.minValue}  ",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const TextSpan(
                        text: "Max: ",
                        style: TextStyle(color: Colors.black54),
                      ),
                      TextSpan(
                        text: "${t.maxValue}",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // Helper icon
  IconData _getSensorIcon(String sensor) {
    switch (sensor) {
      case "temperature":
        return Icons.thermostat_outlined;
      case "heartRate":
        return Icons.monitor_heart;
      case "spo":
        return Icons.local_fire_department_outlined;
      case "respiratoryRate":
        return Icons.air_outlined;
      case "humidity":
        return Icons.water_drop_outlined;
      case "lightIntensity":
        return Icons.light_mode_outlined;
      default:
        return Icons.device_hub_rounded;
    }
  }
}
