import 'package:flutter/material.dart';
import 'package:get/get.dart';
// Ganti dengan import model dan widget sesuai project-mu
import 'package:smart_feeder_desktop/app/constants/app_colors.dart';
import 'package:smart_feeder_desktop/app/models/cctv_model.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/monitoring_data/camera/halter_camera_controller.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_button.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_input.dart';

class HalterCameraPage extends StatefulWidget {
  const HalterCameraPage({super.key});

  @override
  State<HalterCameraPage> createState() => _HalterCameraPageState();
}

class _HalterCameraPageState extends State<HalterCameraPage> {
  final TextEditingController _searchController = TextEditingController();
  final HalterCameraController _controller = Get.put(HalterCameraController());
  late CctvDataTableSource _dataSource;
  String _searchText = "";
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int? _sortColumnIndex;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _dataSource = CctvDataTableSource(cctvs: _controller.cctvList);
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.trim().toLowerCase();
        _dataSource.updateFilter(_searchText);
      });
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
                        'Daftar CCTV',
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
                        label: "Cari CCTV",
                        controller: _searchController,
                        icon: Icons.search,
                        hint: 'Masukkan ID, IP Address, Port, Username',
                        fontSize: 24,
                      ),
                    ),
                    // Table
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final tableWidth = constraints.maxWidth;
                          // Kolom: [ID, IP Address, Port, Username, Password, Aksi]
                          final idW = tableWidth * 0.13;
                          final ipW = tableWidth * 0.22;
                          final portW = tableWidth * 0.13;
                          final userW = tableWidth * 0.13;
                          final passW = tableWidth * 0.13;
                          final actionW = tableWidth * 0.20;

                          return SingleChildScrollView(
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    CustomButton(
                                      width:
                                          MediaQuery.of(context).size.width *
                                          0.15,
                                      height: 70,
                                      backgroundColor: Colors.green,
                                      fontSize: 24,
                                      icon: Icons.table_view_rounded,
                                      text: 'Export Excel',
                                      onPressed: () {},
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Theme(
                                  data: Theme.of(context).copyWith(
                                    cardColor: Colors.white,
                                    dataTableTheme: DataTableThemeData(
                                      headingRowColor:
                                          MaterialStateProperty.all(
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
                                            _dataSource.sort(
                                              (d) => d.cctvId,
                                              ascending,
                                            );
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
                                            _dataSource.sort(
                                              (d) => d.ipAddress,
                                              ascending,
                                            );
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
                                            _dataSource.sort(
                                              (d) => d.port,
                                              ascending,
                                            );
                                          });
                                        },
                                      ),
                                      DataColumn(
                                        label: SizedBox(
                                          width: userW,
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
                                            _dataSource.sort(
                                              (d) => d.username,
                                              ascending,
                                            );
                                          });
                                        },
                                      ),
                                      DataColumn(
                                        label: SizedBox(
                                          width: passW,
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
                                            _dataSource.sort(
                                              (d) => d.password,
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
                                    source: _dataSource,
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
                        },
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

// DataTableSource untuk PaginatedDataTable
class CctvDataTableSource extends DataTableSource {
  List<CctvModel> cctvs;
  List<CctvModel> filteredCctvs;
  int _selectedCount = 0;

  CctvDataTableSource({required this.cctvs}) : filteredCctvs = List.from(cctvs);

  void updateFilter(String searchText) {
    if (searchText.isEmpty) {
      filteredCctvs = List.from(cctvs);
    } else {
      filteredCctvs = cctvs.where((d) {
        return d.cctvId.toLowerCase().contains(searchText) ||
            d.ipAddress.toLowerCase().contains(searchText) ||
            d.port.toString().contains(searchText) ||
            d.username.toLowerCase().contains(searchText) ||
            d.password.toLowerCase().contains(searchText);
      }).toList();
    }
    notifyListeners();
  }

  void sort<T>(Comparable<T> Function(CctvModel d) getField, bool ascending) {
    filteredCctvs.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending
          ? Comparable.compare(aValue, bValue)
          : Comparable.compare(bValue, aValue);
    });
    notifyListeners();
  }

  @override
  DataRow getRow(int index) {
    final cctv = filteredCctvs[index];
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
                width: 80,
                height: 30,
                text: 'Detail',
                borderRadius: 6,
                onPressed: () {
                  // TODO: aksi detail
                },
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                tooltip: 'Hapus',
                onPressed: () {
                  // TODO: aksi hapus
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  int get rowCount => filteredCctvs.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;
}
