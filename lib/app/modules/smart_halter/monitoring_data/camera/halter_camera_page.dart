import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/constants/app_colors.dart';
import 'package:smart_feeder_desktop/app/models/halter/cctv_model.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/monitoring_data/camera/halter_camera_controller.dart';
import 'package:smart_feeder_desktop/app/utils/dialog_utils.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_button.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_input.dart';

class HalterCameraPage extends StatefulWidget {
  const HalterCameraPage({super.key});

  @override
  State<HalterCameraPage> createState() => _HalterCameraPageState();
}

class _HalterCameraPageState extends State<HalterCameraPage> {
  final TextEditingController _searchController = TextEditingController();
  final HalterCameraController _controller = Get.find<HalterCameraController>();

  String _searchText = "";
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int? _sortColumnIndex;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _controller.loadCctvs();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.trim().toLowerCase();
      });
    });
  }

  List<CctvModel> _filteredCctv(List<CctvModel> stables) {
    if (_searchText.isEmpty) return stables;
    return stables.where((s) {
      return s.cctvId.toLowerCase().contains(_searchText) ||
          s.ipAddress.toLowerCase().contains(_searchText) ||
          s.port.toString().contains(_searchText) ||
          s.username.toLowerCase().contains(_searchText) ||
          s.password.toLowerCase().contains(_searchText);
    }).toList();
  }

  void _showCctvFormModal({
    CctvModel? cctv,
    required bool isEdit,
    required Function(CctvModel) onSubmit,
    BuildContext? parentContext,
  }) async {
    String newId = cctv?.cctvId ?? '';
    if (!isEdit) {
      // Ambil ID berikutnya dari controller/db
      newId = await _controller.getNextCctvId();
    }
    final ipCtrl = TextEditingController(text: cctv?.ipAddress ?? '');
    final portCtrl = TextEditingController(text: cctv?.port.toString() ?? '');
    final usernameCtrl = TextEditingController(text: cctv?.username ?? '');
    final passwordCtrl = TextEditingController(text: cctv?.password ?? '');

    showCustomDialog(
      context: parentContext ?? context,
      title: isEdit ? 'Edit Cctv' : 'Tambah Cctv',
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
                  "ID Cctv: ",
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
            label: "Ip Address *",
            controller: ipCtrl,
            hint: "Masukkan nama Cctv",
          ),
          const SizedBox(height: 16),
          CustomInput(
            label: "Port *",
            controller: portCtrl,
            hint: "Masukkan Port Cctv",
          ),
          const SizedBox(height: 16),
          CustomInput(
            label: "Username *",
            controller: usernameCtrl,
            hint: "Masukkan Username Cctv",
          ),
          const SizedBox(height: 16),
          CustomInput(
            label: "Password *",
            controller: passwordCtrl,
            hint: "Masukkan Password Cctv",
          ),
        ],
      ),
      onConfirm: () {
        if (ipCtrl.text.trim().isEmpty ||
            portCtrl.text.trim().isEmpty ||
            usernameCtrl.text.trim().isEmpty ||
            passwordCtrl.text.trim().isEmpty) {
          Get.snackbar(
            "Input Tidak Lengkap",
            "Semua field wajib diisi.",
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
          return;
        }

        final newCctv = CctvModel(
          cctvId: newId,
          ipAddress: ipCtrl.text.trim(),
          port: int.tryParse(portCtrl.text.trim()) ?? 0,
          username: usernameCtrl.text.trim(),
          password: passwordCtrl.text.trim(),
        );
        onSubmit(newCctv);
      },
    );
  }

  void _showDetailModal(CctvModel stable) {
    showCustomDialog(
      context: context,
      title: "Detail Cctv",
      icon: Icons.info_outline,
      iconColor: Colors.blueGrey,
      showConfirmButton: false,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _detailRow("ID", stable.cctvId),
          const SizedBox(height: 8),
          _detailRow("IP Address", stable.ipAddress),
          const SizedBox(height: 8),
          _detailRow("Port", stable.port.toString()),
          const SizedBox(height: 8),
          _detailRow("Username", stable.username),
          const SizedBox(height: 8),
          _detailRow("Password", stable.password),
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

  void _confirmDelete(CctvModel cctv) {
    showCustomDialog(
      context: context,
      title: "Konfirmasi Hapus",
      icon: Icons.delete_forever,
      iconColor: Colors.red,
      message: 'Hapus Cctv "${cctv.cctvId}"?',
      showConfirmButton: true,
      confirmText: "Hapus",
      cancelText: "Batal",
      onConfirm: () async {
        await _controller.deleteCctv(cctv.cctvId);
      },
    );
  }

  // void _sort<T extends Comparable>(
  //   List<CctvModel> cctvs,
  //   T Function(CctvModel d) getField,
  //   bool ascending,
  // ) {
  //   setState(() {
  //     cctvs.sort((a, b) {
  //       final aValue = getField(a);
  //       final bValue = getField(b);
  //       return ascending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
  //     });
  //   });
  // }

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
                        'Daftar Cctv',
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
                  final cctvList = _controller.cctvList.toList();
                  final filteredCctvs = _filteredCctv(cctvList);

                  if (_sortColumnIndex != null) {
                    switch (_sortColumnIndex!) {
                      case 0:
                        filteredCctvs.sort(
                          (a, b) => _sortAscending
                              ? a.cctvId.compareTo(b.cctvId)
                              : b.cctvId.compareTo(a.cctvId),
                        );
                        break;
                      case 1:
                        filteredCctvs.sort(
                          (a, b) => _sortAscending
                              ? a.ipAddress.compareTo(b.ipAddress)
                              : b.ipAddress.compareTo(a.ipAddress),
                        );
                        break;
                      case 2:
                        filteredCctvs.sort(
                          (a, b) => _sortAscending
                              ? a.port.compareTo(b.port)
                              : b.port.compareTo(a.port),
                        );
                        break;
                      case 3:
                        filteredCctvs.sort(
                          (a, b) => _sortAscending
                              ? a.username.compareTo(b.username)
                              : b.username.compareTo(a.username),
                        );
                        break;
                      case 4:
                        filteredCctvs.sort(
                          (a, b) => _sortAscending
                              ? a.password.compareTo(b.password)
                              : b.password.compareTo(a.password),
                        );
                        break;
                    }
                  }

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: CustomInput(
                          label: "Cari CCTV",
                          controller: _searchController,
                          icon: Icons.search,
                          hint:
                              'Masukkan ID, IP address, port, username atau password',
                          fontSize: 24,
                        ),
                      ),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final idW = MediaQuery.of(context).size.width * 0.06;
                          final ipW = MediaQuery.of(context).size.width * 0.15;
                          final portW =
                              MediaQuery.of(context).size.width * 0.05;
                          final actionW =
                              MediaQuery.of(context).size.width * 0.26;
                          final passwordW =
                              MediaQuery.of(context).size.width * 0.10;
                          final usernameW =
                              MediaQuery.of(context).size.width * 0.10;

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
                                    onPressed: () => _showCctvFormModal(
                                      isEdit: false,
                                      onSubmit: (CctvModel newCctv) async {
                                        await _controller.addCctv(newCctv);
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
                                      _controller.exportCctvExcel(
                                        filteredCctvs,
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
                                      _controller.exportCctvPDF(filteredCctvs);
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Total Data: ${cctvList.length}',
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
                                        width: ipW,
                                        child: const Center(
                                          child: Text(
                                            'IP Address',
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
                                        width: portW,
                                        child: const Center(
                                          child: Text(
                                            'Port',
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
                                        width: usernameW,
                                        child: const Center(
                                          child: Text(
                                            'Username',
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
                                        width: passwordW,
                                        child: const Center(
                                          child: Text(
                                            'Password',
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
                                  source: CctvDataTableSource(
                                    cctvs: filteredCctvs,
                                    onDetail: _showDetailModal,
                                    onEdit: (cctv) => _showCctvFormModal(
                                      isEdit: true,
                                      cctv: cctv,
                                      onSubmit: (CctvModel newCctv) async {
                                        await _controller.updateCctv(newCctv);
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

class CctvDataTableSource extends DataTableSource {
  final List<CctvModel> cctvs;
  final void Function(CctvModel) onDetail;
  final void Function(CctvModel) onEdit;
  final void Function(CctvModel) onDelete;

  CctvDataTableSource({
    required this.cctvs,
    required this.onDetail,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  DataRow getRow(int index) {
    final cctv = cctvs[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Center(child: Text(cctv.cctvId))),
        DataCell(Center(child: Text(cctv.ipAddress))),
        DataCell(Center(child: Text(cctv.port.toString()))),
        DataCell(Center(child: Text(cctv.username))),
        DataCell(Center(child: Text(cctv.password))),
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
                onPressed: () => onDetail(cctv),
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
                onPressed: () => onEdit(cctv),
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
                  onPressed: () => onDelete(cctv),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  int get rowCount => cctvs.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
