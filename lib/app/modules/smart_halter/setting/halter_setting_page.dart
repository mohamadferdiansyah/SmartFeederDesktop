import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smart_feeder_desktop/app/data/storage/halter/data_team_halter.dart';
import 'package:smart_feeder_desktop/app/models/halter/test_team_model.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/dashboard/halter_dashboard_controller.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/setting/halter_setting_controller.dart';
import 'package:smart_feeder_desktop/app/services/halter_serial_service.dart';
import 'package:smart_feeder_desktop/app/utils/toast_utils.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_button.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_card.dart';
import 'package:smart_feeder_desktop/app/constants/app_colors.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_input.dart';
import 'package:toastification/toastification.dart';

class HalterSettingPage extends StatefulWidget {
  const HalterSettingPage({super.key});

  @override
  State<HalterSettingPage> createState() => HalterSettingPageState();
}

class HalterSettingPageState extends State<HalterSettingPage> {
  final HalterDashboardController controller = Get.find();
  final HalterSettingController settingController = Get.find();
  final HalterSerialService serialService = Get.find<HalterSerialService>();

  final team = DataTeamHalter.getTeam();

  final TextEditingController _namaTimController = TextEditingController();
  final TextEditingController _lokasiController = TextEditingController();
  final List<TextEditingController> _anggotaControllers = [
    TextEditingController(),
  ];
  final DateTime _tanggal = DateTime.now();
  final String tanggalStr = DateFormat(
    "dd MMMM yyyy",
    "id_ID",
  ).format(DateTime.now());

  final TextEditingController _cloudUrlController = TextEditingController(
    text: 'https://smarthalter.ipb.ac.id',
  );

  final TextEditingController _headerController = TextEditingController();
  final TextEditingController _nodeRoomHeaderController =
      TextEditingController();

  // String? settingController.selectedLoraPort.value;
  // bool settingController.loraConnected.value = false;
  String _selectedHeaderType = 'halter'; // 'halter' atau 'kandang'
  String? _selectedJenisPengiriman;
  bool _modeReal = true; // true = mode real aktif, false = testing

  @override
  void initState() {
    super.initState();
    settingController.selectedLoraPort.value =
        settingController.setting.value.loraPort.isEmpty
        ? null
        : settingController.setting.value.loraPort;
    settingController.loraConnected.value =
        settingController.setting.value.loraPort.isNotEmpty;
    _selectedJenisPengiriman = settingController.setting.value.type.isEmpty
        ? null
        : settingController.setting.value.type;
    if (team != null) {
      _namaTimController.text = team!.teamName!;
      _lokasiController.text = team!.location!;
      // Tanggal otomatis dari storage
      // Anggota
      _anggotaControllers.clear();
      if (team!.members!.isNotEmpty) {
        for (final m in team!.members!) {
          _anggotaControllers.add(TextEditingController(text: m));
        }
      } else {
        _anggotaControllers.add(TextEditingController());
      }
    }
    _selectedHeaderType = 'halter';
    _headerController.text = settingController.deviceHeader.value;
    _nodeRoomHeaderController.text = settingController.nodeRoomHeader.value;
    _modeReal = !serialService.isTestingMode;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: CustomCard(
            title: 'Pengaturan Aplikasi Halter',
            withExpanded: false,
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
                        text: "Pengaturan",
                        icon: Icon(Icons.settings_rounded),
                      ),
                      Tab(
                        text: "Form Pengujian",
                        icon: Icon(Icons.assignment_rounded),
                      ),
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
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: _buildSettingTab(context),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: _buildTeamTestTab(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTab(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Wrap(
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
                            withExpanded: false,
                            title: 'Koneksi Cloud',
                            headerColor: AppColors.primary,
                            headerHeight: 50,
                            titleFontSize: 18,
                            width: MediaQuery.of(context).size.width * 0.24,
                            height: MediaQuery.of(context).size.height * 0.24,
                            borderRadius: 16,
                            scrollable: false,
                            content: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Text('Cloud URL'),
                                const SizedBox(height: 4),
                                TextField(
                                  controller: _cloudUrlController,
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
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
                                            title: 'Berhasil Simpan!',
                                            description:
                                                'Koneksi ${_cloudUrlController.text} Disimpan.',
                                          );
                                        },
                                        child: const Text('Simpan'),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blueGrey,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        onPressed: () {
                                          settingController.updateCloud(
                                            url: _cloudUrlController.text,
                                          );
                                          showAppToast(
                                            context: context,
                                            type: ToastificationType.success,
                                            title: 'Berhasil Cek Koneski!',
                                            description:
                                                'Koneksi ${_cloudUrlController.text} Aktif.',
                                          );
                                        },
                                        child: const Text('Cek Koneksi'),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Obx(
                                  () => LinearProgressIndicator(
                                    value:
                                        settingController
                                            .setting
                                            .value
                                            .cloudUrl
                                            .isNotEmpty
                                        ? 1.0
                                        : 0.2,
                                    minHeight: 8,
                                    color:
                                        settingController
                                            .setting
                                            .value
                                            .cloudUrl
                                            .isNotEmpty
                                        ? Colors.green
                                        : Colors.orange,
                                    backgroundColor: Colors.grey[300],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  settingController
                                          .setting
                                          .value
                                          .cloudUrl
                                          .isNotEmpty
                                      ? 'Terhubung'
                                      : 'Tidak Terhubung',
                                  style: TextStyle(
                                    color:
                                        settingController
                                            .setting
                                            .value
                                            .cloudUrl
                                            .isNotEmpty
                                        ? Colors.green
                                        : Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ],
                            ),
                          ),
                          CustomCard(
                            title: 'Koneksi Lora',
                            headerColor: AppColors.primary,
                            withExpanded: false,
                            headerHeight: 50,
                            titleFontSize: 18,
                            width: MediaQuery.of(context).size.width * 0.24,
                            height:
                                MediaQuery.of(context).size.height *
                                0.24, // tambah tinggi sedikit
                            borderRadius: 16,
                            scrollable: false,
                            content: Obx(() {
                              final loraConnected =
                                  settingController.loraConnected.value;
                              final selectedPort =
                                  settingController.selectedLoraPort.value;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Text('Port'),
                                  const SizedBox(height: 4),
                                  DropdownButtonFormField<String>(
                                    value: selectedPort,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      isDense: true,
                                    ),
                                    items: settingController.availablePorts
                                        .toSet()
                                        .map(
                                          (port) => DropdownMenuItem(
                                            value: port,
                                            child: Text(port),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: loraConnected
                                        ? null // Disable dropdown jika sedang terhubung
                                        : (val) {
                                            settingController
                                                    .selectedLoraPort
                                                    .value =
                                                val;
                                            settingController
                                                    .loraConnected
                                                    .value =
                                                false;
                                          },
                                    hint: const Text('Pilih Port'),
                                    disabledHint: Text(
                                      selectedPort ?? 'Pilih Port',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                settingController
                                                        .selectedLoraPort
                                                        .value ==
                                                    null
                                                ? Colors.grey.shade400
                                                : settingController
                                                      .loraConnected
                                                      .value
                                                ? Colors.red
                                                : Colors.green,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          onPressed:
                                              settingController
                                                      .selectedLoraPort
                                                      .value ==
                                                  null
                                              ? () {
                                                  showAppToast(
                                                    context: context,
                                                    type: ToastificationType
                                                        .error,
                                                    title:
                                                        'Pilih Port Terlebih Dahulu!',
                                                    description:
                                                        'Silakan pilih port sebelum menghubungkan Lora.',
                                                  );
                                                }
                                              : loraConnected
                                              ? () {
                                                  setState(() {
                                                    settingController
                                                            .loraConnected
                                                            .value =
                                                        false;
                                                    settingController
                                                            .selectedLoraPort
                                                            .value =
                                                        null;
                                                    settingController
                                                        .disconnectSerial();
                                                    showAppToast(
                                                      context: context,
                                                      type: ToastificationType
                                                          .error,
                                                      title:
                                                          'Koneksi Lora Terputus!',
                                                      description:
                                                          'Lora Telah Terputus.',
                                                    );
                                                  });
                                                }
                                              : () {
                                                  setState(() {
                                                    settingController
                                                            .loraConnected
                                                            .value =
                                                        true;
                                                    settingController.updateLora(
                                                      port: settingController
                                                          .selectedLoraPort
                                                          .value!,
                                                      context: context,
                                                    );
                                                    if (loraConnected) {
                                                      showAppToast(
                                                        context: context,
                                                        type: ToastificationType
                                                            .success,
                                                        title:
                                                            'Koneksi Lora Berhasil!',
                                                        description:
                                                            'Port: ${settingController.selectedLoraPort.value}',
                                                      );
                                                    }
                                                  });
                                                },
                                          child: Text(
                                            loraConnected
                                                ? 'Putuskan'
                                                : 'Hubungkan',
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      // Tombol cek port
                                      SizedBox(
                                        height: 33,
                                        child: ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.primary,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 10,
                                            ),
                                          ),
                                          icon: Icon(Icons.refresh, size: 18),
                                          label: Text(
                                            'Cek Port',
                                            style: TextStyle(fontSize: 13),
                                          ),
                                          onPressed: () async {
                                            await settingController
                                                .refreshAvailablePorts();
                                            setState(() {});
                                            showAppToast(
                                              context: context,
                                              type: ToastificationType.success,
                                              title: 'Port Diperbaharui!',
                                              description:
                                                  'Daftar Port Sudah Dimuat Ulang.',
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  // Status Bar
                                  LinearProgressIndicator(
                                    value: 1,
                                    minHeight: 8,
                                    color: settingController.loraConnected.value
                                        ? Colors.green
                                        : Colors.red,
                                    backgroundColor: Colors.grey[300],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    settingController.loraConnected.value
                                        ? 'Terhubung'
                                        : 'Tidak Terhubung',
                                    style: TextStyle(
                                      color:
                                          settingController.loraConnected.value
                                          ? Colors.green
                                          : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ],
                              );
                            }),
                          ),
                          CustomCard(
                            title: 'Pengiriman Data Halter',
                            headerColor: AppColors.primary,
                            withExpanded: false,

                            headerHeight: 50,
                            titleFontSize: 18,
                            width: MediaQuery.of(context).size.width * 0.24,
                            height: MediaQuery.of(context).size.height * 0.24,
                            borderRadius: 16,
                            scrollable: false,
                            content: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Text('Jenis Pengiriman'),
                                const SizedBox(height: 4),
                                DropdownButtonFormField<String>(
                                  value: _selectedJenisPengiriman,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                  items: ['LoRa', 'Http', 'LoRa + Http']
                                      .map(
                                        (jenis) => DropdownMenuItem(
                                          value: jenis,
                                          child: Text(jenis),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (val) {
                                    setState(() {
                                      _selectedJenisPengiriman = val;
                                    });
                                  },
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  height: 40,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () {
                                      settingController.updateJenisPengiriman(
                                        _selectedJenisPengiriman!,
                                      );
                                      showAppToast(
                                        context: context,
                                        type: ToastificationType.success,
                                        title: 'Berhasil Diubah!',
                                        description:
                                            'Jenis Pengiriman $_selectedJenisPengiriman Disimpan.',
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
                            height: MediaQuery.of(context).size.height * 0.24,
                            borderRadius: 16,
                            scrollable: false,
                            content: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                            controller.selectedStableId.value,
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
                                        borderRadius: BorderRadius.circular(8),
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
                CustomCard(
                  titleFontSize: 20,
                  headerHeight: 50,
                  trailing: Icon(
                    Icons.house_siding_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                  withExpanded: false,
                  height: MediaQuery.of(context).size.height * 0.34,
                  title: "Pengaturan Lainnya",
                  content: Column(
                    children: [
                      Wrap(
                        spacing: 18,
                        runSpacing: 18,
                        children: [
                          CustomCard(
                            title: 'Header Device ID',
                            headerColor: AppColors.primary,
                            withExpanded: false,
                            headerHeight: 50,
                            titleFontSize: 18,
                            width: MediaQuery.of(context).size.width * 0.24,
                            height: MediaQuery.of(context).size.height * 0.26,
                            borderRadius: 16,
                            scrollable: false,
                            content: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                DropdownButtonFormField<String>(
                                  value: _selectedHeaderType,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'halter',
                                      child: Text('IoT Node Halter'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'kandang',
                                      child: Text('IoT Node Kandang'),
                                    ),
                                  ],
                                  onChanged: (val) {
                                    setState(() {
                                      _selectedHeaderType = val ?? 'halter';
                                      if (_selectedHeaderType == 'halter') {
                                        _headerController.text =
                                            settingController
                                                .deviceHeader
                                                .value;
                                      } else {
                                        _nodeRoomHeaderController.text =
                                            settingController
                                                .nodeRoomHeader
                                                .value;
                                      }
                                    });
                                  },
                                ),
                                const SizedBox(height: 12),
                                if (_selectedHeaderType == 'halter')
                                  CustomInput(
                                    label: 'Header Device ID Halter',
                                    controller: _headerController,
                                    hint: 'Masukan Header Device ID Halter',
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'[a-zA-Z\s]'),
                                      ),
                                    ],
                                  ),
                                if (_selectedHeaderType == 'kandang')
                                  CustomInput(
                                    label: 'Header Device ID Node Kandang',
                                    controller: _nodeRoomHeaderController,
                                    hint:
                                        'Masukan Header Device ID Node Kandang',
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'[a-zA-Z\s]'),
                                      ),
                                    ],
                                  ),
                                const SizedBox(height: 12),
                                CustomButton(
                                  text: 'Simpan Header',
                                  backgroundColor: AppColors.primary,
                                  onPressed: () {
                                    if (_selectedHeaderType == 'halter') {
                                      if (_headerController.text
                                          .trim()
                                          .isEmpty) {
                                        showAppToast(
                                          context: context,
                                          type: ToastificationType.error,
                                          title: 'Data Tidak Lengkap!',
                                          description:
                                              'Lengkapi Data Header ID.',
                                        );
                                        return;
                                      }
                                      settingController.setDeviceHeader(
                                        _headerController.text.trim(),
                                      );
                                      showAppToast(
                                        context: context,
                                        type: ToastificationType.success,
                                        title: 'Berhasil Diubah!',
                                        description: 'Header Halter Diubah.',
                                      );
                                    } else {
                                      if (_nodeRoomHeaderController.text
                                          .trim()
                                          .isEmpty) {
                                        showAppToast(
                                          context: context,
                                          type: ToastificationType.error,
                                          title: 'Data Tidak Lengkap!',
                                          description:
                                              'Lengkapi Data Header ID.',
                                        );
                                        return;
                                      }
                                      settingController.setNodeRoomHeader(
                                        _nodeRoomHeaderController.text.trim(),
                                      );
                                      showAppToast(
                                        context: context,
                                        type: ToastificationType.success,
                                        title: 'Berhasil Diubah!',
                                        description:
                                            'Header Node Kandang Diubah.',
                                      );
                                    }
                                  },
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
          ],
        ),
      ),
    );
  }

  Widget _buildTeamTestTab(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          CustomCard(
            title: 'Form Penguji',
            headerColor: AppColors.primary,
            withExpanded: false,
            headerHeight: 50,
            titleFontSize: 18,
            width: MediaQuery.of(context).size.width * 0.51,
            height: MediaQuery.of(context).size.height * 0.58,
            borderRadius: 16,
            scrollable: false,
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  CustomInput(
                    controller: _namaTimController,
                    label: 'Tim Pengujian *',
                    hint: 'Masukan Tim Pengujian',
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: CustomInput(
                          label: 'Lokasi Pengujian *',
                          hint: 'Masukan Lokasi Pengujian',
                          controller: _lokasiController,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tanggal Pengujian',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    tanggalStr,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      buildModeRealSwitchSimple(context),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Anggota Pengujian *',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    children: List.generate(_anggotaControllers.length, (i) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: CustomInput(
                                controller: _anggotaControllers[i],
                                label: '',
                                fontSize: 15,
                                hint: 'Nama Anggota ${i + 1}',
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (i == _anggotaControllers.length - 1)
                              IconButton(
                                icon: const Icon(
                                  Icons.add_circle,
                                  color: Colors.green,
                                ),
                                tooltip: 'Tambah Anggota',
                                onPressed: () {
                                  setState(() {
                                    _anggotaControllers.add(
                                      TextEditingController(),
                                    );
                                  });
                                },
                              ),
                            if (_anggotaControllers.length > 1)
                              IconButton(
                                icon: const Icon(
                                  Icons.remove_circle,
                                  color: Colors.red,
                                ),
                                tooltip: 'Hapus Anggota',
                                onPressed: () {
                                  setState(() {
                                    _anggotaControllers.removeAt(i);
                                  });
                                },
                              ),
                          ],
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 18),
                  CustomButton(
                    onPressed: () {
                      final namaTim = _namaTimController.text.trim();
                      final lokasi = _lokasiController.text.trim();
                      final tanggal = _tanggal;
                      final anggota = _anggotaControllers
                          .map((c) => c.text.trim())
                          .where((t) => t.isNotEmpty)
                          .toList();

                      // Validasi
                      if (namaTim.isEmpty &&
                          lokasi.isEmpty &&
                          anggota.isEmpty) {
                        showAppToast(
                          context: context,
                          type: ToastificationType.error,
                          title: 'Data Tidak Lengkap!',
                          description: 'Lengkapi Data Tim Penguji.',
                        );
                        return;
                      }
                      if (namaTim.isEmpty) {
                        showAppToast(
                          context: context,
                          type: ToastificationType.error,
                          title: 'Data Tidak Lengkap!',
                          description: 'Nama Tim Penguji Wajib Diisi.',
                        );
                        return;
                      }
                      if (lokasi.isEmpty) {
                        showAppToast(
                          context: context,
                          type: ToastificationType.error,
                          title: 'Data Tidak Lengkap!',
                          description: 'Lokasi Pengujian Wajib Diisi.',
                        );
                        return;
                      }
                      if (anggota.isEmpty) {
                        showAppToast(
                          context: context,
                          type: ToastificationType.error,
                          title: 'Data Tidak Lengkap!',
                          description: 'Minimal 1 Anggota Penguji Wajib Diisi.',
                        );
                        return;
                      }

                      final team = TestTeamModel(
                        teamName: namaTim,
                        location: lokasi,
                        date: tanggal,
                        members: anggota,
                      );
                      DataTeamHalter.saveTeam(team);

                      serialService.setTestingMode(!_modeReal);

                      showAppToast(
                        context: context,
                        type: ToastificationType.success,
                        title: 'Berhasil Disimpan!',
                        description: 'Data Tim Penguji Disimpan.',
                      );
                    },
                    text: 'Simpan',
                    iconTrailing: Icons.save,
                    backgroundColor: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          CustomCard(
            title: 'Keterangan',
            headerHeight: 50,
            titleFontSize: 18,
            withExpanded: false,
            width: MediaQuery.of(context).size.width * 0.23,
            height: MediaQuery.of(context).size.height * 0.58,
            content: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• Data tim penguji digunakan untuk identifikasi hasil pengujian alat dan pelacakan hasil monitoring.',
                    style: TextStyle(fontSize: 15, color: Colors.black87),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Pastikan semua form terisi sebelum menyimpan agar data pengujian valid.',
                    style: TextStyle(fontSize: 15, color: Colors.black87),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Tanggal pengujian otomatis mengikuti tanggal hari ini.',
                    style: TextStyle(fontSize: 15, color: Colors.black87),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Anggota tim dapat ditambah atau dikurangi sesuai kebutuhan.',
                    style: TextStyle(fontSize: 15, color: Colors.black87),
                  ),
                  SizedBox(height: 16),
                  Divider(),
                  SizedBox(height: 8),
                  Text(
                    'Mode Real',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.green,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    '• Jika Mode Real AKTIF: Halter digunakan di kuda asli, validasi suhu dan sensor akan berjalan sesuai standar kesehatan kuda.',
                    style: TextStyle(fontSize: 15, color: Colors.black87),
                  ),
                  SizedBox(height: 6),
                  Text(
                    '• Jika Mode Real NON-AKTIF: Halter hanya untuk test sensor, validasi suhu dan sensor tidak aktif (data sensor tetap masuk meski tidak normal).',
                    style: TextStyle(fontSize: 15, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildModeRealSwitchSimple(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mode Real',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                const Icon(
                  Icons.science_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                StatefulBuilder(
                  builder: (context, setStateSwitch) {
                    return Switch(
                      value: _modeReal,
                      activeColor: Colors.green,
                      inactiveThumbColor: Colors.red,
                      onChanged: (val) {
                        setState(() {
                          _modeReal = val;
                        });
                        setStateSwitch(() {});
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
