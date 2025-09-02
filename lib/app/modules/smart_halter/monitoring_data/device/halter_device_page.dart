import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
// Ganti dengan import model dan widget sesuai project-mu
import 'package:smart_feeder_desktop/app/constants/app_colors.dart';
import 'package:smart_feeder_desktop/app/data/data_team_halter.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_device_detail_model.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_device_model.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/monitoring_data/device/halter_device_controller.dart';
import 'package:smart_feeder_desktop/app/utils/dialog_utils.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_button.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_input.dart';

class HalterDevicePage extends StatefulWidget {
  const HalterDevicePage({Key? key}) : super(key: key);

  @override
  State<HalterDevicePage> createState() => _HalterDevicePageState();
}

class _HalterDevicePageState extends State<HalterDevicePage> {
  final TextEditingController _searchController = TextEditingController();
  final HalterDeviceController _controller = Get.find<HalterDeviceController>();
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
          CustomInput(
            label: "Device ID (Wajib diisi)",
            controller: idCtrl,
            hint: "Masukkan Device ID (Format: SHIPB001)",
          ),
        ],
      ),
      onConfirm: () {
        if (idCtrl.text.trim().isEmpty) {
          Get.snackbar(
            "Input Tidak Lengkap",
            "Device ID wajib diisi.",
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
          return;
        }
        final newDevice = HalterDeviceModel(
          deviceId: idCtrl.text.trim(),
          status: device?.status ?? 'off',
          batteryPercent: device?.batteryPercent ?? 0,
          horseId: device?.horseId,
        );
        onSubmit(newDevice);
      },
    );
  }

  void _showDeviceFormModalEdit(
    HalterDeviceModel device,
    Function(HalterDeviceModel) onSubmit, {
    BuildContext? parentContext,
  }) async {
    final idCtrl = TextEditingController(text: device.deviceId);

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
          CustomInput(
            label: "Device ID (Wajib diisi)",
            controller: idCtrl,
            hint: "Masukkan Device ID",
          ),
        ],
      ),
      onConfirm: () {
        if (idCtrl.text.trim().isEmpty) {
          Get.snackbar(
            "Input Tidak Lengkap",
            "Device ID wajib diisi.",
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
          return;
        }
        final editedDevice = HalterDeviceModel(
          deviceId: idCtrl.text.trim(),
          status: device.status,
          batteryPercent: device.batteryPercent,
          horseId: device.horseId,
        );
        onSubmit(editedDevice);
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
        final updated = HalterDeviceModel(
          deviceId: device.deviceId,
          status: device.status,
          batteryPercent: device.batteryPercent,
          horseId: selectedHorseId,
        );
        await _controller.updateDevice(updated);
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
        );
        await _controller.updateDevice(updated);
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
              child: const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    children: [
                      Text(
                        'Daftar Halter Device',
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
                        label: "Cari device",
                        controller: _searchController,
                        icon: Icons.search,
                        hint: 'Masukkan ID, status, atau kuda',
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
                        final horseW = tableWidth * 0.13;
                        final statusW = tableWidth * 0.10;
                        final batteryW = tableWidth * 0.10;
                        final actionW = tableWidth * 0.32;

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
                              oldDeviceId: device.deviceId,
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
                                    onPressed: () {
                                      _controller.exportDeviceExcel(
                                        devices,
                                        _controller.getHorseNameById,
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
                                    onPressed: () {
                                      _controller.exportDevicePDF(
                                        devices,
                                        _controller.getHorseNameById,
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

  List<HalterDeviceDetailModel> get filteredData {
    // Filter by deviceId
    var data = widget.allData
        .where((d) => d.deviceId == widget.deviceId)
        .toList();
    // Filter tanggal jika dipilih
    if (tanggalAwal != null) {
      data = data.where((d) => d.time.isAfter(tanggalAwal!)).toList();
    }
    if (tanggalAkhir != null) {
      data = data.where((d) => d.time.isBefore(tanggalAkhir!)).toList();
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(32),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
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
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    children: [
                      Text(
                        'Detail Data Device ${widget.deviceId}',
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
            // Filter tanggal + Export
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  // Tanggal Awal
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
                            ? "${tanggalAwal!.toIso8601String().split('T').first}"
                            : "",
                      ),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: tanggalAwal ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null)
                          setState(() => tanggalAwal = picked);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Tanggal Akhir
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
                            ? "${tanggalAkhir!.toIso8601String().split('T').first}"
                            : "",
                      ),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: tanggalAkhir ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null)
                          setState(() => tanggalAkhir = picked);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  CustomButton(
                    onPressed: () {
                      setState(() {});
                    },
                    text: "Pilih Tanggal",
                    width: 150,
                    height: 50,
                    backgroundColor: AppColors.primary,
                    fontSize: 16,
                  ),
                  const SizedBox(width: 8),
                  CustomButton(
                    onPressed: () {
                      setState(() {
                        tanggalAwal = null;
                        tanggalAkhir = null;
                      });
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
                    onPressed: () {
                      final team = DataTeamHalter.getTeam();
                      _controller.exportDetailExcel(filteredData, team);
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
                      _controller.exportDetailPDF(filteredData);
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Total Data: ${filteredData.length}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Tabel data
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text("No")),
                      DataColumn(label: Text("Timestamp")),
                      DataColumn(label: Text("Device Id")),
                      DataColumn(label: Text("Latitude (°)")),
                      DataColumn(label: Text("Longitude (°)")),
                      DataColumn(label: Text("Altitude (m)")),
                      DataColumn(label: Text("SoG (km/h)")),
                      DataColumn(label: Text("CoG (°)")),
                      // DataColumn(label: Text("AcceX (m/s²)")),
                      // DataColumn(label: Text("AcceY (m/s²)")),
                      // DataColumn(label: Text("AcceZ (m/s²)")),
                      // DataColumn(label: Text("GyroX (°/s)")),
                      // DataColumn(label: Text("GyroY (°/s)")),
                      // DataColumn(label: Text("GyroZ (°/s)")),
                      // DataColumn(label: Text("MagX (μT)")),
                      // DataColumn(label: Text("MagY (μT)")),
                      // DataColumn(label: Text("MagZ (μT)")),
                      DataColumn(label: Text("Roll (°)")),
                      DataColumn(label: Text("Pitch (°)")),
                      DataColumn(label: Text("Yaw (°)")),
                      // DataColumn(label: Text("Arus (A)")),
                      DataColumn(label: Text("Tegangan (mV)")),
                      DataColumn(label: Text("Detak Jantung (beat/m)")),
                      DataColumn(label: Text("SpO₂ (%)")),
                      DataColumn(label: Text("Suhu (°C)")),
                      DataColumn(label: Text("Respirasi (breath/m)")),
                    ],
                    rows: List.generate(filteredData.length, (i) {
                      final d = filteredData[i];
                      return DataRow(
                        cells: [
                          DataCell(Center(child: Text('${i + 1}'))),
                          DataCell(
                            Center(
                              child: Text(
                                d.time != null
                                    ? DateFormat(
                                        'dd-MM-yyyy HH:mm:ss',
                                      ).format(d.time)
                                    : "-",
                              ),
                            ),
                          ),
                          DataCell(Center(child: Text(d.deviceId))),
                          DataCell(Center(child: Text('${d.latitude ?? "-"}'))),
                          DataCell(
                            Center(child: Text('${d.longitude ?? "-"}')),
                          ),
                          DataCell(Center(child: Text('${d.altitude ?? "-"}'))),
                          DataCell(Center(child: Text('${d.sog ?? "-"}'))),
                          DataCell(Center(child: Text('${d.cog ?? "-"}'))),
                          // DataCell(Center(child: Text('${d.acceX ?? "-"}'))),
                          // DataCell(Center(child: Text('${d.acceY ?? "-"}'))),
                          // DataCell(Center(child: Text('${d.acceZ ?? "-"}'))),
                          // DataCell(Center(child: Text('${d.gyroX ?? "-"}'))),
                          // DataCell(Center(child: Text('${d.gyroY ?? "-"}'))),
                          // DataCell(Center(child: Text('${d.gyroZ ?? "-"}'))),
                          // DataCell(Center(child: Text('${d.magX ?? "-"}'))),
                          // DataCell(Center(child: Text('${d.magY ?? "-"}'))),
                          // DataCell(Center(child: Text('${d.magZ ?? "-"}'))),
                          DataCell(Center(child: Text('${d.roll ?? "-"}'))),
                          DataCell(Center(child: Text('${d.pitch ?? "-"}'))),
                          DataCell(Center(child: Text('${d.yaw ?? "-"}'))),
                          // DataCell(Center(child: Text('${d.current ?? "-"}'))),
                          DataCell(Center(child: Text('${d.voltage ?? "-"}'))),
                          DataCell(
                            Center(child: Text('${d.heartRate ?? "-"}')),
                          ),
                          DataCell(Center(child: Text('${d.spo ?? "-"}'))),
                          DataCell(
                            Center(child: Text('${d.temperature ?? "-"}')),
                          ),
                          DataCell(
                            Center(child: Text('${d.respiratoryRate ?? "-"}')),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
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
