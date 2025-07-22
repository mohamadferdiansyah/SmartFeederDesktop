import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smart_feeder_desktop/app/constants/app_colors.dart';
import 'package:smart_feeder_desktop/app/models/history_entry_model.dart';
import 'package:smart_feeder_desktop/app/modules/smart_feeder/monitoring_data/history/feeder_history_controller.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_button.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_input.dart';

class FeederHistoryPage extends StatefulWidget {
  const FeederHistoryPage({Key? key}) : super(key: key);

  @override
  State<FeederHistoryPage> createState() => _FeederHistoryPageState();
}

class _FeederHistoryPageState extends State<FeederHistoryPage> {
  final TextEditingController _searchController = TextEditingController();
  late HistoryDataTableSource _dataSource;
  String _searchText = "";
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int? _sortColumnIndex;
  bool _sortAscending = true;
  final FeederHistoryController controller =
      Get.find<FeederHistoryController>();

  @override
  void initState() {
    super.initState();
    _dataSource = HistoryDataTableSource(entries: controller.historyList);
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
                        'Data Riwayat Pengisian',
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
                        label: "Cari riwayat",
                        controller: _searchController,
                        icon: Icons.search,
                        hint: 'Masukkan nama kandang, jadwal, atau tanggal',
                        fontSize: 24,
                      ),
                    ),
                    // Table
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final tableWidth = constraints.maxWidth;
                          // Kolom: [Kandang, Tanggal, Jadwal, Air, Pakan]
                          final stableW = tableWidth * 0.15;
                          final dateW = tableWidth * 0.20;
                          final scheduleW = tableWidth * 0.18;
                          final waterW = tableWidth * 0.10;
                          final feedW = tableWidth * 0.10;
                          final actionW = tableWidth * 0.20;

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
                                              width: stableW,
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
                                                  'Kandang',
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
                                                (e) => e.stableIndex,
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
                                              width: dateW,
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
                                                  'Tanggal',
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
                                                (e) => e.datetime,
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
                                              width: scheduleW,
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
                                                  'Jadwal',
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
                                                (e) => e.scheduleText,
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
                                              width: waterW,
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
                                                  'Air (L)',
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
                                                (e) => e.water,
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
                                              width: feedW,
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
                                                  'Pakan (g)',
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
                                                (e) => e.feed,
                                                ascending,
                                              );
                                            });
                                          },
                                        ),
                                        DataColumn(
                                          label: SizedBox(
                                            width: actionW,
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

// DataTableSource untuk PaginatedDataTable riwayat pengisian
class HistoryDataTableSource extends DataTableSource {
  List<HistoryEntryModel> entries;
  List<HistoryEntryModel> filteredEntries;
  int _selectedCount = 0;
  int? hoveredColumnIndex;

  HistoryDataTableSource({required this.entries})
    : filteredEntries = List.from(entries);

  void updateFilter(String searchText) {
    if (searchText.isEmpty) {
      filteredEntries = List.from(entries);
    } else {
      filteredEntries = entries.where((e) {
        return
        // Kamu bisa ganti sesuai kebutuhan search
        ('Kandang ${e.stableIndex + 1}'.toLowerCase().contains(searchText)) ||
            e.scheduleText.toLowerCase().contains(searchText) ||
            DateFormat(
              'yyyy-MM-dd HH:mm',
            ).format(e.datetime).contains(searchText) ||
            e.water.toString().contains(searchText) ||
            e.feed.toString().contains(searchText);
      }).toList();
    }
    notifyListeners();
  }

  void sort<T>(
    Comparable<T> Function(HistoryEntryModel e) getField,
    bool ascending,
  ) {
    filteredEntries.sort((a, b) {
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
    final entry = filteredEntries[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Center(child: Text('Kandang ${entry.stableIndex + 1}'))),
        DataCell(
          Center(
            child: Text(DateFormat('yyyy-MM-dd HH:mm').format(entry.datetime)),
          ),
        ),
        DataCell(Center(child: Text(entry.scheduleText))),
        DataCell(Center(child: Text(entry.water.toStringAsFixed(1)))),
        DataCell(Center(child: Text(entry.feed.toStringAsFixed(1)))),
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
  int get rowCount => filteredEntries.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;
}
