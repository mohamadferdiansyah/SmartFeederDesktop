import 'package:flutter/material.dart';
import 'package:get/get.dart';
// Ganti import berikut sesuai struktur project-mu
import 'package:smart_feeder_desktop/app/constants/app_colors.dart';
import 'package:smart_feeder_desktop/app/models/halter/node_room_model.dart';
import 'package:smart_feeder_desktop/app/models/room_model.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/monitoring_data/room/halter_room_controller.dart';
import 'package:smart_feeder_desktop/app/utils/dialog_utils.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_button.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_input.dart';

class HalterRoomPage extends StatefulWidget {
  const HalterRoomPage({super.key});

  @override
  State<HalterRoomPage> createState() => _HalterRoomPageState();
}

class _HalterRoomPageState extends State<HalterRoomPage> {
  final TextEditingController _searchController = TextEditingController();
  final HalterRoomController _controller = Get.find<HalterRoomController>();
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int? _sortColumnIndex;
  bool _sortAscending = true;
  String _searchText = "";

  @override
  void initState() {
    super.initState();
    _controller.loadRooms();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.trim().toLowerCase();
      });
    });
  }

  // Filter rooms untuk search
  List<RoomModel> _filteredRooms(List<RoomModel> rooms) {
    if (_searchText.isEmpty) return rooms;
    return rooms.where((d) {
      return d.roomId.toLowerCase().contains(_searchText) ||
          d.name.toLowerCase().contains(_searchText) ||
          (d.deviceSerial?.toLowerCase() ?? '').contains(_searchText) ||
          d.status.toLowerCase().contains(_searchText) ||
          _controller
              .getCctvNames(d.cctvId ?? [])
              .toLowerCase()
              .contains(_searchText);
    }).toList();
  }

  // Modal Tambah/Edit Ruangan (tidak diubah)
  void _showRoomFormModal({
    RoomModel? room,
    required bool isEdit,
    required Function(RoomModel) onSubmit,
    BuildContext? parentContext,
  }) async {
    String newId = room?.roomId ?? '';
    if (!isEdit) {
      newId = await _controller.getNextRoomId();
    }
    final nameCtrl = TextEditingController(text: room?.name ?? '');
    String? selectedStableId = room?.stableId;
    String? selectedDeviceSerial = room?.deviceSerial;
    String? selectedHorseId = room?.horseId;
    String? selectedCctv = room?.cctvId?.isNotEmpty == true
        ? room!.cctvId!.first
        : null;

    showCustomDialog(
      context: parentContext ?? context,
      title: isEdit ? 'Edit Ruangan' : 'Tambah Ruangan',
      icon: isEdit ? Icons.edit : Icons.add_circle_rounded,
      iconColor: isEdit ? Colors.amber : Colors.green,
      showConfirmButton: true,
      confirmText: isEdit ? "Simpan" : "Tambah",
      cancelText: "Batal",
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isEdit || newId.isNotEmpty) ...[
            Row(
              children: [
                const Text(
                  "ID Ruangan: ",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                Text(
                  newId,
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
            label: "Nama Ruangan (Wajib diisi)",
            controller: nameCtrl,
            hint: "Masukkan nama ruangan",
          ),
          const SizedBox(height: 16),
          Obx(() {
            final stableList = _controller.stableList;
            return DropdownButtonFormField<String>(
              value: selectedStableId,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: "Kandang (Wajib diisi)",
              ),
              items: stableList
                  .map(
                    (s) => DropdownMenuItem(
                      value: s.stableId,
                      child: Text("${s.stableId} - ${s.name}"),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                setState(() {
                  selectedStableId = v;
                });
              },
            );
          }),
          const SizedBox(height: 16),
          Obx(() {
            final nodeRoomList = _controller.nodeRoomList;
            return DropdownButtonFormField<String>(
              value: selectedDeviceSerial,
              isExpanded: true,
              decoration: const InputDecoration(labelText: "Device Id"),
              items: nodeRoomList
                  .map(
                    (n) => DropdownMenuItem(
                      value: n.deviceId,
                      child: Text(n.deviceId),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                setState(() {
                  selectedDeviceSerial = v;
                });
              },
            );
          }),
          const SizedBox(height: 16),
          // Obx(() {
          //   final horseList = _controller.horseList;
          //   return DropdownButtonFormField<String>(
          //     value: selectedHorseId,
          //     isExpanded: true,
          //     decoration: const InputDecoration(labelText: "Kuda"),
          //     items: [
          //       ...horseList
          //           .map(
          //             (h) => DropdownMenuItem(
          //               value: h.horseId,
          //               child: Text("${h.horseId} - ${h.name}"),
          //             ),
          //           )
          //           .toList(),
          //     ],
          //     onChanged: (v) {
          //       setState(() {
          //         selectedHorseId = v;
          //       });
          //     },
          //   );
          // }),
          // SizedBox(height: 16),
          Obx(() {
            final cctvList = _controller.cctvList;
            return DropdownButtonFormField<String>(
              value: selectedHorseId,
              isExpanded: true,
              decoration: const InputDecoration(labelText: "CCTV"),
              items: [
                ...cctvList
                    .map(
                      (h) => DropdownMenuItem(
                        value: h.cctvId,
                        child: Text("${h.cctvId} - ${h.ipAddress}"),
                      ),
                    )
                    .toList(),
              ],
              onChanged: (v) {
                setState(() {
                  selectedHorseId = v;
                });
              },
            );
          }),
        ],
      ),
      onConfirm: () {
        if (nameCtrl.text.trim().isEmpty ||
            selectedStableId == null ||
            selectedStableId!.isEmpty) {
          Get.snackbar(
            "Input Tidak Lengkap",
            "Nama Ruangan dan Kandang wajib diisi.",
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
          return;
        }

        final String status =
            (selectedHorseId != null && selectedHorseId!.isNotEmpty)
            ? "used"
            : "available";

        final newRoom = RoomModel(
          roomId: newId,
          name: nameCtrl.text.trim(),
          deviceSerial: selectedDeviceSerial,
          status: status,
          cctvId: selectedCctv != null ? [selectedCctv] : ['Tidak Ada CCTV'],
          stableId: selectedStableId ?? "",
          horseId: selectedHorseId,
          remainingWater: 0,
          remainingFeed: 0,
          waterScheduleType: "",
          feedScheduleType: "",
        );
        onSubmit(newRoom);
      },
    );
  }

  void _showDetailModal(RoomModel room) {
    showCustomDialog(
      context: context,
      title: "Detail Ruangan",
      icon: Icons.info_outline,
      iconColor: Colors.blueGrey,
      showConfirmButton: false,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _detailRow("ID", room.roomId),
          const SizedBox(height: 8),
          _detailRow("Nama", room.name),
          const SizedBox(height: 8),
          _detailRow("Kandang", room.stableId),
          const SizedBox(height: 8),
          _detailRow("Device Id", room.deviceSerial ?? "-"),
          const SizedBox(height: 8),
          _detailRow("Kuda", room.horseId ?? "-"),
          const SizedBox(height: 8),
          _detailRow("Status", room.status),
        ],
      ),
    );
  }

  void _showRoomFormModalEdit(
    RoomModel room,
    Function(RoomModel) onSubmit, {
    BuildContext? parentContext,
  }) async {
    final nameCtrl = TextEditingController(text: room.name);
    String? selectedStableId = room.stableId;
    String? selectedDeviceSerial = room.deviceSerial;
    String? selectedHorseId = room.horseId;
    String? selectedCctv = room.cctvId?.isNotEmpty == true
        ? room.cctvId!.first
        : null;

    showCustomDialog(
      context: parentContext ?? context,
      title: 'Edit Ruangan',
      icon: Icons.edit,
      iconColor: Colors.amber,
      showConfirmButton: true,
      confirmText: "Simpan",
      cancelText: "Batal",
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Text(
                "ID Ruangan: ",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              Text(
                room.roomId,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CustomInput(
            label: "Nama Ruangan (Wajib diisi)",
            controller: nameCtrl,
            hint: "Masukkan nama ruangan",
          ),
          const SizedBox(height: 16),
          Obx(() {
            final stableList = _controller.stableList;
            return DropdownButtonFormField<String>(
              value: selectedStableId,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: "Kandang (Wajib diisi)",
              ),
              items: stableList
                  .map(
                    (s) => DropdownMenuItem(
                      value: s.stableId,
                      child: Text("${s.stableId} - ${s.name}"),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                setState(() {
                  selectedStableId = v;
                });
              },
            );
          }),
          const SizedBox(height: 16),
          Obx(() {
            final nodeRoomList = _controller.nodeRoomList;
            return DropdownButtonFormField<String>(
              value: selectedDeviceSerial,
              isExpanded: true,
              decoration: const InputDecoration(labelText: "Device Id"),
              items: nodeRoomList
                  .map(
                    (n) => DropdownMenuItem(
                      value: n.deviceId,
                      child: Text(n.deviceId),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                setState(() {
                  selectedDeviceSerial = v;
                });
              },
            );
          }),
          const SizedBox(height: 16),
          Obx(() {
            final horseList = _controller.horseList;
            return DropdownButtonFormField<String>(
              value: selectedHorseId,
              isExpanded: true,
              decoration: const InputDecoration(labelText: "Kuda"),
              items: [
                ...horseList
                    .map(
                      (h) => DropdownMenuItem(
                        value: h.horseId,
                        child: Text("${h.horseId} - ${h.name}"),
                      ),
                    )
                    .toList(),
              ],
              onChanged: (v) {
                setState(() {
                  selectedHorseId = v;
                });
              },
            );
          }),
          const SizedBox(height: 16),
          Obx(() {
            final cctvList = _controller.cctvList;
            return DropdownButtonFormField<String>(
              value: selectedCctv,
              isExpanded: true,
              decoration: const InputDecoration(labelText: "CCTV"),
              items: [
                ...cctvList
                    .map(
                      (h) => DropdownMenuItem(
                        value: h.cctvId,
                        child: Text("${h.cctvId} - ${h.ipAddress}"),
                      ),
                    )
                    .toList(),
              ],
              onChanged: (v) {
                setState(() {
                  selectedCctv = v;
                });
              },
            );
          }),
        ],
      ),
      onConfirm: () {
        if (nameCtrl.text.trim().isEmpty ||
            selectedStableId == null ||
            selectedStableId!.isEmpty) {
          Get.snackbar(
            "Input Tidak Lengkap",
            "Nama Ruangan dan Kandang wajib diisi.",
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
          return;
        }

        final String status =
            (selectedHorseId != null && selectedHorseId!.isNotEmpty)
            ? "used"
            : "available";

        final editedRoom = RoomModel(
          roomId: room.roomId,
          name: nameCtrl.text.trim(),
          deviceSerial: selectedDeviceSerial,
          status: status,
          cctvId: selectedCctv != null ? [?selectedCctv] : ['Tidak Ada CCTV'],
          stableId: selectedStableId ?? "",
          horseId: selectedHorseId,
          remainingWater: room.remainingWater,
          remainingFeed: room.remainingFeed,
          waterScheduleType: room.waterScheduleType,
          feedScheduleType: room.feedScheduleType,
        );
        onSubmit(editedRoom);
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

  void _confirmDelete(RoomModel room) {
    showCustomDialog(
      context: context,
      title: "Konfirmasi Hapus",
      icon: Icons.delete_forever,
      iconColor: Colors.red,
      message: 'Hapus ruangan "${room.name}"?',
      showConfirmButton: true,
      confirmText: "Hapus",
      cancelText: "Batal",
      onConfirm: () async {
        await _controller.deleteRoom(room.roomId);
      },
    );
  }

  // Proses sort
  void _sort<T>(
    List<RoomModel> rooms,
    Comparable<T> Function(RoomModel d) getField,
    bool ascending,
  ) {
    rooms.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending
          ? Comparable.compare(aValue, bValue)
          : Comparable.compare(bValue, aValue);
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
                        'Daftar Ruangan',
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
                        label: "Cari ruangan",
                        controller: _searchController,
                        icon: Icons.search,
                        hint: 'Masukkan ID, nama, status, jadwal, atau device',
                        fontSize: 24,
                      ),
                    ),
                    // Table
                    Expanded(
                      child: Obx(() {
                        List<RoomModel> rooms = _filteredRooms(
                          _controller.roomList.toList(),
                        );

                        // Sort
                        if (_sortColumnIndex != null) {
                          switch (_sortColumnIndex!) {
                            case 0:
                              _sort<String>(
                                rooms,
                                (d) => d.roomId,
                                _sortAscending,
                              );
                              break;
                            case 1:
                              _sort<String>(
                                rooms,
                                (d) => d.name,
                                _sortAscending,
                              );
                              break;
                            case 2:
                              _sort<String>(
                                rooms,
                                (d) => d.deviceSerial ?? '',
                                _sortAscending,
                              );
                              break;
                            case 3:
                              _sort<String>(
                                rooms,
                                (d) => d.status,
                                _sortAscending,
                              );
                              break;
                          }
                        }

                        final tableWidth =
                            MediaQuery.of(context).size.width - 72.0;
                        final idW = tableWidth * 0.05;
                        final nameW = tableWidth * 0.10;
                        final serialW = tableWidth * 0.10;
                        final statusW = tableWidth * 0.05;
                        final cctvW = tableWidth * 0.15;
                        final actionW = tableWidth * 0.30;

                        // DataTableSource dibuat ulang setiap build
                        final dataSource = RoomDataTableSource(
                          context: context,
                          rooms: rooms,
                          getCctvNames: _controller.getCctvNames,
                          onDetail: _showDetailModal,
                          onDelete: _confirmDelete,
                          onEdit: (room) =>
                              _showRoomFormModalEdit(room, (editedRoom) async {
                                await _controller.updateRoom(editedRoom);
                              }),
                        );

                        return SingleChildScrollView(
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  CustomButton(
                                    width:
                                        MediaQuery.of(context).size.width * 0.1,
                                    height: 50,
                                    backgroundColor: Colors.green,
                                    fontSize: 18,
                                    icon: Icons.add_circle_rounded,
                                    text: 'Tambah Data',
                                    onPressed: () => _showRoomFormModal(
                                      isEdit: false,
                                      onSubmit: (RoomModel newRoom) async {
                                        await _controller.addRoom(newRoom);
                                      },
                                    ),
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
                                      _controller.exportRoomExcel(
                                        rooms,
                                        _controller.getCctvNames,
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
                                      _controller.exportRoomPDF(
                                        rooms,
                                        _controller.getCctvNames,
                                      );
                                    },
                                  ),
                                ],
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
                                        width: nameW,
                                        child: const Center(
                                          child: Text(
                                            'Nama',
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
                                        width: serialW,
                                        child: const Center(
                                          child: Text(
                                            'Device Id',
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
                                        width: cctvW,
                                        child: const Center(
                                          child: Text(
                                            'CCTV',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
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
// DataTableSource untuk PaginatedDataTable

class RoomDataTableSource extends DataTableSource {
  final BuildContext context;
  final List<RoomModel> rooms;
  final String Function(List<String>) getCctvNames;
  final Function(RoomModel) onDetail;
  final Function(RoomModel) onDelete;
  final Function(RoomModel) onEdit;
  int _selectedCount = 0;
  final HalterRoomController _controller = Get.find<HalterRoomController>();

  RoomDataTableSource({
    required this.context,
    required this.rooms,
    required this.getCctvNames,
    required this.onDetail,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  DataRow getRow(int index) {
    final room = rooms[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Center(child: Text(room.roomId))),
        DataCell(Center(child: Text(room.name))),
        DataCell(Center(child: Text(room.deviceSerial ?? 'Tidak ada'))),
        DataCell(
          Center(child: Text(room.status == 'used' ? 'Terisi' : 'Kosong')),
        ),
        DataCell(Center(child: Text(getCctvNames(room.cctvId ?? [])))),
        DataCell(
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomButton(
                width: 160,
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
                      return RoomNodeDataDialog(
                        deviceId: room.deviceSerial ?? '',
                        allData: _controller.nodeRoomList.toList(),
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
                onPressed: () => onDetail(room),
              ),
              const SizedBox(width: 6),
              CustomButton(
                width: 115,
                height: 38,
                backgroundColor: Colors.amber,
                text: 'Edit',
                icon: Icons.edit,
                borderRadius: 6,
                fontSize: 14,
                onPressed: () => onEdit(room),
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
                  onPressed: () => onDelete(room),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  int get rowCount => rooms.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;
}

class RoomNodeDataDialog extends StatefulWidget {
  final String deviceId;
  final List<NodeRoomModel> allData;

  const RoomNodeDataDialog({
    super.key,
    required this.deviceId,
    required this.allData,
  });

  @override
  State<RoomNodeDataDialog> createState() => _RoomNodeDataDialogState();
}

class _RoomNodeDataDialogState extends State<RoomNodeDataDialog> {
  DateTime? tanggalAwal;
  DateTime? tanggalAkhir;
  final HalterRoomController _controller = Get.find<HalterRoomController>();

  List<NodeRoomModel> get filteredData {
    // Filter by deviceId
    var data = widget.allData
        .where((d) => d.deviceId == widget.deviceId)
        .toList();
    // Jika NodeRoomModel punya timestamp, bisa filter tanggal di sini.
    // Namun model sekarang tidak punya field time, jadi filter tanggal diabaikan.
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
                      _controller.exportNodeRoomExcel(filteredData);
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
                      _controller.exportNodeRoomPDF(filteredData);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Tabel data
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final tableWidth = constraints.maxWidth;
                  final noW = tableWidth * 0.05; // 10%
                  final devIdW = tableWidth * 0.15; // 18%
                  final tempW = tableWidth * 0.15; // 18%
                  final humidityW = tableWidth * 0.15; // 18%
                  final lightW = tableWidth * 0.15; // 18%
                  final timeW = tableWidth * 0.15; // 18%
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: [
                        DataColumn(
                          label: SizedBox(
                            width: noW,
                            child: const Text(
                              "No",
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: devIdW,
                            child: const Text(
                              "Device Id",
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: tempW,
                            child: const Text(
                              "Temperature (°C)",
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: humidityW,
                            child: const Text(
                              "Humidity (%)",
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: lightW,
                            child: const Text(
                              "Light Intensity",
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: timeW,
                            child: const Text(
                              "Time",
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                      rows: List.generate(filteredData.length, (i) {
                        final d = filteredData[i];
                        return DataRow(
                          cells: [
                            DataCell(
                              SizedBox(
                                width: noW,
                                child: Text(
                                  '${i + 1}',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: devIdW,
                                child: Text(
                                  d.deviceId,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: tempW,
                                child: Text(
                                  d.temperature.toStringAsFixed(2),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: humidityW,
                                child: Text(
                                  d.humidity.toStringAsFixed(2),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: lightW,
                                child: Text(
                                  d.lightIntensity.toStringAsFixed(2),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: timeW,
                                child: Text(
                                  d.time != null
                                      ? d.time!
                                            .toIso8601String()
                                            .split('T')[1]
                                            .split('.')[0]
                                      : '-',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
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
