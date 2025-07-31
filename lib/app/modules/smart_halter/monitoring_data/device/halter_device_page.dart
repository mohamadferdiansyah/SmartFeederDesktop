import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// Ganti dengan import model dan widget sesuai project-mu
import 'package:smart_feeder_desktop/app/constants/app_colors.dart';
import 'package:smart_feeder_desktop/app/models/halter_device_detail_model.dart';
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
      context: context,
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
  final BuildContext context;
  List<HalterDeviceModel> devices;
  List<HalterDeviceModel> filteredDevices;
  final String Function(String?) getHorseName;
  final HalterDeviceController controller = Get.find<HalterDeviceController>();
  int _selectedCount = 0;

  HalterDeviceDataTableSource({
    required this.context,
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
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => HalterRawDataDialog(
                      deviceId: device.deviceId,
                      allData: controller.detailHistory
                          .where((d) => d.deviceId == device.deviceId)
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
  int get rowCount => filteredDevices.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;
}

class HalterRawDataDialog extends StatefulWidget {
  final String deviceId;
  final List<HalterDeviceDetailModel> allData;

  const HalterRawDataDialog({
    super.key,
    required this.deviceId,
    required this.allData,
  });

  @override
  State<HalterRawDataDialog> createState() => _HalterRawDataDialogState();
}

class _HalterRawDataDialogState extends State<HalterRawDataDialog> {
  DateTime? tanggalAwal;
  DateTime? tanggalAkhir;

  List<HalterDeviceDetailModel> get filteredData {
    // Filter by deviceId
    var data = widget.allData
        .where((d) => d.deviceId == widget.deviceId)
        .toList();
    // Filter tanggal jika dipilih
    if (tanggalAwal != null) {
      data = data
          .where((d) => d.time != null && d.time!.isAfter(tanggalAwal!))
          .toList();
    }
    if (tanggalAkhir != null) {
      data = data
          .where((d) => d.time != null && d.time!.isBefore(tanggalAkhir!))
          .toList();
    }
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
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    children: [
                      Text(
                        'Detail Data Raw Device ${widget.deviceId}',
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
            // Filter tanggal + Export
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  // Tanggal Awal
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
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text("No")),
                    DataColumn(label: Text("Device Id")),
                    DataColumn(label: Text("Latitude")),
                    DataColumn(label: Text("Longitude")),
                    DataColumn(label: Text("Altitude")),
                    DataColumn(label: Text("SoG")),
                    DataColumn(label: Text("CoG")),
                    DataColumn(label: Text("AcceX")),
                    DataColumn(label: Text("AcceY")),
                    DataColumn(label: Text("AcceZ")),
                    DataColumn(label: Text("gyroX")),
                    DataColumn(label: Text("gyroY")),
                    DataColumn(label: Text("gyroZ")),
                    DataColumn(label: Text("magX")),
                    DataColumn(label: Text("magY")),
                    DataColumn(label: Text("magZ")),
                    DataColumn(label: Text("Roll")),
                    DataColumn(label: Text("Pitch")),
                    DataColumn(label: Text("Yaw")),
                    DataColumn(label: Text("Arus")),
                    DataColumn(label: Text("Voltase")),
                    DataColumn(label: Text("BPM")),
                    DataColumn(label: Text("SPO")),
                    DataColumn(label: Text("Suhu")),
                    DataColumn(label: Text("Respirasi")),
                    DataColumn(label: Text("Time")),
                  ],
                  rows: List.generate(filteredData.length, (i) {
                    final d = filteredData[i];
                    return DataRow(
                      cells: [
                        DataCell(Text('${i + 1}')),
                        DataCell(Text(d.deviceId)),
                        DataCell(Text('${d.latitude ?? "-"}')),
                        DataCell(Text('${d.longitude ?? "-"}')),
                        DataCell(Text('${d.altitude ?? "-"}')),
                        DataCell(Text('${d.sog ?? "-"}')),
                        DataCell(Text('${d.cog ?? "-"}')),
                        DataCell(Text('${d.acceX ?? "-"}')),
                        DataCell(Text('${d.acceY ?? "-"}')),
                        DataCell(Text('${d.acceZ ?? "-"}')),
                        DataCell(Text('${d.gyroX ?? "-"}')),
                        DataCell(Text('${d.gyroY ?? "-"}')),
                        DataCell(Text('${d.gyroZ ?? "-"}')),
                        DataCell(Text('${d.magX ?? "-"}')),
                        DataCell(Text('${d.magY ?? "-"}')),
                        DataCell(Text('${d.magZ ?? "-"}')),
                        DataCell(Text('${d.roll ?? "-"}')),
                        DataCell(Text('${d.pitch ?? "-"}')),
                        DataCell(Text('${d.yaw ?? "-"}')),
                        DataCell(Text('${d.arus ?? "-"}')),
                        DataCell(Text('${d.voltase ?? "-"}')),
                        DataCell(Text('${d.bpm ?? "-"}')),
                        DataCell(Text('${d.spo ?? "-"}')),
                        DataCell(Text('${d.suhu ?? "-"}')),
                        DataCell(Text('${d.respirasi ?? "-"}')),
                        DataCell(
                          Text(
                            d.time != null ? d.time!.toIso8601String() : "-",
                          ),
                        ),
                      ],
                    );
                  }),
                ),
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
