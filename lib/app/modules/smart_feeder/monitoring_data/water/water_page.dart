import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/models/water_model.dart';
import 'package:smart_feeder_desktop/app/modules/smart_feeder/monitoring_data/water/water_contorller.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_button.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_input.dart';
import 'package:smart_feeder_desktop/app/constants/app_colors.dart';

class WaterPage extends StatefulWidget {
  const WaterPage({Key? key}) : super(key: key);

  @override
  State<WaterPage> createState() => _WaterPageState();
}

class _WaterPageState extends State<WaterPage> {
  final TextEditingController _searchController = TextEditingController();
  final WaterContorller _controller = Get.put(WaterContorller());
  late WaterStockDataTableSource _dataSource;
  String _searchText = "";
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int? _sortColumnIndex;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _dataSource = WaterStockDataTableSource(stocks: _controller.waterList);
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
                        'Data Air',
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
                        label: "Cari data air",
                        controller: _searchController,
                        icon: Icons.search,
                        hint: 'Masukkan ID, sumber, status, volume, tanggal',
                        fontSize: 24,
                      ),
                    ),
                    // Table
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final tableWidth = constraints.maxWidth;
                          // Kolom: [ID, Sumber Air, Volume, Tanggal Masuk, Status, Aksi]
                          final idW = tableWidth * 0.20;
                          final sourceNameW = tableWidth * 0.25;
                          final volumeW = tableWidth * 0.25;
                          final actionW = tableWidth * 0.26;

                          return SingleChildScrollView(
                            child: Theme(
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
                                      SizedBox(width: 12),
                                      CustomButton(
                                        width:
                                            MediaQuery.of(context).size.width *
                                            0.15,
                                        height: 70,
                                        backgroundColor: Colors.blue,
                                        fontSize: 24,
                                        icon: Icons.add_rounded,
                                        text: 'Tambah Data',
                                        onPressed: () {},
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 12),
                                  PaginatedDataTable(
                                    columnSpacing: 0,
                                    horizontalMargin: 0,
                                    sortColumnIndex: _sortColumnIndex,
                                    sortAscending: _sortAscending,
                                    columns: [
                                      DataColumn(
                                        label: SizedBox(
                                          width: idW,
                                          child: Center(
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
                                              (d) => d.waterId,
                                              ascending,
                                            );
                                          });
                                        },
                                      ),
                                      DataColumn(
                                        label: SizedBox(
                                          width: sourceNameW,
                                          child: Center(
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
                                            _dataSource.sort(
                                              (d) => d.name,
                                              ascending,
                                            );
                                          });
                                        },
                                      ),
                                      DataColumn(
                                        label: SizedBox(
                                          width: volumeW,
                                          child: Center(
                                            child: Text(
                                              'Volume (L)',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        numeric: true,
                                        onSort: (columnIndex, ascending) {
                                          setState(() {
                                            _sortColumnIndex = columnIndex;
                                            _sortAscending = ascending;
                                            _dataSource.sort(
                                              (d) => d.stock,
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
class WaterStockDataTableSource extends DataTableSource {
  List<WaterModel> stocks;
  List<WaterModel> filteredStocks;
  int _selectedCount = 0;

  WaterStockDataTableSource({required this.stocks})
    : filteredStocks = List.from(stocks);

  void updateFilter(String searchText) {
    if (searchText.isEmpty) {
      filteredStocks = List.from(stocks);
    } else {
      filteredStocks = stocks.where((d) {
        return d.waterId.toLowerCase().contains(searchText) ||
            d.name.toLowerCase().contains(searchText) ||
            d.stock.toString().contains(searchText);
      }).toList();
    }
    notifyListeners();
  }

  void sort<T>(Comparable<T> Function(WaterModel d) getField, bool ascending) {
    filteredStocks.sort((a, b) {
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
    final d = filteredStocks[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Center(child: Text(d.waterId))),
        DataCell(Center(child: Text(d.name))),
        DataCell(Center(child: Text('${d.stock}'))),
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
  int get rowCount => filteredStocks.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;
}
