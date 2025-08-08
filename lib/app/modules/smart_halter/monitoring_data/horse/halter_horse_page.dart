import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/constants/app_colors.dart';
import 'package:smart_feeder_desktop/app/models/horse_model.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/monitoring_data/horse/halter_horse_controller.dart';
import 'package:smart_feeder_desktop/app/utils/dialog_utils.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_button.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_input.dart';

class HalterHorsePage extends StatefulWidget {
  const HalterHorsePage({super.key});

  @override
  State<HalterHorsePage> createState() => _HalterHorsePageState();
}

class _HalterHorsePageState extends State<HalterHorsePage> {
  final TextEditingController _searchController = TextEditingController();
  final HalterHorseController _controller = Get.find<HalterHorseController>();
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int? _sortColumnIndex;
  bool _sortAscending = true;
  String _searchText = "";

  @override
  void initState() {
    super.initState();
    _controller.loadHorses();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.trim().toLowerCase();
      });
    });
  }

  // Filter horses untuk search
  List<HorseModel> _filteredHorses(List<HorseModel> horses) {
    if (_searchText.isEmpty) return horses;
    return horses.where((d) {
      return d.horseId.toLowerCase().contains(_searchText) ||
          d.name.toLowerCase().contains(_searchText) ||
          d.type.toLowerCase().contains(_searchText) ||
          d.gender.toLowerCase().contains(_searchText) ||
          d.age.toString().contains(_searchText) ||
          (d.roomId ?? '').toLowerCase().contains(_searchText);
    }).toList();
  }

  // Modal Tambah/Edit Kuda
  void _showHorseFormModal({
    HorseModel? horse,
    required bool isEdit,
    required Function(HorseModel) onSubmit,
    BuildContext? parentContext,
  }) async {
    String newId = horse?.horseId ?? '';
    if (!isEdit) {
      newId = await _controller.getNextHorseId();
    }
    final nameCtrl = TextEditingController(text: horse?.name ?? '');
    String? selectedType = horse?.type;
    String? selectedGender = horse?.gender;
    final ageCtrl = TextEditingController(
      text: horse?.age != null ? horse!.age.toString() : '',
    );
    String? selectedRoomId = horse?.roomId;

    showCustomDialog(
      context: parentContext ?? context,
      title: isEdit ? 'Edit Kuda' : 'Tambah Kuda',
      icon: isEdit ? Icons.edit : Icons.add_circle_rounded,
      iconColor: isEdit ? Colors.amber : Colors.green,
      showConfirmButton: true,
      confirmText: isEdit ? "Simpan" : "Tambah",
      cancelText: "Batal",
      // GUNAKAN StatefulBuilder DI SINI!
      content: StatefulBuilder(
        builder: (context, modalSetState) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isEdit || newId.isNotEmpty) ...[
              Row(
                children: [
                  const Text(
                    "ID Kuda: ",
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
              label: "Nama Kuda (Wajib diisi)",
              controller: nameCtrl,
              hint: "Masukkan nama kuda",
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedType,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: "Jenis Kuda (Wajib diisi)",
              ),
              items: const [
                DropdownMenuItem(value: "local", child: Text("Lokal")),
                DropdownMenuItem(value: "crossbred", child: Text("Crossbred")),
              ],
              onChanged: (v) => modalSetState(() => selectedType = v),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedGender,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: "Gender (Wajib diisi)",
              ),
              items: const [
                DropdownMenuItem(value: "Jantan", child: Text("Jantan")),
                DropdownMenuItem(value: "Betina", child: Text("Betina")),
              ],
              onChanged: (v) => modalSetState(() => selectedGender = v),
            ),
            const SizedBox(height: 16),
            CustomInput(
              label: "Umur (tahun, wajib diisi)",
              controller: ageCtrl,
              hint: "Masukkan umur kuda",
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Obx(() {
              final filteredRooms = _controller.roomList
                  .where((r) => r.horseId == null || r.horseId == '')
                  .toList();
              final selectedValue =
                  filteredRooms.any((r) => r.roomId == selectedRoomId)
                  ? selectedRoomId
                  : null;

              return DropdownButtonFormField<String>(
                value: selectedValue,
                isExpanded: true,
                decoration: const InputDecoration(labelText: "Ruangan"),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text("Tidak Dikandangkan"),
                  ),
                  ...filteredRooms.map(
                    (r) => DropdownMenuItem(
                      value: r.roomId,
                      child: Text("${r.roomId} - ${r.name}"),
                    ),
                  ),
                ],
                onChanged: (v) => modalSetState(() => selectedRoomId = v),
              );
            }),
          ],
        ),
      ),
      onConfirm: () {
        if (nameCtrl.text.trim().isEmpty ||
            selectedType == null ||
            selectedGender == null ||
            selectedType!.isEmpty ||
            selectedGender!.isEmpty ||
            ageCtrl.text.trim().isEmpty) {
          Get.snackbar(
            "Input Tidak Lengkap",
            "Nama, Jenis, Gender, dan Umur wajib diisi.",
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
          return;
        }

        final int? ageInt = int.tryParse(ageCtrl.text.trim());
        if (ageInt == null || ageInt <= 0) {
          Get.snackbar(
            "Input Tidak Valid",
            "Umur harus berupa angka > 0.",
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
          return;
        }

        final newHorse = HorseModel(
          horseId: newId,
          name: nameCtrl.text.trim(),
          type: selectedType!,
          gender: selectedGender!,
          age: ageInt,
          roomId: selectedRoomId,
        );
        onSubmit(newHorse);
      },
    );
  }

  void _showHorseFormModalEdit(
    HorseModel horse,
    Function(HorseModel) onSubmit, {
    BuildContext? parentContext,
  }) async {
    final nameCtrl = TextEditingController(text: horse.name);
    final typeCtrl = TextEditingController(text: horse.type);
    String? selectedGender = horse.gender;
    final ageCtrl = TextEditingController(text: horse.age.toString());
    String? selectedRoomId = horse.roomId;

    showCustomDialog(
      context: parentContext ?? context,
      title: 'Edit Kuda',
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
                "ID Kuda: ",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              Text(
                horse.horseId,
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
            label: "Nama Kuda (Wajib diisi)",
            controller: nameCtrl,
            hint: "Masukkan nama kuda",
          ),
          const SizedBox(height: 16),
          CustomInput(
            label: "Jenis (Wajib diisi)",
            controller: typeCtrl,
            hint: "Masukkan jenis kuda",
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: selectedGender,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: "Gender (Wajib diisi)",
            ),
            items: [
              DropdownMenuItem(value: "Jantan", child: Text("Jantan")),
              DropdownMenuItem(value: "Betina", child: Text("Betina")),
            ],
            onChanged: (v) {
              setState(() {
                selectedGender = v;
              });
            },
          ),
          const SizedBox(height: 16),
          CustomInput(
            label: "Umur (tahun, wajib diisi)",
            controller: ageCtrl,
            hint: "Masukkan umur kuda",
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          Obx(() {
            final filteredRooms = _controller.roomList
                .where(
                  (r) =>
                      r.horseId == null ||
                      r.horseId == '' ||
                      r.roomId == selectedRoomId,
                )
                .toList();

            // Validasi value
            final isValid =
                selectedRoomId == null ||
                filteredRooms.any((r) => r.roomId == selectedRoomId);
            final value = isValid ? selectedRoomId : null;

            return DropdownButtonFormField<String>(
              value: value,
              isExpanded: true,
              decoration: const InputDecoration(labelText: "Ruangan"),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text("Tidak Dikandangkan"),
                ),
                ...filteredRooms.map(
                  (r) => DropdownMenuItem(
                    value: r.roomId,
                    child: Text("${r.roomId} - ${r.name}"),
                  ),
                ),
              ],
              onChanged: (v) {
                setState(() {
                  selectedRoomId = v;
                });
              },
            );
          }),
        ],
      ),
      onConfirm: () {
        if (nameCtrl.text.trim().isEmpty ||
            typeCtrl.text.trim().isEmpty ||
            selectedGender == null ||
            selectedGender!.isEmpty ||
            ageCtrl.text.trim().isEmpty) {
          Get.snackbar(
            "Input Tidak Lengkap",
            "Nama, Jenis, Gender, dan Umur wajib diisi.",
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
          return;
        }

        final int? ageInt = int.tryParse(ageCtrl.text.trim());
        if (ageInt == null || ageInt <= 0) {
          Get.snackbar(
            "Input Tidak Valid",
            "Umur harus berupa angka > 0.",
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
          return;
        }

        final editedHorse = HorseModel(
          horseId: horse.horseId,
          name: nameCtrl.text.trim(),
          type: typeCtrl.text.trim(),
          gender: selectedGender!,
          age: ageInt,
          roomId: selectedRoomId,
        );
        onSubmit(editedHorse);
      },
    );
  }

  void _showDetailModal(HorseModel horse) {
    showCustomDialog(
      context: context,
      title: "Detail Kuda",
      icon: Icons.info_outline,
      iconColor: Colors.blueGrey,
      showConfirmButton: false,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _detailRow("ID", horse.horseId),
          const SizedBox(height: 8),
          _detailRow("Nama", horse.name),
          const SizedBox(height: 8),
          _detailRow("Jenis", horse.type),
          const SizedBox(height: 8),
          _detailRow("Gender", horse.gender),
          const SizedBox(height: 8),
          _detailRow("Umur", horse.age.toString()),
          const SizedBox(height: 8),
          _detailRow("Ruangan", horse.roomId ?? "Tidak Digunakan"),
        ],
      ),
    );
  }

  void _confirmDelete(HorseModel horse) {
    showCustomDialog(
      context: context,
      title: "Konfirmasi Hapus",
      icon: Icons.delete_forever,
      iconColor: Colors.red,
      message: 'Hapus data kuda "${horse.name}"?',
      showConfirmButton: true,
      confirmText: "Hapus",
      cancelText: "Batal",
      onConfirm: () async {
        await _controller.deleteHorse(horse.horseId);
      },
    );
  }

  void _sort<T>(
    List<HorseModel> horses,
    Comparable<T> Function(HorseModel d) getField,
    bool ascending,
  ) {
    horses.sort((a, b) {
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
                        'Daftar Kuda',
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
                        label: "Cari kuda",
                        controller: _searchController,
                        icon: Icons.search,
                        hint: 'Masukkan ID, nama, jenis, gender, umur, ruangan',
                        fontSize: 24,
                      ),
                    ),
                    // Table
                    Expanded(
                      child: Obx(() {
                        List<HorseModel> horses = _filteredHorses(
                          _controller.horseList.toList(),
                        );

                        // Sort
                        if (_sortColumnIndex != null) {
                          switch (_sortColumnIndex!) {
                            case 0:
                              _sort<String>(
                                horses,
                                (d) => d.horseId,
                                _sortAscending,
                              );
                              break;
                            case 1:
                              _sort<String>(
                                horses,
                                (d) => d.name,
                                _sortAscending,
                              );
                              break;
                            case 2:
                              _sort<String>(
                                horses,
                                (d) => d.type,
                                _sortAscending,
                              );
                              break;
                            case 3:
                              _sort<String>(
                                horses,
                                (d) => d.gender,
                                _sortAscending,
                              );
                              break;
                            case 4:
                              _sort<int>(
                                horses,
                                (d) => d.age as Comparable<int>,
                                _sortAscending,
                              );
                              break;
                            case 5:
                              _sort<String>(
                                horses,
                                (d) => d.roomId ?? '',
                                _sortAscending,
                              );
                              break;
                          }
                        }

                        final tableWidth =
                            MediaQuery.of(context).size.width - 72.0;
                        final idW = tableWidth * 0.05;
                        final nameW = tableWidth * 0.10;
                        final typeW = tableWidth * 0.06;
                        final genderW = tableWidth * 0.06;
                        final ageW = tableWidth * 0.06;
                        final roomW = tableWidth * 0.10;
                        final actionW = tableWidth * 0.30;

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
                                    onPressed: () => _showHorseFormModal(
                                      isEdit: false,
                                      onSubmit: (HorseModel newHorse) async {
                                        await _controller.addHorse(newHorse);
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
                                      _controller.exportToExcel(horses);
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
                                      _controller.exportToPDF(horses);
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
                                        width: typeW,
                                        child: const Center(
                                          child: Text(
                                            'Jenis',
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
                                        width: genderW,
                                        child: const Center(
                                          child: Text(
                                            'Gender',
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
                                        width: ageW,
                                        child: const Center(
                                          child: Text(
                                            'Umur',
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
                                        width: roomW,
                                        child: const Center(
                                          child: Text(
                                            'Ruangan',
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
                                  rowsPerPage: _rowsPerPage,
                                  availableRowsPerPage: const [5, 10, 20],
                                  onRowsPerPageChanged: (value) {
                                    setState(() {
                                      _rowsPerPage = value ?? 5;
                                    });
                                  },
                                  showCheckboxColumn: false,
                                  source: HorseDataTableSource(
                                    context: context,
                                    horses: horses,
                                    onDetail: _showDetailModal,
                                    onEdit: (horse) => _showHorseFormModalEdit(
                                      horse,
                                      (editedHorse) async {
                                        await _controller.updateHorse(
                                          editedHorse,
                                        );
                                      },
                                      parentContext: context,
                                    ),
                                    onDelete: _confirmDelete,
                                  ),
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
}

// DataTableSource untuk PaginatedDataTable
class HorseDataTableSource extends DataTableSource {
  final BuildContext context;
  final List<HorseModel> horses;
  final Function(HorseModel) onDetail;
  final Function(HorseModel) onEdit;
  final Function(HorseModel) onDelete;
  int _selectedCount = 0;

  HorseDataTableSource({
    required this.context,
    required this.horses,
    required this.onDetail,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  DataRow getRow(int index) {
    final horse = horses[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Center(child: Text(horse.horseId))),
        DataCell(Center(child: Text(horse.name))),
        DataCell(Center(child: Text(horse.type))),
        DataCell(Center(child: Text(horse.gender))),
        DataCell(Center(child: Text(horse.age.toString()))),
        DataCell(Center(child: Text(horse.roomId ?? "Tidak Digunakan"))),
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
                onPressed: () => onDetail(horse),
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
                onPressed: () => onEdit(horse),
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
                  onPressed: () => onDelete(horse),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  int get rowCount => horses.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;
}
