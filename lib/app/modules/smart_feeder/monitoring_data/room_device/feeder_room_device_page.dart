import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/constants/app_colors.dart';
import 'package:smart_feeder_desktop/app/models/feeder/feeder_room_device_model.dart';
import 'package:smart_feeder_desktop/app/modules/smart_feeder/monitoring_data/room_device/feeder_room_device_controller.dart';
import 'package:smart_feeder_desktop/app/utils/dialog_utils.dart';
import 'package:smart_feeder_desktop/app/utils/toast_utils.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_button.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_input.dart';
import 'package:toastification/toastification.dart';

class FeederRoomDevicePage extends StatefulWidget {
  const FeederRoomDevicePage({super.key});

  @override
  State<FeederRoomDevicePage> createState() => _FeederRoomDevicePageState();
}

class _FeederRoomDevicePageState extends State<FeederRoomDevicePage> {
  final TextEditingController _searchController = TextEditingController();
  final FeederRoomDeviceController _controller =
      Get.find<FeederRoomDeviceController>();
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

  List<FeederRoomDeviceModel> _filteredDevices(
    List<FeederRoomDeviceModel> devices,
  ) {
    if (_searchText.isEmpty) return devices;
    return devices.where((d) {
      return d.deviceId.toLowerCase().contains(_searchText) ||
          (d.roomId ?? '').toLowerCase().contains(_searchText) ||
          d.status.toLowerCase().contains(_searchText) ||
          d.batteryPercent.toString().contains(_searchText) ||
          d.feedRemaining.toString().contains(_searchText) ||
          d.waterRemaining.toString().contains(_searchText);
    }).toList();
  }

  void _showTambahModal() {
    final idCtrl = TextEditingController();

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
                  "ID",
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
                  hint: "Masukkan ID",
                ),
              ),
            ],
          ),
        ],
      ),
      onConfirm: () {
        if (idCtrl.text.trim().isEmpty) {
          showAppToast(
            context: context,
            type: ToastificationType.error,
            title: 'Data Tidak Lengkap!',
            description: 'Lengkapi Data Device.',
          );
          return;
        }
        showAppToast(
          context: context,
          type: ToastificationType.success,
          title: 'Berhasil Ditambahkan!',
          description: 'Data Feeder "${idCtrl.text.trim()}" Ditambahkan.',
        );
      },
    );
  }

  void _showDetailModal(FeederRoomDeviceModel device) {
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
          _detailRow("Status", device.status == 'on' ? 'Aktif' : 'Tidak Aktif'),
          const SizedBox(height: 8),
          _detailRow("Battery", "${device.batteryPercent}%"),
          const SizedBox(height: 8),
          _detailRow(
            "Ruangan",
            (device.roomId != null && device.roomId!.isNotEmpty)
                ? _controller.getRoomName(device.roomId!)
                : "-",
          ),
          const SizedBox(height: 8),
          _detailRow("Sisa Pakan", "${device.feedRemaining}g"),
          const SizedBox(height: 8),
          _detailRow("Sisa Air", "${device.waterRemaining}L"),
        ],
      ),
    );
  }

  void _showEditModal(FeederRoomDeviceModel device) {
    final idCtrl = TextEditingController(text: device.deviceId);
    final statusCtrl = TextEditingController(text: device.status);
    final batteryCtrl = TextEditingController(
      text: device.batteryPercent.toString(),
    );
    final feedCtrl = TextEditingController(
      text: device.feedRemaining.toString(),
    );
    final waterCtrl = TextEditingController(
      text: device.waterRemaining.toString(),
    );
    String? selectedRoomId = device.roomId;

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
                  "ID",
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
                  hint: "Masukkan ID",
                ),
              ),
            ],
          ),
        ],
      ),
      onConfirm: () {
        showAppToast(
          context: context,
          type: ToastificationType.success,
          title: 'Berhasil Diubah!',
          description: 'Data Feeder "${device.deviceId}" Diubah.',
        );
      },
    );
  }

  void _showPilihRuanganModal(FeederRoomDeviceModel device) {
    String? selectedRoomId = device.roomId;
    showCustomDialog(
      context: context,
      title: "Pilih Ruangan",
      icon: Icons.house_siding_rounded,
      iconColor: AppColors.primary,
      showConfirmButton: true,
      confirmText: "Simpan",
      cancelText: "Batal",
      content: Obx(() {
        final roomList = _controller.roomList;
        final validIds = roomList.map((r) => r.roomId).toList();
        final value =
            (selectedRoomId != null && validIds.contains(selectedRoomId))
            ? selectedRoomId
            : null;

        return DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          decoration: const InputDecoration(labelText: "Ruangan"),
          items: [
            const DropdownMenuItem(value: null, child: Text("Tidak Digunakan")),
            ...roomList.map(
              (r) => DropdownMenuItem(
                value: r.roomId,
                child: Text("${r.roomId} - ${r.name}"),
              ),
            ),
          ],
          onChanged: (v) => setState(() => selectedRoomId = v),
        );
      }),
      onConfirm: () {
        if (selectedRoomId == null) {
          showAppToast(
            context: context,
            type: ToastificationType.error,
            title: 'Gagal Dipasang!',
            description: 'Pilih Ruangan Untuk Dipasang.',
          );
          return;
        }
        showAppToast(
          context: context,
          type: ToastificationType.success,
          title: 'Berhasil Dipasang!',
          description: 'Feeder Dipasang Di Ruangan.',
        );
      },
    );
  }

  void _showLepasRuanganModal(FeederRoomDeviceModel device) {
    showCustomDialog(
      context: context,
      title: "Konfirmasi Lepas Ruangan",
      icon: Icons.link_off,
      iconColor: Colors.orange,
      message: (device.roomId != null && device.roomId!.isNotEmpty)
          ? "Lepaskan device dari ruangan \"${_controller.getRoomName(device.roomId!)}\" untuk device ${device.deviceId}?"
          : "Device belum terpasang di ruangan manapun.",
      showConfirmButton: true,
      confirmText: "Lepas",
      cancelText: "Batal",
      onConfirm: () {
        showAppToast(
          context: context,
          type: ToastificationType.success,
          title: 'Berhasil Dilepas!',
          description: 'Feeder Dilepas Dari Ruangan.',
        );
      },
    );
  }

  void _showRiwayatModal(FeederRoomDeviceModel device) {
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

  void _confirmDelete(FeederRoomDeviceModel device) {
    showCustomDialog(
      context: context,
      title: "Konfirmasi Hapus",
      icon: Icons.delete_forever,
      iconColor: Colors.red,
      message: 'Hapus device "${device.deviceId}"?',
      showConfirmButton: true,
      confirmText: "Hapus",
      cancelText: "Batal",
      onConfirm: () {
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
    List<FeederRoomDeviceModel> devices,
    Comparable<T> Function(FeederRoomDeviceModel d) getField,
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
    final devices = _filteredDevices(_controller.feederRoomDeviceList);
    final tableWidth = MediaQuery.of(context).size.width - 72.0;
    final idW = tableWidth * 0.08;
    final roomW = tableWidth * 0.07;
    final statusW = tableWidth * 0.07;
    final batteryW = tableWidth * 0.07;
    final feedW = tableWidth * 0.07;
    final waterW = tableWidth * 0.07;
    final actionW = tableWidth * 0.3;

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
                        'Daftar Perangkat Ruangan',
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
                        label: "Cari perangkat",
                        controller: _searchController,
                        icon: Icons.search,
                        hint:
                            'Masukkan ID, ruangan, status, baterai, pakan, air',
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
                              width: idW,
                              child: const Center(
                                child: Text(
                                  'ID',
                                  style: TextStyle(fontWeight: FontWeight.bold),
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
                              width: roomW,
                              child: const Center(
                                child: Text(
                                  'Ruangan',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            onSort: (columnIndex, ascending) {
                              setState(() {
                                _sortColumnIndex = columnIndex;
                                _sortAscending = ascending;
                                _sort<String>(
                                  devices,
                                  (d) => d.roomId ?? '',
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
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            onSort: (columnIndex, ascending) {
                              setState(() {
                                _sortColumnIndex = columnIndex;
                                _sortAscending = ascending;
                                _sort<String>(
                                  devices,
                                  (d) => d.status,
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
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            onSort: (columnIndex, ascending) {
                              setState(() {
                                _sortColumnIndex = columnIndex;
                                _sortAscending = ascending;
                                _sort<String>(
                                  devices,
                                  (d) => d.batteryPercent.toString(),
                                  ascending,
                                );
                              });
                            },
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: feedW,
                              child: const Center(
                                child: Text(
                                  'Sisa Pakan',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            onSort: (columnIndex, ascending) {
                              setState(() {
                                _sortColumnIndex = columnIndex;
                                _sortAscending = ascending;
                                _sort<String>(
                                  devices,
                                  (d) => d.feedRemaining.toString(),
                                  ascending,
                                );
                              });
                            },
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: waterW,
                              child: const Center(
                                child: Text(
                                  'Sisa Air',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            onSort: (columnIndex, ascending) {
                              setState(() {
                                _sortColumnIndex = columnIndex;
                                _sortAscending = ascending;
                                _sort<String>(
                                  devices,
                                  (d) => d.waterRemaining.toString(),
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
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ],
                        source: FeederRoomDeviceDataTableSource(
                          context: context,
                          devices: devices,
                          getRoomName: _controller.getRoomName,
                          onDetail: _showDetailModal,
                          onEdit: _showEditModal,
                          onDelete: _confirmDelete,
                          onRiwayat: _showRiwayatModal,
                          onPilihRuangan: _showPilihRuanganModal,
                          onLepasRuangan: _showLepasRuanganModal,
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FeederRoomDeviceDataTableSource extends DataTableSource {
  final BuildContext context;
  final List<FeederRoomDeviceModel> devices;
  final String Function(String) getRoomName;
  final void Function(FeederRoomDeviceModel) onDetail;
  final void Function(FeederRoomDeviceModel) onEdit;
  final void Function(FeederRoomDeviceModel) onDelete;
  final void Function(FeederRoomDeviceModel) onRiwayat;
  final void Function(FeederRoomDeviceModel) onPilihRuangan;
  final void Function(FeederRoomDeviceModel) onLepasRuangan;

  FeederRoomDeviceDataTableSource({
    required this.context,
    required this.devices,
    required this.getRoomName,
    required this.onDetail,
    required this.onEdit,
    required this.onDelete,
    required this.onRiwayat,
    required this.onPilihRuangan,
    required this.onLepasRuangan,
  });

  @override
  DataRow getRow(int index) {
    final device = devices[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Center(child: Text(device.deviceId))),
        DataCell(
          Center(
            child: Text(
              device.roomId != null ? getRoomName(device.roomId!) : '-',
            ),
          ),
        ),
        DataCell(
          Center(child: Text(device.status == 'on' ? 'Aktif' : 'Tidak Aktif')),
        ),
        DataCell(Center(child: Text('${device.batteryPercent}%'))),
        DataCell(
          Center(
            child: Text(
              '${device.feedRemaining}g / 500g',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        DataCell(
          Center(
            child: Text(
              '${device.waterRemaining}L / 5L',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
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
                onPressed: () => onRiwayat(device),
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
              device.roomId == null
                  ? CustomButton(
                      width: 170,
                      height: 38,
                      backgroundColor: AppColors.primary,
                      text: 'Pilih Ruangan',
                      icon: Icons.house_siding_rounded,
                      borderRadius: 6,
                      fontSize: 14,
                      onPressed: () => onPilihRuangan(device),
                    )
                  : CustomButton(
                      width: 170,
                      height: 38,
                      backgroundColor: Colors.orange,
                      text: 'Lepas Ruangan',
                      icon: Icons.link_off,
                      borderRadius: 6,
                      fontSize: 14,
                      onPressed: () => onLepasRuangan(device),
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
