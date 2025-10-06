import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_feeder_desktop/app/constants/app_colors.dart';
import 'package:smart_feeder_desktop/app/models/horse_model.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/monitoring_data/horse/detail/halter_horse_detail_page.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/monitoring_data/horse/halter_horse_controller.dart';
import 'package:smart_feeder_desktop/app/utils/dialog_utils.dart';
import 'package:smart_feeder_desktop/app/utils/toast_utils.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_button.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_input.dart';
import 'package:toastification/toastification.dart';

class HalterHorsePage extends StatefulWidget {
  const HalterHorsePage({super.key});

  @override
  State<HalterHorsePage> createState() => _HalterHorsePageState();
}

class _HalterHorsePageState extends State<HalterHorsePage> {
  final TextEditingController _searchController = TextEditingController();
  final HalterHorseController _controller = Get.find<HalterHorseController>();
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int? _sortColumnIndex;
  bool _sortAscending = true;
  String _searchText = "";
  HorseModel? _selectedHorseDetail;

  List<XFile> _selectedImages = [];

  @override
  void initState() {
    super.initState();
    _controller.loadHorses();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.trim().toLowerCase();
      });
    });
  }

  void _showDetailModal(HorseModel horse) {
    setState(() {
      _selectedHorseDetail = horse;
    });
  }

  void _closeDetail() {
    setState(() {
      _selectedHorseDetail = null;
    });
  }

  // Filter horses untuk search
  List<HorseModel> _filteredHorses(List<HorseModel> horses) {
    if (_searchText.isEmpty) return horses;
    return horses.where((d) {
      return d.horseId.toLowerCase().contains(_searchText) ||
          d.name.toLowerCase().contains(_searchText) ||
          d.type.toLowerCase().contains(_searchText) ||
          d.gender.toLowerCase().contains(_searchText) ||
          (d.category ?? '').toLowerCase().contains(_searchText) ||
          d.age.toString().contains(_searchText) ||
          (d.roomId ?? '').toLowerCase().contains(_searchText);
    }).toList();
  }

  // Modal Tambah/Edit Kuda
  void _showHorseFormModal({
    HorseModel? horse,
    required bool isEdit,
    required Function(HorseModel) onSubmit,
    BuildContext? parentContext,
  }) async {
    _selectedImages = [];
    String newId = horse?.horseId ?? '';
    if (!isEdit) {
      newId = await _controller.getNextHorseId();
    }
    final nameCtrl = TextEditingController(text: horse?.name ?? '');
    String? selectedType = horse?.type;
    String? selectedGender = horse?.gender;
    final ageCtrl = TextEditingController(
      text: horse?.age != null ? horse!.age.toString() : '',
    );
    String? selectedRoomId = horse?.roomId;
    String? selectedCategory = horse?.category;
    final birthPlaceCtrl = TextEditingController(text: horse?.birthPlace ?? '');
    DateTime? birthDate = horse?.birthDate;
    DateTime? settleDate = horse?.settleDate;
    final lengthCtrl = TextEditingController(
      text: horse?.length?.toString() ?? '',
    );
    final weightCtrl = TextEditingController(
      text: horse?.weight?.toString() ?? '',
    );
    final heightCtrl = TextEditingController(
      text: horse?.height?.toString() ?? '',
    );
    final chestCircumCtrl = TextEditingController(
      text: horse?.chestCircum?.toString() ?? '',
    );
    final skinColorCtrl = TextEditingController(text: horse?.skinColor ?? '');
    final markDescCtrl = TextEditingController(text: horse?.markDesc ?? '');
    // List<String> photos = horse?.photos ?? [];

    showCustomDialog(
      context: parentContext ?? context,
      width: MediaQuery.of(context).size.width * 0.5,
      title: isEdit ? 'Edit Kuda' : 'Tambah Kuda',
      icon: isEdit ? Icons.edit : Icons.add_circle_rounded,
      iconColor: isEdit ? Colors.amber : Colors.green,
      showConfirmButton: true,
      confirmText: isEdit ? "Simpan" : "Tambah",
      cancelText: "Batal",
      content: SingleChildScrollView(
        child: StatefulBuilder(
          builder: (context, modalSetState) => Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // KIRI: Identitas dasar
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isEdit || newId.isNotEmpty) ...[
                      Row(
                        children: [
                          const Text(
                            "ID Kuda: ",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            newId,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                    CustomInput(
                      label: "Nama Kuda *",
                      controller: nameCtrl,
                      hint: "Masukkan nama kuda",
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: "Jenis Kuda *",
                      ),
                      items: const [
                        DropdownMenuItem(value: "lokal", child: Text("Lokal")),
                        DropdownMenuItem(
                          value: "crossbred",
                          child: Text("Crossbred"),
                        ),
                      ],
                      onChanged: (v) => modalSetState(() => selectedType = v),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedGender,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: "Jenis Kelamin *",
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: "Jantan",
                          child: Text("Jantan"),
                        ),
                        DropdownMenuItem(
                          value: "Betina",
                          child: Text("Betina"),
                        ),
                        DropdownMenuItem(
                          value: "Kebiri",
                          child: Text("Kebiri"),
                        ),
                      ],
                      onChanged: (v) => modalSetState(() => selectedGender = v),
                    ),
                    const SizedBox(height: 16),
                    CustomInput(
                      label: "Umur *",
                      controller: ageCtrl,
                      hint: "Masukkan umur kuda",
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: "Kategori"),
                      items: const [
                        DropdownMenuItem(
                          value: null,
                          child: Text("Tidak ada kategori"),
                        ),
                        DropdownMenuItem(
                          value: "Produksi",
                          child: Text("Produksi"),
                        ),
                        DropdownMenuItem(
                          value: "Imunisasi",
                          child: Text("Imunisasi"),
                        ),
                        DropdownMenuItem(value: "Sehat", child: Text("Sehat")),
                        DropdownMenuItem(value: "Sakit", child: Text("Sakit")),
                        DropdownMenuItem(
                          value: "Istirahat",
                          child: Text("Istirahat"),
                        ),
                        DropdownMenuItem(
                          value: "Lainnya",
                          child: Text("Lainnya"),
                        ),
                      ],
                      onChanged: (v) =>
                          modalSetState(() => selectedCategory = v),
                    ),
                    const SizedBox(height: 16),
                    Obx(() {
                      final filteredRooms = _controller.roomList
                          .where((r) => r.horseId == null || r.horseId == '')
                          .toList();
                      final selectedValue =
                          filteredRooms.any((r) => r.roomId == selectedRoomId)
                          ? selectedRoomId
                          : null;

                      return DropdownButtonFormField<String>(
                        value: selectedValue,
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: "Ruangan"),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text("Tidak Dikandangkan"),
                          ),
                          ...filteredRooms.map(
                            (r) => DropdownMenuItem(
                              value: r.roomId,
                              child: Text("${r.roomId} - ${r.name}"),
                            ),
                          ),
                        ],
                        onChanged: (v) =>
                            modalSetState(() => selectedRoomId = v),
                      );
                    }),
                    const SizedBox(height: 16),
                    CustomInput(
                      label: "Tempat Lahir",
                      hint: "Masukan Tempat Lahir",
                      controller: birthPlaceCtrl,
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: birthDate ?? DateTime.now(),
                          firstDate: DateTime(1990),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          modalSetState(() => birthDate = picked);
                        }
                      },
                      child: AbsorbPointer(
                        child: CustomInput(
                          label: "Tanggal Lahir",
                          controller: TextEditingController(
                            text: birthDate != null
                                ? "${birthDate!.toIso8601String().split('T').first}"
                                : "",
                          ),
                          icon: Icons.calendar_today,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: settleDate ?? DateTime.now(),
                          firstDate: DateTime(1990),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          modalSetState(() => settleDate = picked);
                        }
                      },
                      child: AbsorbPointer(
                        child: CustomInput(
                          label: "Tanggal Menetap",
                          controller: TextEditingController(
                            text: settleDate != null
                                ? "${settleDate!.toIso8601String().split('T').first}"
                                : "",
                          ),
                          icon: Icons.calendar_today,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 32),
              // KANAN: Detail fisik dan foto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          "",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '',
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomInput(
                      label: "Panjang Kuda (cm)",
                      hint: "Masukan Panjang Kuda",
                      controller: lengthCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d*$'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomInput(
                      label: "Berat Kuda (kg)",
                      hint: "Masukan Berat Kuda",
                      controller: weightCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d*$'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomInput(
                      label: "Tinggi Kuda (cm)",
                      hint: "Masukan Tinggi Kuda",
                      controller: heightCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d*$'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomInput(
                      label: "Lingkar Dada Kuda (cm)",
                      hint: "Masukan Lingkar Dada Kuda",
                      controller: chestCircumCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d*$'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomInput(
                      label: "Warna Kulit",
                      hint: "Masukan Warna Kulit Kuda",
                      controller: skinColorCtrl,
                    ),
                    const SizedBox(height: 16),
                    CustomInput(
                      label: "Deskripsi Tanda",
                      hint: "Masukan Deskripsi Tanda Kuda",
                      controller: markDescCtrl,
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final List<XFile> images = await picker
                            .pickMultiImage();
                        modalSetState(() {
                          _selectedImages.addAll(images);
                        });
                      },
                      height: 40,
                      text: 'Pilih Foto Kuda',
                      iconTrailing: Icons.photo_rounded,
                      backgroundColor: AppColors.primary,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 90,
                      child: Scrollbar(
                        thumbVisibility: true,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: _selectedImages
                              .asMap()
                              .entries
                              .map(
                                (entry) => Stack(
                                  alignment: Alignment.topRight,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(right: 8),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          File(entry.value.path),
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 2,
                                      right: 2,
                                      child: GestureDetector(
                                        onTap: () {
                                          modalSetState(() {
                                            _selectedImages.removeAt(entry.key);
                                          });
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.red.withOpacity(0.8),
                                            shape: BoxShape.circle,
                                          ),
                                          padding: const EdgeInsets.all(2),
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      onConfirm: () {
        if (nameCtrl.text.trim().isEmpty ||
            selectedType == null ||
            selectedGender == null ||
            selectedType!.isEmpty ||
            selectedGender!.isEmpty ||
            ageCtrl.text.trim().isEmpty) {
          showAppToast(
            context: context,
            type: ToastificationType.error,
            title: 'Data Tidak Lengkap!',
            description: 'Lengkapi Data Kuda.',
          );
          return;
        }

        final int? ageInt = int.tryParse(ageCtrl.text.trim());

        final newHorse = HorseModel(
          horseId: newId,
          name: nameCtrl.text.trim(),
          type: selectedType!,
          gender: selectedGender!,
          age: ageInt!,
          roomId: selectedRoomId,
          category: selectedCategory,
          birthPlace: birthPlaceCtrl.text.trim(),
          birthDate: birthDate,
          settleDate: settleDate,
          length: double.tryParse(lengthCtrl.text.trim()),
          weight: double.tryParse(weightCtrl.text.trim()),
          height: double.tryParse(heightCtrl.text.trim()),
          chestCircum: double.tryParse(chestCircumCtrl.text.trim()),
          skinColor: skinColorCtrl.text.trim(),
          markDesc: markDescCtrl.text.trim(),
          photos: _selectedImages.map((img) => img.path).toList(),
        );
        onSubmit(newHorse);
        showAppToast(
          context: context,
          type: ToastificationType.success,
          title: 'Berhasil Ditambahkan!',
          description: 'Data Kuda Ditambahkan.',
        );
      },
    );
  }

  void _showHorseFormModalEdit(
    HorseModel horse,
    Function(HorseModel) onSubmit, {
    BuildContext? parentContext,
  }) async {
    // Reset foto setiap buka modal edit
    _selectedImages = horse.photos != null
        ? horse.photos!.map((path) => XFile(path)).toList()
        : [];

    String newId = horse.horseId;
    final nameCtrl = TextEditingController(text: horse.name);
    String? selectedType = horse.type;
    String? selectedGender = horse.gender;
    final ageCtrl = TextEditingController(text: horse.age.toString());
    String? selectedRoomId = horse.roomId;
    String? selectedCategory = horse.category;
    final birthPlaceCtrl = TextEditingController(text: horse.birthPlace ?? '');
    DateTime? birthDate = horse.birthDate;
    DateTime? settleDate = horse.settleDate;
    final lengthCtrl = TextEditingController(
      text: horse.length?.toString() ?? '',
    );
    final weightCtrl = TextEditingController(
      text: horse.weight?.toString() ?? '',
    );
    final heightCtrl = TextEditingController(
      text: horse.height?.toString() ?? '',
    );
    final chestCircumCtrl = TextEditingController(
      text: horse.chestCircum?.toString() ?? '',
    );
    final skinColorCtrl = TextEditingController(text: horse.skinColor ?? '');
    final markDescCtrl = TextEditingController(text: horse.markDesc ?? '');

    showCustomDialog(
      context: parentContext ?? context,
      width: MediaQuery.of(context).size.width * 0.5,
      title: 'Edit Kuda',
      icon: Icons.edit,
      iconColor: Colors.amber,
      showConfirmButton: true,
      confirmText: "Simpan",
      cancelText: "Batal",
      content: SingleChildScrollView(
        child: StatefulBuilder(
          builder: (context, modalSetState) => Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // KIRI: Identitas dasar
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          "ID Kuda: ",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          newId,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomInput(
                      label: "Nama Kuda *",
                      controller: nameCtrl,
                      hint: "Masukkan nama kuda",
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: "Jenis Kuda *",
                      ),
                      items: const [
                        DropdownMenuItem(value: "lokal", child: Text("Lokal")),
                        DropdownMenuItem(
                          value: "crossbred",
                          child: Text("Crossbred"),
                        ),
                      ],
                      onChanged: (v) => modalSetState(() => selectedType = v),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedGender,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: "Jenis Kelamin *",
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: "Jantan",
                          child: Text("Jantan"),
                        ),
                        DropdownMenuItem(
                          value: "Betina",
                          child: Text("Betina"),
                        ),
                        DropdownMenuItem(
                          value: "Kebiri",
                          child: Text("Kebiri"),
                        ),
                      ],
                      onChanged: (v) => modalSetState(() => selectedGender = v),
                    ),
                    const SizedBox(height: 16),
                    CustomInput(
                      label: "Umur (tahun, wajib diisi)",
                      controller: ageCtrl,
                      hint: "Masukkan umur kuda",
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: "Kategori (opsional)",
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: null,
                          child: Text("Tidak ada kategori"),
                        ),
                        DropdownMenuItem(
                          value: "Produksi",
                          child: Text("Produksi"),
                        ),
                        DropdownMenuItem(
                          value: "Imunisasi",
                          child: Text("Imunisasi"),
                        ),
                        DropdownMenuItem(value: "Sehat", child: Text("Sehat")),
                        DropdownMenuItem(value: "Sakit", child: Text("Sakit")),
                        DropdownMenuItem(
                          value: "Istirahat",
                          child: Text("Istirahat"),
                        ),
                        DropdownMenuItem(
                          value: "Lainnya",
                          child: Text("Lainnya"),
                        ),
                      ],
                      onChanged: (v) =>
                          modalSetState(() => selectedCategory = v),
                    ),
                    const SizedBox(height: 16),
                    Obx(() {
                      final filteredRooms = _controller.roomList
                          .where((r) => r.horseId == null || r.horseId == '')
                          .toList();
                      final selectedValue =
                          filteredRooms.any((r) => r.roomId == selectedRoomId)
                          ? selectedRoomId
                          : null;

                      return DropdownButtonFormField<String>(
                        value: selectedValue,
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: "Ruangan"),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text("Tidak Dikandangkan"),
                          ),
                          ...filteredRooms.map(
                            (r) => DropdownMenuItem(
                              value: r.roomId,
                              child: Text("${r.roomId} - ${r.name}"),
                            ),
                          ),
                        ],
                        onChanged: (v) =>
                            modalSetState(() => selectedRoomId = v),
                      );
                    }),
                    const SizedBox(height: 16),
                    CustomInput(
                      label: "Tempat Lahir",
                      hint: "Masukan Tempat Lahir",
                      controller: birthPlaceCtrl,
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: birthDate ?? DateTime.now(),
                          firstDate: DateTime(1990),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          modalSetState(() => birthDate = picked);
                        }
                      },
                      child: AbsorbPointer(
                        child: CustomInput(
                          label: "Tanggal Lahir",
                          controller: TextEditingController(
                            text: birthDate != null
                                ? "${birthDate!.toIso8601String().split('T').first}"
                                : "",
                          ),
                          icon: Icons.calendar_today,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: settleDate ?? DateTime.now(),
                          firstDate: DateTime(1990),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          modalSetState(() => settleDate = picked);
                        }
                      },
                      child: AbsorbPointer(
                        child: CustomInput(
                          label: "Tanggal Menetap",
                          controller: TextEditingController(
                            text: settleDate != null
                                ? "${settleDate!.toIso8601String().split('T').first}"
                                : "",
                          ),
                          icon: Icons.calendar_today,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 32),
              // KANAN: Detail fisik dan foto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          "",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '',
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomInput(
                      label: "Panjang Kuda (cm)",
                      hint: "Masukan Panjang Kuda",
                      controller: lengthCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d*$'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomInput(
                      label: "Berat Kuda (kg)",
                      hint: "Masukan Berat Kuda",
                      controller: weightCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d*$'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomInput(
                      label: "Tinggi Kuda (cm)",
                      hint: "Masukan Tinggi Kuda",
                      controller: heightCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d*$'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomInput(
                      label: "Lingkar Dada Kuda (cm)",
                      hint: "Masukan Lingkar Dada Kuda",
                      controller: chestCircumCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d*$'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomInput(
                      label: "Warna Kulit Kuda",
                      hint: "Masukan Warna Kulit Kuda",
                      controller: skinColorCtrl,
                    ),
                    const SizedBox(height: 16),
                    CustomInput(
                      label: "Deskripsi Tanda",
                      hint: "Masukan Deskripsi Tanda",
                      controller: markDescCtrl,
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final List<XFile> images = await picker
                            .pickMultiImage();
                        modalSetState(() {
                          _selectedImages.addAll(images);
                        });
                      },
                      height: 40,
                      text: 'Pilih Foto Kuda',
                      iconTrailing: Icons.photo_rounded,
                      backgroundColor: AppColors.primary,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 90,
                      child: Scrollbar(
                        thumbVisibility: true,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: _selectedImages
                              .where(
                                (img) => img.path.isNotEmpty,
                              ) // <-- filter path kosong
                              .toList()
                              .asMap()
                              .entries
                              .map(
                                (entry) => Stack(
                                  alignment: Alignment.topRight,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(right: 8),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          File(entry.value.path),
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 2,
                                      right: 2,
                                      child: GestureDetector(
                                        onTap: () {
                                          modalSetState(() {
                                            _selectedImages.removeAt(entry.key);
                                          });
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.red.withOpacity(0.8),
                                            shape: BoxShape.circle,
                                          ),
                                          padding: const EdgeInsets.all(2),
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      onConfirm: () {
        if (nameCtrl.text.trim().isEmpty ||
            selectedType == null ||
            selectedGender == null ||
            selectedType == null ||
            selectedGender == null ||
            ageCtrl.text.trim().isEmpty) {
          showAppToast(
            context: context,
            type: ToastificationType.error,
            title: 'Data Tidak Lengkap!',
            description: 'Lengkapi Data Kuda.',
          );
          return;
        }

        final int? ageInt = int.tryParse(ageCtrl.text.trim());

        final editedHorse = HorseModel(
          horseId: horse.horseId,
          name: nameCtrl.text.trim(),
          type: selectedType!,
          gender: selectedGender!,
          age: ageInt!,
          roomId: selectedRoomId,
          category: selectedCategory,
          birthPlace: birthPlaceCtrl.text.trim(),
          birthDate: birthDate,
          settleDate: settleDate,
          length: double.tryParse(lengthCtrl.text.trim()),
          weight: double.tryParse(weightCtrl.text.trim()),
          height: double.tryParse(heightCtrl.text.trim()),
          chestCircum: double.tryParse(chestCircumCtrl.text.trim()),
          skinColor: skinColorCtrl.text.trim(),
          markDesc: markDescCtrl.text.trim(),
          photos: _selectedImages.map((img) => img.path).toList(),
        );
        onSubmit(editedHorse);
        showAppToast(
          context: context,
          type: ToastificationType.success,
          title: 'Berhasil Diubah!',
          description: 'Data Kuda "${horse.name}" Diubah.',
        );
      },
    );
  }

  void _confirmDelete(HorseModel horse) {
    showCustomDialog(
      context: context,
      title: "Konfirmasi Hapus",
      icon: Icons.delete_forever,
      iconColor: Colors.red,
      message: 'Hapus data kuda "${horse.name}"?',
      showConfirmButton: true,
      confirmText: "Hapus",
      cancelText: "Batal",
      onConfirm: () async {
        await _controller.deleteHorse(horse.horseId);
        showAppToast(
          context: context,
          type: ToastificationType.success,
          title: 'Berhasil Dihapus!',
          description: 'Data Kuda "${horse.name}" Dihapus.',
        );
      },
    );
  }

  void _keluarkanKudaDariKandang(HorseModel horse) {
    showCustomDialog(
      context: context,
      title: "Keluarkan Kuda dari Kandang",
      icon: Icons.exit_to_app,
      iconColor: Colors.orange,
      message: "Keluarkan ${horse.name} dari kandang?",
      showConfirmButton: true,
      confirmText: "Keluarkan",
      cancelText: "Batal",
      onConfirm: () async {
        await _controller.keluarkanKudaDariKandang(horse.horseId);
        showAppToast(
          context: context,
          type: ToastificationType.success,
          title: 'Berhasil Dikeluarkan!',
          description: '"${horse.name}" Dikeluarkan Dari Kandang.',
        );
      },
    );
  }

  void _masukanKudaKeKandang(HorseModel horse, Function(HorseModel) onSubmit) {
    // Cari room yang kolom horse_id == horse.horseId
    final room = _controller.roomList.firstWhereOrNull(
      (r) => r.horseId == horse.horseId,
    );

    showCustomDialog(
      context: context,
      title: "Masukkan Kuda ke Kandang",
      icon: Icons.house_siding_rounded,
      iconColor: AppColors.primary,
      message: room != null
          ? "Masukkan kuda ${horse.name} ke ruangan ${room.name} (${room.roomId})?"
          : "Kuda belum dipasangkan ke ruangan manapun.",
      showConfirmButton: true,
      confirmText: "Konfirmasi",
      cancelText: "Batal",
      onConfirm: () {
        if (room == null) {
          showAppToast(
            context: context,
            type: ToastificationType.error,
            title: 'Tidak Ada Ruangan!',
            description: 'Kuda belum dipasangkan ke ruangan manapun.',
          );
          return;
        }
        final editedHorse = HorseModel(
          horseId: horse.horseId,
          name: horse.name,
          type: horse.type,
          gender: horse.gender,
          age: horse.age,
          roomId: room.roomId,
          category: horse.category,
          birthPlace: horse.birthPlace,
          birthDate: horse.birthDate,
          settleDate: horse.settleDate,
          length: horse.length,
          weight: horse.weight,
          height: horse.height,
          chestCircum: horse.chestCircum,
          skinColor: horse.skinColor,
          markDesc: horse.markDesc,
          photos: horse.photos,
        );
        onSubmit(editedHorse);
        showAppToast(
          context: context,
          type: ToastificationType.success,
          title: 'Berhasil Dimasukan!',
          description: '"${horse.name}" Dimasukan Ke Kandang.',
        );
      },
    );
  }

  void _sort<T extends Comparable>(
    List<HorseModel> devices,
    T Function(HorseModel d) getField,
    bool ascending,
  ) {
    devices.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedHorseDetail != null) {
      return HalterHorseDetailWidget(
        horse: _selectedHorseDetail!,
        onBack: _closeDetail,
      );
    }

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
                        hint:
                            'Masukkan ID, nama, jenis, kategori, gender, umur, atau ruangan',
                        fontSize: 24,
                      ),
                    ),
                    // Table
                    Expanded(
                      child: Obx(() {
                        List<HorseModel> horses = _filteredHorses(
                          _controller.horseList.toList(),
                        );

                        // Sort
                        if (_sortColumnIndex != null) {
                          switch (_sortColumnIndex!) {
                            case 0:
                              _sort<String>(
                                horses,
                                (d) => d.horseId,
                                _sortAscending,
                              );
                              break;
                            case 1:
                              _sort<String>(
                                horses,
                                (d) => d.name,
                                _sortAscending,
                              );
                              break;
                            case 2:
                              _sort<String>(
                                horses,
                                (d) => d.type,
                                _sortAscending,
                              );
                              break;
                            case 3:
                              _sort<String>(
                                horses,
                                (d) => d.category ?? '',
                                _sortAscending,
                              );
                              break;
                            case 4:
                              _sort<String>(
                                horses,
                                (d) => d.gender,
                                _sortAscending,
                              );
                              break;
                            case 5:
                              _sort<int>(horses, (d) => d.age, _sortAscending);
                              break;
                            case 6:
                              _sort<String>(
                                horses,
                                (d) => d.roomId ?? '',
                                _sortAscending,
                              );
                              break;
                          }
                        }

                        final tableWidth =
                            MediaQuery.of(context).size.width - 72.0;
                        final idW = tableWidth * 0.05;
                        final nameW = tableWidth * 0.10;
                        final typeW = tableWidth * 0.06;
                        final genderW = tableWidth * 0.06;
                        final ageW = tableWidth * 0.06;
                        final roomW = tableWidth * 0.06;
                        final actionW = tableWidth * 0.28;
                        final categoryW = tableWidth * 0.06;

                        return SingleChildScrollView(
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  CustomButton(
                                    width:
                                        MediaQuery.of(context).size.width * 0.1,
                                    height: 50,
                                    backgroundColor: Colors.green,
                                    fontSize: 18,
                                    icon: Icons.add_circle_rounded,
                                    text: 'Tambah Data',
                                    onPressed: () => _showHorseFormModal(
                                      isEdit: false,
                                      onSubmit: (HorseModel newHorse) async {
                                        await _controller.addHorse(newHorse);
                                      },
                                    ),
                                  ),
                                  Spacer(),
                                  Text(
                                    'Export Data :',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(width: 12),
                                  CustomButton(
                                    width:
                                        MediaQuery.of(context).size.width * 0.1,
                                    height: 50,
                                    backgroundColor: Colors.green,
                                    fontSize: 18,
                                    icon: Icons.table_view_rounded,
                                    text: 'Export Excel',
                                    onPressed: () async {
                                      final success = await _controller
                                          .exportToExcel(horses);
                                      showAppToast(
                                        context: context,
                                        type: success
                                            ? ToastificationType.success
                                            : ToastificationType.error,
                                        title: success
                                            ? 'Berhasil Export!'
                                            : 'Export Dibatalkan!',
                                        description: success
                                            ? 'Data Kuda Diexport Ke Excel.'
                                            : 'Export data kuda dibatalkan.',
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 12),
                                  CustomButton(
                                    width:
                                        MediaQuery.of(context).size.width * 0.1,
                                    height: 50,
                                    backgroundColor: Colors.redAccent,
                                    fontSize: 18,
                                    icon: Icons.picture_as_pdf,
                                    text: 'Export PDF',
                                    onPressed: () async {
                                      final success = await _controller
                                          .exportToPDF(horses);
                                      showAppToast(
                                        context: context,
                                        type: success
                                            ? ToastificationType.success
                                            : ToastificationType.error,
                                        title: success
                                            ? 'Berhasil Export!'
                                            : 'Export Dibatalkan!',
                                        description: success
                                            ? 'Data Kuda Diexport Ke PDF.'
                                            : 'Export data kuda dibatalkan.',
                                      );
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Total Data: ${horses.length}',
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
                                        });
                                      },
                                    ),
                                    DataColumn(
                                      label: SizedBox(
                                        width: categoryW,
                                        child: const Center(
                                          child: Text(
                                            'Kategori',
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
                                        width: genderW,
                                        child: const Center(
                                          child: Text(
                                            'Jenis Kelamin',
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
                                  rowsPerPage: _rowsPerPage,
                                  availableRowsPerPage: const [5, 10, 20],
                                  onRowsPerPageChanged: (value) {
                                    setState(() {
                                      _rowsPerPage = value ?? 5;
                                    });
                                  },
                                  showCheckboxColumn: false,
                                  source: HorseDataTableSource(
                                    context: context,
                                    horses: horses,
                                    // onLepasRuangan: (horse) =>
                                    //     _showLepasRuanganModal(horse, (
                                    //       editedHorse,
                                    //     ) async {
                                    //       await _controller.updateHorse(
                                    //         editedHorse,
                                    //       );
                                    //     }),
                                    // onSelectRoom: (horse) =>
                                    //     _showPilihRuanganModal(horse, (
                                    //       editedHorse,
                                    //     ) async {
                                    //       await _controller.updateHorse(
                                    //         editedHorse,
                                    //       );
                                    //     }),
                                    onMasuk: (horse) => _masukanKudaKeKandang(
                                      horse,
                                      (editedHorse) async {
                                        await _controller.updateHorse(
                                          editedHorse,
                                        );
                                      },
                                    ),
                                    onKeluar: (horse) =>
                                        _keluarkanKudaDariKandang(horse),
                                    onDetail: _showDetailModal,
                                    onEdit: (horse) => _showHorseFormModalEdit(
                                      horse,
                                      (editedHorse) async {
                                        await _controller.updateHorse(
                                          editedHorse,
                                        );
                                      },
                                      parentContext: context,
                                    ),
                                    onDelete: _confirmDelete,
                                  ),
                                ),
                              ),
                            ],
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

  // Widget _detailRow(String label, String value) => Padding(
  //   padding: const EdgeInsets.symmetric(vertical: 2),
  //   child: Row(
  //     children: [
  //       Text(
  //         "$label: ",
  //         style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
  //       ),
  //       Flexible(child: Text(value, style: const TextStyle(fontSize: 16))),
  //     ],
  //   ),
  // );
}

// DataTableSource untuk PaginatedDataTable
class HorseDataTableSource extends DataTableSource {
  final BuildContext context;
  final List<HorseModel> horses;
  final Function(HorseModel) onDetail;
  final Function(HorseModel) onEdit;
  final Function(HorseModel) onDelete;
  final Function(HorseModel) onKeluar;
  final Function(HorseModel) onMasuk;
  int _selectedCount = 0;

  HorseDataTableSource({
    required this.context,
    required this.horses,
    required this.onDetail,
    required this.onEdit,
    required this.onDelete,
    required this.onKeluar,
    required this.onMasuk,
  });

  @override
  DataRow getRow(int index) {
    final horse = horses[index];
    final room = Get.find<HalterHorseController>().roomList.firstWhereOrNull(
      (r) => r.horseId == horse.horseId,
    );
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Center(child: Text(horse.horseId))),
        DataCell(Center(child: Text(horse.name))),
        DataCell(
          Center(child: Text(horse.type == "lokal" ? 'Lokal' : 'Crossbred')),
        ),
        DataCell(Center(child: Text(horse.category ?? "-"))),
        DataCell(Center(child: Text(horse.gender))),
        DataCell(Center(child: Text(horse.age.toString()))),
        DataCell(Center(child: Text(horse.roomId ?? "Tidak Digunakan"))),
        DataCell(
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomButton(
                width: 115,
                height: 38,
                text: 'Detail',
                backgroundColor: Colors.blueGrey,
                icon: Icons.info_outline,
                borderRadius: 6,
                fontSize: 14,
                onPressed: () => onDetail(horse),
              ),
              const SizedBox(width: 6),
              CustomButton(
                width: 115,
                height: 38,
                backgroundColor: Colors.amber,
                text: 'Edit',
                icon: Icons.edit,
                borderRadius: 6,
                fontSize: 14,
                onPressed: () => onEdit(horse),
              ),
              const SizedBox(width: 6),
              horse.roomId != null
                  ? CustomButton(
                      width: 180,
                      height: 38,
                      backgroundColor: Colors.orange,
                      text: 'Keluarkan Kuda',
                      icon: Icons.link_off,
                      borderRadius: 6,
                      fontSize: 14,
                      onPressed: () {
                        onKeluar(horse);
                      },
                    )
                  : CustomButton(
                      width: 180,
                      height: 38,
                      backgroundColor: room != null
                          ? AppColors.primary
                          : Colors.grey,
                      text: room != null ? 'Masukan Kuda' : 'Tidak Ada Ruang',
                      icon: Icons.house_siding_rounded,
                      borderRadius: 6,
                      fontSize: 14,
                      onPressed: () {
                        if (room != null) {
                          onMasuk(horse);
                        } else {}
                      },
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
                  onPressed: () => onDelete(horse),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  int get rowCount => horses.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;
}
