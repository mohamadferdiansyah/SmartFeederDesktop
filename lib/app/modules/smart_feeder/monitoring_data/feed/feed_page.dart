import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/constants/app_colors.dart';
import 'package:smart_feeder_desktop/app/models/feed_model.dart';
import 'package:smart_feeder_desktop/app/modules/smart_feeder/monitoring_data/feed/feed_controller.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_button.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_input.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final TextEditingController _searchController = TextEditingController();
  final FeedController _controller = Get.put(FeedController());
  late FeedStockDataTableSource _dataSource;
  String _searchText = "";
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int? _sortColumnIndex;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _dataSource = FeedStockDataTableSource(stocks: _controller.feedList);
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
                        'Data Pakan',
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
                        label: "Cari data pakan",
                        controller: _searchController,
                        icon: Icons.search,
                        hint:
                            'Masukkan ID, nama pakan, supplier, status, tanggal',
                        fontSize: 24,
                      ),
                    ),
                    // Table
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final tableWidth = constraints.maxWidth;
                          // Kolom: [ID, Nama Pakan, Jumlah, Tanggal Masuk, Supplier, Status, Aksi]
                          final idW = tableWidth * 0.15;
                          final feedNameW = tableWidth * 0.20;
                          final qtyW = tableWidth * 0.20;
                          final statusW = tableWidth * 0.20;
                          final actionW = tableWidth * 0.20;

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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        'Export Data :',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      const SizedBox(width: 12),
                                      CustomButton(
                                        width:
                                            MediaQuery.of(context).size.width *
                                            0.1,
                                        height: 50,
                                        backgroundColor: Colors.green,
                                        fontSize: 18,
                                        icon: Icons.table_view_rounded,
                                        text: 'Export Excel',
                                        onPressed: () {
                                          _controller.exportFeedExcel(
                                            _dataSource.filteredStocks,
                                          );
                                        },
                                      ),
                                      const SizedBox(width: 12),
                                      CustomButton(
                                        width:
                                            MediaQuery.of(context).size.width *
                                            0.1,
                                        height: 50,
                                        backgroundColor: Colors.redAccent,
                                        fontSize: 18,
                                        icon: Icons.picture_as_pdf,
                                        text: 'Export PDF',
                                        onPressed: () {
                                          _controller.exportFeedPDF(
                                            _dataSource.filteredStocks,
                                          );
                                        },
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
                                              (d) => d.feedId,
                                              ascending,
                                            );
                                          });
                                        },
                                      ),
                                      DataColumn(
                                        label: SizedBox(
                                          width: feedNameW,
                                          child: Center(
                                            child: Text(
                                              'Nama Pakan',
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
                                          width: qtyW,
                                          child: Center(
                                            child: Text(
                                              'Jumlah (Kg)',
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
                                          width: statusW,
                                          child: Center(
                                            child: Text(
                                              'Tipe',
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
                                              (d) => d.type,
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
class FeedStockDataTableSource extends DataTableSource {
  List<FeedModel> stocks;
  List<FeedModel> filteredStocks;
  int _selectedCount = 0;

  FeedStockDataTableSource({required this.stocks})
    : filteredStocks = List.from(stocks);

  void updateFilter(String searchText) {
    if (searchText.isEmpty) {
      filteredStocks = List.from(stocks);
    } else {
      filteredStocks = stocks.where((d) {
        return d.feedId.toLowerCase().contains(searchText) ||
            d.name.toLowerCase().contains(searchText) ||
            d.type.toString().contains(searchText) ||
            d.stock.toString().contains(searchText);
      }).toList();
    }
    notifyListeners();
  }

  void sort<T>(Comparable<T> Function(FeedModel d) getField, bool ascending) {
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
        DataCell(Center(child: Text(d.feedId))),
        DataCell(Center(child: Text(d.name))),
        DataCell(Center(child: Text('${d.stock}'))),
        DataCell(Center(child: Text(d.type.toString()))),
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
