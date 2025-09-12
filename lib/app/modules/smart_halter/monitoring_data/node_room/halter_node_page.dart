// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
// Ganti dengan import model dan widget sesuai project-mu
import 'package:smart_feeder_desktop/app/constants/app_colors.dart';
import 'package:smart_feeder_desktop/app/data/data_controller.dart';
import 'package:smart_feeder_desktop/app/data/data_team_halter.dart';
import 'package:smart_feeder_desktop/app/models/halter/node_room_detail_model.dart';
import 'package:smart_feeder_desktop/app/models/halter/node_room_model.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/monitoring_data/node_room/halter_node_controller.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/setting/halter_setting_controller.dart';
import 'package:smart_feeder_desktop/app/utils/dialog_utils.dart';
import 'package:smart_feeder_desktop/app/utils/toast_utils.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_button.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_input.dart';
import 'package:toastification/toastification.dart';

class HalterNodePage extends StatefulWidget {
  const HalterNodePage({super.key});

  @override
  State<HalterNodePage> createState() => _HalterNodePageState();
}

class _HalterNodePageState extends State<HalterNodePage> {
  final TextEditingController _searchController = TextEditingController();
  final HalterNodeController _controller = Get.find<HalterNodeController>();
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int? _sortColumnIndex;
  bool _sortAscending = true;
  String _searchText = "";

  @override
  void initState() {
    super.initState();
    _controller.loadNode();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.trim().toLowerCase();
      });
    });
  }

  List<NodeRoomModel> _filteredNodes(List<NodeRoomModel> nodes) {
    if (_searchText.isEmpty) return nodes;
    return nodes.where((d) {
      return d.deviceId.toLowerCase().contains(_searchText) ||
          d.temperature.toString().contains(_searchText) ||
          d.humidity.toString().contains(_searchText) ||
          d.humidity.toString().contains(_searchText) ||
          d.lightIntensity.toString().contains(_searchText);
    }).toList();
  }

  // ...existing code...
  void _showNodeFormModal({
    NodeRoomModel? node,
    required bool isEdit,
    required Function(NodeRoomModel) onSubmit,
    BuildContext? parentContext,
  }) async {
    final idCtrl = TextEditingController(text: node?.deviceId ?? '');
    final header = Get.find<HalterSettingController>().nodeRoomHeader.value;
    final versionCtrl = TextEditingController(text: node?.version ?? '1.5');

    showCustomDialog(
      context: parentContext ?? context,
      title: isEdit ? 'Edit Node Device' : 'Tambah Node Device',
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
                  node!.deviceId,
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
            description: 'Lengkapi Data Node Kandang.',
          );
          return;
        }
        final header = Get.find<HalterSettingController>().nodeRoomHeader.value;
        final deviceId = '$header${idCtrl.text.trim()}';

        final newNode = NodeRoomModel(
          deviceId: deviceId,
          temperature: node?.temperature ?? 0,
          humidity: node?.humidity ?? 0,
          lightIntensity: node?.lightIntensity ?? 0,
          time: node?.time,
          version: versionCtrl.text,
        );
        onSubmit(newNode);
        showAppToast(
          context: context,
          type: ToastificationType.success,
          title: 'Berhasil Ditambahkan!',
          description: 'Data Node Kandang Ditambahkan.',
        );
      },
    );
  }

  void _showNodeFormModalEdit(
    NodeRoomModel node,
    Function(NodeRoomModel) onSubmit, {
    BuildContext? parentContext,
  }) async {
    // Ambil header dari deviceId yang sudah ada
    final header = Get.find<HalterSettingController>().nodeRoomHeader.value;
    // Ambil versi dari node
    final versionCtrl = TextEditingController(text: node.version);
    // Ambil id tanpa header (jika deviceId sudah ada header di depan)
    final idWithoutHeader = node.deviceId.startsWith(header)
        ? node.deviceId.substring(header.length)
        : node.deviceId;
    final idCtrl = TextEditingController(text: idWithoutHeader);

    showCustomDialog(
      context: parentContext ?? context,
      title: 'Edit Node Device',
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
            description: 'Lengkapi Data Node Kandang.',
          );
          return;
        }
        final deviceId = '$header${idCtrl.text.trim()}';
        final editedNode = NodeRoomModel(
          deviceId: deviceId,
          temperature: node.temperature,
          humidity: node.humidity,
          lightIntensity: node.lightIntensity,
          time: node.time,
          version: versionCtrl.text,
        );
        onSubmit(editedNode);
        showAppToast(
          context: context,
          type: ToastificationType.success,
          title: 'Berhasil Diubah!',
          description: 'Data Node Kandang "${node.deviceId} Diubah.',
        );
      },
    );
  }

  void _showPilihRuanganModal(NodeRoomModel node) {
    String? selectedRoomId; // atau node.roomId jika model ada field roomId

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
        // Semua deviceSerial yang sudah dipakai room lain (kecuali node ini)
        // final allUsedDeviceSerials = roomList
        //     .where(
        //       (r) => r.deviceSerial != null && r.deviceSerial != node.deviceId,
        //     )
        //     .map((r) => r.deviceSerial)
        //     .toSet();

        // Hanya ruangan yang belum dipakai atau memang sedang dipakai node ini
        final availableRooms = roomList
            .where(
              (r) =>
                  r.deviceSerial == node.deviceId ||
                  r.deviceSerial == null ||
                  r.deviceSerial == '',
            )
            .toList();

        // Validasi value
        final validIds = availableRooms.map((r) => r.roomId).toList();
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
            ...availableRooms.map(
              (r) => DropdownMenuItem(
                value: r.roomId,
                child: Text("${r.roomId} - ${r.name}"),
              ),
            ),
          ],
          onChanged: (v) => setState(() => selectedRoomId = v),
        );
      }),
      onConfirm: () async {
        if (selectedRoomId == null) {
          showAppToast(
            context: context,
            type: ToastificationType.error,
            title: 'Gagal Dipasang!',
            description: 'Pilih Ruangan Untuk Dipasang.',
          );
          return;
        }
        await _controller.pilihRuanganUntukNode(node.deviceId, selectedRoomId);
        await _controller.loadNode(); // Tambahkan ini agar refresh RxList
        showAppToast(
          context: context,
          type: ToastificationType.success,
          title: 'Node Kandang Dipasang!',
          description: 'Node Kandang Dipasang Di "${selectedRoomId}".',
        );
      },
    );
  }

  void _showLepasRuanganModal(NodeRoomModel node) {
    showCustomDialog(
      context: context,
      title: "Konfirmasi Lepas Ruangan",
      icon: Icons.link_off,
      iconColor: Colors.orange,
      message: "Lepas node device ${node.deviceId} dari ruangan?",
      showConfirmButton: true,
      confirmText: "Lepas",
      cancelText: "Batal",
      onConfirm: () async {
        await _controller.pilihRuanganUntukNode(node.deviceId, null);
        await _controller.loadNode(); // Tambahkan ini agar refresh RxList
        showAppToast(
          context: context,
          type: ToastificationType.success,
          title: 'Node Kandang Dilepas!',
          description: 'Node Kandang Dilepas Dari Ruangan.',
        );
      },
    );
  }

  void _showDetailModal(NodeRoomModel node) {
    showDialog(
      context: context,
      builder: (context) {
        return RoomNodeDataDialog(deviceId: node.deviceId);
      },
    );
  }

  void _confirmDelete(NodeRoomModel node) {
    showCustomDialog(
      context: context,
      title: "Konfirmasi Hapus",
      icon: Icons.delete_forever,
      iconColor: Colors.red,
      message: 'Hapus node device "${node.deviceId}"?',
      showConfirmButton: true,
      confirmText: "Hapus",
      cancelText: "Batal",
      onConfirm: () async {
        await _controller.deleteNode(node.deviceId);
        showAppToast(
          context: context,
          type: ToastificationType.success,
          title: 'Berhasil Dihapus!',
          description: 'Data Node Kandang "${node.deviceId}" Dihapus.',
        );
      },
    );
  }

  void _sort<T extends Comparable>(
    List<NodeRoomModel> devices,
    T Function(NodeRoomModel d) getField,
    bool ascending,
  ) {
    devices.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
    });
  }

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
                        'Daftar IoT Node Kandang',
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
                        label: "Cari IoT Node Kandang",
                        controller: _searchController,
                        icon: Icons.search,
                        hint: 'Masukkan ID, suhu, kelembaban, light',
                        fontSize: 24,
                      ),
                    ),
                    // Table
                    Expanded(
                      child: Obx(() {
                        List<NodeRoomModel> nodes = _filteredNodes(
                          _controller.nodeRoomList.toList(),
                        );

                        if (_sortColumnIndex != null) {
                          switch (_sortColumnIndex!) {
                            case 0:
                              _sort<String>(
                                nodes,
                                (d) => d.deviceId,
                                _sortAscending,
                              );
                              break;
                            case 1:
                              _sort<double>(
                                nodes,
                                (d) => d.temperature,
                                _sortAscending,
                              );
                              break;
                            case 2:
                              _sort<double>(
                                nodes,
                                (d) => d.humidity,
                                _sortAscending,
                              );
                              break;
                            case 3:
                              _sort<double>(
                                nodes,
                                (d) => d.lightIntensity,
                                _sortAscending,
                              );
                              break;
                          }
                        }

                        final tableWidth =
                            MediaQuery.of(context).size.width - 72.0;
                        final idW = tableWidth * 0.10;
                        final tempW = tableWidth * 0.08;
                        final humW = tableWidth * 0.08;
                        final lightW = tableWidth * 0.08;
                        final actionW = tableWidth * 0.32;
                        final versionW = tableWidth * 0.09;

                        final dataSource = NodeRoomDataTableSource(
                          context: context,
                          nodes: nodes,
                          onDetail: _showDetailModal,
                          onDelete: _confirmDelete,
                          onEdit: (node) =>
                              _showNodeFormModalEdit(node, (editedNode) async {
                                await _controller.deleteNode(node.deviceId);
                                await _controller.addNode(editedNode);
                                await _controller.loadNode();
                              }),
                          onLepasRuangan: _showLepasRuanganModal,
                          onSelectRoom: (node) {
                            _showPilihRuanganModal(node);
                          },
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
                                      _showNodeFormModal(
                                        isEdit: false,
                                        onSubmit: (node) async {
                                          await _controller.addNode(node);
                                          await _controller.loadNode();
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
                                          .exportNodeRoomExcel(
                                            _controller.nodeRoomList.toList(),
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
                                            ? 'Data Node Kandang Diexport Ke Excel.'
                                            : 'Export data node kandang dibatalkan.',
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
                                          .exportNodeRoomPDF(
                                            _controller.nodeRoomList.toList(),
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
                                            ? 'Data Node Kandang Diexport Ke PDF.'
                                            : 'Export data node kandang dibatalkan.',
                                      );
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Total Data: ${nodes.length}',
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
                                    ),
                                    DataColumn(
                                      label: SizedBox(
                                        width: tempW,
                                        child: const Center(
                                          child: Text(
                                            'Suhu (°C)',
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
                                        width: humW,
                                        child: const Center(
                                          child: Text(
                                            'Kelembaban (%)',
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
                                        width: lightW,
                                        child: const Center(
                                          child: Text(
                                            'Cahaya (Lux)',
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

class NodeRoomDataTableSource extends DataTableSource {
  final BuildContext context;
  final List<NodeRoomModel> nodes;
  final void Function(NodeRoomModel) onDetail;
  final void Function(NodeRoomModel) onSelectRoom;
  final void Function(NodeRoomModel) onEdit;
  final void Function(NodeRoomModel) onDelete;
  final void Function(NodeRoomModel) onLepasRuangan;
  final HalterNodeController _controller = Get.find<HalterNodeController>();

  NodeRoomDataTableSource({
    required this.context,
    required this.nodes,
    required this.onDetail,
    required this.onSelectRoom,
    required this.onEdit,
    required this.onDelete,
    required this.onLepasRuangan,
  });

  @override
  DataRow getRow(int index) {
    final node = nodes[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Center(child: Text(node.deviceId))),
        DataCell(SizedBox(child: Center(child: Text(node.version)))),
        DataCell(Center(child: Text(node.temperature.toStringAsFixed(2)))),
        DataCell(Center(child: Text(node.humidity.toStringAsFixed(2)))),
        DataCell(Center(child: Text(node.lightIntensity.toStringAsFixed(2)))),
        DataCell(
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomButton(
                width: 165,
                height: 38,
                text: 'Riwayat Node',
                backgroundColor: Colors.blue,
                icon: Icons.history,
                borderRadius: 6,
                fontSize: 14,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return RoomNodeDataDialog(deviceId: node.deviceId);
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

              // _controller.isRoomHaveNode(node.deviceId)
              node.deviceId ==
                      _controller.getRoomByNodeId(node.deviceId)?.deviceSerial
                  ? CustomButton(
                      width: 170,
                      height: 38,
                      backgroundColor: Colors.orange,
                      text: 'Lepas Ruangan',
                      icon: Icons.link_off,
                      borderRadius: 6,
                      fontSize: 14,
                      onPressed: () {
                        onLepasRuangan(node);
                      },
                    )
                  : CustomButton(
                      width: 170,
                      height: 38,
                      backgroundColor: AppColors.primary,
                      text: 'Pilih Ruangan',
                      icon: Icons.house_siding_rounded,
                      borderRadius: 6,
                      fontSize: 14,
                      onPressed: () {
                        onSelectRoom(node);
                      },
                    ),
              // CustomButton(
              //   width: 170,
              //   height: 38,
              //   backgroundColor: AppColors.primary,
              //   text: 'Pilih Ruangan',
              //   icon: Icons.house_siding_rounded,
              //   borderRadius: 6,
              //   fontSize: 14,
              //   onPressed: () {
              //     onSelectRoom(node);
              //   },
              // ),
              // CustomButton(
              //   width: 160,
              //   height: 38,
              //   backgroundColor: AppColors.primary,
              //   text: 'Pilih Ruangan',
              //   icon: Icons.house_siding_rounded,
              //   borderRadius: 6,
              //   fontSize: 14,
              //   onPressed: () {
              //     onSelectRoom(node);
              //   },
              // ),
              const SizedBox(width: 6),
              Container(
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: IconButton(
                  icon: const Icon(Icons.edit, color: Colors.amber),
                  tooltip: 'Edit',
                  onPressed: () => onEdit(node),
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
                  onPressed: () {
                    onDelete(node);
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  int get rowCount => nodes.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}

class RoomNodeDataDialog extends StatefulWidget {
  final String deviceId;

  const RoomNodeDataDialog({super.key, required this.deviceId});

  @override
  State<RoomNodeDataDialog> createState() => _RoomNodeDataDialogState();
}

class _RoomNodeDataDialogState extends State<RoomNodeDataDialog> {
  DateTime? tanggalAwal;
  DateTime? tanggalAkhir;
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int? _sortColumnIndex;
  bool _sortAscending = true;
  final DataController _dataController = Get.find<DataController>();
  final HalterNodeController _controller = Get.find<HalterNodeController>();
  final team = DataTeamHalter.getTeam();

  List<NodeRoomDetailModel> get filteredData {
    var data = _dataController.nodeRoomDetailHistory
        .where((d) => d.deviceId == widget.deviceId)
        .toList();
    if (tanggalAwal != null) {
      data = data.where((d) {
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
      data = data.where((d) {
        final tAkhir = DateTime(
          tanggalAkhir!.year,
          tanggalAkhir!.month,
          tanggalAkhir!.day,
        );
        final tData = DateTime(d.time.year, d.time.month, d.time.day);
        return tData.isAtSameMomentAs(tAkhir) || tData.isBefore(tAkhir);
      }).toList();
    }
    return data;
  }

  @override
  void initState() {
    super.initState();
    _dataController.loadNodeRoomDetailHistory();
  }

  void _sort<T extends Comparable>(
    List<NodeRoomDetailModel> data,
    T Function(NodeRoomDetailModel d) getField,
    bool ascending,
  ) {
    data.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
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
                        'Detail Data Node Device ${widget.deviceId}',
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
                  // Tanggal Awal (disabled/readonly, karena NodeRoomModel tidak ada time)
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
                      final success = await _controller
                          .exportNodeRoomDetailExcel(filteredData, team);
                      showAppToast(
                        context: context,
                        type: success
                            ? ToastificationType.success
                            : ToastificationType.error,
                        title: success
                            ? 'Berhasil Export!'
                            : 'Export Dibatalkan!',
                        description: success
                            ? 'Data Detail Node Diexport Ke Excel.'
                            : 'Export data detail node dibatalkan.',
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
                      final success = await _controller.exportNodeRoomDetailPDF(
                        filteredData,
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
                            ? 'Data Detail Node Diexport Ke PDF.'
                            : 'Export data detail node dibatalkan.',
                      );
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Obx(() {
                  final totalData = filteredData.length;
                  return Text(
                    'Total Data: $totalData ',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 12),
            // Tabel data dengan pagination
            Expanded(
              child: Obx(() {
                final allData = _dataController.nodeRoomDetailHistory;
                final filteredData = allData
                    .where((d) => d.deviceId == widget.deviceId)
                    .toList();

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final tableWidth = constraints.maxWidth;
                    final noW = tableWidth * 0.05;
                    final timeW = tableWidth * 0.17;
                    final devIdW = tableWidth * 0.17;
                    final tempW = tableWidth * 0.18;
                    final humidityW = tableWidth * 0.18;
                    final lightW = tableWidth * 0.18;

                    List<NodeRoomDetailModel> sortedData = List.from(
                      filteredData,
                    );
                    if (_sortColumnIndex != null) {
                      switch (_sortColumnIndex!) {
                        case 0:
                          _sort<String>(
                            sortedData,
                            (d) => d.deviceId,
                            _sortAscending,
                          );
                          break;
                        case 1:
                          _sort<DateTime>(
                            sortedData,
                            (d) => d.time,
                            _sortAscending,
                          );
                          break;
                        case 2:
                          _sort<double>(
                            sortedData,
                            (d) => d.temperature,
                            _sortAscending,
                          );
                          break;
                        case 3:
                          _sort<double>(
                            sortedData,
                            (d) => d.humidity,
                            _sortAscending,
                          );
                          break;
                        case 4:
                          _sort<double>(
                            sortedData,
                            (d) => d.lightIntensity,
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
                              width: devIdW,
                              child: const Center(child: Text("ID")),
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
                              width: tempW,
                              child: const Center(child: Text("Suhu (°C)")),
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
                              width: humidityW,
                              child: const Center(
                                child: Text("Kelembapan (%)"),
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
                              width: lightW,
                              child: const Center(
                                child: Text("Indeks Cahaya (Lux)"),
                              ),
                            ),
                            onSort: (columnIndex, ascending) {
                              setState(() {
                                _sortColumnIndex = columnIndex;
                                _sortAscending = ascending;
                              });
                            },
                          ),
                        ],
                        source: NodeRoomDetailDataTableSource(
                          sortedData,
                          noW,
                          timeW,
                          devIdW,
                          tempW,
                          humidityW,
                          lightW,
                        ),
                        rowsPerPage: _rowsPerPage,
                        availableRowsPerPage: const [5, 10, 20, 50, 100],
                        onRowsPerPageChanged: (value) {
                          setState(() {
                            _rowsPerPage = value ?? 5;
                          });
                        },
                        showCheckboxColumn: false,
                      ),
                    );
                  },
                );
              }),
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

class NodeRoomDetailDataTableSource extends DataTableSource {
  final List<NodeRoomDetailModel> data;
  final double noW, timeW, devIdW, tempW, humidityW, lightW;

  NodeRoomDetailDataTableSource(
    this.data,
    this.noW,
    this.timeW,
    this.devIdW,
    this.tempW,
    this.humidityW,
    this.lightW,
  );

  @override
  DataRow getRow(int index) {
    final d = data[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(
          SizedBox(
            width: noW,
            child: Center(child: Text('${index + 1}')),
          ),
        ),
        DataCell(
          SizedBox(
            width: timeW,
            child: Center(
              child: Text(
                d.time != null
                    ? DateFormat('dd-MM-yyyy HH:mm:ss').format(d.time)
                    : "-",
              ),
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: devIdW,
            child: Center(child: Text(d.deviceId)),
          ),
        ),
        DataCell(
          SizedBox(
            width: tempW,
            child: Center(child: Text(d.temperature.toStringAsFixed(2))),
          ),
        ),
        DataCell(
          SizedBox(
            width: humidityW,
            child: Center(child: Text(d.humidity.toStringAsFixed(2))),
          ),
        ),
        DataCell(
          SizedBox(
            width: lightW,
            child: Center(child: Text(d.lightIntensity.toStringAsFixed(2))),
          ),
        ),
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
