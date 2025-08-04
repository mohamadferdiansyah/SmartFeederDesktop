import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/constants/app_colors.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_raw_data_model.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/raw_data/halter_raw_data_controller.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_button.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_input.dart';

class HalterRawDataPage extends StatefulWidget {
  const HalterRawDataPage({super.key});

  @override
  State<HalterRawDataPage> createState() => _HalterRawDataPageState();
}

class _HalterRawDataPageState extends State<HalterRawDataPage> {
  final TextEditingController _searchController = TextEditingController();
  final HalterRawDataController _controller =
      Get.find<HalterRawDataController>();
  late HalterRawDataTableSource _dataSource;
  String _searchText = "";
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int? _sortColumnIndex;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _dataSource = HalterRawDataTableSource(data: _controller.dataSerialList);
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.trim().toLowerCase();
        _controller.setSearchText(_searchText);
        _dataSource.updateFilter(_controller.filteredList);
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
                        'Data Serial Monitor',
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
                    // Filter tanggal dan search box
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: CustomInput(
                            label: "Cari Data",
                            controller: _searchController,
                            icon: Icons.search,
                            hint: 'Masukkan data mentah',
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Filter Tanggal',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: 350,
                              child: Obx(
                                () => TextField(
                                  readOnly: true,
                                  controller: TextEditingController(
                                    text: _controller.selectedDate.value,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: "Filter Tanggal",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: AppColors.primary.withOpacity(
                                          0.5,
                                        ),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: AppColors.primary,
                                        width: 1.5,
                                      ),
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.calendar_today,
                                    ),
                                  ),
                                  onTap: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2023),
                                      lastDate: DateTime(2100),
                                    );
                                    if (picked != null) {
                                      final tgl =
                                          "${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                                      _controller.setSelectedDate(tgl);
                                      _dataSource.updateFilter(
                                        _controller.filteredList,
                                      );
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        CustomButton(
                          text: 'Reset',
                          width: 195,
                          fontSize: 18,
                          height: 48,
                          onPressed: () {
                            _controller.setSelectedDate('');
                            _controller.setSearchText('');
                            _searchController.clear();
                            _dataSource.updateFilter(_controller.filteredList);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
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
                          onPressed: () {
                            _controller.exportRawExcel(
                              _controller.filteredList,
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
                          onPressed: () {
                            _controller.exportRawPDF(_controller.filteredList);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Table
                    Expanded(
                      child: Obx(() {
                        final filteredList = _controller.filteredList;
                        final tableWidth =
                            MediaQuery.of(context).size.width - 72;
                        final noW = tableWidth * 0.04;
                        final dataW = tableWidth * 0.47;
                        final tglW = tableWidth * 0.1;
                        final waktuW = tableWidth * 0.07;
                        final aksiW = tableWidth * 0.12;

                        return Theme(
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
                                  width: noW,
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
                                  width: dataW,
                                  child: const Center(
                                    child: Text(
                                      'Data',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: SizedBox(
                                  width: tglW,
                                  child: const Center(
                                    child: Text(
                                      'Tanggal',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: SizedBox(
                                  width: waktuW,
                                  child: const Center(
                                    child: Text(
                                      'Waktu',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: SizedBox(
                                  width: aksiW,
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
                            source: HalterRawDataTableSource(
                              data: filteredList,
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
                        );
                      }),
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

class HalterRawDataTableSource extends DataTableSource {
  List<HalterRawDataModel> data;
  List<HalterRawDataModel> filteredData;

  HalterRawDataTableSource({required this.data})
    : filteredData = List.from(data);

  void updateFilter(List<HalterRawDataModel> filtered) {
    filteredData = filtered;
    notifyListeners();
  }

  @override
  DataRow getRow(int index) {
    final item = filteredData[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Center(child: Text(item.no.toString()))),
        DataCell(
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(item.data),
          ),
        ),
        DataCell(Center(child: Text(item.tanggal))),
        DataCell(Center(child: Text(item.waktu))),
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
  int get rowCount => filteredData.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
