import 'package:flutter/material.dart';
import 'package:get/get.dart';
// Ganti import berikut sesuai struktur project-mu
import 'package:smart_feeder_desktop/app/constants/app_colors.dart';
import 'package:smart_feeder_desktop/app/models/node_room_model.dart';
import 'package:smart_feeder_desktop/app/models/room_model.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/monitoring_data/room/halter_room_controller.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_button.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_input.dart';

class HalterRoomPage extends StatefulWidget {
  const HalterRoomPage({super.key});

  @override
  State<HalterRoomPage> createState() => _HalterRoomPageState();
}

class _HalterRoomPageState extends State<HalterRoomPage> {
  final TextEditingController _searchController = TextEditingController();
  final HalterRoomController _controller = Get.put(HalterRoomController());
  late RoomDataTableSource _dataSource;
  String _searchText = "";
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int? _sortColumnIndex;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    // Pastikan cctv controller sudah diinisialisasi sebelum HalterRoomController
    _dataSource = RoomDataTableSource(
      context: context,
      rooms: _controller.roomList,
      getCctvNames: _controller.getCctvNames,
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
                        'Daftar Ruangan',
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
                        label: "Cari ruangan",
                        controller: _searchController,
                        icon: Icons.search,
                        hint: 'Masukkan ID, nama, status, jadwal, atau device',
                        fontSize: 24,
                      ),
                    ),
                    // Table
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final tableWidth = constraints.maxWidth;
                          // Kolom: [ID, Nama, Serial, Status, CCTV, Sisa Air, Sisa Pakan, Jadwal, Aksi]
                          final idW = tableWidth * 0.10;
                          final nameW = tableWidth * 0.15;
                          final serialW = tableWidth * 0.15;
                          final statusW = tableWidth * 0.10;
                          final cctvW = tableWidth * 0.30;
                          final actionW = tableWidth * 0.15;

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
                                      onPressed: () {},
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
                                              (d) => d.roomId,
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
                                          width: serialW,
                                          child: const Center(
                                            child: Text(
                                              'Device Serial',
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
                                              (d) => d.deviceSerial,
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
                                              (d) => d.status,
                                              ascending,
                                            );
                                          });
                                        },
                                      ),
                                      DataColumn(
                                        label: SizedBox(
                                          width: cctvW,
                                          child: const Center(
                                            child: Text(
                                              'CCTV',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
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
class RoomDataTableSource extends DataTableSource {
  final BuildContext context;
  List<RoomModel> rooms;
  List<RoomModel> filteredRooms;
  final String Function(List<String>) getCctvNames;
  final HalterRoomController controller = Get.find<HalterRoomController>();
  int _selectedCount = 0;

  RoomDataTableSource({
    required this.rooms,
    required this.getCctvNames,
    required this.context,
  }) : filteredRooms = List.from(rooms);

  void updateFilter(String searchText) {
    if (searchText.isEmpty) {
      filteredRooms = List.from(rooms);
    } else {
      filteredRooms = rooms.where((d) {
        return d.roomId.toLowerCase().contains(searchText) ||
            d.name.toLowerCase().contains(searchText) ||
            d.deviceSerial.toLowerCase().contains(searchText) ||
            d.status.toLowerCase().contains(searchText) ||
            getCctvNames(d.cctvIds).toLowerCase().contains(searchText);
      }).toList();
    }
    notifyListeners();
  }

  void sort<T>(Comparable<T> Function(RoomModel d) getField, bool ascending) {
    filteredRooms.sort((a, b) {
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
    final room = filteredRooms[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Center(child: Text(room.roomId))),
        DataCell(Center(child: Text(room.name))),
        DataCell(Center(child: Text(room.deviceSerial))),
        DataCell(
          Center(child: Text(room.status == 'used' ? 'Aktif' : 'Tidak Aktif')),
        ),
        DataCell(Center(child: Text(getCctvNames(room.cctvIds)))),
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
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => RoomNodeDataDialog(
                      deviceId: room.deviceSerial,
                      allData: controller.nodeRoomList
                          .where((d) => d.deviceId == room.deviceSerial)
                          .toList(),
                    ),
                  );
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
  int get rowCount => filteredRooms.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;
}

class RoomNodeDataDialog extends StatefulWidget {
  final String deviceId;
  final List<NodeRoomModel> allData;

  const RoomNodeDataDialog({
    super.key,
    required this.deviceId,
    required this.allData,
  });

  @override
  State<RoomNodeDataDialog> createState() => _RoomNodeDataDialogState();
}

class _RoomNodeDataDialogState extends State<RoomNodeDataDialog> {
  DateTime? tanggalAwal;
  DateTime? tanggalAkhir;

  List<NodeRoomModel> get filteredData {
    // Filter by deviceId
    var data = widget.allData
        .where((d) => d.deviceId == widget.deviceId)
        .toList();
    // Jika NodeRoomModel punya timestamp, bisa filter tanggal di sini.
    // Namun model sekarang tidak punya field time, jadi filter tanggal diabaikan.
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(32),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              height: 80,
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
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    children: [
                      Text(
                        'Detail Data Node Device ${widget.deviceId}',
                        style: const TextStyle(
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
            // Filter tanggal + Export
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  // Tanggal Awal (disabled/readonly, karena NodeRoomModel tidak ada time)
                  Flexible(
                    child: TextField(
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: "Tanggal Awal",
                        hintText: "Pilih tanggal awal",
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
                        prefixIcon: const Icon(Icons.calendar_today),
                      ),
                      controller: TextEditingController(
                        text: tanggalAwal != null
                            ? "${tanggalAwal!.toIso8601String().split('T').first}"
                            : "",
                      ),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: tanggalAwal ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null)
                          setState(() => tanggalAwal = picked);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Tanggal Akhir
                  Flexible(
                    child: TextField(
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: "Tanggal Akhir",
                        hintText: "Pilih tanggal akhir",
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
                        prefixIcon: const Icon(Icons.calendar_today),
                      ),
                      controller: TextEditingController(
                        text: tanggalAkhir != null
                            ? "${tanggalAkhir!.toIso8601String().split('T').first}"
                            : "",
                      ),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: tanggalAkhir ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null)
                          setState(() => tanggalAkhir = picked);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  CustomButton(
                    onPressed: () {
                      setState(() {});
                    },
                    text: "Pilih Tanggal",
                    width: 150,
                    height: 50,
                    backgroundColor: AppColors.primary,
                    fontSize: 16,
                  ),
                  const SizedBox(width: 8),
                  CustomButton(
                    onPressed: () {
                      setState(() {
                        tanggalAwal = null;
                        tanggalAkhir = null;
                      });
                    },
                    text: "Reset Tanggal",
                    width: 150,
                    height: 50,
                    backgroundColor: Colors.grey,
                  ),
                  const Spacer(),
                  Text('Export Data :', style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 12),
                  CustomButton(
                    width: MediaQuery.of(context).size.width * 0.1,
                    height: 50,
                    backgroundColor: Colors.green,
                    fontSize: 18,
                    icon: Icons.table_view_rounded,
                    text: 'Export Excel',
                    onPressed: () {},
                  ),
                  const SizedBox(width: 12),
                  CustomButton(
                    width: MediaQuery.of(context).size.width * 0.1,
                    height: 50,
                    backgroundColor: Colors.redAccent,
                    fontSize: 18,
                    icon: Icons.picture_as_pdf,
                    text: 'Export PDF',
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Tabel data
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final tableWidth = constraints.maxWidth;
                  final noW = tableWidth * 0.05; // 10%
                  final devIdW = tableWidth * 0.15; // 18%
                  final tempW = tableWidth * 0.15; // 18%
                  final humidityW = tableWidth * 0.15; // 18%
                  final lightW = tableWidth * 0.15; // 18%
                  final timeW = tableWidth * 0.15; // 18%
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: [
                        DataColumn(
                          label: SizedBox(
                            width: noW,
                            child: const Text(
                              "No",
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: devIdW,
                            child: const Text(
                              "Device Id",
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: tempW,
                            child: const Text(
                              "Temperature (°C)",
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: humidityW,
                            child: const Text(
                              "Humidity (%)",
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: lightW,
                            child: const Text(
                              "Light Intensity",
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: timeW,
                            child: const Text(
                              "Time",
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                      rows: List.generate(filteredData.length, (i) {
                        final d = filteredData[i];
                        return DataRow(
                          cells: [
                            DataCell(
                              SizedBox(
                                width: noW,
                                child: Text(
                                  '${i + 1}',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: devIdW,
                                child: Text(
                                  d.deviceId,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: tempW,
                                child: Text(
                                  d.temperature.value.toStringAsFixed(2),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: humidityW,
                                child: Text(
                                  d.humidity.value.toStringAsFixed(2),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: lightW,
                                child: Text(
                                  d.lightIntensity.value.toStringAsFixed(2),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: timeW,
                                child: Text(
                                  d.time != null
                                      ? d.time!
                                            .toIso8601String()
                                            .split('T')[1]
                                            .split('.')[0]
                                      : '-',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  );
                },
              ),
            ),
            // Tombol Tutup
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  text: "Tutup",
                  width: 150,
                  height: 50,
                  backgroundColor: AppColors.primary,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
