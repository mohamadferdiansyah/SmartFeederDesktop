// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
// Ganti dengan import model dan widget sesuai project-mu
import 'package:smart_feeder_desktop/app/constants/app_colors.dart';
import 'package:smart_feeder_desktop/app/data/data_controller.dart';
import 'package:smart_feeder_desktop/app/data/storage/halter/data_team_halter.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_device_detail_model.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_device_model.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/data_logs/log_device/halter_device_power_log_controller.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/monitoring_data/device/halter_device_controller.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/setting/halter_setting_controller.dart';
import 'package:smart_feeder_desktop/app/utils/dialog_utils.dart';
import 'package:smart_feeder_desktop/app/utils/toast_utils.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_button.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_input.dart';
import 'package:toastification/toastification.dart';

class HalterDevicePage extends StatefulWidget {
  const HalterDevicePage({super.key});

  @override
  State<HalterDevicePage> createState() => _HalterDevicePageState();
}

class _HalterDevicePageState extends State<HalterDevicePage> {
  final TextEditingController _searchController = TextEditingController();
  final HalterDeviceController _controller = Get.find<HalterDeviceController>();
  final header = Get.find<HalterSettingController>().deviceHeader.value;
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int? _sortColumnIndex;
  bool _sortAscending = true;
  String _searchText = "";

  @override
  void initState() {
    super.initState();
    _controller.refreshDevices();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.trim().toLowerCase();
      });
    });
  }

  List<HalterDeviceModel> _filteredDevices(List<HalterDeviceModel> devices) {
    if (_searchText.isEmpty) return devices;
    return devices.where((d) {
      return d.deviceId.toLowerCase().contains(_searchText) ||
          (d.horseId ?? '').toLowerCase().contains(_searchText) ||
          d.status.toLowerCase().contains(_searchText) ||
          d.version.toLowerCase().contains(_searchText) ||
          d.batteryPercent.toString().contains(_searchText);
    }).toList();
  }

  void _showDeviceFormModal({
    HalterDeviceModel? device,
    required bool isEdit,
    required Function(HalterDeviceModel) onSubmit,
    BuildContext? parentContext,
  }) async {
    final idCtrl = TextEditingController(text: device?.deviceId ?? '');
    final versionCtrl = TextEditingController(text: device?.version ?? '1.5');

    showCustomDialog(
      context: parentContext ?? context,
      title: isEdit ? 'Edit Device' : 'Tambah Device',
      icon: isEdit ? Icons.edit : Icons.add_circle_rounded,
      iconColor: isEdit ? Colors.amber : Colors.green,
      showConfirmButton: true,
      confirmText: isEdit ? "Simpan" : "Tambah",
      cancelText: "Batal",
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isEdit) ...[
            Row(
              children: [
                const Text(
                  "Device ID: ",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                Text(
                  device!.deviceId,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  header,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CustomInput(
                  label: "Device ID *",
                  controller: idCtrl,
                  hint: "Masukkan ID (misal: 001)",
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: versionCtrl.text,
            decoration: const InputDecoration(labelText: "Versi Device"),
            items: const [
              DropdownMenuItem(value: "1.5", child: Text("Versi 1.5")),
              DropdownMenuItem(value: "2.0", child: Text("Versi 2.0")),
            ],
            onChanged: (v) => versionCtrl.text = v ?? "1.5",
          ),
        ],
      ),
      onConfirm: () {
        if (idCtrl.text.trim().isEmpty) {
          showAppToast(
            context: context,
            type: ToastificationType.error,
            title: 'Data Tidak Lengkap!',
            description: 'Lengkapi Data Halter.',
          );
          return;
        }
        final newDevice = HalterDeviceModel(
          deviceId: '$header${idCtrl.text.trim()}',
          status: device?.status ?? 'off',
          batteryPercent: device?.batteryPercent ?? 0,
          horseId: device?.horseId,
          version: versionCtrl.text,
        );
        onSubmit(newDevice);
        showAppToast(
          context: context,
          type: ToastificationType.success,
          title: 'Berhasil Ditambahkan!',
          description: 'Data Halter Ditambahkan.',
        );
      },
    );
  }

  void _showDeviceFormModalEdit(
    HalterDeviceModel device,
    Function(HalterDeviceModel) onSubmit, {
    BuildContext? parentContext,
  }) async {
    final header = Get.find<HalterSettingController>().deviceHeader.value;
    final idWithoutHeader = device.deviceId.startsWith(header)
        ? device.deviceId.substring(header.length)
        : device.deviceId;
    final idCtrl = TextEditingController(text: idWithoutHeader);
    final versionCtrl = TextEditingController(text: device.version);

    showCustomDialog(
      context: parentContext ?? context,
      title: 'Edit Device',
      icon: Icons.edit,
      iconColor: Colors.amber,
      showConfirmButton: true,
      confirmText: "Simpan",
      cancelText: "Batal",
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  header,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CustomInput(
                  label: "Device ID *",
                  controller: idCtrl,
                  hint: "Masukkan ID (misal: 001)",
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: versionCtrl.text,
            decoration: const InputDecoration(labelText: "Versi Device"),
            items: const [
              DropdownMenuItem(value: "1.5", child: Text("Versi 1.5")),
              DropdownMenuItem(value: "2.0", child: Text("Versi 2.0")),
            ],
            onChanged: (v) => versionCtrl.text = v ?? "1.5",
          ),
        ],
      ),
      onConfirm: () {
        if (idCtrl.text.trim().isEmpty) {
          showAppToast(
            context: context,
            type: ToastificationType.error,
            title: 'Data Tidak Lengkap!',
            description: 'Lengkapi Data Halter.',
          );
          return;
        }
        final editedDevice = HalterDeviceModel(
          deviceId: '$header${idCtrl.text.trim()}',
          status: device.status,
          batteryPercent: device.batteryPercent,
          horseId: device.horseId,
          version: versionCtrl.text,
        );
        onSubmit(editedDevice);
        showAppToast(
          context: context,
          type: ToastificationType.success,
          title: 'Berhasil Diubah!',
          description: 'Data Halter "${editedDevice.deviceId}" Diubah.',
        );
      },
    );
  }

  // Modal, detail, dan lain-lain (SAMA seperti contoh sebelumnya)
  void _showDetailModal(HalterDeviceModel device) {
    showCustomDialog(
      context: context,
      title: "Detail Device",
      icon: Icons.info_outline,
      iconColor: Colors.blueGrey,
      showConfirmButton: false,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _detailRow("Device ID", device.deviceId),
          const SizedBox(height: 8),
          _detailRow("Status", device.status),
          const SizedBox(height: 8),
          _detailRow("Battery", "${device.batteryPercent}%"),
          const SizedBox(height: 8),
          _detailRow("Kuda", _controller.getHorseNameById(device.horseId)),
        ],
      ),
    );
  }

  void _showPilihKudaModal(HalterDeviceModel device) {
    String? selectedHorseId = device.horseId;
    showCustomDialog(
      context: context,
      title: "Pilih Kuda",
      icon: Icons.pets_rounded,
      iconColor: AppColors.primary,
      showConfirmButton: true,
      confirmText: "Simpan",
      cancelText: "Batal",
      content: Obx(() {
        final horseList = _controller.horseList;
        final allUsedHorseIds = _controller.halterDeviceList
            .where((d) => d.horseId != null && d.deviceId != device.deviceId)
            .map((d) => d.horseId)
            .toSet();

        // Filter: hanya kuda yang belum dipakai atau yang memang sedang terpasang di device ini
        final availableHorses = horseList
            .where(
              (h) =>
                  h.horseId == selectedHorseId ||
                  !allUsedHorseIds.contains(h.horseId),
            )
            .toList();

        // validasi value biar nggak error Dropdown
        final validIds = availableHorses.map((h) => h.horseId).toList();
        final value =
            (selectedHorseId != null && validIds.contains(selectedHorseId))
            ? selectedHorseId
            : null;

        return DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          decoration: const InputDecoration(labelText: "Kuda"),
          items: [
            const DropdownMenuItem(value: null, child: Text("Tidak Digunakan")),
            ...availableHorses.map(
              (h) => DropdownMenuItem(
                value: h.horseId,
                child: Text("${h.horseId} - ${h.name}"),
              ),
            ),
          ],
          onChanged: (v) => setState(() => selectedHorseId = v),
        );
      }),
      onConfirm: () async {
        if (selectedHorseId == null) {
          showAppToast(
            context: context,
            type: ToastificationType.error,
            title: 'Gagal Dipasang!',
            description: 'Pilih Kuda Untuk Dipasang.',
          );
          return;
        }
        final updated = HalterDeviceModel(
          deviceId: device.deviceId,
          status: device.status,
          batteryPercent: device.batteryPercent,
          horseId: selectedHorseId,
          version: device.version,
        );
        await _controller.updateDevice(updated, device.deviceId);
        showAppToast(
          context: context,
          type: ToastificationType.success,
          title: 'Berhasil Dipasang!',
          description: 'Halter Dipasang Di Kuda.',
        );
      },
    );
  }

  void _showLepasAlatModal(HalterDeviceModel device) {
    showCustomDialog(
      context: context,
      title: "Konfirmasi Lepas Alat",
      icon: Icons.link_off,
      iconColor: Colors.orange,
      message:
          "Lepaskan alat dari kuda \"${_controller.getHorseNameById(device.horseId)}\" untuk device ${device.deviceId}?",
      showConfirmButton: true,
      confirmText: "Lepas",
      cancelText: "Batal",
      onConfirm: () async {
        final updated = HalterDeviceModel(
          deviceId: device.deviceId,
          status: device.status,
          batteryPercent: device.batteryPercent,
          horseId: null,
          version: device.version,
        );
        await _controller.updateDevice(updated, device.deviceId);
        showAppToast(
          context: context,
          type: ToastificationType.success,
          title: 'Berhasil Dilepas!',
          description: 'Halter Dilepas Dari Kuda.',
        );
      },
    );
  }

  void _confirmDelete(HalterDeviceModel device) {
    showCustomDialog(
      context: context,
      title: "Konfirmasi Hapus",
      icon: Icons.delete_forever,
      iconColor: Colors.red,
      message: 'Hapus device "${device.deviceId}"?',
      showConfirmButton: true,
      confirmText: "Hapus",
      cancelText: "Batal",
      onConfirm: () async {
        await _controller.deleteDevice(device.deviceId);
        showAppToast(
          context: context,
          type: ToastificationType.success,
          title: 'Berhasil Dihapus!',
          description: 'Data Halter "${device.deviceId}" Dihapus.',
        );
      },
    );
  }

  Widget _detailRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      children: [
        Text(
          "$label: ",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Flexible(child: Text(value, style: const TextStyle(fontSize: 16))),
      ],
    ),
  );

  // ...existing code...
  void _sort<T extends Comparable>(
    List<HalterDeviceModel> devices,
    T Function(HalterDeviceModel d) getField,
    bool ascending,
  ) {
    devices.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
    });
  }
  // ...existing code...

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        width: double.infinity,
        height: double.infinity,
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              height: 70,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
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
              child: const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    children: [
                      Text(
                        'Daftar IoT Node Halter',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 36.0,
                  vertical: 12.0,
                ),
                child: Column(
                  children: [
                    // Search Box
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: CustomInput(
                        label: "Cari IoT Node Halter",
                        controller: _searchController,
                        icon: Icons.search,
                        hint: 'Masukkan ID, versi, kuda, status, atau baterai',
                        fontSize: 24,
                      ),
                    ),
                    // Table
                    Expanded(
                      child: Obx(() {
                        List<HalterDeviceModel> devices = _filteredDevices(
                          _controller.halterDeviceList.toList(),
                        );

                        // Sort
                        if (_sortColumnIndex != null) {
                          switch (_sortColumnIndex!) {
                            case 0:
                              _sort<String>(
                                devices,
                                (d) => d.deviceId,
                                _sortAscending,
                              );
                              break;
                            case 1:
                              _sort<String>(
                                devices,
                                (d) => d.horseId ?? '',
                                _sortAscending,
                              );
                              break;
                            case 2:
                              _sort<String>(
                                devices,
                                (d) => d.status,
                                _sortAscending,
                              );
                              break;
                            case 3:
                              _sort<int>(
                                devices,
                                (d) => d.batteryPercent,
                                _sortAscending,
                              );
                              break;
                          }
                        }

                        final tableWidth =
                            MediaQuery.of(context).size.width - 72.0;
                        final idW = tableWidth * 0.10;
                        final horseW = tableWidth * 0.10;
                        final statusW = tableWidth * 0.09;
                        final batteryW = tableWidth * 0.09;
                        final actionW = tableWidth * 0.32;
                        final versionW = tableWidth * 0.05;

                        final dataSource = HalterDeviceDataTableSource(
                          context: context,
                          devices: devices,
                          getHorseName: _controller.getHorseNameById,
                          onDetail: _showDetailModal,
                          onPilihKuda: _showPilihKudaModal,
                          onLepasAlat: _showLepasAlatModal,
                          onDelete: _confirmDelete,
                          onEdit: (device) => _showDeviceFormModalEdit(device, (
                            editedDevice,
                          ) async {
                            await _controller.updateDevice(
                              editedDevice,
                              device.deviceId,
                            );
                            _controller.refreshDevices();
                          }),
                        );

                        return SingleChildScrollView(
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  CustomButton(
                                    width:
                                        MediaQuery.of(context).size.width * 0.1,
                                    height: 50,
                                    backgroundColor: Colors.green,
                                    fontSize: 18,
                                    icon: Icons.add_circle_rounded,
                                    text: 'Tambah Data',
                                    onPressed: () {
                                      _showDeviceFormModal(
                                        isEdit: false,
                                        onSubmit: (device) async {
                                          await _controller.addDevice(device);
                                          _controller.refreshDevices();
                                        },
                                      );
                                    },
                                  ),
                                  Spacer(),
                                  Text(
                                    'Export Data :',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(width: 12),
                                  CustomButton(
                                    width:
                                        MediaQuery.of(context).size.width * 0.1,
                                    height: 50,
                                    backgroundColor: Colors.green,
                                    fontSize: 18,
                                    icon: Icons.table_view_rounded,
                                    text: 'Export Excel',
                                    onPressed: () async {
                                      final success = await _controller
                                          .exportDeviceExcel(
                                            devices,
                                            _controller.getHorseNameById,
                                          );
                                      showAppToast(
                                        context: context,
                                        type: success
                                            ? ToastificationType.success
                                            : ToastificationType.error,
                                        title: success
                                            ? 'Berhasil Export!'
                                            : 'Export Dibatalkan!',
                                        description: success
                                            ? 'Data Halter Diexport Ke Excel.'
                                            : 'Export data halter dibatalkan.',
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 12),
                                  CustomButton(
                                    width:
                                        MediaQuery.of(context).size.width * 0.1,
                                    height: 50,
                                    backgroundColor: Colors.redAccent,
                                    fontSize: 18,
                                    icon: Icons.picture_as_pdf,
                                    text: 'Export PDF',
                                    onPressed: () async {
                                      final success = await _controller
                                          .exportDevicePDF(
                                            devices,
                                            _controller.getHorseNameById,
                                          );
                                      showAppToast(
                                        context: context,
                                        type: success
                                            ? ToastificationType.success
                                            : ToastificationType.error,
                                        title: success
                                            ? 'Berhasil Export!'
                                            : 'Export Dibatalkan!',
                                        description: success
                                            ? 'Data Halter Diexport Ke PDF.'
                                            : 'Export data halter dibatalkan.',
                                      );
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Total Data: ${devices.length}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Theme(
                                data: Theme.of(context).copyWith(
                                  cardColor: Colors.white,
                                  dataTableTheme: DataTableThemeData(
                                    headingRowColor: MaterialStateProperty.all(
                                      Colors.grey[200]!,
                                    ),
                                    dataRowColor: MaterialStateProperty.all(
                                      Colors.white,
                                    ),
                                  ),
                                ),
                                child: PaginatedDataTable(
                                  columnSpacing: 0,
                                  horizontalMargin: 0,
                                  sortColumnIndex: _sortColumnIndex,
                                  sortAscending: _sortAscending,
                                  columns: [
                                    DataColumn(
                                      label: SizedBox(
                                        width: idW,
                                        child: const Center(
                                          child: Text(
                                            'ID',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      onSort: (columnIndex, ascending) {
                                        setState(() {
                                          _sortColumnIndex = columnIndex;
                                          _sortAscending = ascending;
                                        });
                                      },
                                    ),
                                    DataColumn(
                                      label: SizedBox(
                                        width: versionW,
                                        child: const Center(
                                          child: Text(
                                            'Versi',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      onSort: (columnIndex, ascending) {
                                        setState(() {
                                          _sortColumnIndex = columnIndex;
                                          _sortAscending = ascending;
                                        });
                                      },
                                    ),
                                    DataColumn(
                                      label: SizedBox(
                                        width: horseW,
                                        child: const Center(
                                          child: Text(
                                            'Kuda',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      onSort: (columnIndex, ascending) {
                                        setState(() {
                                          _sortColumnIndex = columnIndex;
                                          _sortAscending = ascending;
                                        });
                                      },
                                    ),
                                    DataColumn(
                                      label: SizedBox(
                                        width: statusW,
                                        child: const Center(
                                          child: Text(
                                            'Status',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      onSort: (columnIndex, ascending) {
                                        setState(() {
                                          _sortColumnIndex = columnIndex;
                                          _sortAscending = ascending;
                                        });
                                      },
                                    ),
                                    DataColumn(
                                      label: SizedBox(
                                        width: batteryW,
                                        child: const Center(
                                          child: Text(
                                            'Baterai (%)',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      onSort: (columnIndex, ascending) {
                                        setState(() {
                                          _sortColumnIndex = columnIndex;
                                          _sortAscending = ascending;
                                        });
                                      },
                                    ),
                                    DataColumn(
                                      label: SizedBox(
                                        width: actionW,
                                        child: const Center(
                                          child: Text(
                                            'Aksi',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                  source: dataSource,
                                  rowsPerPage: _rowsPerPage,
                                  availableRowsPerPage: const [5, 10, 20],
                                  onRowsPerPageChanged: (value) {
                                    setState(() {
                                      _rowsPerPage = value ?? 5;
                                    });
                                  },
                                  showCheckboxColumn: false,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HalterDeviceDataTableSource extends DataTableSource {
  final BuildContext context;
  final List<HalterDeviceModel> devices;
  final String Function(String?) getHorseName;
  final void Function(HalterDeviceModel) onDetail;
  final void Function(HalterDeviceModel) onPilihKuda;
  final void Function(HalterDeviceModel) onEdit;
  final void Function(HalterDeviceModel) onDelete;
  final void Function(HalterDeviceModel) onLepasAlat;
  final HalterDeviceController _controller = Get.find<HalterDeviceController>();

  HalterDeviceDataTableSource({
    required this.context,
    required this.devices,
    required this.getHorseName,
    required this.onDetail,
    required this.onPilihKuda,
    required this.onEdit,
    required this.onDelete,
    required this.onLepasAlat,
  });

  @override
  DataRow getRow(int index) {
    final device = devices[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Center(child: Text(device.deviceId))),
        DataCell(Center(child: Text(device.version))),
        DataCell(Center(child: Text(getHorseName(device.horseId)))),
        DataCell(
          Center(child: Text(device.status == 'on' ? 'Aktif' : 'Tidak Aktif')),
        ),
        DataCell(
          Center(
            child: Text(
              device.status == 'on'
                  ? '${device.batteryPercent}%'
                  : 'Terakhir: ${device.batteryPercent}%',
            ),
          ),
        ),
        DataCell(
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomButton(
                width: 165,
                height: 38,
                text: 'Riwayat Halter',
                backgroundColor: Colors.blue,
                icon: Icons.history,
                borderRadius: 6,
                fontSize: 14,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return HalterRawDataDialog(
                        deviceId: device.deviceId,
                        allData: _controller.detailHistoryList,
                      );
                    },
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Container(
                  height: 38,
                  width: 2,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
              CustomButton(
                width: 115,
                height: 38,
                text: 'Detail',
                backgroundColor: Colors.blueGrey,
                icon: Icons.info_outline,
                borderRadius: 6,
                fontSize: 14,
                onPressed: () => onDetail(device),
              ),
              const SizedBox(width: 6),
              device.horseId == null
                  ? CustomButton(
                      width: 135,
                      height: 38,
                      backgroundColor: AppColors.primary,
                      text: 'Pilih Kuda',
                      icon: Icons.pets_rounded,
                      borderRadius: 6,
                      fontSize: 14,
                      onPressed: () => onPilihKuda(device),
                    )
                  : CustomButton(
                      width: 135,
                      height: 38,
                      backgroundColor: Colors.orange,
                      text: 'Lepas Alat',
                      icon: Icons.link_off,
                      borderRadius: 6,
                      fontSize: 14,
                      onPressed: () => onLepasAlat(device),
                    ),
              const SizedBox(width: 6),
              Container(
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: IconButton(
                  icon: const Icon(Icons.edit, color: Colors.amber),
                  tooltip: 'Edit',
                  onPressed: () => onEdit(device),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Hapus',
                  onPressed: () => onDelete(device),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  int get rowCount => devices.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}

class HalterRawDataDialog extends StatefulWidget {
  final String deviceId;
  final List<HalterDeviceDetailModel> allData;

  const HalterRawDataDialog({
    super.key,
    required this.deviceId,
    required this.allData,
  });

  @override
  State<HalterRawDataDialog> createState() => _HalterRawDataDialogState();
}

class _HalterRawDataDialogState extends State<HalterRawDataDialog> {
  DateTime? tanggalAwal;
  DateTime? tanggalAkhir;
  final HalterDeviceController _controller = Get.find<HalterDeviceController>();
  final DataController _dataController = Get.find<DataController>();
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int? _sortColumnIndex;
  bool _sortAscending = true;

  List<HalterDeviceDetailModel> _filteredData(
    List<HalterDeviceDetailModel> data,
  ) {
    var filtered = data.where((d) => d.deviceId == widget.deviceId).toList();
    if (tanggalAwal != null) {
      filtered = filtered.where((d) {
        final tAwal = DateTime(
          tanggalAwal!.year,
          tanggalAwal!.month,
          tanggalAwal!.day,
        );
        final tData = DateTime(d.time.year, d.time.month, d.time.day);
        return tData.isAtSameMomentAs(tAwal) || tData.isAfter(tAwal);
      }).toList();
    }
    if (tanggalAkhir != null) {
      filtered = filtered.where((d) {
        final tAkhir = DateTime(
          tanggalAkhir!.year,
          tanggalAkhir!.month,
          tanggalAkhir!.day,
        );
        final tData = DateTime(d.time.year, d.time.month, d.time.day);
        return tData.isAtSameMomentAs(tAkhir) || tData.isBefore(tAkhir);
      }).toList();
    }
    return filtered;
  }

  // @override
  // void initState() {
  //   super.initState();
  //   _dataController.loadAllHalterDeviceDetails();
  // }

  void _sort<T>(
    List<HalterDeviceDetailModel> data,
    Comparable<T> Function(HalterDeviceDetailModel d) getField,
    bool ascending,
  ) {
    data.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending
          ? Comparable.compare(aValue, bValue)
          : Comparable.compare(bValue, aValue);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(32),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.82,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              height: 80,
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
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    children: [
                      Text(
                        'Detail Data Device ${widget.deviceId}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Filter tanggal + Export
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Flexible(
                    child: TextField(
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: "Tanggal Awal",
                        hintText: "Pilih tanggal awal",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.primary.withOpacity(0.5),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                        prefixIcon: const Icon(Icons.calendar_today),
                      ),
                      controller: TextEditingController(
                        text: tanggalAwal != null
                            ? DateFormat('dd-MM-yyyy').format(tanggalAwal!)
                            : "",
                      ),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: tanggalAwal ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() {
                            tanggalAwal = picked;
                            // Validasi dan swap jika perlu
                            if (tanggalAkhir != null &&
                                tanggalAwal!.isAfter(tanggalAkhir!)) {
                              final temp = tanggalAwal;
                              tanggalAwal = tanggalAkhir;
                              tanggalAkhir = temp;
                            }
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: TextField(
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: "Tanggal Akhir",
                        hintText: "Pilih tanggal akhir",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.primary.withOpacity(0.5),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                        prefixIcon: const Icon(Icons.calendar_today),
                      ),
                      controller: TextEditingController(
                        text: tanggalAkhir != null
                            ? DateFormat('dd-MM-yyyy').format(tanggalAkhir!)
                            : "",
                      ),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: tanggalAkhir ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() {
                            tanggalAkhir = picked;
                            // Validasi dan swap jika perlu
                            if (tanggalAwal != null &&
                                tanggalAwal!.isAfter(tanggalAkhir!)) {
                              final temp = tanggalAwal;
                              tanggalAwal = tanggalAkhir;
                              tanggalAkhir = temp;
                            }
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  CustomButton(
                    onPressed: () {
                      setState(() {
                        tanggalAwal = null;
                        tanggalAkhir = null;
                      });
                      showAppToast(
                        context: context,
                        type: ToastificationType.success,
                        title: 'Berhasil Reset!',
                        description: 'Filter Tanggal Direset.',
                      );
                    },
                    text: "Reset Tanggal",
                    width: 150,
                    height: 50,
                    backgroundColor: Colors.grey,
                  ),
                  const Spacer(),
                  Text('Export Data :', style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 12),
                  CustomButton(
                    width: MediaQuery.of(context).size.width * 0.1,
                    height: 50,
                    backgroundColor: Colors.green,
                    fontSize: 18,
                    icon: Icons.table_view_rounded,
                    text: 'Export Excel',
                    onPressed: () async {
                      final team = DataTeamHalter.getTeam();
                      final success = await _controller.exportDetailExcel(
                        _filteredData(_controller.detailHistoryList)..sort((
                          a,
                          b,
                        ) {
                          final aTime =
                              a.time ?? DateTime.fromMillisecondsSinceEpoch(0);
                          final bTime =
                              b.time ?? DateTime.fromMillisecondsSinceEpoch(0);
                          return bTime.compareTo(aTime);
                        }),
                        team,
                      );
                      showAppToast(
                        context: context,
                        type: success
                            ? ToastificationType.success
                            : ToastificationType.error,
                        title: success
                            ? 'Berhasil Export!'
                            : 'Export Dibatalkan!',
                        description: success
                            ? 'Data Detail Device Diexport Ke Excel.'
                            : 'Export data detail device dibatalkan.',
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  CustomButton(
                    width: MediaQuery.of(context).size.width * 0.1,
                    height: 50,
                    backgroundColor: Colors.redAccent,
                    fontSize: 18,
                    icon: Icons.picture_as_pdf,
                    text: 'Export PDF',
                    onPressed: () async {
                      final success = await _controller.exportDetailPDF(
                        _filteredData(_controller.detailHistoryList)..sort((
                          a,
                          b,
                        ) {
                          final aTime =
                              a.time ?? DateTime.fromMillisecondsSinceEpoch(0);
                          final bTime =
                              b.time ?? DateTime.fromMillisecondsSinceEpoch(0);
                          return bTime.compareTo(aTime);
                        }),
                      );
                      showAppToast(
                        context: context,
                        type: success
                            ? ToastificationType.success
                            : ToastificationType.error,
                        title: success
                            ? 'Berhasil Export!'
                            : 'Export Dibatalkan!',
                        description: success
                            ? 'Data Detail Device Diexport Ke PDF.'
                            : 'Export data detail device dibatalkan.',
                      );
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Obx(() {
                final filtered = _filteredData(_controller.detailHistoryList)
                  ..sort((a, b) {
                    final aTime =
                        a.time ?? DateTime.fromMillisecondsSinceEpoch(0);
                    final bTime =
                        b.time ?? DateTime.fromMillisecondsSinceEpoch(0);
                    return bTime.compareTo(aTime);
                  });
                ;
                final logList =
                    Get.find<HalterDevicePowerLogController>().logList;
                final logsForDevice = logList
                    .where((log) => log.deviceId == widget.deviceId)
                    .toList();

                Duration totalDurasi = Duration.zero;
                for (final log in logsForDevice) {
                  if (log.durationOn != null) {
                    totalDurasi += log.durationOn!;
                  } else {
                    // Jika alat masih nyala, hitung dari powerOnTime ke sekarang
                    totalDurasi += DateTime.now().difference(log.powerOnTime);
                  }
                }
                final jam = totalDurasi.inHours;
                final menit = totalDurasi.inMinutes % 60;
                final totalDurasiStr = jam > 0
                    ? "$jam jam $menit menit"
                    : "$menit menit";

                // Untuk lastPowerOn (paling baru)
                logsForDevice.sort(
                  (a, b) => b.powerOnTime.compareTo(a.powerOnTime),
                );
                final lastLog = logsForDevice.isNotEmpty
                    ? logsForDevice.first
                    : null;
                final lastPowerOn = lastLog?.powerOnTime;

                int totalSinceOn = 0;
                if (lastPowerOn != null) {
                  final filteredSinceOn = filtered
                      .where(
                        (d) => d.time != null && d.time.isAfter(lastPowerOn),
                      )
                      .toList();
                  totalSinceOn = filteredSinceOn.length;
                }

                return Row(
                  children: [
                    // Total Data
                    Text(
                      'Total Data: ${filtered.length}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Total Durasi Aktif: $totalDurasiStr',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 32),
                    // Data sejak nyala terakhir, jam nyala, rata-rata, durasi nyala
                    Row(
                      children: [
                        Text(
                          'Data Terbaru Dari ${lastPowerOn != null ? "(${DateFormat('HH:mm:ss').format(lastPowerOn)})" : ''}: $totalSinceOn',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 18),
                        // Text(
                        //   'Durasi nyala: $durasiNyala',
                        //   style: const TextStyle(
                        //     fontSize: 18,
                        //     fontWeight: FontWeight.bold,
                        //     color: Colors.green,
                        //   ),
                        // ),
                      ],
                    ),
                  ],
                );
              }),
            ),
            const SizedBox(height: 12),
            // Tabel data
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final tableWidth = constraints.maxWidth;
                  final noW = tableWidth * 0.02;
                  final timeW = tableWidth * 0.1;
                  final devIdW = tableWidth * 0.08;
                  final latW = tableWidth * 0.07;
                  final longW = tableWidth * 0.13;
                  final altW = tableWidth * 0.06;
                  final sogW = tableWidth * 0.06;
                  final cogW = tableWidth * 0.06;
                  final rollW = tableWidth * 0.05;
                  final pitchW = tableWidth * 0.05;
                  final yawW = tableWidth * 0.05;
                  final voltW = tableWidth * 0.07;
                  final hrW = tableWidth * 0.09;
                  final spoW = tableWidth * 0.07;
                  final suhuW = tableWidth * 0.07;
                  final respW = tableWidth * 0.08;

                  return Theme(
                    data: Theme.of(context).copyWith(
                      cardColor: Colors.white,
                      dataTableTheme: DataTableThemeData(
                        headingRowColor: MaterialStateProperty.all(
                          Colors.grey[200]!,
                        ),
                        dataRowColor: MaterialStateProperty.all(Colors.white),
                      ),
                    ),
                    child: Obx(() {
                      final filtered =
                          _filteredData(_controller.detailHistoryList)
                            ..sort((a, b) {
                              final aTime =
                                  a.time ??
                                  DateTime.fromMillisecondsSinceEpoch(0);
                              final bTime =
                                  b.time ??
                                  DateTime.fromMillisecondsSinceEpoch(0);
                              return bTime.compareTo(aTime);
                            });
                      // Sort
                      if (_sortColumnIndex != null) {
                        switch (_sortColumnIndex!) {
                          case 0:
                            _sort<String>(
                              filtered,
                              (d) => d.deviceId,
                              _sortAscending,
                            );
                            break;
                          case 1:
                            _sort<DateTime>(
                              filtered,
                              (d) => d.time,
                              _sortAscending,
                            );
                            break;
                        }
                      }
                      return PaginatedDataTable(
                        columnSpacing: 0,
                        horizontalMargin: 0,
                        sortColumnIndex: _sortColumnIndex,
                        sortAscending: _sortAscending,
                        columns: [
                          DataColumn(
                            label: SizedBox(
                              width: noW,
                              child: const Center(child: Text("No")),
                            ),
                            onSort: (columnIndex, ascending) {
                              setState(() {
                                _sortColumnIndex = columnIndex;
                                _sortAscending = ascending;
                              });
                            },
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: timeW,
                              child: const Center(child: Text("Timestamp")),
                            ),
                            onSort: (columnIndex, ascending) {
                              setState(() {
                                _sortColumnIndex = columnIndex;
                                _sortAscending = ascending;
                              });
                            },
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: devIdW,
                              child: const Center(child: Text("Device Id")),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: latW,
                              child: const Center(child: Text("Latitude (°)")),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: longW,
                              child: const Center(child: Text("Longitude (°)")),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: altW,
                              child: const Center(child: Text("Altitude (m)")),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: sogW,
                              child: const Center(child: Text("SoG (km/h)")),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: cogW,
                              child: const Center(child: Text("CoG (°)")),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: rollW,
                              child: const Center(child: Text("Roll (°)")),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: pitchW,
                              child: const Center(child: Text("Pitch (°)")),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: yawW,
                              child: const Center(child: Text("Yaw (°)")),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: voltW,
                              child: const Center(child: Text("Tegangan (V)")),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: hrW,
                              child: const Center(
                                child: Text("Detak Jantung (beat/m)"),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: spoW,
                              child: const Center(child: Text("SpO₂ (%)")),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: suhuW,
                              child: const Center(child: Text("Suhu (°C)")),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: respW,
                              child: const Center(
                                child: Text("Respirasi (breath/m)"),
                              ),
                            ),
                          ),
                        ],
                        source: HalterDeviceDetailDataTableSource(filtered),
                        rowsPerPage: _rowsPerPage,
                        availableRowsPerPage: const [5, 10],
                        onRowsPerPageChanged: (value) {
                          setState(() {
                            _rowsPerPage = value ?? 5;
                          });
                        },
                        showCheckboxColumn: false,
                      );
                    }),
                  );
                },
              ),
            ),
            // Tombol Tutup
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  text: "Tutup",
                  width: 150,
                  height: 50,
                  backgroundColor: AppColors.primary,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HalterDeviceDetailDataTableSource extends DataTableSource {
  final List<HalterDeviceDetailModel> data;

  HalterDeviceDetailDataTableSource(this.data);

  @override
  DataRow getRow(int index) {
    final d = data[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Center(child: Text('${index + 1}'))),
        DataCell(
          Center(
            child: Text(
              d.time != null
                  ? DateFormat('dd-MM-yyyy HH:mm:ss').format(d.time)
                  : "-",
            ),
          ),
        ),
        DataCell(Center(child: Text(d.deviceId))),
        DataCell(Center(child: Text('${d.latitude ?? "-"}'))),
        DataCell(Center(child: Text('${d.longitude ?? "-"}'))),
        DataCell(Center(child: Text('${d.altitude ?? "-"}'))),
        DataCell(Center(child: Text('${d.sog ?? "-"}'))),
        DataCell(Center(child: Text('${d.cog ?? "-"}'))),
        DataCell(Center(child: Text('${d.roll ?? "-"}'))),
        DataCell(Center(child: Text('${d.pitch ?? "-"}'))),
        DataCell(Center(child: Text('${d.yaw ?? "-"}'))),
        DataCell(Center(child: Text('${d.voltage ?? "-"}'))),
        DataCell(Center(child: Text('${d.heartRate ?? "-"}'))),
        DataCell(Center(child: Text('${d.spo ?? "-"}'))),
        DataCell(Center(child: Text('${d.temperature ?? "-"}'))),
        DataCell(Center(child: Text('${d.respiratoryRate ?? "-"}'))),
      ],
    );
  }

  @override
  int get rowCount => data.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
