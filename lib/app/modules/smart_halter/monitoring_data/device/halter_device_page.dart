import 'package:flutter/material.dart';
import 'package:get/get.dart';
// Ganti dengan import model dan widget sesuai project-mu
import 'package:smart_feeder_desktop/app/constants/app_colors.dart';
import 'package:smart_feeder_desktop/app/models/halter_device_model.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/monitoring_data/device/halter_device_controller.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_button.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_input.dart';

class HalterDevicePage extends StatefulWidget {
  const HalterDevicePage({Key? key}) : super(key: key);

  @override
  State<HalterDevicePage> createState() => _HalterDevicePageState();
}

class _HalterDevicePageState extends State<HalterDevicePage> {
  final TextEditingController _searchController = TextEditingController();
  final HalterDeviceController _controller = Get.put(HalterDeviceController());
  late HalterDeviceDataTableSource _dataSource;
  String _searchText = "";
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int? _sortColumnIndex;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _dataSource = HalterDeviceDataTableSource(
      devices: _controller.halterDeviceList,
      getHorseName: _controller.getHorseNameById,
    );
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
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final tableWidth = constraints.maxWidth;
                          // Kolom: [ID, Kuda, Status, Aksi]
                          final idW = tableWidth * 0.25;
                          final horseW = tableWidth * 0.25;
                          final statusW = tableWidth * 0.25;
                          final actionW = tableWidth * 0.21;

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
                                              (d) => d.deviceId,
                                              ascending,
                                            );
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
                                            _dataSource.sort(
                                              (d) => d.horseId ?? '',
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
                                              (d) => d.status.toString(),
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
class HalterDeviceDataTableSource extends DataTableSource {
  List<HalterDeviceModel> devices;
  List<HalterDeviceModel> filteredDevices;
  final String Function(String?) getHorseName;
  int _selectedCount = 0;

  HalterDeviceDataTableSource({
    required this.devices,
    required this.getHorseName,
  }) : filteredDevices = List.from(devices);

  void updateFilter(String searchText) {
    if (searchText.isEmpty) {
      filteredDevices = List.from(devices);
    } else {
      filteredDevices = devices.where((d) {
        return d.deviceId.toLowerCase().contains(searchText) ||
            (d.horseId ?? 'tidak digunakan').toLowerCase().contains(
              searchText,
            ) ||
            d.status.toString().toLowerCase().contains(searchText);
      }).toList();
    }
    notifyListeners();
  }

  void sort<T>(
    Comparable<T> Function(HalterDeviceModel d) getField,
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
        DataCell(Center(child: Text(device.deviceId))),
        DataCell(
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(getHorseName(device.horseId)),
                Text(
                  device.horseId != null
                      ? ' | ${device.horseId.toString()}'
                      : '',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
        DataCell(
          Center(child: Text(device.status == 'on' ? 'Aktif' : 'Tidak Aktif')),
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
  int get rowCount => filteredDevices.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;
}
