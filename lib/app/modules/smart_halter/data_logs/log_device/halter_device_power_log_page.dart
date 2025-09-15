import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smart_feeder_desktop/app/constants/app_colors.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_device_power_log_model.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/data_logs/log_device/halter_device_power_log_controller.dart';
import 'package:smart_feeder_desktop/app/utils/toast_utils.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_button.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_input.dart';
import 'package:toastification/toastification.dart';

class HalterDevicePowerLogPage extends StatefulWidget {
  const HalterDevicePowerLogPage({super.key});

  @override
  State<HalterDevicePowerLogPage> createState() =>
      _HalterDevicePowerLogPageState();
}

class _HalterDevicePowerLogPageState extends State<HalterDevicePowerLogPage> {
  final HalterDevicePowerLogController controller =
      Get.find<HalterDevicePowerLogController>();
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

  List<HalterDevicePowerLogModel> _filteredLogs(
    List<HalterDevicePowerLogModel> logs,
  ) {
    if (_searchText.isEmpty) return logs;
    return logs.where((log) {
      return log.deviceId.toLowerCase().contains(_searchText) ||
          (DateFormat(
            'dd-MM-yyyy HH:mm:ss',
          ).format(log.powerOnTime).toLowerCase().contains(_searchText)) ||
          (log.powerOffTime != null &&
              DateFormat(
                'dd-MM-yyyy HH:mm:ss',
              ).format(log.powerOffTime!).toLowerCase().contains(_searchText));
    }).toList();
  }

  void _sort<T>(
    List<HalterDevicePowerLogModel> logs,
    Comparable<T> Function(HalterDevicePowerLogModel d) getField,
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
                        'Log Device Power',
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
                  final logs = controller.logList.toList();
                  final filteredLogs = _filteredLogs(logs)
                    ..sort(
                      (a, b) => b.powerOnTime.compareTo(a.powerOnTime),
                    ); // urut desc

                  if (_sortColumnIndex != null) {
                    switch (_sortColumnIndex!) {
                      case 0:
                        _sort(filteredLogs, (d) => d.deviceId, _sortAscending);
                        break;
                      case 1:
                        _sort(
                          filteredLogs,
                          (d) => d.powerOnTime,
                          _sortAscending,
                        );
                        break;
                      case 2:
                        _sort(
                          filteredLogs,
                          (d) => d.powerOffTime ?? DateTime(0),
                          _sortAscending,
                        );
                        break;
                      case 3:
                        _sort(
                          filteredLogs,
                          (d) => d.durationOn?.inMinutes ?? 0,
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
                          label: "Cari Log Device Power",
                          controller: _searchController,
                          icon: Icons.search,
                          hint: 'Masukkan Device ID atau Waktu',
                          fontSize: 24,
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Export Data :',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 12),
                          CustomButton(
                            width: MediaQuery.of(context).size.width * 0.1,
                            height: 50,
                            backgroundColor: Colors.green,
                            fontSize: 18,
                            icon: Icons.table_view_rounded,
                            text: 'Export Excel',
                            onPressed: () async {
                              final success = await controller.exportLogExcel(
                                filteredLogs,
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
                                    ? 'Log Power Device Diexport Ke Excel.'
                                    : 'Export log power device dibatalkan.',
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
                              final success = await controller.exportLogPDF(
                                filteredLogs,
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
                                    ? 'Log Power Device Diexport Ke PDF.'
                                    : 'Export log power device dibatalkan.',
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
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
                                width: MediaQuery.of(context).size.width * 0.13,
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
                                width: MediaQuery.of(context).size.width * 0.2,
                                child: const Center(
                                  child: Text(
                                    'Waktu Nyala',
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
                                width: MediaQuery.of(context).size.width * 0.2,
                                child: const Center(
                                  child: Text(
                                    'Waktu Mati',
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
                                width: MediaQuery.of(context).size.width * 0.13,
                                child: const Center(
                                  child: Text(
                                    'Durasi Nyala',
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
                          source: DevicePowerLogDataTableSource(filteredLogs),
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

class DevicePowerLogDataTableSource extends DataTableSource {
  final List<HalterDevicePowerLogModel> logs;

  DevicePowerLogDataTableSource(this.logs);

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
              DateFormat('dd-MM-yyyy HH:mm:ss').format(log.powerOnTime),
            ),
          ),
        ),
        DataCell(
          Center(
            child: Text(
              log.powerOffTime != null
                  ? DateFormat('dd-MM-yyyy HH:mm:ss').format(log.powerOffTime!)
                  : '-',
            ),
          ),
        ),
        DataCell(
          Center(
            child: Text(
              log.durationOn != null
                  ? '${log.durationOn!.inMinutes} menit'
                  : '-',
            ),
          ),
        ),
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
