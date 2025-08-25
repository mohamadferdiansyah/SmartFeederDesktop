import 'package:flutter/material.dart';
import 'package:smart_feeder_desktop/app/constants/app_colors.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_card.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_button.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_input.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_feeder_log_card.dart';

class FeederRuleEnginePage extends StatefulWidget {
  const FeederRuleEnginePage({super.key});

  @override
  State<FeederRuleEnginePage> createState() => _FeederRuleEnginePageState();
}

class _FeederRuleEnginePageState extends State<FeederRuleEnginePage> {
  // Controller dummy untuk input Kandang
  final TextEditingController kandangFeedMinCtrl = TextEditingController(
    text: "200",
  );
  final TextEditingController kandangWaterMinCtrl = TextEditingController(
    text: "3000",
  );
  final TextEditingController kandangPhMinCtrl = TextEditingController(
    text: "6.5",
  );

  // Controller dummy untuk input Alat Feeder
  final TextEditingController feederBatteryMinCtrl = TextEditingController(
    text: "30",
  );

  // Controller dummy untuk input Tanki
  final TextEditingController tankiWaterMinCtrl = TextEditingController(
    text: "10000",
  );
  final TextEditingController tankiFeedMinCtrl = TextEditingController(
    text: "8000",
  );
  final TextEditingController tankiPhMinCtrl = TextEditingController(
    text: "6.8",
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: CustomCard(
          withExpanded: false,
          title: 'Feeder Rule Engine',
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
                    Tab(text: "Kandang", icon: Icon(Icons.house_rounded)),
                    Tab(
                      text: "Alat Feeder",
                      icon: Icon(Icons.precision_manufacturing_rounded),
                    ),
                    Tab(text: "Tanki", icon: Icon(Icons.propane_tank_rounded)),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: TabBarView(
                    children: [
                      _scrollableTab(_buildKandangTab(context)),
                      _scrollableTab(_buildFeederTab(context)),
                      _scrollableTab(_buildTankiTab(context)),
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

  Widget _scrollableTab(Widget child) => LayoutBuilder(
    builder: (context, constraints) => SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: constraints.maxHeight,
          minWidth: constraints.maxWidth,
        ),
        child: IntrinsicHeight(child: child),
      ),
    ),
  );

  // --- TAB KANDANG ---
  Widget _buildKandangTab(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildSettingWithCard(
                'Minimal Pakan di Tempat Makan',
                'Minimal Pakan (gram)',
                null,
                kandangFeedMinCtrl,
                null,
                () {},
                Icons.rice_bowl_outlined,
              ),
              _buildSettingWithCard(
                'Minimal Air di Tempat Minum',
                'Minimal Air (ml)',
                null,
                kandangWaterMinCtrl,
                null,
                () {},
                Icons.water_drop_outlined,
              ),
              _buildSettingWithCard(
                'Minimal pH Air di Tempat Minum',
                'Minimal pH Air',
                null,
                kandangPhMinCtrl,
                null,
                () {},
                Icons.science_outlined,
              ),
              _buildLogCard(
                width: MediaQuery.of(context).size.width * 0.766,
                height: MediaQuery.of(context).size.height * 0.36,
                title: "Log Kandang",
                logs: [
                  {
                    "deviceId": "KDG001",
                    "message": "Pakan di tempat makan hampir habis (180 gram)",
                    "type": "feed_min",
                    "time": DateTime.now(),
                    "isWarning": true,
                  },
                  {
                    "deviceId": "KDG001",
                    "message": "Air di tempat minum hampir habis (2500 ml)",
                    "type": "water_min",
                    "time": DateTime.now(),
                    "isWarning": true,
                  },
                  {
                    "deviceId": "KDG002",
                    "message": "pH air di tempat minum rendah (5.8)",
                    "type": "ph_min",
                    "time": DateTime.now(),
                    "isWarning": true,
                  },
                  {
                    "deviceId": "KDG002",
                    "message": "Pakan masih cukup (250 gram)",
                    "type": "feed_min",
                    "time": DateTime.now(),
                    "isWarning": false,
                  },
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- TAB ALAT FEEDER ---
  Widget _buildFeederTab(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildSettingWithCard(
                'Minimal Baterai Alat Feeder',
                'Minimal Baterai (%)',
                null,
                feederBatteryMinCtrl,
                null,
                () {},
                Icons.battery_alert_outlined,
              ),
              _buildLogCard(
                title: "Log Alat Feeder",
                logs: [
                  {
                    "deviceId": "FD001",
                    "message": "Baterai alat feeder rendah (20%)",
                    "type": "battery_min",
                    "time": DateTime.now(),
                    "isWarning": true,
                  },
                  {
                    "deviceId": "FD001",
                    "message": "Baterai alat feeder normal (80%)",
                    "type": "battery_min",
                    "time": DateTime.now(),
                    "isWarning": false,
                  },
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- TAB TANKI ---
  Widget _buildTankiTab(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildSettingWithCard(
                'Minimal Isi Air Tanki',
                'Minimal Air (ml)',
                null,
                tankiWaterMinCtrl,
                null,
                () {},
                Icons.water_drop_rounded,
              ),
              _buildSettingWithCard(
                'Minimal Isi Pakan Tanki',
                'Minimal Pakan (gram)',
                null,
                tankiFeedMinCtrl,
                null,
                () {},
                Icons.rice_bowl_rounded,
              ),
              _buildSettingWithCard(
                'Minimal pH Air Tanki',
                'Minimal pH Air',
                null,
                tankiPhMinCtrl,
                null,
                () {},
                Icons.science_rounded,
              ),
              _buildLogCard(
                width: MediaQuery.of(context).size.width * 0.766,
                height: MediaQuery.of(context).size.height * 0.36,
                title: "Log Tanki",
                logs: [
                  {
                    "deviceId": "TNK001",
                    "message": "Isi air di tanki rendah (5000 ml)",
                    "type": "water_tank_min",
                    "time": DateTime.now(),
                    "isWarning": true,
                  },
                  {
                    "deviceId": "TNK001",
                    "message": "Isi pakan di tanki rendah (3000 gram)",
                    "type": "feed_tank_min",
                    "time": DateTime.now(),
                    "isWarning": true,
                  },
                  {
                    "deviceId": "TNK001",
                    "message": "pH air di tanki rendah (5.9)",
                    "type": "ph_tank_min",
                    "time": DateTime.now(),
                    "isWarning": true,
                  },
                  {
                    "deviceId": "TNK001",
                    "message": "Isi air di tanki normal (12000 ml)",
                    "type": "water_tank_min",
                    "time": DateTime.now(),
                    "isWarning": false,
                  },
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

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

  Widget _buildLogCard({
    required String title,
    required List<Map<String, dynamic>> logs,
    double? width,
    double? height,
  }) {
    return SizedBox(
      width: width ?? MediaQuery.of(context).size.width * 0.51,
      height: height ?? MediaQuery.of(context).size.height * 0.52,
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
                child: logs.isEmpty
                    ? const Center(child: Text("Belum ada log."))
                    : ListView.builder(
                        itemCount: logs.length,
                        itemBuilder: (context, index) {
                          final log = logs[index];
                          return CustomFeederLogCard(
                            deviceName: log['deviceId'] ?? '-',
                            roomName: null,
                            type: log['type'] ?? '',
                            logMessage: log['message'] ?? '-',
                            time: log['time'] ?? DateTime.now(),
                            isWarning: log['isWarning'] ?? false,
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
}
