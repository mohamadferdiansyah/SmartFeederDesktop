import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smart_feeder_desktop/app/constants/app_colors.dart';
import 'package:smart_feeder_desktop/app/models/walker/walker_history_model.dart';
import 'package:smart_feeder_desktop/app/modules/horse_walker/history/walker_history_controller.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_button.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_input.dart';

class WalkerHistoryPage extends StatefulWidget {
  const WalkerHistoryPage({super.key});

  @override
  State<WalkerHistoryPage> createState() => _WalkerHistoryPageState();
}

class _WalkerHistoryPageState extends State<WalkerHistoryPage> {
  final WalkerHistoryController controller = Get.put(WalkerHistoryController());
  final TextEditingController searchController = TextEditingController();

  String searchText = '';
  int rowsPerPage = 10;
  int sortColumnIndex = 0;
  bool sortAscending = false;

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      setState(() {
        searchText = searchController.text;
      });
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<WalkerHistoryModel> get filteredHistory {
    var history = controller.walkerHistoryList.toList();

    if (searchText.isNotEmpty) {
      history = history.where((h) {
        final horseNames = controller.getHorseNamesByIds(h.horseIds).join(' ');
        return h.deviceId.toLowerCase().contains(searchText.toLowerCase()) ||
            h.status.toLowerCase().contains(searchText.toLowerCase()) ||
            h.statusText.toLowerCase().contains(searchText.toLowerCase()) ||
            horseNames.toLowerCase().contains(searchText.toLowerCase()) ||
            h.formattedTimeStart.contains(searchText) ||
            h.formattedTimeStop.contains(searchText);
      }).toList();
    }

    return history;
  }

  void sortHistory(
    List<WalkerHistoryModel> history,
    int columnIndex,
    bool ascending,
  ) {
    switch (columnIndex) {
      case 0: // Device ID
        history.sort(
          (a, b) => ascending
              ? a.deviceId.compareTo(b.deviceId)
              : b.deviceId.compareTo(a.deviceId),
        );
        break;
      case 1: // Status
        history.sort(
          (a, b) => ascending
              ? a.status.compareTo(b.status)
              : b.status.compareTo(a.status),
        );
        break;
      case 2: // Time Start
        history.sort(
          (a, b) => ascending
              ? a.timeStart.compareTo(b.timeStart)
              : b.timeStart.compareTo(a.timeStart),
        );
        break;
      case 3: // Speed
        history.sort(
          (a, b) => ascending
              ? a.speed.compareTo(b.speed)
              : b.speed.compareTo(a.speed),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header
              Container(
                height: 60,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Riwayat Walker',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // Search and Actions
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: CustomInput(
                              label: "Cari riwayat",
                              controller: searchController,
                              icon: Icons.search,
                              hint:
                                  'Masukkan device ID, status, kuda, atau tanggal',
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 16),
                          CustomButton(
                            width: 120,
                            height: 50,
                            backgroundColor: Colors.orange,
                            icon: Icons.clear_all,
                            text: 'Clear All',
                            onPressed: () {
                              _showClearConfirmation();
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Statistics Cards
                      _buildStatisticsCards(),
                      const SizedBox(height: 20),
                      // Data Table
                      Expanded(
                        child: Obx(() {
                          final history = filteredHistory;
                          sortHistory(history, sortColumnIndex, sortAscending);

                          return SingleChildScrollView(
                            child: PaginatedDataTable(
                              header: Text(
                                'Total: ${history.length} riwayat',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              columns: [
                                DataColumn(
                                  label: const Text(
                                    'Device ID',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onSort: (columnIndex, ascending) {
                                    setState(() {
                                      sortColumnIndex = columnIndex;
                                      sortAscending = ascending;
                                    });
                                  },
                                ),
                                DataColumn(
                                  label: const Text(
                                    'Status',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onSort: (columnIndex, ascending) {
                                    setState(() {
                                      sortColumnIndex = columnIndex;
                                      sortAscending = ascending;
                                    });
                                  },
                                ),
                                const DataColumn(
                                  label: Text(
                                    'Kuda',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const DataColumn(
                                  label: Text(
                                    'Mode & Durasi',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: const Text(
                                    'Kecepatan',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onSort: (columnIndex, ascending) {
                                    setState(() {
                                      sortColumnIndex = columnIndex;
                                      sortAscending = ascending;
                                    });
                                  },
                                ),
                                DataColumn(
                                  label: const Text(
                                    'Waktu Mulai',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onSort: (columnIndex, ascending) {
                                    setState(() {
                                      sortColumnIndex = columnIndex;
                                      sortAscending = ascending;
                                    });
                                  },
                                ),
                                const DataColumn(
                                  label: Text(
                                    'Waktu Selesai',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const DataColumn(
                                  label: Text(
                                    'Durasi Aktual',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                              source: WalkerHistoryDataSource(
                                history: history,
                                controller: controller,
                              ),
                              rowsPerPage: rowsPerPage,
                              availableRowsPerPage: const [5, 10, 20, 50],
                              onRowsPerPageChanged: (value) {
                                setState(() {
                                  rowsPerPage = value ?? 10;
                                });
                              },
                              sortColumnIndex: sortColumnIndex,
                              sortAscending: sortAscending,
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
      ),
    );
  }

  // Update method _buildStatisticsCards
Widget _buildStatisticsCards() {
  return Obx(() {
    final stats = controller.getDetailedStatistics();

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Riwayat',
            stats['TOTAL'].toString(),
            Icons.history,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Sedang Berjalan',
            stats['SEDANG_BERJALAN'].toString(),
            Icons.play_arrow,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Selesai',
            stats['SELESAI'].toString(),
            Icons.check_circle,
            Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Dihentikan',
            stats['DIHENTIKAN'].toString(),
            Icons.stop_circle,
            Colors.red,
          ),
        ),
      ],
    );
  });
}

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showClearConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Semua Riwayat'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus semua riwayat walker?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              controller.clearHistory();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Semua riwayat berhasil dihapus')),
              );
            },
            child: const Text(
              'Hapus Semua',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

class WalkerHistoryDataSource extends DataTableSource {
  final List<WalkerHistoryModel> history;
  final WalkerHistoryController controller;

  WalkerHistoryDataSource({required this.history, required this.controller});

  @override
  DataRow getRow(int index) {
    final item = history[index];
    final horseNames = controller.getHorseNamesByIds(item.horseIds);

    return DataRow(
      cells: [
        DataCell(Text(item.deviceId)),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: item.statusColor.withOpacity(0.1),
              border: Border.all(color: item.statusColor),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  item.statusIcon,
                  color: item.statusColor,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  item.statusText,
                  style: TextStyle(
                    color: item.statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        DataCell(
          Text(
            horseNames.isNotEmpty ? horseNames.join(', ') : 'Tidak ada kuda',
            overflow: TextOverflow.ellipsis,
          ),
        ),
        DataCell(Text('${item.modeText}: ${item.durationText}')),
        DataCell(Text('${item.speed} RPM')),
        DataCell(Text(item.formattedTimeStart)),
        DataCell(Text(item.formattedTimeStop)),
        DataCell(Text(item.actualDurationText)),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => history.length;

  @override
  int get selectedRowCount => 0;
}