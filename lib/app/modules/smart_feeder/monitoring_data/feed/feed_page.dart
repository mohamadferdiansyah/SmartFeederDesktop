import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/constants/app_colors.dart';
import 'package:smart_feeder_desktop/app/models/feeder/feed_model.dart';
import 'package:smart_feeder_desktop/app/modules/smart_feeder/monitoring_data/feed/feed_controller.dart';
import 'package:smart_feeder_desktop/app/utils/dialog_utils.dart';
import 'package:smart_feeder_desktop/app/utils/toast_utils.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_button.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_input.dart';
import 'package:toastification/toastification.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final TextEditingController _searchController = TextEditingController();
  final FeedController _controller = Get.find<FeedController>();
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

  List<FeedModel> _filteredFeeds(List<FeedModel> feeds) {
    if (_searchText.isEmpty) return feeds;
    return feeds.where((d) {
      return d.code.toLowerCase().contains(_searchText) ||
          d.brand.toLowerCase().contains(_searchText) ||
          d.type.toLowerCase().contains(_searchText) ||
          d.capacity.toString().contains(_searchText);
    }).toList();
  }

  void _showTambahModal() {
    final codeCtrl = TextEditingController();
    final brandCtrl = TextEditingController();
    final capacityCtrl = TextEditingController();
    String? selectedType;

    showCustomDialog(
      context: context,
      title: 'Tambah Data Pakan',
      icon: Icons.add_circle_rounded,
      iconColor: Colors.green,
      showConfirmButton: true,
      confirmText: "Tambah",
      cancelText: "Batal",
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomInput(
            label: "Kode Pakan *",
            controller: codeCtrl,
            hint: "Masukkan Kode Pakan",
          ),
          const SizedBox(height: 16),
          CustomInput(
            label: "Merk *",
            controller: brandCtrl,
            hint: "Masukkan Merk",
          ),
          const SizedBox(height: 16),
          CustomInput(
            label: "Kapasitas (Kg) *",
            controller: capacityCtrl,
            hint: "Masukkan Kapasitas",
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: selectedType,
            isExpanded: true,
            decoration: const InputDecoration(labelText: "Tipe *"),
            items: const [
              DropdownMenuItem(value: "Pellet", child: Text("Pellet")),
              DropdownMenuItem(value: "Mash", child: Text("Mash")),
              DropdownMenuItem(value: "Crumb", child: Text("Crumb")),
              DropdownMenuItem(value: "Whole", child: Text("Whole")),
            ],
            onChanged: (v) => selectedType = v,
          ),
        ],
      ),
      onConfirm: () async {
        if (codeCtrl.text.trim().isEmpty ||
            brandCtrl.text.trim().isEmpty ||
            capacityCtrl.text.trim().isEmpty ||
            selectedType == null ||
            selectedType!.isEmpty) {
          showAppToast(
            context: context,
            type: ToastificationType.error,
            title: 'Data Tidak Lengkap!',
            description: 'Lengkapi Data Pakan.',
          );
          return;
        }
        final newFeed = FeedModel(
          code: codeCtrl.text.trim(),
          brand: brandCtrl.text.trim(),
          capacity: double.tryParse(capacityCtrl.text.trim()) ?? 0,
          type: selectedType!,
        );
        await _controller.addFeed(newFeed);
        showAppToast(
          context: context,
          type: ToastificationType.success,
          title: 'Berhasil Ditambahkan!',
          description: 'Data Pakan "${codeCtrl.text.trim()}" Ditambahkan.',
        );
      },
    );
  }

  void _showDetailModal(FeedModel feed) {
    showCustomDialog(
      context: context,
      title: "Detail Data Pakan",
      icon: Icons.info_outline,
      iconColor: Colors.blueGrey,
      showConfirmButton: false,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _detailRow("Kode Pakan", feed.code),
          const SizedBox(height: 8),
          _detailRow("Merk", feed.brand),
          const SizedBox(height: 8),
          _detailRow("Kapasitas", "${feed.capacity} Kg"),
          const SizedBox(height: 8),
          _detailRow("Tipe", feed.type),
        ],
      ),
    );
  }

  void _showEditModal(FeedModel feed) {
    final codeCtrl = TextEditingController(text: feed.code);
    final brandCtrl = TextEditingController(text: feed.brand);
    final capacityCtrl = TextEditingController(text: feed.capacity.toString());
    String? selectedType = feed.type;

    showCustomDialog(
      context: context,
      title: 'Edit Data Pakan',
      icon: Icons.edit,
      iconColor: Colors.amber,
      showConfirmButton: true,
      confirmText: "Simpan",
      cancelText: "Batal",
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomInput(
            label: "Kode Pakan *",
            controller: codeCtrl,
            hint: "Masukkan Code",
          ),
          const SizedBox(height: 16),
          CustomInput(
            label: "Merk *",
            controller: brandCtrl,
            hint: "Masukkan Merk",
          ),
          const SizedBox(height: 16),
          CustomInput(
            label: "Kapasitas (Kg) *",
            controller: capacityCtrl,
            hint: "Masukkan Kapasitas",
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: selectedType,
            isExpanded: true,
            decoration: const InputDecoration(labelText: "Tipe *"),
            items: const [
              DropdownMenuItem(value: "Pellet", child: Text("Pellet")),
              DropdownMenuItem(value: "Mash", child: Text("Mash")),
              DropdownMenuItem(value: "Crumb", child: Text("Crumb")),
              DropdownMenuItem(value: "Whole", child: Text("Whole")),
            ],
            onChanged: (v) => selectedType = v,
          ),
        ],
      ),
      onConfirm: () async {
        if (codeCtrl.text.trim().isEmpty ||
            brandCtrl.text.trim().isEmpty ||
            capacityCtrl.text.trim().isEmpty ||
            selectedType == null ||
            selectedType!.isEmpty) {
          showAppToast(
            context: context,
            type: ToastificationType.error,
            title: 'Data Tidak Lengkap!',
            description: 'Lengkapi Data Pakan.',
          );
          return;
        }
        final editedFeed = FeedModel(
          code: codeCtrl.text.trim(),
          brand: brandCtrl.text.trim(),
          capacity: double.tryParse(capacityCtrl.text.trim()) ?? 0,
          type: selectedType!,
        );
        await _controller.updateFeed(editedFeed, feed.code);
        showAppToast(
          context: context,
          type: ToastificationType.success,
          title: 'Berhasil Diubah!',
          description: 'Data Pakan "${feed.code}" Diubah.',
        );
      },
    );
  }

  void _confirmDelete(FeedModel feed) {
    showCustomDialog(
      context: context,
      title: "Konfirmasi Hapus",
      icon: Icons.delete_forever,
      iconColor: Colors.red,
      message: 'Hapus data pakan "${feed.code}"?',
      showConfirmButton: true,
      confirmText: "Hapus",
      cancelText: "Batal",
      onConfirm: () async {
        await _controller.deleteFeed(feed.code);
        showAppToast(
          context: context,
          type: ToastificationType.success,
          title: 'Berhasil Dihapus!',
          description: 'Data Pakan "${feed.code}" Dihapus.',
        );
      },
    );
  }

  Widget _detailRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      children: [
        Text(
          "$label: ",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Flexible(child: Text(value, style: const TextStyle(fontSize: 16))),
      ],
    ),
  );

  void _sort<T>(
    List<FeedModel> feeds,
    Comparable<T> Function(FeedModel d) getField,
    bool ascending,
  ) {
    feeds.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending
          ? Comparable.compare(aValue, bValue)
          : Comparable.compare(bValue, aValue);
    });
  }

  @override
  Widget build(BuildContext context) {
    final tableWidth = MediaQuery.of(context).size.width - 72.0;
    final codeW = tableWidth * 0.15;
    final brandW = tableWidth * 0.13;
    final capacityW = tableWidth * 0.13;
    final typeW = tableWidth * 0.13;
    final actionW = tableWidth * 0.21;

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
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    children: [
                      const Text(
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
                child: Obx(() {
                  final feeds = _filteredFeeds(_controller.feedList);
                  return Column(
                    children: [
                      // Search Box
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: CustomInput(
                          label: "Cari data pakan",
                          controller: _searchController,
                          icon: Icons.search,
                          hint: 'Masukkan Kode Pakan, Merek, Kapasitas, Tipe',
                          fontSize: 24,
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          CustomButton(
                            width: MediaQuery.of(context).size.width * 0.1,
                            height: 50,
                            backgroundColor: Colors.green,
                            fontSize: 18,
                            icon: Icons.add_circle_rounded,
                            text: 'Tambah Data',
                            onPressed: _showTambahModal,
                          ),
                          const Spacer(),
                          const Text(
                            'Export Data :',
                            style: TextStyle(fontSize: 16),
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
                              _controller.exportFeedExcel(feeds);
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
                              _controller.exportFeedPDF(feeds);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Total Data: ${feeds.length}',
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
                                width: codeW,
                                child: const Center(
                                  child: Text(
                                    'Kode Pakan',
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
                                  _sort<String>(
                                    feeds,
                                    (d) => d.code,
                                    ascending,
                                  );
                                });
                              },
                            ),
                            DataColumn(
                              label: SizedBox(
                                width: brandW,
                                child: const Center(
                                  child: Text(
                                    'Merk',
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
                                  _sort<String>(
                                    feeds,
                                    (d) => d.brand,
                                    ascending,
                                  );
                                });
                              },
                            ),
                            DataColumn(
                              label: SizedBox(
                                width: capacityW,
                                child: const Center(
                                  child: Text(
                                    'Kapasitas',
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
                                  _sort<num>(
                                    feeds,
                                    (d) => d.capacity,
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
                                  _sort<String>(
                                    feeds,
                                    (d) => d.type,
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
                          source: FeedDataTableSource(
                            context: context,
                            feeds: feeds,
                            onDetail: _showDetailModal,
                            onEdit: _showEditModal,
                            onDelete: _confirmDelete,
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

class FeedDataTableSource extends DataTableSource {
  final BuildContext context;
  final List<FeedModel> feeds;
  final void Function(FeedModel) onDetail;
  final void Function(FeedModel) onEdit;
  final void Function(FeedModel) onDelete;

  FeedDataTableSource({
    required this.context,
    required this.feeds,
    required this.onDetail,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  DataRow getRow(int index) {
    final d = feeds[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Center(child: Text(d.code))),
        DataCell(Center(child: Text(d.brand))),
        DataCell(Center(child: Text('${d.capacity}'))),
        DataCell(Center(child: Text(d.type))),
        DataCell(
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomButton(
                width: 120,
                height: 38,
                text: 'Detail',
                backgroundColor: Colors.blueGrey,
                icon: Icons.info_outline,
                borderRadius: 6,
                fontSize: 14,
                onPressed: () => onDetail(d),
              ),
              const SizedBox(width: 6),
              Container(
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: IconButton(
                  icon: const Icon(Icons.edit, color: Colors.amber),
                  tooltip: 'Edit',
                  onPressed: () => onEdit(d),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Hapus',
                  onPressed: () => onDelete(d),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  int get rowCount => feeds.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
