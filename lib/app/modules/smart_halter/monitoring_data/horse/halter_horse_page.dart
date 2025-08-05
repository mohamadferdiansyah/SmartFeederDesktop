import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/constants/app_colors.dart';
import 'package:smart_feeder_desktop/app/models/horse_model.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/monitoring_data/horse/halter_horse_controller.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_button.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_input.dart';

class HalterHorsePage extends StatefulWidget {
  const HalterHorsePage({super.key});

  @override
  State<HalterHorsePage> createState() => _HalterHorsePageState();
}

class _HalterHorsePageState extends State<HalterHorsePage> {
  final TextEditingController _searchController = TextEditingController();
  final HalterHorseController _controller = Get.find<HalterHorseController>();
  late HorseDataTableSource _dataSource;
  String _searchText = "";
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int? _sortColumnIndex;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _dataSource = HorseDataTableSource(horses: _controller.horseList);
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
                        'Daftar Kuda',
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
                        label: "Cari kuda",
                        controller: _searchController,
                        icon: Icons.search,
                        hint: 'Masukkan ID, nama, jenis, gender, atau umur',
                        fontSize: 24,
                      ),
                    ),
                    // Table
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final tableWidth = constraints.maxWidth;
                          // Kolom: [ID, Nama, Jenis, Gender, Umur, Ruangan, Aksi]
                          final idW = tableWidth * 0.10;
                          final nameW = tableWidth * 0.15;
                          final typeW = tableWidth * 0.10;
                          final genderW = tableWidth * 0.10;
                          final ageW = tableWidth * 0.12;
                          final roomW = tableWidth * 0.15;
                          final actionW = tableWidth * 0.20;

                          return SingleChildScrollView(
                            child: Column(
                              children: [
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
                                      width:
                                          MediaQuery.of(context).size.width *
                                          0.1,
                                      height: 50,
                                      backgroundColor: Colors.green,
                                      fontSize: 18,
                                      icon: Icons.table_view_rounded,
                                      text: 'Export Excel',
                                      onPressed: () {
                                        _controller.exportToExcel(
                                          _controller.horseList,
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
                                        _controller.exportToPDF(
                                          _controller.horseList,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
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
                                              (d) => d.horseId,
                                              ascending,
                                            );
                                          });
                                        },
                                      ),
                                      DataColumn(
                                        label: SizedBox(
                                          width: nameW,
                                          child: const Center(
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
                                          width: typeW,
                                          child: const Center(
                                            child: Text(
                                              'Jenis',
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
                                          width: genderW,
                                          child: const Center(
                                            child: Text(
                                              'Gender',
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
                                              (d) => d.gender,
                                              ascending,
                                            );
                                          });
                                        },
                                      ),
                                      DataColumn(
                                        label: SizedBox(
                                          width: ageW,
                                          child: const Center(
                                            child: Text(
                                              'Umur',
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
                                              (d) => d.age,
                                              ascending,
                                            );
                                          });
                                        },
                                      ),
                                      DataColumn(
                                        label: SizedBox(
                                          width: roomW,
                                          child: const Center(
                                            child: Text(
                                              'Ruangan',
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
                                              (d) => d.roomId ?? '',
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
class HorseDataTableSource extends DataTableSource {
  List<HorseModel> horses;
  List<HorseModel> filteredHorses;
  int _selectedCount = 0;

  HorseDataTableSource({required this.horses})
    : filteredHorses = List.from(horses);

  void updateFilter(String searchText) {
    if (searchText.isEmpty) {
      filteredHorses = List.from(horses);
    } else {
      filteredHorses = horses.where((d) {
        return d.horseId.toLowerCase().contains(searchText) ||
            d.name.toLowerCase().contains(searchText) ||
            d.type.toLowerCase().contains(searchText) ||
            d.gender.toLowerCase().contains(searchText) ||
            d.age.toString().toLowerCase().contains(searchText) ||
            (d.roomId ?? '').toLowerCase().contains(searchText);
      }).toList();
    }
    notifyListeners();
  }

  void sort<T>(Comparable<T> Function(HorseModel d) getField, bool ascending) {
    filteredHorses.sort((a, b) {
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
    final horse = filteredHorses[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Center(child: Text(horse.horseId))),
        DataCell(Center(child: Text(horse.name))),
        DataCell(Center(child: Text(horse.type))),
        DataCell(Center(child: Text(horse.gender))),
        DataCell(Center(child: Text(horse.age.toString()))),
        DataCell(Center(child: Text(horse.roomId ?? "Tidak Digunakan"))),
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
  int get rowCount => filteredHorses.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;
}
