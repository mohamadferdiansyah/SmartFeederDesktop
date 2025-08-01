import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/constants/app_colors.dart';
import 'package:smart_feeder_desktop/app/models/halter_rule_engine_model.dart';
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

  late TextEditingController suhuMinCtrl,
      suhuMaxCtrl,
      spoMinCtrl,
      spoMaxCtrl,
      bpmMinCtrl,
      bpmMaxCtrl,
      respMaxCtrl;

  @override
  void initState() {
    super.initState();
    final s = controller.setting.value;
    suhuMinCtrl = TextEditingController(text: s.suhuMin.toString());
    suhuMaxCtrl = TextEditingController(text: s.suhuMax.toString());
    spoMinCtrl = TextEditingController(text: s.spoMin.toString());
    spoMaxCtrl = TextEditingController(text: s.spoMax.toString());
    bpmMinCtrl = TextEditingController(text: s.bpmMin.toString());
    bpmMaxCtrl = TextEditingController(text: s.bpmMax.toString());
    respMaxCtrl = TextEditingController(text: s.respirasiMax.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: CustomCard(
        withExpanded: false,
        title: 'Rule Engine',
        content: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                child: Wrap(
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
                            suhuMin: double.tryParse(suhuMinCtrl.text) ?? 36.5,
                            suhuMax: double.tryParse(suhuMaxCtrl.text) ?? 39.0,
                            spoMin: double.tryParse(spoMinCtrl.text) ?? 95.0,
                            spoMax: double.tryParse(spoMaxCtrl.text) ?? 100.0,
                            bpmMin: int.tryParse(bpmMinCtrl.text) ?? 28,
                            bpmMax: int.tryParse(bpmMaxCtrl.text) ?? 44,
                            respirasiMax:
                                double.tryParse(respMaxCtrl.text) ?? 20.0,
                          ),
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
                            suhuMin: double.tryParse(suhuMinCtrl.text) ?? 36.5,
                            suhuMax: double.tryParse(suhuMaxCtrl.text) ?? 39.0,
                            spoMin: double.tryParse(spoMinCtrl.text) ?? 95.0,
                            spoMax: double.tryParse(spoMaxCtrl.text) ?? 100.0,
                            bpmMin: int.tryParse(bpmMinCtrl.text) ?? 28,
                            bpmMax: int.tryParse(bpmMaxCtrl.text) ?? 44,
                            respirasiMax:
                                double.tryParse(respMaxCtrl.text) ?? 20.0,
                          ),
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
                            suhuMin: double.tryParse(suhuMinCtrl.text) ?? 36.5,
                            suhuMax: double.tryParse(suhuMaxCtrl.text) ?? 39.0,
                            spoMin: double.tryParse(spoMinCtrl.text) ?? 95.0,
                            spoMax: double.tryParse(spoMaxCtrl.text) ?? 100.0,
                            bpmMin: int.tryParse(bpmMinCtrl.text) ?? 28,
                            bpmMax: int.tryParse(bpmMaxCtrl.text) ?? 44,
                            respirasiMax:
                                double.tryParse(respMaxCtrl.text) ?? 20.0,
                          ),
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
                            suhuMin: double.tryParse(suhuMinCtrl.text) ?? 36.5,
                            suhuMax: double.tryParse(suhuMaxCtrl.text) ?? 39.0,
                            spoMin: double.tryParse(spoMinCtrl.text) ?? 95.0,
                            spoMax: double.tryParse(spoMaxCtrl.text) ?? 100.0,
                            bpmMin: int.tryParse(bpmMinCtrl.text) ?? 28,
                            bpmMax: int.tryParse(bpmMaxCtrl.text) ?? 44,
                            respirasiMax:
                                double.tryParse(respMaxCtrl.text) ?? 20.0,
                          ),
                        );
                      },
                      Icons.air_outlined,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.51,
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
                                borderRadius: BorderRadius.only(
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
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        'Log Alert Halter',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Spacer(),
                                      Icon(
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
                                padding: const EdgeInsets.only(
                                  right: 16.0,
                                  top: 8,
                                ),
                                child: ListView.builder(
                                  itemCount:
                                      controller.halterHorseLogList.length,
                                  itemBuilder: (context, index) {
                                    final log =
                                        controller.halterHorseLogList[index];
                                    return CustomHalterLogCard(
                                      horseName: log.deviceId,
                                      logMessage: log.message,
                                      time: log.time,
                                      type: log.type,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
          Spacer(),
          CustomButton(
            onPressed: () {
              onSave();
              toastification.show(
                context: context,
                title: Text(
                  'Berhasil Menyimpan Pengaturan $labelOne',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                type: ToastificationType.success,
                description: Column(
                  children: [
                    Text('Suhu Min: ${ctrlOne.text}'),
                    if (ctrlTwo != null) Text('Suhu Max: ${ctrlTwo.text}'),
                  ],
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
                alignment: Alignment.topCenter,
                autoCloseDuration: const Duration(seconds: 2),
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
}
