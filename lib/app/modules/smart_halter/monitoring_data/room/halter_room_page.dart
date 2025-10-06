import 'package:flutter/material.dart';
import 'package:get/get.dart';
// Ganti import berikut sesuai struktur project-mu
import 'package:smart_feeder_desktop/app/constants/app_colors.dart';
import 'package:smart_feeder_desktop/app/models/room_model.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/monitoring_data/room/halter_room_controller.dart';
import 'package:smart_feeder_desktop/app/utils/dialog_utils.dart';
import 'package:smart_feeder_desktop/app/utils/toast_utils.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_button.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_input.dart';
import 'package:toastification/toastification.dart';

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
    String? selectedCctv1 = room?.cctvId?.isNotEmpty == true
        ? room?.cctvId?.first
        : null;
    String? selectedCctv2 = room?.cctvId != null && room!.cctvId!.length > 1
        ? room.cctvId![1]
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
            label: "Nama Ruangan *",
            controller: nameCtrl,
            hint: "Masukkan nama ruangan",
          ),
          const SizedBox(height: 16),
          Obx(() {
            final stableList = _controller.stableList;
            return DropdownButtonFormField<String>(
              value: selectedStableId,
              isExpanded: true,
              decoration: const InputDecoration(labelText: "Kandang *"),
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
          Row(
            children: [
              SizedBox(
                width: 200,
                child: Obx(() {
                  final allCctvs = _controller.cctvList;
                  final allRooms = _controller.roomList;

                  // Dapatkan semua CCTV yang sudah digunakan oleh room lain
                  final usedCctvIds = <String>{};
                  for (final r in allRooms) {
                    if (r.roomId != newId && r.cctvId != null) {
                      usedCctvIds.addAll(r.cctvId!);
                    }
                  }

                  // Filter CCTV: hanya yang belum digunakan atau yang sedang digunakan room ini
                  final availableCctvs = allCctvs.where((cctv) {
                    return !usedCctvIds.contains(cctv.cctvId) ||
                        cctv.cctvId == selectedCctv1;
                  }).toList();

                  // Validasi selectedCctv1
                  final validIds = availableCctvs.map((c) => c.cctvId).toList();
                  final value =
                      (selectedCctv1 != null &&
                          validIds.contains(selectedCctv1))
                      ? selectedCctv1
                      : null;

                  return DropdownButtonFormField<String>(
                    value: value,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: "CCTV 1"),
                    items: [
                      const DropdownMenuItem(
                        value: 'kosong',
                        child: Text("Tidak Pakai CCTV"),
                      ),
                      ...availableCctvs.map(
                        (h) => DropdownMenuItem(
                          value: h.cctvId,
                          child: Text("${h.cctvId} - ${h.ipAddress}"),
                        ),
                      ),
                    ],
                    onChanged: (v) {
                      setState(() {
                        selectedCctv1 = v;
                      });
                    },
                  );
                }),
              ),
              Spacer(),
              SizedBox(
                width: 200,
                child: Obx(() {
                  final allCctvs = _controller.cctvList;
                  final allRooms = _controller.roomList;

                  // Dapatkan semua CCTV yang sudah digunakan oleh room lain
                  final usedCctvIds = <String>{};
                  for (final r in allRooms) {
                    if (r.roomId != newId && r.cctvId != null) {
                      usedCctvIds.addAll(r.cctvId!);
                    }
                  }

                  // Tambahkan CCTV1 yang dipilih ke daftar yang tidak boleh dipilih untuk CCTV2
                  if (selectedCctv1 != null && selectedCctv1 != 'kosong') {
                    usedCctvIds.add(selectedCctv1!);
                  }

                  // Filter CCTV: hanya yang belum digunakan atau yang sedang digunakan room ini
                  final availableCctvs = allCctvs.where((cctv) {
                    return !usedCctvIds.contains(cctv.cctvId) ||
                        cctv.cctvId == selectedCctv2;
                  }).toList();

                  // Validasi selectedCctv2
                  final validIds = availableCctvs.map((c) => c.cctvId).toList();
                  final value =
                      (selectedCctv2 != null &&
                          validIds.contains(selectedCctv2))
                      ? selectedCctv2
                      : null;

                  return DropdownButtonFormField<String>(
                    value: value,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: "CCTV 2"),
                    items: [
                      const DropdownMenuItem(
                        value: 'kosong',
                        child: Text("Tidak Pakai CCTV"),
                      ),
                      ...availableCctvs.map(
                        (h) => DropdownMenuItem(
                          value: h.cctvId,
                          child: Text("${h.cctvId} - ${h.ipAddress}"),
                        ),
                      ),
                    ],
                    onChanged: (v) {
                      setState(() {
                        selectedCctv2 = v;
                      });
                    },
                  );
                }),
              ),
            ],
          ),
        ],
      ),
      onConfirm: () {
        if (nameCtrl.text.trim().isEmpty ||
            selectedStableId == null ||
            selectedStableId!.isEmpty) {
          showAppToast(
            context: context,
            type: ToastificationType.error,
            title: 'Data Tidak Lengkap!',
            description: 'Lengkapi Data Node Kandang.',
          );
          return;
        }

        final String status =
            (selectedHorseId != null && selectedHorseId.isNotEmpty)
            ? "used"
            : "available";

        final newRoom = RoomModel(
          roomId: newId,
          name: nameCtrl.text.trim(),
          deviceSerial: selectedDeviceSerial,
          status: status,
          cctvId: [
            if (selectedCctv1 != null && selectedCctv1 != 'kosong')
              selectedCctv1!,
            if (selectedCctv2 != null && selectedCctv2 != 'kosong')
              selectedCctv2!,
          ],
          stableId: selectedStableId ?? "",
          horseId: selectedHorseId,
          remainingWater: 'kosong',
          remainingFeed: 0,
        );
        onSubmit(newRoom);
        showAppToast(
          context: context,
          type: ToastificationType.success,
          title: 'Berhasil Ditambahkan!',
          description: 'Data Ruangan Ditambahkan.',
        );
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
    String? selectedCctv1 = room.cctvId != null && room.cctvId!.length > 0
        ? room.cctvId![0]
        : null;
    String? selectedCctv2 = room.cctvId != null && room.cctvId!.length > 1
        ? room.cctvId![1]
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
            label: "Nama Ruangan *",
            controller: nameCtrl,
            hint: "Masukkan nama ruangan",
          ),
          const SizedBox(height: 16),
          Obx(() {
            final stableList = _controller.stableList;
            return DropdownButtonFormField<String>(
              value: selectedStableId,
              isExpanded: true,
              decoration: const InputDecoration(labelText: "Kandang *"),
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
          Row(
            children: [
              SizedBox(
                width: 200,
                child: Obx(() {
                  final allCctvs = _controller.cctvList;
                  final allRooms = _controller.roomList;

                  // Dapatkan semua CCTV yang sudah digunakan oleh room lain (kecuali room yang sedang diedit)
                  final usedCctvIds = <String>{};
                  for (final r in allRooms) {
                    if (r.roomId != room.roomId && r.cctvId != null) {
                      usedCctvIds.addAll(r.cctvId!);
                    }
                  }

                  // Filter CCTV: hanya yang belum digunakan atau yang sedang digunakan room ini
                  final availableCctvs = allCctvs.where((cctv) {
                    return !usedCctvIds.contains(cctv.cctvId) ||
                        cctv.cctvId == selectedCctv1;
                  }).toList();

                  // Validasi selectedCctv1
                  final validIds = availableCctvs.map((c) => c.cctvId).toList();
                  final value =
                      (selectedCctv1 != null &&
                          validIds.contains(selectedCctv1))
                      ? selectedCctv1
                      : null;

                  return DropdownButtonFormField<String>(
                    value: value,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: "CCTV 1"),
                    items: [
                      const DropdownMenuItem(
                        value: 'kosong',
                        child: Text("Tidak Pakai CCTV"),
                      ),
                      ...availableCctvs.map(
                        (h) => DropdownMenuItem(
                          value: h.cctvId,
                          child: Text("${h.cctvId} - ${h.ipAddress}"),
                        ),
                      ),
                    ],
                    onChanged: (v) {
                      setState(() {
                        selectedCctv1 = v;
                      });
                    },
                  );
                }),
              ),
              Spacer(),
              SizedBox(
                width: 200,
                child: Obx(() {
                  final allCctvs = _controller.cctvList;
                  final allRooms = _controller.roomList;

                  // Dapatkan semua CCTV yang sudah digunakan oleh room lain (kecuali room yang sedang diedit)
                  final usedCctvIds = <String>{};
                  for (final r in allRooms) {
                    if (r.roomId != room.roomId && r.cctvId != null) {
                      usedCctvIds.addAll(r.cctvId!);
                    }
                  }

                  // Tambahkan CCTV1 yang dipilih ke daftar yang tidak boleh dipilih untuk CCTV2
                  if (selectedCctv1 != null && selectedCctv1 != 'kosong') {
                    usedCctvIds.add(selectedCctv1!);
                  }

                  // Filter CCTV: hanya yang belum digunakan atau yang sedang digunakan room ini
                  final availableCctvs = allCctvs.where((cctv) {
                    return !usedCctvIds.contains(cctv.cctvId) ||
                        cctv.cctvId == selectedCctv2;
                  }).toList();

                  // Validasi selectedCctv2
                  final validIds = availableCctvs.map((c) => c.cctvId).toList();
                  final value =
                      (selectedCctv2 != null &&
                          validIds.contains(selectedCctv2))
                      ? selectedCctv2
                      : null;

                  return DropdownButtonFormField<String>(
                    value: value,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: "CCTV 2"),
                    items: [
                      const DropdownMenuItem(
                        value: 'kosong',
                        child: Text("Tidak Pakai CCTV"),
                      ),
                      ...availableCctvs.map(
                        (h) => DropdownMenuItem(
                          value: h.cctvId,
                          child: Text("${h.cctvId} - ${h.ipAddress}"),
                        ),
                      ),
                    ],
                    onChanged: (v) {
                      setState(() {
                        selectedCctv2 = v;
                      });
                    },
                  );
                }),
              ),
            ],
          ),
        ],
      ),
      onConfirm: () {
        if (nameCtrl.text.trim().isEmpty ||
            selectedStableId == null ||
            selectedStableId!.isEmpty) {
          showAppToast(
            context: context,
            type: ToastificationType.error,
            title: 'Data Tidak Lengkap!',
            description: 'Lengkapi Data Node Kandang.',
          );
          return;
        }

        final String status =
            (selectedHorseId != null && selectedHorseId.isNotEmpty)
            ? "used"
            : "available";

        final editedRoom = RoomModel(
          roomId: room.roomId,
          name: nameCtrl.text.trim(),
          deviceSerial: selectedDeviceSerial,
          status: status,
          cctvId: [
            if (selectedCctv1 != null && selectedCctv1 != 'kosong')
              selectedCctv1!,
            if (selectedCctv2 != null && selectedCctv2 != 'kosong')
              selectedCctv2!,
          ],
          stableId: selectedStableId ?? "",
          horseId: selectedHorseId,
          remainingWater: room.remainingWater,
          remainingFeed: room.remainingFeed,
        );
        onSubmit(editedRoom);
        showAppToast(
          context: context,
          type: ToastificationType.success,
          title: 'Berhasil Diubah!',
          description: 'Data Ruangan "${room.name}" Diubah.',
        );
      },
    );
  }

  void _lepasKudaDariRuangan(RoomModel room) {
    showCustomDialog(
      context: context,
      title: "Lepas Kuda dari Ruangan",
      icon: Icons.link_off,
      iconColor: Colors.orange,
      message: "Lepaskan kuda dari ruangan ${room.name}?",
      showConfirmButton: true,
      confirmText: "Lepas",
      cancelText: "Batal",
      onConfirm: () async {
        // Set horse_id di room dan room_id di horse jadi null
        await _controller.lepasKudaDariRuangan(room.roomId, room.horseId);
        showAppToast(
          context: context,
          type: ToastificationType.success,
          title: 'Berhasil Dilepas!',
          description: 'Kuda Dikeluarkan Dari Kandang.',
        );
      },
    );
  }

  void _showPilihKudaModal(RoomModel room, Function(String? horseId) onSubmit) {
    String? selectedHorseId = room.horseId;

    showCustomDialog(
      context: context,
      title: "Pilih Kuda",
      icon: Icons.pets_rounded,
      iconColor: AppColors.primary,
      showConfirmButton: true,
      confirmText: "Simpan",
      cancelText: "Batal",
      content: Obx(() {
        // Hanya kuda yang belum dipakai atau memang sedang di room ini
        final availableHorses = _controller.horseList
            .where(
              (h) =>
                  h.roomId == null || h.roomId == '' || h.roomId == room.roomId,
            )
            .toList();

        final selectedValue =
            availableHorses.any((h) => h.horseId == selectedHorseId)
            ? selectedHorseId
            : null;

        return DropdownButtonFormField<String>(
          value: selectedValue,
          isExpanded: true,
          decoration: const InputDecoration(labelText: "Kuda"),
          items: [
            const DropdownMenuItem(value: null, child: Text("Tidak Ada Kuda")),
            ...availableHorses.map(
              (h) => DropdownMenuItem(
                value: h.horseId,
                child: Text("${h.horseId} - ${h.name}"),
              ),
            ),
          ],
          onChanged: (v) => setState(() {
            selectedHorseId = v;
          }),
        );
      }),
      onConfirm: () {
        if (selectedHorseId == null) {
          showAppToast(
            context: context,
            type: ToastificationType.error,
            title: 'Gagal Disimpan!',
            description: 'Pilih Kuda Untuk Disimpan.',
          );
          return;
        }
        onSubmit(selectedHorseId);
        showAppToast(
          context: context,
          type: ToastificationType.success,
          title: 'Berhasil Dimasukan!',
          description: 'Kuda Dimasukan Ke Kandang.',
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
        showAppToast(
          context: context,
          type: ToastificationType.success,
          title: 'Berhasil Dihapus!',
          description: 'Data Ruangan "${room.name}" Dihapus.',
        );
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
                        label: "Cari Ruangan",
                        controller: _searchController,
                        icon: Icons.search,
                        hint:
                            'Masukkan ID, nama, node kandang, status, atau cctv',
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
                            case 4: // Tambahkan case untuk kolom CCTV
                              _sort<String>(
                                rooms,
                                (d) => _controller.getCctvNames(d.cctvId ?? []),
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
                        final cctvW = tableWidth * 0.20;
                        final actionW = tableWidth * 0.25;

                        // DataTableSource dibuat ulang setiap build
                        final dataSource = RoomDataTableSource(
                          context: context,
                          rooms: rooms,
                          getCctvNames: _controller.getCctvNames,
                          onDetail: _showDetailModal,
                          onLepas: _lepasKudaDariRuangan,
                          onDelete: _confirmDelete,
                          onSelectRoom: (room) => _showPilihKudaModal(room, (
                            selectedHorseId,
                          ) async {
                            await _controller.pilihKudaUntukRuangan(
                              room.roomId,
                              selectedHorseId,
                            );
                          }),
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
                                    onPressed: () async {
                                      final success = await _controller
                                          .exportRoomExcel(
                                            rooms,
                                            _controller.getCctvNames,
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
                                            ? 'Data Kandang Diexport Ke Excel.'
                                            : 'Export data kandang dibatalkan.',
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
                                          .exportRoomPDF(
                                            rooms,
                                            _controller.getCctvNames,
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
                                            ? 'Data Kandang Diexport Ke PDF.'
                                            : 'Export data kandang dibatalkan.',
                                      );
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Total Data: ${rooms.length}',
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
                                            'Node Kandang ID',
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
                                      onSort: (columnIndex, ascending) {
                                        // Tambahkan onSort ini
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
// DataTableSource untuk PaginatedDataTable

class RoomDataTableSource extends DataTableSource {
  final BuildContext context;
  final List<RoomModel> rooms;
  final String Function(List<String>) getCctvNames;
  final Function(RoomModel) onDetail;
  final Function(RoomModel) onLepas;
  final Function(RoomModel) onSelectRoom;
  final Function(RoomModel) onDelete;
  final Function(RoomModel) onEdit;
  int _selectedCount = 0;

  RoomDataTableSource({
    required this.context,
    required this.rooms,
    required this.getCctvNames,
    required this.onDetail,
    required this.onLepas,
    required this.onSelectRoom,
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
              room.horseId != null
                  ? CustomButton(
                      width: 150,
                      height: 38,
                      backgroundColor: Colors.orange,
                      text: 'Lepas Kuda',
                      icon: Icons.link_off,
                      borderRadius: 6,
                      fontSize: 14,
                      onPressed: () {
                        onLepas(room);
                      },
                    )
                  : CustomButton(
                      width: 150,
                      height: 38,
                      backgroundColor: AppColors.primary,
                      text: 'Pilih Kuda',
                      icon: Icons.pets_rounded,
                      borderRadius: 6,
                      fontSize: 14,
                      onPressed: () {
                        onSelectRoom(room);
                      },
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
