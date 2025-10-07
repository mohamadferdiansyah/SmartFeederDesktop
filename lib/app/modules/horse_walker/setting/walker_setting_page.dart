import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/modules/horse_walker/setting/walker_setting_controller.dart';
import 'package:smart_feeder_desktop/app/utils/toast_utils.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_card.dart';
import 'package:smart_feeder_desktop/app/constants/app_colors.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_input.dart';
import 'package:toastification/toastification.dart';

class WalkerSettingPage extends StatefulWidget {
  const WalkerSettingPage({super.key});

  @override
  State<WalkerSettingPage> createState() => WalkerSettingPageState();
}

class WalkerSettingPageState extends State<WalkerSettingPage> {
  final WalkerSettingController settingController = Get.find();
  final TextEditingController _mqttHostController = TextEditingController();
  final TextEditingController _mqttPortController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _mqttHostController.text = settingController.mqttHost.value;
    _mqttPortController.text = settingController.mqttPort.value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: CustomCard(
        title: 'Pengaturan Aplikasi Horse Walker',
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
                      title: "Pengaturan Koneksi Horse Walker",
                      content: Column(
                        children: [
                          Wrap(
                            spacing: 18,
                            runSpacing: 18,
                            children: [
                              CustomCard(
                                title: 'Koneksi MQTT Walker',
                                withExpanded: false,
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
                                              hint: 'Masukan Host MQTT Walker',
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
                                              hint: 'Masukan Port MQTT Walker',
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
                                                ? 'Walker Terhubung'
                                                : 'Walker Tidak Terhubung',
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
                                                      title: 'Walker MQTT Terputus!',
                                                      description:
                                                          'Koneksi Walker MQTT telah diputuskan.',
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
                                                          ? 'Walker Berhasil Dihubungkan!'
                                                          : 'Walker Gagal Menghubungkan!',
                                                      description: success
                                                          ? 'Walker MQTT Host dan Port Disimpan & Dihubungkan.'
                                                          : 'Tidak dapat terhubung ke Walker MQTT Broker.',
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
                                                      ? 'Putuskan Walker'
                                                      : 'Hubungkan Walker',
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