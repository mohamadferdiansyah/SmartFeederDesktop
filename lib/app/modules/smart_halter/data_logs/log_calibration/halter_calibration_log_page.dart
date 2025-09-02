import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smart_feeder_desktop/app/constants/app_colors.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_calibration_log_model.dart';
import 'halter_calibration_log_controller.dart';

class HalterCalibrationLogPage extends StatefulWidget {
  const HalterCalibrationLogPage({super.key});

  @override
  State<HalterCalibrationLogPage> createState() =>
      _HalterCalibrationLogPageState();
}

class _HalterCalibrationLogPageState extends State<HalterCalibrationLogPage> {
  final HalterCalibrationLogController controller =
      Get.find<HalterCalibrationLogController>();
  final TextEditingController _searchController = TextEditingController();
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

  List<HalterCalibrationLogModel> _filteredLogs(
    List<HalterCalibrationLogModel> logs,
  ) {
    if (_searchText.isEmpty) return logs;
    return logs.where((log) {
      return log.deviceId.toLowerCase().contains(_searchText) ||
          log.sensorName.toLowerCase().contains(_searchText) ||
          DateFormat(
            'dd-MM-yyyy HH:mm:ss',
          ).format(log.timestamp).toLowerCase().contains(_searchText);
    }).toList();
  }

  void _sort<T>(
    List<HalterCalibrationLogModel> logs,
    Comparable<T> Function(HalterCalibrationLogModel d) getField,
    bool ascending,
  ) {
    logs.sort((a, b) {
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
                        'Log Kalibrasi Halter Device',
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
                  final logs = controller.logs.toList();
                  final filteredLogs = _filteredLogs(logs)
                    ..sort(
                      (a, b) => b.timestamp.compareTo(a.timestamp),
                    ); // urut desc
                    
                  if (_sortColumnIndex != null) {
                    switch (_sortColumnIndex!) {
                      case 0:
                        _sort(filteredLogs, (d) => d.deviceId, _sortAscending);
                        break;
                      case 1:
                        _sort(filteredLogs, (d) => d.timestamp, _sortAscending);
                        break;
                      case 2:
                        _sort(
                          filteredLogs,
                          (d) => d.sensorName,
                          _sortAscending,
                        );
                        break;
                      case 3:
                        _sort(filteredLogs, (d) => d.referensi, _sortAscending);
                        break;
                      case 4:
                        _sort(
                          filteredLogs,
                          (d) => d.sensorValue,
                          _sortAscending,
                        );
                        break;
                      case 5:
                        _sort(
                          filteredLogs,
                          (d) => d.nilaiKalibrasi,
                          _sortAscending,
                        );
                        break;
                    }
                  }

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            labelText: "Cari Log Kalibrasi",
                            hintText: 'Masukkan Device ID, Sensor, atau Waktu',
                            prefixIcon: const Icon(Icons.search),
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
                          ),
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Total Data: ${logs.length}',
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
                                width: MediaQuery.of(context).size.width * 0.07,
                                child: const Center(
                                  child: Text(
                                    'No',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            DataColumn(
                              label: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.1,
                                child: const Center(
                                  child: Text(
                                    'Device ID',
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
                                width: MediaQuery.of(context).size.width * 0.14,
                                child: const Center(
                                  child: Text(
                                    'Timestamp',
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
                                width: MediaQuery.of(context).size.width * 0.14,
                                child: const Center(
                                  child: Text(
                                    'Nama Sensor',
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
                                width: MediaQuery.of(context).size.width * 0.09,
                                child: const Center(
                                  child: Text(
                                    'Data lookup (Referensi)',
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
                                width: MediaQuery.of(context).size.width * 0.09,
                                child: const Center(
                                  child: Text(
                                    'Data Sensor',
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
                                width: MediaQuery.of(context).size.width * 0.09,
                                child: const Center(
                                  child: Text(
                                    'Nilai Kalibrasi',
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
                          ],
                          source: CalibrationLogDataTableSource(filteredLogs),
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
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CalibrationLogDataTableSource extends DataTableSource {
  final List<HalterCalibrationLogModel> logs;

  CalibrationLogDataTableSource(this.logs);

  @override
  DataRow getRow(int index) {
    final log = logs[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Center(child: Text('${index + 1}'))), // Index column
        DataCell(Center(child: Text(log.deviceId))),
        DataCell(
          Center(
            child: Text(
              DateFormat('dd-MM-yyyy HH:mm:ss').format(log.timestamp),
            ),
          ),
        ),
        DataCell(Center(child: Text(log.sensorName))),
        DataCell(Center(child: Text(log.referensi))),
        DataCell(Center(child: Text(log.sensorValue))),
        DataCell(Center(child: Text(log.nilaiKalibrasi))),
      ],
    );
  }

  @override
  int get rowCount => logs.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
