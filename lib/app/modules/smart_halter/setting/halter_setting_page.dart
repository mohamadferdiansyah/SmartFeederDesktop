import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smart_feeder_desktop/app/data/data_team_halter.dart';
import 'package:smart_feeder_desktop/app/models/halter/test_team_model.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/dashboard/halter_dashboard_controller.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/setting/halter_setting_controller.dart';
import 'package:smart_feeder_desktop/app/services/halter_serial_service.dart';
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

  String? _selectedLoraPort;
  bool _loraConnected = false;

  String? _selectedJenisPengiriman;

  @override
  void initState() {
    super.initState();
    _selectedLoraPort = settingController.setting.value.loraPort.isEmpty
        ? null
        : settingController.setting.value.loraPort;
    _loraConnected = settingController.setting.value.loraPort.isNotEmpty;
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
                            child: _buildOtherTab(context),
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
                                      onPressed: () {},
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
                                        toastification.show(
                                          context: context,
                                          title: Text(
                                            'Koneksi Cloud Berhasil',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          type: ToastificationType.success,
                                          description: Text(
                                            'Cloud URL: ${_cloudUrlController.text}',
                                          ),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.black26,
                                              blurRadius: 8,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                          alignment: Alignment.topCenter,
                                          autoCloseDuration: const Duration(
                                            seconds: 2,
                                          ),
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
                          height: MediaQuery.of(context).size.height * 0.24,
                          borderRadius: 16,
                          scrollable: false,
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text('Port'),
                              const SizedBox(height: 4),
                              DropdownButtonFormField<String>(
                                value:
                                    _selectedLoraPort != null &&
                                        settingController.availablePorts
                                            .toSet()
                                            .contains(_selectedLoraPort)
                                    ? _selectedLoraPort
                                    : null,
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
                                onChanged: (val) {
                                  setState(() {
                                    _selectedLoraPort = val;
                                    _loraConnected = false;
                                    settingController.updateLora(
                                      port: _selectedLoraPort!,
                                    );
                                  });
                                },
                                hint: const Text('Pilih Port'),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  // Tombol Simpan Port (optional, bisa diisi logic simpan port ke controller)
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
                                      onPressed: _selectedLoraPort == null
                                          ? null
                                          : () {
                                              // Logic simpan port jika perlu
                                            },
                                      child: const Text('Simpan Port'),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  // Tombol Connect/Disconnect
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            _selectedLoraPort == null
                                            ? Colors.grey.shade400
                                            : _loraConnected
                                            ? Colors.red
                                            : Colors.green,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      onPressed: _loraConnected
                                          ? () {
                                              setState(() {
                                                _loraConnected = false;
                                                settingController
                                                    .disconnectSerial();
                                                toastification.show(
                                                  context: context,
                                                  title: const Text(
                                                    'Koneksi Lora Terputus',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  type:
                                                      ToastificationType.error,
                                                  description: const Text(
                                                    'Lora telah terputus.',
                                                  ),
                                                  boxShadow: const [
                                                    BoxShadow(
                                                      color: Colors.black26,
                                                      blurRadius: 8,
                                                      offset: Offset(0, 2),
                                                    ),
                                                  ],
                                                  alignment:
                                                      Alignment.topCenter,
                                                  autoCloseDuration:
                                                      const Duration(
                                                        seconds: 2,
                                                      ),
                                                );
                                              });
                                            }
                                          : () {
                                              setState(() {
                                                _loraConnected =
                                                    !_loraConnected;
                                                settingController.updateLora(
                                                  port: _selectedLoraPort!,
                                                );
                                                if (_loraConnected) {
                                                  toastification.show(
                                                    context: context,
                                                    title: const Text(
                                                      'Koneksi Lora Berhasil',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    type: ToastificationType
                                                        .success,
                                                    description: Text(
                                                      'Port: $_selectedLoraPort',
                                                    ),
                                                    boxShadow: const [
                                                      BoxShadow(
                                                        color: Colors.black26,
                                                        blurRadius: 8,
                                                        offset: Offset(0, 2),
                                                      ),
                                                    ],
                                                    alignment:
                                                        Alignment.topCenter,
                                                    autoCloseDuration:
                                                        const Duration(
                                                          seconds: 2,
                                                        ),
                                                  );
                                                }
                                              });
                                            },
                                      child: Text(
                                        _loraConnected
                                            ? 'Putuskan'
                                            : 'Hubungkan',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Status Bar
                              LinearProgressIndicator(
                                value: 1,
                                minHeight: 8,
                                color: _loraConnected
                                    ? Colors.green
                                    : Colors.red,
                                backgroundColor: Colors.grey[300],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _loraConnected
                                    ? 'Terhubung'
                                    : 'Tidak Terhubung',
                                style: TextStyle(
                                  color: _loraConnected
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ],
                          ),
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
                                    toastification.show(
                                      context: context,
                                      title: const Text(
                                        'Pengaturan Jenis Pengiriman Berhasil',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      type: ToastificationType.success,
                                      description: Text(
                                        'Jenis Pengiriman: $_selectedJenisPengiriman',
                                      ),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 8,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                      alignment: Alignment.topCenter,
                                      autoCloseDuration: const Duration(
                                        seconds: 2,
                                      ),
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
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
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
                                    toastification.show(
                                      context: context,
                                      title: Text(
                                        'Pengaturan Kandang Berhasil',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      type: ToastificationType.success,
                                      description: Text(
                                        'Kandang: ${controller.selectedStableId.value}',
                                      ),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 8,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                      alignment: Alignment.topCenter,
                                      autoCloseDuration: const Duration(
                                        seconds: 2,
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Simpan',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              LinearProgressIndicator(
                                value: 1, // contoh dummy
                                minHeight: 8,
                                color: Colors.green,
                                backgroundColor: Colors.grey[300],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Terhubung',
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.right,
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
    );
  }

  Widget _buildOtherTab(BuildContext context) {
    return Center(
      child: Column(
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
                    label: 'Tim Pengujian',
                    hint: 'Masukan Tim Pengujian',
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: CustomInput(
                          label: 'Lokasi Pengujian',
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
                    'Anggota Pengujian',
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
                      final namaTim = _namaTimController.text;
                      final lokasi = _lokasiController.text;
                      final tanggal = _tanggal;
                      final anggota = _anggotaControllers
                          .map((c) => c.text)
                          .where((t) => t.isNotEmpty)
                          .toList();

                      final team = TestTeamModel(
                        teamName: namaTim,
                        location: lokasi,
                        date: tanggal,
                        members: anggota,
                      );
                      DataTeamHalter.saveTeam(team);

                      toastification.show(
                        context: context,
                        title: const Text('Data Tim Penguji Tersimpan'),
                        type: ToastificationType.success,
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
            ),
          ),
        ],
      ),
    );
  }

  Widget buildModeRealSwitchSimple(BuildContext context) {
    final HalterSerialService serialService = Get.find<HalterSerialService>();
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
                      value: !serialService.isTestingMode,
                      activeColor: Colors.green,
                      inactiveThumbColor: Colors.red,
                      onChanged: (val) {
                        serialService.setTestingMode(!val);
                        setStateSwitch(() {});
                        toastification.show(
                          context: context,
                          title: Text(
                            val ? 'Mode Real Aktif' : 'Mode Testing Aktif',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          type: val
                              ? ToastificationType.success
                              : ToastificationType.info,
                          alignment: Alignment.topCenter,
                          autoCloseDuration: const Duration(seconds: 2),
                        );
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
