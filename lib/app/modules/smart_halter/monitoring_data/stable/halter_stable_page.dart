import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/constants/app_colors.dart';
import 'package:smart_feeder_desktop/app/models/stable_model.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/monitoring_data/stable/halter_stable_controller.dart';
import 'package:smart_feeder_desktop/app/utils/dialog_utils.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_button.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_input.dart';

class HalterStablePage extends StatefulWidget {
  const HalterStablePage({super.key});

  @override
  State<HalterStablePage> createState() => _HalterStablePageState();
}

class _HalterStablePageState extends State<HalterStablePage> {
  final TextEditingController _searchController = TextEditingController();
  final HalterStableController _controller = Get.find<HalterStableController>();

  String _searchText = "";
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int? _sortColumnIndex;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _controller.loadStables();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.trim().toLowerCase();
      });
    });
  }

  List<StableModel> _filteredStables(List<StableModel> stables) {
    if (_searchText.isEmpty) return stables;
    return stables.where((s) {
      return s.stableId.toLowerCase().contains(_searchText) ||
          s.name.toLowerCase().contains(_searchText) ||
          s.address.toLowerCase().contains(_searchText);
    }).toList();
  }

  void _showStableFormModal({
    StableModel? stable,
    required bool isEdit,
    required Function(StableModel) onSubmit,
    BuildContext? parentContext,
  }) async {
    String newId = stable?.stableId ?? '';
    if (!isEdit) {
      // Ambil ID berikutnya dari controller/db
      newId = await _controller.getNextStableId();
    }
    final nameCtrl = TextEditingController(text: stable?.name ?? '');
    final addrCtrl = TextEditingController(text: stable?.address ?? '');

    showCustomDialog(
      context: parentContext ?? context,
      title: isEdit ? 'Edit Kandang' : 'Tambah Kandang',
      icon: isEdit ? Icons.edit : Icons.add_circle_rounded,
      iconColor: isEdit ? Colors.amber : Colors.green,
      showConfirmButton: true,
      confirmText: isEdit ? "Simpan" : "Tambah",
      cancelText: "Batal",
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Hanya tampilkan ID (readonly), tidak bisa diedit/tambah
          if (isEdit || newId.isNotEmpty) ...[
            Row(
              children: [
                const Text(
                  "ID Kandang: ",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                Text(
                  newId,
                  style: TextStyle(
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
            label: "Nama *",
            controller: nameCtrl,
            hint: "Masukkan nama kandang",
          ),
          const SizedBox(height: 16),
          CustomInput(
            label: "Alamat *",
            controller: addrCtrl,
            hint: "Masukkan alamat kandang",
          ),
        ],
      ),
      onConfirm: () {
        if (nameCtrl.text.trim().isEmpty || addrCtrl.text.trim().isEmpty) {
          Get.snackbar(
            "Input Tidak Lengkap",
            "Nama Kandang dan Alamat wajib diisi.",
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
          return;
        }

        final newStable = StableModel(
          stableId: newId,
          name: nameCtrl.text.trim(),
          address: addrCtrl.text.trim(),
        );
        onSubmit(newStable);
      },
    );
  }

  void _showDetailModal(StableModel stable) {
    showCustomDialog(
      context: context,
      title: "Detail Kandang",
      icon: Icons.info_outline,
      iconColor: Colors.blueGrey,
      showConfirmButton: false,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _detailRow("ID", stable.stableId),
          const SizedBox(height: 8),
          _detailRow("Nama", stable.name),
          const SizedBox(height: 8),
          _detailRow("Alamat", stable.address),
        ],
      ),
    );
  }

  // Helper untuk styling row detail
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

  void _confirmDelete(StableModel stable) {
    showCustomDialog(
      context: context,
      title: "Konfirmasi Hapus",
      icon: Icons.delete_forever,
      iconColor: Colors.red,
      message: 'Hapus kandang "${stable.name}"?',
      showConfirmButton: true,
      confirmText: "Hapus",
      cancelText: "Batal",
      onConfirm: () async {
        await _controller.deleteStable(stable.stableId);
      },
    );
  }

  void _sort<T>(
    List<StableModel> stables,
    T Function(StableModel d) getField,
    bool ascending,
  ) {
    stables.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      if (aValue is Comparable && bValue is Comparable) {
        return ascending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
      }
      return 0;
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
                        'Daftar Kandang',
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
                  final stableList = _controller.stableList.toList();
                  final filteredStables = _filteredStables(stableList);

                  if (_sortColumnIndex != null) {
                    switch (_sortColumnIndex!) {
                      case 0:
                        _sort(
                          filteredStables,
                          (d) => d.stableId,
                          _sortAscending,
                        );
                        break;
                      case 1:
                        _sort(filteredStables, (d) => d.name, _sortAscending);
                        break;
                      case 2:
                        _sort(
                          filteredStables,
                          (d) => d.address,
                          _sortAscending,
                        );
                        break;
                    }
                  }

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: CustomInput(
                          label: "Cari Kandang",
                          controller: _searchController,
                          icon: Icons.search,
                          hint: 'Masukkan ID, nama, atau alamat',
                          fontSize: 24,
                        ),
                      ),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final idW = MediaQuery.of(context).size.width * 0.09;
                          final nameW =
                              MediaQuery.of(context).size.width * 0.22;
                          final addressW =
                              MediaQuery.of(context).size.width * 0.22;
                          final actionW =
                              MediaQuery.of(context).size.width * 0.20;

                          return Column(
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
                                    onPressed: () => _showStableFormModal(
                                      isEdit: false,
                                      onSubmit: (StableModel newStable) async {
                                        await _controller.addStable(newStable);
                                      },
                                    ),
                                  ),
                                  const Spacer(),
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
                                      _controller.exportStableExcel(
                                        filteredStables,
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
                                      _controller.exportStablePDF(
                                        filteredStables,
                                      );
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Total Data: ${stableList.length}',
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
                                        width: addressW,
                                        child: const Center(
                                          child: Text(
                                            'Alamat',
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
                                  source: StableDataTableSource(
                                    stables: filteredStables,
                                    onDetail: _showDetailModal,
                                    onEdit: (stable) => _showStableFormModal(
                                      isEdit: true,
                                      stable: stable,
                                      onSubmit: (StableModel newStable) async {
                                        await _controller.updateStable(
                                          newStable,
                                        );
                                      },
                                    ),
                                    onDelete: _confirmDelete,
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
                        },
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

class StableDataTableSource extends DataTableSource {
  final List<StableModel> stables;
  final void Function(StableModel) onDetail;
  final void Function(StableModel) onEdit;
  final void Function(StableModel) onDelete;

  StableDataTableSource({
    required this.stables,
    required this.onDetail,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  DataRow getRow(int index) {
    final stable = stables[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Center(child: Text(stable.stableId))),
        DataCell(Center(child: Text(stable.name))),
        DataCell(Center(child: Text(stable.address))),
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
                onPressed: () => onDetail(stable),
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
                onPressed: () => onEdit(stable),
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
                  onPressed: () => onDelete(stable),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  int get rowCount => stables.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
