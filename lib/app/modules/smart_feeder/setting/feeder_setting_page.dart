import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/modules/smart_feeder/dashboard/feeder_dashboard_controller.dart';
import 'package:smart_feeder_desktop/app/modules/smart_feeder/setting/feeder_setting_controller.dart';
import 'package:smart_feeder_desktop/app/utils/toast_utils.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_card.dart';
import 'package:smart_feeder_desktop/app/constants/app_colors.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_input.dart';
import 'package:toastification/toastification.dart';

class FeederSettingPage extends StatefulWidget {
  const FeederSettingPage({super.key});

  @override
  State<FeederSettingPage> createState() => FeederSettingPageState();
}

class FeederSettingPageState extends State<FeederSettingPage> {
  final FeederDashboardController controller = Get.find();
  final FeederSettingController settingController = Get.find();
  final TextEditingController _mqttHostController = TextEditingController();
  final TextEditingController _mqttPortController = TextEditingController();

  // final TextEditingController _cloudUrlController = TextEditingController(
  //   text: 'https://smarthalter.ipb.ac.id',
  // );

  // String? _selectedLoraPort;
  // bool _loraConnected = false;

  // String? _selectedJenisPengiriman = 'LoRa';

  @override
  void initState() {
    super.initState();
    // _selectedLoraPort = settingController.setting.value.loraPort.isEmpty
    //     ? null
    //     : settingController.setting.value.loraPort;
    // _loraConnected = settingController.setting.value.loraPort.isNotEmpty;
    _mqttHostController.text = settingController.mqttHost.value;
    _mqttPortController.text = settingController.mqttPort.value.toString();
  }

  @override
  Widget build(BuildContext context) {
    // Atur ukuran card agar tidak full height, dan grid agar responsif
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: CustomCard(
        title: 'Pengaturan Aplikasi Halter',
        withExpanded: false,
        content: Center(
          child: Column(
            children: [
              SingleChildScrollView(
                child: Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  children: [
                    CustomCard(
                      titleFontSize: 20,
                      headerHeight: 50,
                      trailing: Icon(
                        Icons.wifi_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                      withExpanded: false,
                      height: MediaQuery.of(context).size.height * 0.33,
                      title: "Pengaturan Koneksi",
                      content: Column(
                        children: [
                          Wrap(
                            spacing: 18,
                            runSpacing: 18,
                            children: [
                              CustomCard(
                                title: 'Koneksi MQTT',
                                headerColor: AppColors.primary,
                                headerHeight: 50,
                                titleFontSize: 18,
                                width: MediaQuery.of(context).size.width * 0.3,
                                height:
                                    MediaQuery.of(context).size.height * 0.24,
                                borderRadius: 16,
                                scrollable: false,
                                content: Column(
                                  children: [
                                    Obx(() {
                                      final isConnected =
                                          settingController.mqttConnected.value;
                                      return Row(
                                        children: [
                                          Expanded(
                                            child: CustomInput(
                                              label: 'MQTT Host/Broker',
                                              controller: _mqttHostController,
                                              hint: 'Masukan Host MQTT',
                                              enabled: !isConnected,
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          SizedBox(
                                            width:
                                                MediaQuery.of(
                                                  context,
                                                ).size.width *
                                                0.05,
                                            child: CustomInput(
                                              label: 'MQTT Port',
                                              controller: _mqttPortController,
                                              hint: 'Masukan Port MQTT',
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                              ],
                                              enabled: !isConnected,
                                            ),
                                          ),
                                        ],
                                      );
                                    }),
                                    const SizedBox(height: 8),
                                    Obx(
                                      () => Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          LinearProgressIndicator(
                                            value: 1,
                                            minHeight: 8,
                                            color:
                                                settingController
                                                    .mqttConnected
                                                    .value
                                                ? Colors.green
                                                : Colors.red,
                                            backgroundColor: Colors.grey[300],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            settingController
                                                    .mqttConnected
                                                    .value
                                                ? 'Terhubung'
                                                : 'Tidak Terhubung',
                                            style: TextStyle(
                                              color:
                                                  settingController
                                                      .mqttConnected
                                                      .value
                                                  ? Colors.green
                                                  : Colors.red,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.right,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Obx(() {
                                      final isConnected =
                                          settingController.mqttConnected.value;
                                      final isLoading =
                                          settingController.mqttLoading.value;
                                      return SizedBox(
                                        width: double.infinity,
                                        height: 40,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: isConnected
                                                ? Colors.red
                                                : AppColors.primary,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          onPressed: isLoading
                                              ? null
                                              : () async {
                                                  if (isConnected) {
                                                    settingController
                                                        .disconnectMqtt();
                                                    showAppToast(
                                                      context: context,
                                                      type: ToastificationType
                                                          .info,
                                                      title: 'MQTT Terputus!',
                                                      description:
                                                          'Koneksi MQTT telah diputuskan.',
                                                    );
                                                  } else {
                                                    settingController
                                                        .setMqttHost(
                                                          _mqttHostController
                                                              .text
                                                              .trim(),
                                                        );
                                                    settingController.setMqttPort(
                                                      int.tryParse(
                                                            _mqttPortController
                                                                .text
                                                                .trim(),
                                                          ) ??
                                                          1883,
                                                    );
                                                    final success =
                                                        await settingController
                                                            .connectMqtt();
                                                    showAppToast(
                                                      context: context,
                                                      type: success
                                                          ? ToastificationType
                                                                .success
                                                          : ToastificationType
                                                                .error,
                                                      title: success
                                                          ? 'Berhasil Dihubungkan!'
                                                          : 'Gagal Menghubungkan!',
                                                      description: success
                                                          ? 'MQTT Host dan Port Disimpan & Dihubungkan.'
                                                          : 'Tidak dapat terhubung ke MQTT Broker.',
                                                    );
                                                  }
                                                },
                                          child: isLoading
                                              ? const SizedBox(
                                                  width: 24,
                                                  height: 24,
                                                  child:
                                                      CircularProgressIndicator(
                                                        color: Colors.white,
                                                        strokeWidth: 3,
                                                      ),
                                                )
                                              : Text(
                                                  isConnected
                                                      ? 'Putuskan'
                                                      : 'Hubungkan',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                ),
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    CustomCard(
                      titleFontSize: 20,
                      headerHeight: 50,
                      trailing: Icon(
                        Icons.house_siding_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                      withExpanded: false,
                      height: MediaQuery.of(context).size.height * 0.33,
                      title: "Pengaturan Kandang",
                      content: Column(
                        children: [
                          Wrap(
                            spacing: 18,
                            runSpacing: 18,
                            children: [
                              CustomCard(
                                title: 'Pilih Kandang',
                                headerColor: AppColors.primary,
                                withExpanded: false,
                                headerHeight: 50,
                                titleFontSize: 18,
                                width: MediaQuery.of(context).size.width * 0.24,
                                height:
                                    MediaQuery.of(context).size.height * 0.24,
                                borderRadius: 16,
                                scrollable: false,
                                content: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    const Text('Kandang'),
                                    const SizedBox(height: 4),
                                    Obx(() {
                                      final list = controller.stableList;
                                      // Cari apakah selectedStableId ada di list, kalau tidak, set null
                                      final selected =
                                          list.any(
                                            (s) =>
                                                s.stableId ==
                                                controller
                                                    .selectedStableId
                                                    .value,
                                          )
                                          ? controller.selectedStableId.value
                                          : null;

                                      if (selected == null && list.isNotEmpty) {
                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                              controller.setSelectedStableId(
                                                list.first.stableId,
                                              );
                                            });
                                      }
                                      return DropdownButtonFormField<String>(
                                        value: selected,
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          isDense: true,
                                        ),
                                        items: list
                                            .map(
                                              (stable) => DropdownMenuItem(
                                                value: stable.stableId,
                                                child: Text(stable.name),
                                              ),
                                            )
                                            .toList(),
                                        onChanged: (val) {
                                          if (val != null) {
                                            controller.setSelectedStableId(val);
                                          }
                                        },
                                        hint: const Text('Pilih Kandang'),
                                      );
                                    }),
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 40,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        onPressed: () {
                                          showAppToast(
                                            context: context,
                                            type: ToastificationType.success,
                                            title: 'Berhasil Dipilih!',
                                            description:
                                                'Kandang ${controller.selectedStableId.value} Dipilih.',
                                          );
                                        },
                                        child: const Text(
                                          'Simpan',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
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
}
