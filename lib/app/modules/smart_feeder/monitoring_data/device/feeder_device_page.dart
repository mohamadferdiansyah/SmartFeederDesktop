import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/constants/app_colors.dart';
import 'package:smart_feeder_desktop/app/models/feeder_device_model.dart';
import 'package:smart_feeder_desktop/app/modules/smart_feeder/monitoring_data/device/feeder_device_controller.dart';
import 'package:intl/intl.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_button.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_input.dart';

class FeederDevicePage extends StatefulWidget {
  const FeederDevicePage({Key? key}) : super(key: key);

  @override
  State<FeederDevicePage> createState() => _FeederDevicePageState();
}

class _FeederDevicePageState extends State<FeederDevicePage> {
  final TextEditingController _searchController = TextEditingController();
  final FeederDeviceController _controller = Get.find<FeederDeviceController>();
  late DeviceDataTableSource _dataSource;
  String _searchText = "";
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int? _sortColumnIndex;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _dataSource = DeviceDataTableSource(devices: _controller.devices);
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
                        'Daftar Perangkat',
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
                        hint: 'Masukkan ID, nama, tipe, status, atau tanggal',
                        fontSize: 24,
                      ),
                    ),
                    // Table
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final tableWidth = constraints.maxWidth;
                          // Kolom: [ID, Nama, Tipe, Status, LastActive]
                          // Misal: ID: 15%, Nama: 30%, Tipe: 10%, Status: 10%, LastActive: 25%
                          final idW = tableWidth * 0.10;
                          final nameW = tableWidth * 0.30;
                          final typeW = tableWidth * 0.10;
                          final statusW = tableWidth * 0.10;
                          final lastActiveW = tableWidth * 0.20;
                          final actionW = tableWidth * 0.15;

                          return Expanded(
                            child: SingleChildScrollView(
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
                                  SizedBox(height: 12),
                                  Theme(
                                    data: Theme.of(context).copyWith(
                                      cardColor: Colors
                                          .white, // warna area body & footer PENUH
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
                                      columnSpacing:
                                          0, // karena sudah pakai SizedBox di cell
                                      horizontalMargin: 0,
                                      sortColumnIndex: _sortColumnIndex,
                                      sortAscending: _sortAscending,
                                      columns: [
                                        DataColumn(
                                          label: MouseRegion(
                                            onEnter: (_) => setState(() {
                                              _dataSource.hoveredColumnIndex =
                                                  0;
                                            }),
                                            onExit: (_) => setState(() {
                                              _dataSource.hoveredColumnIndex =
                                                  null;
                                            }),
                                            child: AnimatedContainer(
                                              duration: Duration(
                                                milliseconds: 150,
                                              ),
                                              width: idW,
                                              decoration: BoxDecoration(
                                                color:
                                                    _dataSource
                                                            .hoveredColumnIndex ==
                                                        0
                                                    ? Colors.blue.withOpacity(
                                                        0.15,
                                                      )
                                                    : Colors.transparent,
                                              ),
                                              child: Center(
                                                child: const Text(
                                                  'ID',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          onSort: (columnIndex, ascending) {
                                            setState(() {
                                              _sortColumnIndex = columnIndex;
                                              _sortAscending = ascending;
                                              _dataSource.sort(
                                                (d) => d.id,
                                                ascending,
                                              );
                                            });
                                          },
                                        ),
                                        DataColumn(
                                          label: MouseRegion(
                                            onEnter: (_) => setState(() {
                                              _dataSource.hoveredColumnIndex =
                                                  1;
                                            }),
                                            onExit: (_) => setState(() {
                                              _dataSource.hoveredColumnIndex =
                                                  null;
                                            }),
                                            child: AnimatedContainer(
                                              duration: Duration(
                                                milliseconds: 150,
                                              ),
                                              width: nameW,
                                              decoration: BoxDecoration(
                                                color:
                                                    _dataSource
                                                            .hoveredColumnIndex ==
                                                        1
                                                    ? Colors.blue.withOpacity(
                                                        0.15,
                                                      )
                                                    : Colors.transparent,
                                              ),
                                              child: Center(
                                                child: const Text(
                                                  'Nama',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          onSort: (columnIndex, ascending) {
                                            setState(() {
                                              _sortColumnIndex = columnIndex;
                                              _sortAscending = ascending;
                                              _dataSource.sort(
                                                (d) => d.id,
                                                ascending,
                                              );
                                            });
                                          },
                                        ),
                                        DataColumn(
                                          label: MouseRegion(
                                            onEnter: (_) => setState(() {
                                              _dataSource.hoveredColumnIndex =
                                                  2;
                                            }),
                                            onExit: (_) => setState(() {
                                              _dataSource.hoveredColumnIndex =
                                                  null;
                                            }),
                                            child: AnimatedContainer(
                                              duration: Duration(
                                                milliseconds: 150,
                                              ),
                                              width: typeW,
                                              decoration: BoxDecoration(
                                                color:
                                                    _dataSource
                                                            .hoveredColumnIndex ==
                                                        2
                                                    ? Colors.blue.withOpacity(
                                                        0.15,
                                                      )
                                                    : Colors.transparent,
                                              ),
                                              child: Center(
                                                child: const Text(
                                                  'Tipe',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          onSort: (columnIndex, ascending) {
                                            setState(() {
                                              _sortColumnIndex = columnIndex;
                                              _sortAscending = ascending;
                                              _dataSource.sort(
                                                (d) => d.id,
                                                ascending,
                                              );
                                            });
                                          },
                                        ),
                                        DataColumn(
                                          label: MouseRegion(
                                            onEnter: (_) => setState(() {
                                              _dataSource.hoveredColumnIndex =
                                                  3;
                                            }),
                                            onExit: (_) => setState(() {
                                              _dataSource.hoveredColumnIndex =
                                                  null;
                                            }),
                                            child: AnimatedContainer(
                                              duration: Duration(
                                                milliseconds: 150,
                                              ),
                                              width: statusW,
                                              decoration: BoxDecoration(
                                                color:
                                                    _dataSource
                                                            .hoveredColumnIndex ==
                                                        3
                                                    ? Colors.blue.withOpacity(
                                                        0.15,
                                                      )
                                                    : Colors.transparent,
                                              ),
                                              child: Center(
                                                child: const Text(
                                                  'Status',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          onSort: (columnIndex, ascending) {
                                            setState(() {
                                              _sortColumnIndex = columnIndex;
                                              _sortAscending = ascending;
                                              _dataSource.sort(
                                                (d) => d.id,
                                                ascending,
                                              );
                                            });
                                          },
                                        ),
                                        DataColumn(
                                          label: MouseRegion(
                                            onEnter: (_) => setState(() {
                                              _dataSource.hoveredColumnIndex =
                                                  4;
                                            }),
                                            onExit: (_) => setState(() {
                                              _dataSource.hoveredColumnIndex =
                                                  null;
                                            }),
                                            child: AnimatedContainer(
                                              duration: Duration(
                                                milliseconds: 150,
                                              ),
                                              width: lastActiveW,
                                              decoration: BoxDecoration(
                                                color:
                                                    _dataSource
                                                            .hoveredColumnIndex ==
                                                        4
                                                    ? Colors.blue.withOpacity(
                                                        0.15,
                                                      )
                                                    : Colors.transparent,
                                              ),
                                              child: Center(
                                                child: const Text(
                                                  'Last Active',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          onSort: (columnIndex, ascending) {
                                            setState(() {
                                              _sortColumnIndex = columnIndex;
                                              _sortAscending = ascending;
                                              _dataSource.sort(
                                                (d) => d.id,
                                                ascending,
                                              );
                                            });
                                          },
                                        ),
                                        DataColumn(
                                          label: SizedBox(
                                            width: actionW, // atur lebar
                                            child: Center(
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
class DeviceDataTableSource extends DataTableSource {
  List<FeederDeviceModel> devices;
  List<FeederDeviceModel> filteredDevices;
  int _selectedCount = 0;
  int? hoveredColumnIndex;

  DeviceDataTableSource({required this.devices})
    : filteredDevices = List.from(devices);

  void updateFilter(String searchText) {
    if (searchText.isEmpty) {
      filteredDevices = List.from(devices);
    } else {
      filteredDevices = devices.where((d) {
        return d.id.toLowerCase().contains(searchText) ||
            d.name.toLowerCase().contains(searchText) ||
            d.type.toLowerCase().contains(searchText) ||
            d.status.toLowerCase().contains(searchText) ||
            DateFormat(
              'yyyy-MM-dd HH:mm',
            ).format(d.lastActive).contains(searchText);
      }).toList();
    }
    notifyListeners();
  }

  void sort<T>(
    Comparable<T> Function(FeederDeviceModel d) getField,
    bool ascending,
  ) {
    filteredDevices.sort((a, b) {
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
    final device = filteredDevices[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Center(child: Text(device.id))),
        DataCell(Center(child: Text(device.name))),
        DataCell(Center(child: Text(device.type))),
        DataCell(Center(child: Text(device.status))),
        DataCell(
          Center(
            child: Text(
              DateFormat('yyyy-MM-dd HH:mm').format(device.lastActive),
            ),
          ),
        ),
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
              SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
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
  int get rowCount => filteredDevices.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;
}
