import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/constants/app_colors.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_rule_engine_model.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/rule_engine/halter_rule_engine_controller.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_button.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_card.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_halter_log_card.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_input.dart';
import 'package:toastification/toastification.dart';

class HalterRuleEnginePage extends StatefulWidget {
  const HalterRuleEnginePage({super.key});

  @override
  State<HalterRuleEnginePage> createState() => _HalterRuleEnginePageState();
}

class _HalterRuleEnginePageState extends State<HalterRuleEnginePage> {
  final controller = Get.find<HalterRuleEngineController>();

  // Kuda
  late TextEditingController suhuMinCtrl,
      suhuMaxCtrl,
      spoMinCtrl,
      spoMaxCtrl,
      bpmMinCtrl,
      bpmMaxCtrl,
      respMaxCtrl;

  // Halter
  final TextEditingController batteryMinCtrl = TextEditingController(
    text: "20",
  );

  // Node Room
  final TextEditingController roomTempMinCtrl = TextEditingController(
    text: "20",
  );
  final TextEditingController roomTempMaxCtrl = TextEditingController(
    text: "35",
  );
  final TextEditingController roomHumMinCtrl = TextEditingController(
    text: "40",
  );
  final TextEditingController roomHumMaxCtrl = TextEditingController(
    text: "75",
  );
  final TextEditingController roomLuxMinCtrl = TextEditingController(
    text: "100",
  );
  final TextEditingController roomLuxMaxCtrl = TextEditingController(
    text: "1000",
  );

  @override
  void initState() {
    super.initState();
    final s = controller.setting.value;
    suhuMinCtrl = TextEditingController(text: s.tempMin.toString());
    suhuMaxCtrl = TextEditingController(text: s.tempMax.toString());
    spoMinCtrl = TextEditingController(text: s.spoMin.toString());
    spoMaxCtrl = TextEditingController(text: s.spoMax.toString());
    bpmMinCtrl = TextEditingController(text: s.heartRateMin.toString());
    bpmMaxCtrl = TextEditingController(text: s.heartRateMax.toString());
    respMaxCtrl = TextEditingController(text: s.respiratoryMax.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: CustomCard(
          withExpanded: false,
          title: 'Rule Engine',
          content: DefaultTabController(
            length: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TabBar(
                  labelColor: AppColors.primary,
                  unselectedLabelColor: Colors.black54,
                  indicatorColor: AppColors.primary,
                  tabs: const [
                    Tab(text: "Kuda", icon: Icon(Icons.pets_rounded)),
                    Tab(text: "Halter", icon: Icon(Icons.device_hub_rounded)),
                    Tab(
                      text: "Node Room",
                      icon: Icon(Icons.house_siding_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Expanded ensures TabBarView fills available space
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.8,
                  child: TabBarView(
                    children: [
                      _scrollableTab(_buildKudaTab(context)),
                      _scrollableTab(_buildHalterTab(context)),
                      _scrollableTab(_buildNodeRoomTab(context)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper untuk bungkus konten tab dengan scroll view yang proper
  Widget _scrollableTab(Widget child) => LayoutBuilder(
    builder: (context, constraints) => SingleChildScrollView(
      // Agar lebar tab tetap penuh viewport
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: constraints.maxHeight,
          minWidth: constraints.maxWidth,
        ),
        child: IntrinsicHeight(child: child),
      ),
    ),
  );

  // ----- KONTEN TAB Kuda -----
  Widget _buildKudaTab(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildSettingWithCard(
                'Pengaturan Suhu',
                'Suhu Minimal',
                'Suhu Maksimal',
                suhuMinCtrl,
                suhuMaxCtrl,
                () {
                  controller.updateSetting(
                    HalterRuleEngineModel(
                      ruleId: controller.setting.value.ruleId,
                      tempMin: double.tryParse(suhuMinCtrl.text) ?? 36.5,
                      tempMax: double.tryParse(suhuMaxCtrl.text) ?? 39.0,
                      spoMin: double.tryParse(spoMinCtrl.text) ?? 95.0,
                      spoMax: double.tryParse(spoMaxCtrl.text) ?? 100.0,
                      heartRateMin: int.tryParse(bpmMinCtrl.text) ?? 28,
                      heartRateMax: int.tryParse(bpmMaxCtrl.text) ?? 44,
                      respiratoryMax: double.tryParse(respMaxCtrl.text) ?? 20.0,
                      batteryMin: controller.setting.value.batteryMin,
                      tempRoomMin: controller.setting.value.tempRoomMin,
                      tempRoomMax: controller.setting.value.tempRoomMax,
                      humidityMin: controller.setting.value.humidityMin,
                      humidityMax: controller.setting.value.humidityMax,
                      lightIntensityMin:
                          controller.setting.value.lightIntensityMin,
                      lightIntensityMax:
                          controller.setting.value.lightIntensityMax,
                    ),
                  );
                  toastification.show(
                    context: context,
                    title: const Text(
                      'Berhasil Menyimpan Pengaturan Suhu Kuda',
                    ),
                    type: ToastificationType.success,
                    alignment: Alignment.topCenter,
                    autoCloseDuration: const Duration(seconds: 2),
                  );
                },
                Icons.thermostat_outlined,
              ),
              _buildSettingWithCard(
                'Pengaturan Kadar Oksigen Darah',
                'SPO Minimal',
                'SPO Maksimal',
                spoMinCtrl,
                spoMaxCtrl,
                () {
                  controller.updateSetting(
                    HalterRuleEngineModel(
                      ruleId: controller.setting.value.ruleId,
                      tempMin: double.tryParse(suhuMinCtrl.text) ?? 36.5,
                      tempMax: double.tryParse(suhuMaxCtrl.text) ?? 39.0,
                      spoMin: double.tryParse(spoMinCtrl.text) ?? 95.0,
                      spoMax: double.tryParse(spoMaxCtrl.text) ?? 100.0,
                      heartRateMin: int.tryParse(bpmMinCtrl.text) ?? 28,
                      heartRateMax: int.tryParse(bpmMaxCtrl.text) ?? 44,
                      respiratoryMax: double.tryParse(respMaxCtrl.text) ?? 20.0,
                      batteryMin: controller.setting.value.batteryMin,
                      tempRoomMin: controller.setting.value.tempRoomMin,
                      tempRoomMax: controller.setting.value.tempRoomMax,
                      humidityMin: controller.setting.value.humidityMin,
                      humidityMax: controller.setting.value.humidityMax,
                      lightIntensityMin:
                          controller.setting.value.lightIntensityMin,
                      lightIntensityMax:
                          controller.setting.value.lightIntensityMax,
                    ),
                  );
                  toastification.show(
                    context: context,
                    title: const Text(
                      'Berhasil Menyimpan Pengaturan Kadar Oksigen Kuda',
                    ),
                    type: ToastificationType.success,
                    alignment: Alignment.topCenter,
                    autoCloseDuration: const Duration(seconds: 2),
                  );
                },
                Icons.monitor_heart_outlined,
              ),
              _buildSettingWithCard(
                'Pengaturan BPM',
                'BPM Minimal',
                'BPM Maksimal',
                bpmMinCtrl,
                bpmMaxCtrl,
                () {
                  controller.updateSetting(
                    HalterRuleEngineModel(
                      ruleId: controller.setting.value.ruleId,
                      tempMin: double.tryParse(suhuMinCtrl.text) ?? 36.5,
                      tempMax: double.tryParse(suhuMaxCtrl.text) ?? 39.0,
                      spoMin: double.tryParse(spoMinCtrl.text) ?? 95.0,
                      spoMax: double.tryParse(spoMaxCtrl.text) ?? 100.0,
                      heartRateMin: int.tryParse(bpmMinCtrl.text) ?? 28,
                      heartRateMax: int.tryParse(bpmMaxCtrl.text) ?? 44,
                      respiratoryMax: double.tryParse(respMaxCtrl.text) ?? 20.0,
                      batteryMin: controller.setting.value.batteryMin,
                      tempRoomMin: controller.setting.value.tempRoomMin,
                      tempRoomMax: controller.setting.value.tempRoomMax,
                      humidityMin: controller.setting.value.humidityMin,
                      humidityMax: controller.setting.value.humidityMax,
                      lightIntensityMin:
                          controller.setting.value.lightIntensityMin,
                      lightIntensityMax:
                          controller.setting.value.lightIntensityMax,
                    ),
                  );
                  toastification.show(
                    context: context,
                    title: const Text('Berhasil Menyimpan Pengaturan BPM Kuda'),
                    type: ToastificationType.success,
                    alignment: Alignment.topCenter,
                    autoCloseDuration: const Duration(seconds: 2),
                  );
                },
                Icons.monitor_weight_outlined,
              ),
              _buildSettingWithCard(
                'Pengaturan Respirasi',
                'Respirasi Maksimal',
                null,
                respMaxCtrl,
                null,
                () {
                  controller.updateSetting(
                    HalterRuleEngineModel(
                      ruleId: controller.setting.value.ruleId,
                      tempMin: double.tryParse(suhuMinCtrl.text) ?? 36.5,
                      tempMax: double.tryParse(suhuMaxCtrl.text) ?? 39.0,
                      spoMin: double.tryParse(spoMinCtrl.text) ?? 95.0,
                      spoMax: double.tryParse(spoMaxCtrl.text) ?? 100.0,
                      heartRateMin: int.tryParse(bpmMinCtrl.text) ?? 28,
                      heartRateMax: int.tryParse(bpmMaxCtrl.text) ?? 44,
                      respiratoryMax: double.tryParse(respMaxCtrl.text) ?? 20.0,
                      batteryMin: controller.setting.value.batteryMin,
                      tempRoomMin: controller.setting.value.tempRoomMin,
                      tempRoomMax: controller.setting.value.tempRoomMax,
                      humidityMin: controller.setting.value.humidityMin,
                      humidityMax: controller.setting.value.humidityMax,
                      lightIntensityMin:
                          controller.setting.value.lightIntensityMin,
                      lightIntensityMax:
                          controller.setting.value.lightIntensityMax,
                    ),
                  );
                  toastification.show(
                    context: context,
                    title: const Text(
                      'Berhasil Menyimpan Pengaturan Respirasi Kuda',
                    ),
                    type: ToastificationType.success,
                    alignment: Alignment.topCenter,
                    autoCloseDuration: const Duration(seconds: 2),
                  );
                },
                Icons.air_outlined,
              ),
              _buildLogCard(
                title: "Log Alert Kesehatan Kuda",
                allowedTypes: ['suhu', 'spo', 'bpm', 'respirasi'],
                logs: controller.halterHorseLogList,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ----- KONTEN TAB Halter -----
  Widget _buildHalterTab(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildSettingWithCard(
                'Pengaturan Baterai Halter',
                'Minimal Baterai (%)',
                null,
                batteryMinCtrl,
                null,
                () {
                  toastification.show(
                    context: context,
                    title: const Text(
                      'Berhasil Menyimpan Pengaturan Minimal Baterai',
                    ),
                    type: ToastificationType.success,
                    description: Text(
                      'Minimal Baterai: ${batteryMinCtrl.text}%',
                    ),
                    alignment: Alignment.topCenter,
                    autoCloseDuration: const Duration(seconds: 2),
                  );
                },
                Icons.battery_3_bar,
              ),
              _buildLogCard(
                title: "Log Alert Halter",
                allowedTypes: ['battery'],
                logs: controller.halterHorseLogList,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ----- KONTEN TAB Node Room -----
  Widget _buildNodeRoomTab(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildSettingWithCard(
                'Pengaturan Suhu Ruangan',
                'Suhu Minimal',
                'Suhu Maksimal',
                roomTempMinCtrl,
                roomTempMaxCtrl,
                () {
                  toastification.show(
                    context: context,
                    title: const Text(
                      'Berhasil Menyimpan Pengaturan Suhu Ruangan',
                    ),
                    type: ToastificationType.success,
                    description: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Suhu Min: ${roomTempMinCtrl.text}'),
                        Text('Suhu Max: ${roomTempMaxCtrl.text}'),
                      ],
                    ),
                    alignment: Alignment.topCenter,
                    autoCloseDuration: const Duration(seconds: 2),
                  );
                },
                Icons.thermostat_outlined,
              ),
              _buildSettingWithCard(
                'Pengaturan Kelembapan Ruangan',
                'Kelembapan Minimal',
                'Kelembapan Maksimal',
                roomHumMinCtrl,
                roomHumMaxCtrl,
                () {
                  toastification.show(
                    context: context,
                    title: const Text(
                      'Berhasil Menyimpan Pengaturan Kelembapan Ruangan',
                    ),
                    type: ToastificationType.success,
                    description: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Kelembapan Min: ${roomHumMinCtrl.text}'),
                        Text('Kelembapan Max: ${roomHumMaxCtrl.text}'),
                      ],
                    ),
                    alignment: Alignment.topCenter,
                    autoCloseDuration: const Duration(seconds: 2),
                  );
                },
                Icons.water_drop_outlined,
              ),
              _buildSettingWithCard(
                'Pengaturan Lux Ruangan',
                'Lux Minimal',
                'Lux Maksimal',
                roomLuxMinCtrl,
                roomLuxMaxCtrl,
                () {
                  toastification.show(
                    context: context,
                    title: const Text(
                      'Berhasil Menyimpan Pengaturan Lux Ruangan',
                    ),
                    type: ToastificationType.success,
                    description: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Lux Min: ${roomLuxMinCtrl.text}'),
                        Text('Lux Max: ${roomLuxMaxCtrl.text}'),
                      ],
                    ),
                    alignment: Alignment.topCenter,
                    autoCloseDuration: const Duration(seconds: 2),
                  );
                },
                Icons.light_mode_outlined,
              ),
              // CARD LOG UNTUK NODE ROOM
              _buildLogCard(
                width: MediaQuery.of(context).size.width * 0.767,
                title: "Log Alert Node Room",
                allowedTypes: [
                  'room_temperature',
                  'humidity',
                  'light_intensity',
                ],
                logs: controller
                    .halterHorseLogList, // Ganti dengan log node room jika ada
              ),
            ],
          ),
        ],
      ),
    );
  }

  // CARD LOG
  Widget _buildLogCard({
    required String title,
    required List logs,
    required List<String> allowedTypes,
    double? width,
  }) {
    // Filter logs sesuai allowedTypes
    final filteredLogs = logs
        .where((log) => allowedTypes.contains(log.type))
        .toList();

    return SizedBox(
      width: width ?? MediaQuery.of(context).size.width * 0.51,
      height: MediaQuery.of(context).size.height * 0.52,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.166,
        height: MediaQuery.of(context).size.height * 0.66,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              height: 50,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0, top: 8),
                child: filteredLogs.isEmpty
                    ? const Center(child: Text("Belum ada log."))
                    : ListView.builder(
                        itemCount: filteredLogs.length,
                        itemBuilder: (context, index) {
                          final log = filteredLogs[index];
                          return CustomHalterLogCard(
                            horseName: log.deviceId ?? "-",
                            logMessage: log.message ?? "-",
                            time: log.time ?? DateTime.now(),
                            type: log.type,
                            isHigh: log.isHigh,
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // CARD SETTING
  Widget _buildSettingWithCard(
    String title,
    String labelOne,
    String? labelTwo,
    TextEditingController ctrlOne,
    TextEditingController? ctrlTwo,
    VoidCallback onSave,
    IconData icon,
  ) {
    return CustomCard(
      title: title,
      withExpanded: false,
      trailing: Icon(icon, color: Colors.white, size: 24),
      headerColor: AppColors.primary,
      headerHeight: 50,
      titleFontSize: 18,
      width: MediaQuery.of(context).size.width * 0.25,
      height: MediaQuery.of(context).size.height * 0.32,
      borderRadius: 16,
      scrollable: false,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomInput(label: labelOne, controller: ctrlOne),
          if (labelTwo != null && ctrlTwo != null) ...[
            const SizedBox(height: 12),
            CustomInput(label: labelTwo, controller: ctrlTwo),
          ],
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
}
