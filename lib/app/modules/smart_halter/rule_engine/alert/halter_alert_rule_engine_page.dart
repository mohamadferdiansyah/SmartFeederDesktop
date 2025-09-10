import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/constants/app_colors.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_alert_rule_engine_model.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/rule_engine/alert/halter_alert_rule_engine_controller.dart';
import 'package:smart_feeder_desktop/app/utils/toast_utils.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_button.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_card.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_halter_log_card.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_input.dart';
import 'package:toastification/toastification.dart';

class HalterAlertRuleEnginePage extends StatefulWidget {
  const HalterAlertRuleEnginePage({super.key});

  @override
  State<HalterAlertRuleEnginePage> createState() =>
      _HalterAlertRuleEnginePageState();
}

class _HalterAlertRuleEnginePageState extends State<HalterAlertRuleEnginePage> {
  final controller = Get.find<HalterAlertRuleEngineController>();

  // Kuda
  late TextEditingController suhuMinCtrl,
      suhuMaxCtrl,
      spoMinCtrl,
      spoMaxCtrl,
      bpmMinCtrl,
      bpmMaxCtrl,
      respMaxCtrl,
      batteryMinCtrl,
      roomTempMinCtrl,
      roomTempMaxCtrl,
      roomHumMinCtrl,
      roomHumMaxCtrl,
      roomLuxMinCtrl,
      roomLuxMaxCtrl;

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
    batteryMinCtrl = TextEditingController(text: s.batteryMin.toString());
    roomTempMinCtrl = TextEditingController(text: s.tempRoomMin.toString());
    roomTempMaxCtrl = TextEditingController(text: s.tempRoomMax.toString());
    roomHumMinCtrl = TextEditingController(text: s.humidityMin.toString());
    roomHumMaxCtrl = TextEditingController(text: s.humidityMax.toString());
    roomLuxMinCtrl = TextEditingController(
      text: s.lightIntensityMin.toString(),
    );
    roomLuxMaxCtrl = TextEditingController(
      text: s.lightIntensityMax.toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: CustomCard(
          scrollable: false,
          withExpanded: false,
          title: 'Alert Rule Engine',
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
                  height: MediaQuery.of(context).size.height * 0.76,
                  child: TabBarView(
                    children: [
                      _buildKudaTab(context),
                      _buildHalterTab(context),
                      _buildNodeRoomTab(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FloatingActionButton.extended(
          onPressed: () {
            controller.setDefaultSetting();
            // Update semua controller input agar UI langsung berubah
            final s = controller.setting.value;
            setState(() {
              suhuMinCtrl.text = s.tempMin.toString();
              suhuMaxCtrl.text = s.tempMax.toString();
              spoMinCtrl.text = s.spoMin.toString();
              spoMaxCtrl.text = s.spoMax.toString();
              bpmMinCtrl.text = s.heartRateMin.toString();
              bpmMaxCtrl.text = s.heartRateMax.toString();
              respMaxCtrl.text = s.respiratoryMax.toString();
              batteryMinCtrl.text = s.batteryMin.toString();
              roomTempMinCtrl.text = s.tempRoomMin.toString();
              roomTempMaxCtrl.text = s.tempRoomMax.toString();
              roomHumMinCtrl.text = s.humidityMin.toString();
              roomHumMaxCtrl.text = s.humidityMax.toString();
              roomLuxMinCtrl.text = s.lightIntensityMin.toString();
              roomLuxMaxCtrl.text = s.lightIntensityMax.toString();
            });
            toastification.show(
              context: context,
              title: const Text('Settingan Default Berhasil Diaktifkan'),
              type: ToastificationType.success,
              alignment: Alignment.topCenter,
              autoCloseDuration: const Duration(seconds: 2),
            );
          },
          label: const Text(
            'Set Default Setting',
            style: TextStyle(color: Colors.white),
          ),
          icon: const Icon(Icons.restore, color: Colors.white),
          backgroundColor: AppColors.primary,
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
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildSettingWithCard(
                  'Pengaturan Suhu Tubuh (°C)',
                  'Suhu Tubuh Minimal',
                  'Suhu Tubuh Maksimal',
                  suhuMinCtrl,
                  suhuMaxCtrl,
                  () {
                    if (suhuMaxCtrl.text.isEmpty || suhuMinCtrl.text.isEmpty) {
                      showAppToast(
                        context: context,
                        type: ToastificationType.error,
                        title: 'Data Tidak Lengkap!',
                        description: 'Lengkapi Data Suhu.',
                      );
                      return;
                    }
                    controller.updateSetting(
                      HalterAlertRuleEngineModel(
                        ruleId: controller.setting.value.ruleId,
                        tempMin: double.tryParse(suhuMinCtrl.text) ?? 36.5,
                        tempMax: double.tryParse(suhuMaxCtrl.text) ?? 39.0,
                        spoMin: double.tryParse(spoMinCtrl.text) ?? 95.0,
                        spoMax: double.tryParse(spoMaxCtrl.text) ?? 100.0,
                        heartRateMin: int.tryParse(bpmMinCtrl.text) ?? 28,
                        heartRateMax: int.tryParse(bpmMaxCtrl.text) ?? 44,
                        respiratoryMax:
                            double.tryParse(respMaxCtrl.text) ?? 20.0,
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
                    showAppToast(
                      context: context,
                      type: ToastificationType.success,
                      title: 'Berhasil Disimpan!',
                      description:
                          'Suhu Min: ${suhuMinCtrl.text} | Suhu Max: ${suhuMaxCtrl.text}.',
                    );
                  },
                  Icons.thermostat_outlined,
                ),
                _buildSettingWithCard(
                  'Pengaturan SpO₂ (%)',
                  'SpO₂ Minimal',
                  'SpO₂ Maksimal',
                  spoMinCtrl,
                  spoMaxCtrl,
                  () {
                    if (spoMaxCtrl.text.isEmpty || spoMinCtrl.text.isEmpty) {
                      showAppToast(
                        context: context,
                        type: ToastificationType.error,
                        title: 'Data Tidak Lengkap!',
                        description: 'Lengkapi Data SpO₂.',
                      );
                      return;
                    }
                    controller.updateSetting(
                      HalterAlertRuleEngineModel(
                        ruleId: controller.setting.value.ruleId,
                        tempMin: double.tryParse(suhuMinCtrl.text) ?? 36.5,
                        tempMax: double.tryParse(suhuMaxCtrl.text) ?? 39.0,
                        spoMin: double.tryParse(spoMinCtrl.text) ?? 95.0,
                        spoMax: double.tryParse(spoMaxCtrl.text) ?? 100.0,
                        heartRateMin: int.tryParse(bpmMinCtrl.text) ?? 28,
                        heartRateMax: int.tryParse(bpmMaxCtrl.text) ?? 44,
                        respiratoryMax:
                            double.tryParse(respMaxCtrl.text) ?? 20.0,
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
                    showAppToast(
                      context: context,
                      type: ToastificationType.success,
                      title: 'Berhasil Disimpan!',
                      description:
                          'SpO₂ Min: ${spoMinCtrl.text} | SpO₂ Max: ${spoMaxCtrl.text}.',
                    );
                  },
                  Icons.monitor_heart_outlined,
                ),
                _buildSettingWithCard(
                  'Pengaturan Detak Jantung (beat/m)',
                  'Detak Jantung Minimal',
                  'Detak Jantung Maksimal',
                  bpmMinCtrl,
                  bpmMaxCtrl,
                  () {
                    if (bpmMaxCtrl.text.isEmpty || bpmMinCtrl.text.isEmpty) {
                      showAppToast(
                        context: context,
                        type: ToastificationType.error,
                        title: 'Data Tidak Lengkap!',
                        description: 'Lengkapi Data Detak Jantung.',
                      );
                      return;
                    }
                    controller.updateSetting(
                      HalterAlertRuleEngineModel(
                        ruleId: controller.setting.value.ruleId,
                        tempMin: double.tryParse(suhuMinCtrl.text) ?? 36.5,
                        tempMax: double.tryParse(suhuMaxCtrl.text) ?? 39.0,
                        spoMin: double.tryParse(spoMinCtrl.text) ?? 95.0,
                        spoMax: double.tryParse(spoMaxCtrl.text) ?? 100.0,
                        heartRateMin: int.tryParse(bpmMinCtrl.text) ?? 28,
                        heartRateMax: int.tryParse(bpmMaxCtrl.text) ?? 44,
                        respiratoryMax:
                            double.tryParse(respMaxCtrl.text) ?? 20.0,
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
                    showAppToast(
                      context: context,
                      type: ToastificationType.success,
                      title: 'Berhasil Disimpan!',
                      description:
                          'Detak Jantung Min: ${bpmMinCtrl.text} | Detak Jantung Max: ${bpmMaxCtrl.text}.',
                    );
                  },
                  Icons.monitor_weight_outlined,
                ),
                _buildSettingWithCard(
                  'Pengaturan Respirasi (breath/m)',
                  'Respirasi Maksimal',
                  null,
                  respMaxCtrl,
                  null,
                  () {
                    if (respMaxCtrl.text.isEmpty) {
                      showAppToast(
                        context: context,
                        type: ToastificationType.error,
                        title: 'Data Tidak Lengkap!',
                        description: 'Lengkapi Data Respirasi.',
                      );
                      return;
                    }
                    controller.updateSetting(
                      HalterAlertRuleEngineModel(
                        ruleId: controller.setting.value.ruleId,
                        tempMin: double.tryParse(suhuMinCtrl.text) ?? 36.5,
                        tempMax: double.tryParse(suhuMaxCtrl.text) ?? 39.0,
                        spoMin: double.tryParse(spoMinCtrl.text) ?? 95.0,
                        spoMax: double.tryParse(spoMaxCtrl.text) ?? 100.0,
                        heartRateMin: int.tryParse(bpmMinCtrl.text) ?? 28,
                        heartRateMax: int.tryParse(bpmMaxCtrl.text) ?? 44,
                        respiratoryMax:
                            double.tryParse(respMaxCtrl.text) ?? 20.0,
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
                    showAppToast(
                      context: context,
                      type: ToastificationType.success,
                      title: 'Berhasil Disimpan!',
                      description: 'Respirasi Max: ${respMaxCtrl.text}.',
                    );
                  },
                  Icons.air_outlined,
                ),
                _buildLogCard(
                  title: "Log Alert Kesehatan Kuda",
                  allowedTypes: ['temperature', 'spo', 'bpm', 'respirasi'],
                  logs: controller.halterHorseLogList,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ----- KONTEN TAB Halter -----
  Widget _buildHalterTab(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildSettingWithCard(
                  'Pengaturan Baterai Halter (%)',
                  'Minimal Baterai',
                  null,
                  batteryMinCtrl,
                  null,
                  () {
                    if (batteryMinCtrl.text.isEmpty) {
                      showAppToast(
                        context: context,
                        type: ToastificationType.error,
                        title: 'Data Tidak Lengkap!',
                        description: 'Lengkapi Data Baterai.',
                      );
                      return;
                    }
                    controller.updateSetting(
                      HalterAlertRuleEngineModel(
                        ruleId: controller.setting.value.ruleId,
                        tempMin: controller.setting.value.tempMin,
                        tempMax: controller.setting.value.tempMax,
                        spoMin: controller.setting.value.spoMin,
                        spoMax: controller.setting.value.spoMax,
                        heartRateMin: controller.setting.value.heartRateMin,
                        heartRateMax: controller.setting.value.heartRateMax,
                        respiratoryMax: controller.setting.value.respiratoryMax,
                        batteryMin: double.tryParse(batteryMinCtrl.text) ?? 0.0,
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
                    showAppToast(
                      context: context,
                      type: ToastificationType.success,
                      title: 'Berhasil Disimpan!',
                      description: 'Baterai Min: ${batteryMinCtrl.text}.',
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
          ),
        ],
      ),
    );
  }

  // ----- KONTEN TAB Node Room -----
  Widget _buildNodeRoomTab(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildSettingWithCard(
                  'Pengaturan Suhu Ruangan (°C)',
                  'Suhu Minimal',
                  'Suhu Maksimal',
                  roomTempMinCtrl,
                  roomTempMaxCtrl,
                  () {
                    if (roomTempMaxCtrl.text.isEmpty ||
                        roomTempMinCtrl.text.isEmpty) {
                      showAppToast(
                        context: context,
                        type: ToastificationType.error,
                        title: 'Data Tidak Lengkap!',
                        description: 'Lengkapi Data Suhu Ruangan.',
                      );
                      return;
                    }
                    controller.updateSetting(
                      HalterAlertRuleEngineModel(
                        ruleId: controller.setting.value.ruleId,
                        tempMin: controller.setting.value.tempMin,
                        tempMax: controller.setting.value.tempMax,
                        spoMin: controller.setting.value.spoMin,
                        spoMax: controller.setting.value.spoMax,
                        heartRateMin: controller.setting.value.heartRateMin,
                        heartRateMax: controller.setting.value.heartRateMax,
                        respiratoryMax: controller.setting.value.respiratoryMax,
                        batteryMin: controller.setting.value.batteryMin,
                        tempRoomMin:
                            double.tryParse(roomTempMinCtrl.text) ?? 20.0,
                        tempRoomMax:
                            double.tryParse(roomTempMaxCtrl.text) ?? 30.0,
                        humidityMin: controller.setting.value.humidityMin,
                        humidityMax: controller.setting.value.humidityMax,
                        lightIntensityMin:
                            controller.setting.value.lightIntensityMin,
                        lightIntensityMax:
                            controller.setting.value.lightIntensityMax,
                      ),
                    );
                    showAppToast(
                      context: context,
                      type: ToastificationType.success,
                      title: 'Berhasil Disimpan!',
                      description:
                          'Suhu Min: ${roomTempMinCtrl.text} | Suhu Max: ${roomTempMaxCtrl.text}.',
                    );
                  },
                  Icons.thermostat_outlined,
                ),
                _buildSettingWithCard(
                  'Pengaturan Kelembapan Ruangan (%)',
                  'Kelembapan Minimal',
                  'Kelembapan Maksimal',
                  roomHumMinCtrl,
                  roomHumMaxCtrl,
                  () {
                    if (roomHumMaxCtrl.text.isEmpty ||
                        roomHumMinCtrl.text.isEmpty) {
                      showAppToast(
                        context: context,
                        type: ToastificationType.error,
                        title: 'Data Tidak Lengkap!',
                        description: 'Lengkapi Data Kelembapan.',
                      );
                      return;
                    }
                    controller.updateSetting(
                      HalterAlertRuleEngineModel(
                        ruleId: controller.setting.value.ruleId,
                        tempMin: controller.setting.value.tempMin,
                        tempMax: controller.setting.value.tempMax,
                        spoMin: controller.setting.value.spoMin,
                        spoMax: controller.setting.value.spoMax,
                        heartRateMin: controller.setting.value.heartRateMin,
                        heartRateMax: controller.setting.value.heartRateMax,
                        respiratoryMax: controller.setting.value.respiratoryMax,
                        batteryMin: controller.setting.value.batteryMin,
                        tempRoomMin: controller.setting.value.tempRoomMin,
                        tempRoomMax: controller.setting.value.tempRoomMax,
                        humidityMin:
                            double.tryParse(roomHumMinCtrl.text) ?? 30.0,
                        humidityMax:
                            double.tryParse(roomHumMaxCtrl.text) ?? 50.0,
                        lightIntensityMin:
                            controller.setting.value.lightIntensityMin,
                        lightIntensityMax:
                            controller.setting.value.lightIntensityMax,
                      ),
                    );
                    showAppToast(
                      context: context,
                      type: ToastificationType.success,
                      title: 'Berhasil Disimpan!',
                      description:
                          'Kelembapan Min: ${roomHumMinCtrl.text} | Kelembapan Max: ${roomHumMaxCtrl.text}.',
                    );
                  },
                  Icons.water_drop_outlined,
                ),
                _buildSettingWithCard(
                  'Pengaturan Cahaya Ruangan (Lux)',
                  'Cahaya Minimal',
                  'Cahaya Maksimal',
                  roomLuxMinCtrl,
                  roomLuxMaxCtrl,
                  () {
                    if (roomLuxMaxCtrl.text.isEmpty ||
                        roomLuxMinCtrl.text.isEmpty) {
                      showAppToast(
                        context: context,
                        type: ToastificationType.error,
                        title: 'Data Tidak Lengkap!',
                        description: 'Lengkapi Data Cahaya.',
                      );
                      return;
                    }
                    controller.updateSetting(
                      HalterAlertRuleEngineModel(
                        ruleId: controller.setting.value.ruleId,
                        tempMin: controller.setting.value.tempMin,
                        tempMax: controller.setting.value.tempMax,
                        spoMin: controller.setting.value.spoMin,
                        spoMax: controller.setting.value.spoMax,
                        heartRateMin: controller.setting.value.heartRateMin,
                        heartRateMax: controller.setting.value.heartRateMax,
                        respiratoryMax: controller.setting.value.respiratoryMax,
                        batteryMin: controller.setting.value.batteryMin,
                        tempRoomMin: controller.setting.value.tempRoomMin,
                        tempRoomMax: controller.setting.value.tempRoomMax,
                        humidityMin: controller.setting.value.humidityMin,
                        humidityMax: controller.setting.value.humidityMax,
                        lightIntensityMin:
                            double.tryParse(roomLuxMinCtrl.text) ?? 0.0,
                        lightIntensityMax:
                            double.tryParse(roomLuxMaxCtrl.text) ?? 100.0,
                      ),
                    );
                    showAppToast(
                      context: context,
                      type: ToastificationType.success,
                      title: 'Berhasil Disimpan!',
                      description:
                          'Cahaya Min: ${roomLuxMinCtrl.text} | Cahaya Max: ${roomLuxMaxCtrl.text}.',
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
          CustomInput(
            label: labelOne,
            controller: ctrlOne,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
            ],
          ),
          if (labelTwo != null && ctrlTwo != null) ...[
            const SizedBox(height: 12),
            CustomInput(
              label: labelTwo,
              controller: ctrlTwo,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
              ],
            ),
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
