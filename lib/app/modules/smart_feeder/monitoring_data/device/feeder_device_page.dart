import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smart_feeder_desktop/app/constants/app_colors.dart';
import 'package:smart_feeder_desktop/app/models/feeder/feeder_device_detail_model.dart';
import 'package:smart_feeder_desktop/app/models/feeder/feeder_device_history_model.dart';
import 'package:smart_feeder_desktop/app/models/feeder/feeder_device_model.dart';
import 'package:smart_feeder_desktop/app/modules/smart_feeder/monitoring_data/device/feeder_device_controller.dart';
import 'package:smart_feeder_desktop/app/utils/dialog_utils.dart';
import 'package:smart_feeder_desktop/app/utils/toast_utils.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_button.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_input.dart';
import 'package:toastification/toastification.dart';

class FeederDevicePage extends StatefulWidget {
  const FeederDevicePage({super.key});

  @override
  State<FeederDevicePage> createState() => _FeederDevicePageState();
}

class _FeederDevicePageState extends State<FeederDevicePage> {
  final TextEditingController _searchController = TextEditingController();
  final FeederDeviceController _controller = Get.find<FeederDeviceController>();
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int? _sortColumnIndex;
  bool _sortAscending = true;
  String _searchText = "";

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.trim().toLowerCase();
      });
    });
  }

  List<FeederDeviceModel> _filteredDevices(List<FeederDeviceModel> devices) {
    if (_searchText.isEmpty) return devices;
    return devices.where((d) {
      final detail = _controller.feederDeviceDetailList.firstWhereOrNull(
        (det) => det.deviceId == d.deviceId,
      );
      return d.deviceId.toLowerCase().contains(_searchText) ||
          (d.stableId ?? '').toLowerCase().contains(_searchText) ||
          (d.scheduleType == 'auto' ? 'otomatis' : 'manual')
              .toLowerCase()
              .contains(_searchText) ||
          (detail?.batteryPercent.toString() ?? '').contains(_searchText) ||
          (d.version.toString()).contains(_searchText);
    }).toList();
  }

  void _showTambahModal() {
    final idCtrl = TextEditingController();
    final versionCtrl = TextEditingController(text: "1.5");
    final scheduleCtrl = TextEditingController(text: "auto");
    final header = "SFIPB";

    showCustomDialog(
      context: context,
      title: 'Tambah Device',
      icon: Icons.add_circle_rounded,
      iconColor: Colors.green,
      showConfirmButton: true,
      confirmText: "Tambah",
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
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: scheduleCtrl.text,
            decoration: const InputDecoration(labelText: "Mode Penjadwalan"),
            items: const [
              DropdownMenuItem(value: "auto", child: Text("Mode Otomatis")),
              DropdownMenuItem(value: "manual", child: Text("Mode Manual")),
            ],
            onChanged: (v) => scheduleCtrl.text = v ?? "otomatis",
          ),
        ],
      ),
      onConfirm: () async {
        if (idCtrl.text.trim().isEmpty) {
          showAppToast(
            context: context,
            type: ToastificationType.error,
            title: 'Data Tidak Lengkap!',
            description: 'Lengkapi Data Device.',
          );
          return;
        }
        final newDevice = FeederDeviceModel(
          deviceId: '$header${idCtrl.text.trim()}',
          scheduleType: scheduleCtrl.text,
          version: versionCtrl.text,
        );
        await _controller.addDevice(newDevice);
        showAppToast(
          context: context,
          type: ToastificationType.success,
          title: 'Berhasil Ditambahkan!',
          description: 'Data Feeder "${idCtrl.text.trim()}" Ditambahkan.',
        );
      },
    );
  }

  void _showDetailModal(FeederDeviceModel device) {
    final detail = _controller.feederDeviceDetailList.firstWhereOrNull(
      (d) => d.deviceId == device.deviceId,
    );
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
          _detailRow(
            "Status",
            detail?.status == 'on' ? 'Aktif' : 'Tidak Aktif',
          ),
          const SizedBox(height: 8),
          _detailRow("Battery", "${detail?.batteryPercent ?? '-'}%"),
          const SizedBox(height: 8),
          _detailRow(
            "Kandang",
            (device.stableId != null && device.stableId!.isNotEmpty)
                ? _controller.getRoomName(device.stableId!)
                : "-",
          ),
          const SizedBox(height: 8),
          _detailRow("Versi", device.version),
        ],
      ),
    );
  }

  void _showEditModal(FeederDeviceModel device) {
    final header = "SFIPB";
    final idWithoutHeader = device.deviceId.startsWith(header)
        ? device.deviceId.substring(header.length)
        : device.deviceId;
    final idCtrl = TextEditingController(text: idWithoutHeader);
    final versionCtrl = TextEditingController(text: device.version);
    final scheduleCtrl = TextEditingController(text: device.scheduleType);

    showCustomDialog(
      context: context,
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
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: scheduleCtrl.text,
            decoration: const InputDecoration(labelText: "Mode Penjadwalan"),
            items: const [
              DropdownMenuItem(value: "auto", child: Text("Mode Otomatis")),
              DropdownMenuItem(value: "manual", child: Text("Mode Manual")),
            ],
            onChanged: (v) => scheduleCtrl.text = v ?? "otomatis",
          ),
        ],
      ),
      onConfirm: () async {
        await _controller.updateDevice(
          FeederDeviceModel(
            deviceId: '$header${idCtrl.text.trim()}',
            stableId: device.stableId,
            scheduleType: scheduleCtrl.text,
            version: versionCtrl.text,
          ),
          device.deviceId,
        );
        showAppToast(
          context: context,
          type: ToastificationType.success,
          title: 'Berhasil Diubah!',
          description: 'Data Feeder "${device.deviceId}" Diubah.',
        );
      },
    );
  }

  void _showPilihKandangModal(FeederDeviceModel device) {
    String? selectedStableId = device.stableId;
    showCustomDialog(
      context: context,
      title: "Pilih Kandang",
      icon: Icons.home,
      iconColor: AppColors.primary,
      showConfirmButton: true,
      confirmText: "Simpan",
      cancelText: "Batal",
      content: Obx(() {
        final stableList = _controller.stableList;
        final validIds = stableList.map((s) => s.stableId).toList();
        final value =
            (selectedStableId != null && validIds.contains(selectedStableId))
            ? selectedStableId
            : null;

        return DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          decoration: const InputDecoration(labelText: "Kandang"),
          items: [
            const DropdownMenuItem(value: null, child: Text("Tidak Digunakan")),
            ...stableList.map(
              (s) => DropdownMenuItem(
                value: s.stableId,
                child: Text("${s.stableId} - ${s.name}"),
              ),
            ),
          ],
          onChanged: (v) => setState(() => selectedStableId = v),
        );
      }),
      onConfirm: () async {
        if (selectedStableId == null) {
          showAppToast(
            context: context,
            type: ToastificationType.error,
            title: 'Gagal Dipasang!',
            description: 'Pilih Kandang Untuk Dipasang.',
          );
          return;
        }
        await _controller.updateDevice(
          FeederDeviceModel(
            deviceId: device.deviceId,
            stableId: selectedStableId,
            scheduleType: device.scheduleType,
            version: device.version,
          ),
          device.deviceId,
        );
        showAppToast(
          context: context,
          type: ToastificationType.success,
          title: 'Berhasil Dipasang!',
          description: 'Feeder Dipasang Di Kandang.',
        );
      },
    );
  }

  void _showLepasKandangModal(FeederDeviceModel device) {
    showCustomDialog(
      context: context,
      title: "Konfirmasi Lepas Device",
      icon: Icons.link_off,
      iconColor: Colors.orange,
      message: (device.stableId != null && device.stableId!.isNotEmpty)
          ? "Lepaskan device dari kandang \"${_controller.getRoomName(device.stableId!)}\" untuk device ${device.deviceId}?"
          : "Device belum terpasang di kandang manapun.",
      showConfirmButton: true,
      confirmText: "Lepas",
      cancelText: "Batal",
      onConfirm: () async {
        await _controller.updateDevice(
          FeederDeviceModel(
            deviceId: device.deviceId,
            stableId: null,
            scheduleType: device.scheduleType,
            version: device.version,
          ),
          device.deviceId,
        );
        showAppToast(
          context: context,
          type: ToastificationType.success,
          title: 'Berhasil Dilepas!',
          description: 'Feeder Dilepas Dari Kandang.',
        );
      },
    );
  }

  void _showRiwayatModal(FeederDeviceModel device) {
    showCustomDialog(
      context: context,
      title: "Riwayat Device",
      icon: Icons.history,
      iconColor: Colors.blue,
      showConfirmButton: false,
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text("Fitur riwayat belum tersedia."),
      ),
    );
  }

  void _confirmDelete(FeederDeviceModel device) {
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
          description: 'Data Feeder "${device.deviceId}" Dihapus.',
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

  void _sort<T>(
    List<FeederDeviceModel> devices,
    Comparable<T> Function(FeederDeviceModel d) getField,
    bool ascending,
  ) {
    devices.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending
          ? Comparable.compare(aValue, bValue)
          : Comparable.compare(bValue, aValue);
    });
  }

  @override
  Widget build(BuildContext context) {
    print('Device List:');
    for (final d in _controller.feederDeviceList) {
      print(d.deviceId);
    }
    print('Detail List:');
    for (final det in _controller.feederDeviceDetailList) {
      print('${det.deviceId} - ${det.batteryPercent}');
    }
    final detailDevices = _controller.feederDeviceDetailList;
    final deviceHistory = _controller.feederDeviceHistoryList;
    final tableWidth = MediaQuery.of(context).size.width - 72.0;
    final idW = tableWidth * 0.1;
    final kandangW = tableWidth * 0.06;
    final statusW = tableWidth * 0.06;
    final scheduleW = tableWidth * 0.07;
    final versionW = tableWidth * 0.06;
    final batteryW = tableWidth * 0.06;
    final actionW = tableWidth * 0.32;

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
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    children: [
                      Text(
                        'Daftar Perangkat IoT Main Feeder',
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
                child: Obx(() {
                  final devices = _filteredDevices(
                    _controller.feederDeviceList,
                  );
                  return Column(
                    children: [
                      // Search Box
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: CustomInput(
                          label: "Cari perangkat",
                          controller: _searchController,
                          icon: Icons.search,
                          hint: 'Masukkan ID, kandang, status, baterai',
                          fontSize: 24,
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          CustomButton(
                            width: MediaQuery.of(context).size.width * 0.1,
                            height: 50,
                            backgroundColor: Colors.green,
                            fontSize: 18,
                            icon: Icons.add_circle_rounded,
                            text: 'Tambah Data',
                            onPressed: _showTambahModal,
                          ),
                          Spacer(),
                          Text(
                            'Export Data :',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 12),
                          CustomButton(
                            width: MediaQuery.of(context).size.width * 0.1,
                            height: 50,
                            backgroundColor: Colors.green,
                            fontSize: 18,
                            icon: Icons.table_view_rounded,
                            text: 'Export Excel',
                            onPressed: () {
                              _controller.exportDeviceExcel(devices);
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
                            onPressed: () {
                              _controller.exportDevicePDF(devices);
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
                                  _sort<String>(
                                    devices,
                                    (d) => d.deviceId,
                                    ascending,
                                  );
                                });
                              },
                            ),
                            DataColumn(
                              label: SizedBox(
                                width: kandangW,
                                child: const Center(
                                  child: Text(
                                    'Kandang',
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
                                  _sort<String>(
                                    devices,
                                    (d) => d.stableId ?? '',
                                    ascending,
                                  );
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
                                  _sort<String>(
                                    devices,
                                    (d) =>
                                        _controller.feederDeviceDetailList
                                            .firstWhereOrNull(
                                              (det) =>
                                                  det.deviceId == d.deviceId,
                                            )
                                            ?.status ??
                                        '',
                                    ascending,
                                  );
                                });
                              },
                            ),
                            DataColumn(
                              label: SizedBox(
                                width: scheduleW,
                                child: const Center(
                                  child: Text(
                                    'Mode Penjadwalan',
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
                                  _sort<String>(
                                    devices,
                                    (d) => d.scheduleType,
                                    ascending,
                                  );
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
                                  _sort<String>(
                                    devices,
                                    (d) => d.version,
                                    ascending,
                                  );
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
                                  _sort<num>(
                                    devices,
                                    (d) =>
                                        _controller.feederDeviceDetailList
                                            .firstWhereOrNull(
                                              (det) =>
                                                  det.deviceId == d.deviceId,
                                            )
                                            ?.batteryPercent ??
                                        0,
                                    ascending,
                                  );
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
                          source: FeederDeviceDataTableSource(
                            context: context,
                            devices: devices,
                            deviceDetails: detailDevices,
                            history: deviceHistory,
                            getRoomName: _controller.getRoomName,
                            onDetail: _showDetailModal,
                            onEdit: _showEditModal,
                            onDelete: _confirmDelete,
                            onRiwayat: _showRiwayatModal,
                            onPilihKandang: _showPilihKandangModal,
                            onLepasKandang: _showLepasKandangModal,
                          ),
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
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FeederDeviceDataTableSource extends DataTableSource {
  final BuildContext context;
  final List<FeederDeviceModel> devices;
  final List<FeederDeviceHistoryModel> history;
  final List<FeederDeviceDetailModel> deviceDetails;
  final String Function(String) getRoomName;
  final void Function(FeederDeviceModel) onDetail;
  final void Function(FeederDeviceModel) onEdit;
  final void Function(FeederDeviceModel) onDelete;
  final void Function(FeederDeviceModel) onRiwayat;
  final void Function(FeederDeviceModel) onPilihKandang;
  final void Function(FeederDeviceModel) onLepasKandang;

  FeederDeviceDataTableSource({
    required this.context,
    required this.devices,
    required this.history,
    required this.deviceDetails,
    required this.getRoomName,
    required this.onDetail,
    required this.onEdit,
    required this.onDelete,
    required this.onRiwayat,
    required this.onPilihKandang,
    required this.onLepasKandang,
  });

  @override
  DataRow getRow(int index) {
    final device = devices[index];
    final detail = deviceDetails.firstWhereOrNull(
      (d) => d.deviceId == device.deviceId,
    );
    final deviceHistory = history
        .where((d) => d.deviceId == device.deviceId)
        .toList();
    final status = detail?.status ?? '-';
    final batteryPercent = detail?.batteryPercent ?? 0;

    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Center(child: Text(device.deviceId))),
        DataCell(Center(child: Text(device.stableId ?? '-'))),
        DataCell(
          Center(child: Text(status == 'ready' ? 'Aktif' : 'Tidak Aktif')),
        ),
        DataCell(
          Center(
            child: Text(
              device.scheduleType == 'penjadwalan'
                  ? 'Penjadwalan'
                  : device.scheduleType == 'auto'
                  ? 'Otomatis'
                  : 'Manual',
            ),
          ),
        ),
        DataCell(Center(child: Text(device.version))),
        DataCell(Center(child: Text('${batteryPercent}%'))),
        DataCell(
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomButton(
                width: 120,
                height: 38,
                text: 'Riwayat',
                backgroundColor: Colors.blue,
                icon: Icons.history,
                borderRadius: 6,
                fontSize: 14,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return FeederDeviceDetailDialog(
                        deviceId: device.deviceId,
                        allData: deviceHistory,
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
              device.stableId == null
                  ? CustomButton(
                      width: 170,
                      height: 38,
                      backgroundColor: AppColors.primary,
                      text: 'Pilih Kandang',
                      icon: Icons.home,
                      borderRadius: 6,
                      fontSize: 14,
                      onPressed: () => onPilihKandang(device),
                    )
                  : CustomButton(
                      width: 170,
                      height: 38,
                      backgroundColor: Colors.orange,
                      text: 'Lepas Device',
                      icon: Icons.link_off,
                      borderRadius: 6,
                      fontSize: 14,
                      onPressed: () => onLepasKandang(device),
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

class FeederDeviceDetailDialog extends StatefulWidget {
  final String deviceId;
  final List<FeederDeviceHistoryModel> allData;

  const FeederDeviceDetailDialog({
    super.key,
    required this.deviceId,
    required this.allData,
  });

  @override
  State<FeederDeviceDetailDialog> createState() =>
      _FeederDeviceDetailDialogState();
}

class _FeederDeviceDetailDialogState extends State<FeederDeviceDetailDialog> {
  DateTime? tanggalAwal;
  DateTime? tanggalAkhir;
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int? _sortColumnIndex;
  bool _sortAscending = true;

  List<FeederDeviceHistoryModel> _filteredData(
    List<FeederDeviceHistoryModel> data,
  ) {
    var filtered = data.where((d) => d.deviceId == widget.deviceId).toList();
    if (tanggalAwal != null) {
      filtered = filtered.where((d) {
        final tAwal = DateTime(
          tanggalAwal!.year,
          tanggalAwal!.month,
          tanggalAwal!.day,
        );
        final tData = DateTime(
          d.timestamp.year,
          d.timestamp.month,
          d.timestamp.day,
        );
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
        final tData = DateTime(
          d.timestamp.year,
          d.timestamp.month,
          d.timestamp.day,
        );
        return tData.isAtSameMomentAs(tAkhir) || tData.isBefore(tAkhir);
      }).toList();
    }
    return filtered;
  }

  void _sort<T>(
    List<FeederDeviceHistoryModel> data,
    Comparable<T> Function(FeederDeviceHistoryModel d) getField,
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
            // Filter tanggal
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
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Tabel data
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final tableWidth = constraints.maxWidth;
                  final noW = tableWidth * 0.055;
                  final timeW = tableWidth * 0.2;
                  final statusW = tableWidth * 0.18;
                  final destW = tableWidth * 0.18;
                  final amountW = tableWidth * 0.18;
                  final batteryW = tableWidth * 0.18;

                  final filtered = _filteredData(widget.allData);
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
                          (d) => d.timestamp,
                          _sortAscending,
                        );
                        break;
                    }
                  }
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
                    child: PaginatedDataTable(
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
                            width: statusW,
                            child: const Center(child: Text("Device ID")),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: destW,
                            child: const Center(child: Text("Mode")),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: amountW,
                            child: const Center(child: Text("Ruang")),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: batteryW,
                            child: const Center(child: Text("Jumlah")),
                          ),
                        ),
                      ],
                      source: _FeederDeviceDetailDataTableSource(filtered),
                      rowsPerPage: _rowsPerPage,
                      availableRowsPerPage: const [5, 10],
                      onRowsPerPageChanged: (value) {
                        setState(() {
                          _rowsPerPage = value ?? 5;
                        });
                      },
                      showCheckboxColumn: false,
                    ),
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

class _FeederDeviceDetailDataTableSource extends DataTableSource {
  final List<FeederDeviceHistoryModel> data;

  _FeederDeviceDetailDataTableSource(this.data);

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
              d.timestamp != null
                  ? DateFormat('dd-MM-yyyy HH:mm:ss').format(d.timestamp)
                  : "-",
            ),
          ),
        ),
        DataCell(Center(child: Text(d.deviceId))),
        DataCell(
          Center(
            child: Text(
              d.mode == 'penjadwalan'
                  ? 'Penjadwalan'
                  : d.mode == 'auto'
                  ? 'Otomatis'
                  : 'Manual',
            ),
          ),
        ),
        DataCell(Center(child: Text(d.roomId))),
        DataCell(Center(child: Text(d.amount.toString()))),
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
