import 'dart:ui' as BorderType;

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/constants/app_colors.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_biometric_rule_engine_model.dart';
import 'package:smart_feeder_desktop/app/models/halter/halter_position_rule_engine_model.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/rule_engine/table/halter_table_rule_engine_controller.dart';
import 'package:smart_feeder_desktop/app/utils/dialog_utils.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_card.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_button.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_input.dart';
import 'package:toastification/toastification.dart';

class HalterTableRuleEnginePage extends StatefulWidget {
  const HalterTableRuleEnginePage({super.key});

  @override
  State<HalterTableRuleEnginePage> createState() =>
      _HalterTableRuleEnginePageState();
}

class _HalterTableRuleEnginePageState extends State<HalterTableRuleEnginePage> {
  final controller = Get.find<HalterTableRuleEngineController>();

  void _showAddOrEditClassificationModal(
    BuildContext context, {
    HalterBiometricRuleEngineModel? model,
    int? index,
  }) {
    final nameCtrl = TextEditingController(text: model?.name ?? '');
    final suhuMinCtrl = TextEditingController(
      text: model?.suhuMin?.toString() ?? '',
    );
    final suhuMaxCtrl = TextEditingController(
      text: model?.suhuMax?.toString() ?? '',
    );
    final bpmMinCtrl = TextEditingController(
      text: model?.heartRateMin?.toString() ?? '',
    );
    final bpmMaxCtrl = TextEditingController(
      text: model?.heartRateMax?.toString() ?? '',
    );
    final spoMinCtrl = TextEditingController(
      text: model?.spoMin?.toString() ?? '',
    );
    final spoMaxCtrl = TextEditingController(
      text: model?.spoMax?.toString() ?? '',
    );
    final respMinCtrl = TextEditingController(
      text: model?.respirasiMin?.toString() ?? '',
    );
    final respMaxCtrl = TextEditingController(
      text: model?.respirasiMax?.toString() ?? '',
    );

    showCustomDialog(
      context: context,
      title: model == null
          ? 'Tambah Klasifikasi Kesehatan Kuda'
          : 'Edit Klasifikasi',
      icon: model == null ? Icons.add_circle_rounded : Icons.edit,
      iconColor: model == null ? Colors.green : Colors.amber,
      showConfirmButton: true,
      confirmText: "Simpan",
      cancelText: "Batal",
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomInput(
            label: "Nama Klasifikasi *",
            controller: nameCtrl,
            hint: "Masukkan nama klasifikasi",
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CustomInput(
                  label: "Suhu Min (°C)",
                  controller: suhuMinCtrl,
                  hint: "Contoh: 37.0",
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomInput(
                  label: "Suhu Max (°C)",
                  controller: suhuMaxCtrl,
                  hint: "Contoh: 39.0",
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CustomInput(
                  label: "Detak Jantung Min (beat/m)",
                  controller: bpmMinCtrl,
                  hint: "Contoh: 28",
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomInput(
                  label: "Detak Jantung Max (beat/m)",
                  controller: bpmMaxCtrl,
                  hint: "Contoh: 60",
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CustomInput(
                  label: "SpO₂ Min (%)",
                  controller: spoMinCtrl,
                  hint: "Contoh: 93",
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomInput(
                  label: "SpO₂ Max (%)",
                  controller: spoMaxCtrl,
                  hint: "Contoh: 100",
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CustomInput(
                  label: "Respirasi Min (breath/m)",
                  controller: respMinCtrl,
                  hint: "Contoh: 8",
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomInput(
                  label: "Respirasi Max (breath/m)",
                  controller: respMaxCtrl,
                  hint: "Contoh: 24",
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
            ],
          ),
        ],
      ),
      // ...existing code...
      onConfirm: () {
        final name = nameCtrl.text.trim();
        final suhuMin = suhuMinCtrl.text.trim();
        final suhuMax = suhuMaxCtrl.text.trim();
        final bpmMin = bpmMinCtrl.text.trim();
        final bpmMax = bpmMaxCtrl.text.trim();
        final spoMin = spoMinCtrl.text.trim();
        final spoMax = spoMaxCtrl.text.trim();
        final respMin = respMinCtrl.text.trim();
        final respMax = respMaxCtrl.text.trim();

        // Nama wajib diisi, minimal satu parameter diisi
        final isAnyFieldFilled = [
          suhuMin,
          suhuMax,
          bpmMin,
          bpmMax,
          spoMin,
          spoMax,
          respMin,
          respMax,
        ].any((v) => v.isNotEmpty);

        if (name.isEmpty || !isAnyFieldFilled) {
          Get.snackbar(
            "Input Tidak Lengkap",
            "Nama wajib diisi dan minimal satu parameter harus diisi.",
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
          return;
        }

        // Validasi min <= max jika keduanya diisi
        String? error;
        if (suhuMin.isNotEmpty && suhuMax.isNotEmpty) {
          final min = double.tryParse(suhuMin);
          final max = double.tryParse(suhuMax);
          if (min != null && max != null && min > max) {
            error = "Suhu Min tidak boleh lebih besar dari Suhu Max";
          }
        }
        if (bpmMin.isNotEmpty && bpmMax.isNotEmpty) {
          final min = int.tryParse(bpmMin);
          final max = int.tryParse(bpmMax);
          if (min != null && max != null && min > max) {
            error = "BPM Min tidak boleh lebih besar dari BPM Max";
          }
        }
        if (spoMin.isNotEmpty && spoMax.isNotEmpty) {
          final min = double.tryParse(spoMin);
          final max = double.tryParse(spoMax);
          if (min != null && max != null && min > max) {
            error = "SPO Min tidak boleh lebih besar dari SPO Max";
          }
        }
        if (respMin.isNotEmpty && respMax.isNotEmpty) {
          final min = int.tryParse(respMin);
          final max = int.tryParse(respMax);
          if (min != null && max != null && min > max) {
            error = "Respirasi Min tidak boleh lebih besar dari Respirasi Max";
          }
        }
        if (error != null) {
          Get.snackbar(
            "Input Tidak Valid",
            error,
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
          return;
        }

        final newModel = HalterBiometricRuleEngineModel(
          name: name,
          suhuMin: suhuMin.isNotEmpty ? double.tryParse(suhuMin) : null,
          suhuMax: suhuMax.isNotEmpty ? double.tryParse(suhuMax) : null,
          heartRateMin: bpmMin.isNotEmpty ? int.tryParse(bpmMin) : null,
          heartRateMax: bpmMax.isNotEmpty ? int.tryParse(bpmMax) : null,
          spoMin: spoMin.isNotEmpty ? double.tryParse(spoMin) : null,
          spoMax: spoMax.isNotEmpty ? double.tryParse(spoMax) : null,
          respirasiMin: respMin.isNotEmpty ? int.tryParse(respMin) : null,
          respirasiMax: respMax.isNotEmpty ? int.tryParse(respMax) : null,
        );

        if (model == null) {
          controller.addBiometricClassification(newModel);
        } else if (index != null) {
          controller.updateBiometricClassification(index, newModel);
        }
      },
    );
  }

  void _showAddOrEditHeadPositionModal(
    BuildContext context, {
    HalterPositionRuleEngineModel? model,
    int? index,
  }) {
    final nameCtrl = TextEditingController(text: model?.name ?? '');
    final pitchMinCtrl = TextEditingController(
      text: model?.pitchMin?.toString() ?? '',
    );
    final pitchMaxCtrl = TextEditingController(
      text: model?.pitchMax?.toString() ?? '',
    );
    final rollMinCtrl = TextEditingController(
      text: model?.rollMin?.toString() ?? '',
    );
    final rollMaxCtrl = TextEditingController(
      text: model?.rollMax?.toString() ?? '',
    );
    final yawMinCtrl = TextEditingController(
      text: model?.yawMin?.toString() ?? '',
    );
    final yawMaxCtrl = TextEditingController(
      text: model?.yawMax?.toString() ?? '',
    );

    showCustomDialog(
      context: context,
      title: model == null
          ? 'Tambah Klasifikasi Posisi Kepala'
          : 'Edit Klasifikasi Posisi',
      icon: model == null ? Icons.add_circle_rounded : Icons.edit,
      iconColor: model == null ? Colors.green : Colors.amber,
      showConfirmButton: true,
      confirmText: "Simpan",
      cancelText: "Batal",
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomInput(
            label: "Nama Klasifikasi *",
            controller: nameCtrl,
            hint: "Masukkan nama klasifikasi",
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CustomInput(
                  label: "Pitch Min (°)",
                  controller: pitchMinCtrl,
                  hint: "Contoh: -10",
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.-]')),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomInput(
                  label: "Pitch Max (°)",
                  controller: pitchMaxCtrl,
                  hint: "Contoh: 10",
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.-]')),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CustomInput(
                  label: "Roll Min (°)",
                  controller: rollMinCtrl,
                  hint: "Contoh: -10",
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.-]')),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomInput(
                  label: "Roll Max (°)",
                  controller: rollMaxCtrl,
                  hint: "Contoh: 10",
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.-]')),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CustomInput(
                  label: "Yaw Min (°)",
                  controller: yawMinCtrl,
                  hint: "Contoh: -20",
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.-]')),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomInput(
                  label: "Yaw Max (°)",
                  controller: yawMaxCtrl,
                  hint: "Contoh: 20",
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.-]')),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      onConfirm: () {
        final name = nameCtrl.text.trim();
        final pitchMin = pitchMinCtrl.text.trim();
        final pitchMax = pitchMaxCtrl.text.trim();
        final rollMin = rollMinCtrl.text.trim();
        final rollMax = rollMaxCtrl.text.trim();
        final yawMin = yawMinCtrl.text.trim();
        final yawMax = yawMaxCtrl.text.trim();

        final isAnyFieldFilled = [
          pitchMin,
          pitchMax,
          rollMin,
          rollMax,
          yawMin,
          yawMax,
        ].any((v) => v.isNotEmpty);

        if (name.isEmpty || !isAnyFieldFilled) {
          Get.snackbar(
            "Input Tidak Lengkap",
            "Nama wajib diisi dan minimal satu parameter harus diisi.",
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
          return;
        }

        String? error;
        if (pitchMin.isNotEmpty && pitchMax.isNotEmpty) {
          final min = double.tryParse(pitchMin);
          final max = double.tryParse(pitchMax);
          if (min != null && max != null && min > max) {
            error = "Pitch Min tidak boleh lebih besar dari Pitch Max";
          }
        }
        if (rollMin.isNotEmpty && rollMax.isNotEmpty) {
          final min = double.tryParse(rollMin);
          final max = double.tryParse(rollMax);
          if (min != null && max != null && min > max) {
            error = "Roll Min tidak boleh lebih besar dari Roll Max";
          }
        }
        if (yawMin.isNotEmpty && yawMax.isNotEmpty) {
          final min = double.tryParse(yawMin);
          final max = double.tryParse(yawMax);
          if (min != null && max != null && min > max) {
            error = "Yaw Min tidak boleh lebih besar dari Yaw Max";
          }
        }
        if (error != null) {
          Get.snackbar(
            "Input Tidak Valid",
            error,
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
          return;
        }

        final newModel = HalterPositionRuleEngineModel(
          name: name,
          pitchMin: pitchMin.isNotEmpty ? double.tryParse(pitchMin) : null,
          pitchMax: pitchMax.isNotEmpty ? double.tryParse(pitchMax) : null,
          rollMin: rollMin.isNotEmpty ? double.tryParse(rollMin) : null,
          rollMax: rollMax.isNotEmpty ? double.tryParse(rollMax) : null,
          yawMin: yawMin.isNotEmpty ? double.tryParse(yawMin) : null,
          yawMax: yawMax.isNotEmpty ? double.tryParse(yawMax) : null,
        );

        if (model == null) {
          controller.addPositionClassification(newModel);
        } else if (index != null) {
          controller.updatePositionClassification(index, newModel);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: CustomCard(
          withExpanded: false,
          scrollable: false,
          title: 'Table Rule Engine',
          content: DefaultTabController(
            length: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TabBar(
                  labelColor: AppColors.primary,
                  unselectedLabelColor: Colors.black54,
                  indicatorColor: AppColors.primary,
                  tabs: const [
                    Tab(
                      text: "Klasifikasi Kesehatan Kuda",
                      icon: Icon(Icons.monitor_heart),
                    ),
                    Tab(
                      text: "Klasifikasi Posisi Kuda",
                      icon: Icon(Icons.threesixty),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.76,
                  child: TabBarView(
                    children: [
                      _buildKlasifikasiKesehatanTab(context),
                      _buildKlasifikasiPosisiTab(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget _scrollableTab(Widget child) => LayoutBuilder(
  //   builder: (context, constraints) => SingleChildScrollView(
  //     child: ConstrainedBox(
  //       constraints: BoxConstraints(
  //         minHeight: constraints.maxHeight,
  //         minWidth: constraints.maxWidth,
  //       ),
  //       child: IntrinsicHeight(child: child),
  //     ),
  //   ),
  // );

  Widget _buildKlasifikasiKesehatanTab(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Obx(() {
              final list = controller.biometricClassificationList;
              final cardWidth = 350.0;
              final cardHeight = 250.0;
              return Wrap(
                spacing: 18,
                runSpacing: 18,
                children: [
                  ...list.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final c = entry.value;
                    return SizedBox(
                      width: cardWidth,
                      height: cardHeight,
                      child: CustomCard(
                        withExpanded: false,
                        title: c.name,
                        titleFontSize: 18,
                        headerHeight: 44,
                        borderRadius: 14,
                        scrollable: false,
                        content: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.black,
                                  ),
                                  children: [
                                    WidgetSpan(
                                      child: Icon(
                                        Icons.thermostat,
                                        color: Colors.red,
                                        size: 18,
                                      ),
                                    ),
                                    const TextSpan(text: " Suhu (°C): "),
                                    TextSpan(
                                      text: c.suhuMin != null
                                          ? "Min ${c.suhuMin}"
                                          : "-",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const TextSpan(text: "  "),
                                    TextSpan(
                                      text: c.suhuMax != null
                                          ? "Max ${c.suhuMax}"
                                          : "-",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.black,
                                  ),
                                  children: [
                                    WidgetSpan(
                                      child: Icon(
                                        Icons.monitor_heart,
                                        color: Colors.purple,
                                        size: 18,
                                      ),
                                    ),
                                    const TextSpan(
                                      text: " Detak Jantung (beat/m): ",
                                    ),
                                    TextSpan(
                                      text: c.heartRateMin != null
                                          ? "Min ${c.heartRateMin}"
                                          : "-",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const TextSpan(text: "  "),
                                    TextSpan(
                                      text: c.heartRateMax != null
                                          ? "Max ${c.heartRateMax}"
                                          : "-",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.black,
                                  ),
                                  children: [
                                    WidgetSpan(
                                      child: Icon(
                                        Icons.bloodtype,
                                        color: Colors.blue,
                                        size: 18,
                                      ),
                                    ),
                                    const TextSpan(text: " SpO₂ (%): "),
                                    TextSpan(
                                      text: c.spoMin != null
                                          ? "Min ${c.spoMin}"
                                          : "-",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const TextSpan(text: "  "),
                                    TextSpan(
                                      text: c.spoMax != null
                                          ? "Max ${c.spoMax}"
                                          : "-",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.black,
                                  ),
                                  children: [
                                    WidgetSpan(
                                      child: Icon(
                                        Icons.air,
                                        color: Colors.teal,
                                        size: 18,
                                      ),
                                    ),
                                    const TextSpan(
                                      text: " Respirasi (breath/m): ",
                                    ),
                                    TextSpan(
                                      text: c.respirasiMin != null
                                          ? "Min ${c.respirasiMin}"
                                          : "-",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const TextSpan(text: "  "),
                                    TextSpan(
                                      text: c.respirasiMax != null
                                          ? "Max ${c.respirasiMax}"
                                          : "-",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              Row(
                                children: [
                                  Expanded(
                                    child: CustomButton(
                                      text: 'Edit',
                                      icon: Icons.edit,
                                      backgroundColor: Colors.amber,
                                      textColor: Colors.white,
                                      height: 36,
                                      fontSize: 14,
                                      borderRadius: 8,
                                      onPressed: () =>
                                          _showAddOrEditClassificationModal(
                                            context,
                                            model: c,
                                            index: idx,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: CustomButton(
                                      text: 'Hapus',
                                      icon: Icons.delete,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      height: 36,
                                      fontSize: 14,
                                      borderRadius: 8,
                                      onPressed: () {
                                        final confirmCtrl =
                                            TextEditingController();
                                        showCustomDialog(
                                          context: context,
                                          title: "Konfirmasi Hapus",
                                          icon: Icons.delete,
                                          iconColor: Colors.red,
                                          showConfirmButton: true,
                                          confirmText: "Hapus",
                                          cancelText: "Batal",
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Ketik nama rule di bawah ini untuk konfirmasi hapus:',
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                ),
                                              ),
                                              Text(
                                                c.name,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: Colors.red,
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                              TextField(
                                                controller: confirmCtrl,
                                                decoration: InputDecoration(
                                                  hintText:
                                                      "ketik ${c.name} untuk hapus",
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                    borderSide: BorderSide(
                                                      color: AppColors.primary
                                                          .withOpacity(0.5),
                                                    ),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                        borderSide:
                                                            const BorderSide(
                                                              color: AppColors
                                                                  .primary,
                                                              width: 1.5,
                                                            ),
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          onConfirm: () {
                                            if (confirmCtrl.text.trim() !=
                                                c.name) {
                                              Get.snackbar(
                                                "Nama Tidak Sesuai",
                                                "Nama rule yang diketik tidak sesuai.",
                                                snackPosition:
                                                    SnackPosition.TOP,
                                                backgroundColor:
                                                    Colors.redAccent,
                                                colorText: Colors.white,
                                              );
                                              return;
                                            }
                                            controller
                                                .deleteBiometricClassification(
                                                  idx,
                                                );
                                            toastification.show(
                                              context: context,
                                              title: const Text(
                                                'Rule berhasil dihapus',
                                              ),
                                              type: ToastificationType.success,
                                              alignment: Alignment.topCenter,
                                              autoCloseDuration: const Duration(
                                                seconds: 2,
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  // Tombol tambah di ujung
                  SizedBox(
                    width: cardWidth,
                    height: cardHeight,
                    child: DottedBorder(
                      options: RoundedRectDottedBorderOptions(
                        dashPattern: [10, 5],
                        strokeWidth: 2,
                        radius: Radius.circular(16),
                        color: Colors.grey,
                        padding: EdgeInsets.all(16),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => _showAddOrEditClassificationModal(context),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add, color: Colors.grey, size: 28),
                              SizedBox(width: 8),
                              Text(
                                'Tambah Klasifikasi',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildKlasifikasiPosisiTab(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Obx(() {
              final list = controller.positionClassificationList;
              final cardWidth = 350.0;
              final cardHeight = 250.0;
              return Wrap(
                spacing: 18,
                runSpacing: 18,
                children: [
                  ...list.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final c = entry.value;
                    return SizedBox(
                      width: cardWidth,
                      height: cardHeight,
                      child: CustomCard(
                        withExpanded: false,
                        title: c.name,
                        titleFontSize: 18,
                        headerHeight: 44,
                        borderRadius: 14,
                        scrollable: false,
                        content: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.black,
                                  ),
                                  children: [
                                    WidgetSpan(
                                      child: Icon(
                                        Icons.straighten,
                                        color: Colors.blueGrey,
                                        size: 18,
                                      ),
                                    ),
                                    const TextSpan(text: " Pitch (°): "),
                                    TextSpan(
                                      text: c.pitchMin != null
                                          ? "Min ${c.pitchMin}"
                                          : "-",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const TextSpan(text: "  "),
                                    TextSpan(
                                      text: c.pitchMax != null
                                          ? "Max ${c.pitchMax}"
                                          : "-",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.black,
                                  ),
                                  children: [
                                    WidgetSpan(
                                      child: Icon(
                                        Icons.straighten,
                                        color: Colors.green,
                                        size: 18,
                                      ),
                                    ),
                                    const TextSpan(text: " Roll (°): "),
                                    TextSpan(
                                      text: c.rollMin != null
                                          ? "Min ${c.rollMin}"
                                          : "-",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const TextSpan(text: "  "),
                                    TextSpan(
                                      text: c.rollMax != null
                                          ? "Max ${c.rollMax}"
                                          : "-",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.black,
                                  ),
                                  children: [
                                    WidgetSpan(
                                      child: Icon(
                                        Icons.straighten,
                                        color: Colors.orange,
                                        size: 18,
                                      ),
                                    ),
                                    const TextSpan(text: " Yaw (°): "),
                                    TextSpan(
                                      text: c.yawMin != null
                                          ? "Min ${c.yawMin}"
                                          : "-",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const TextSpan(text: "  "),
                                    TextSpan(
                                      text: c.yawMax != null
                                          ? "Max ${c.yawMax}"
                                          : "-",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              Row(
                                children: [
                                  Expanded(
                                    child: CustomButton(
                                      text: 'Edit',
                                      icon: Icons.edit,
                                      backgroundColor: Colors.amber,
                                      textColor: Colors.white,
                                      height: 36,
                                      fontSize: 14,
                                      borderRadius: 8,
                                      onPressed: () =>
                                          _showAddOrEditHeadPositionModal(
                                            context,
                                            model: c,
                                            index: idx,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: CustomButton(
                                      text: 'Hapus',
                                      icon: Icons.delete,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      height: 36,
                                      fontSize: 14,
                                      borderRadius: 8,
                                      onPressed: () {
                                        final confirmCtrl =
                                            TextEditingController();
                                        showCustomDialog(
                                          context: context,
                                          title: "Konfirmasi Hapus",
                                          icon: Icons.delete,
                                          iconColor: Colors.red,
                                          showConfirmButton: true,
                                          confirmText: "Hapus",
                                          cancelText: "Batal",
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Ketik nama rule di bawah ini untuk konfirmasi hapus:',
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                ),
                                              ),
                                              Text(
                                                c.name,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: Colors.red,
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                              TextField(
                                                controller: confirmCtrl,
                                                decoration: InputDecoration(
                                                  hintText:
                                                      "ketik ${c.name} untuk hapus",
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                    borderSide: BorderSide(
                                                      color: AppColors.primary
                                                          .withOpacity(0.5),
                                                    ),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                        borderSide:
                                                            const BorderSide(
                                                              color: AppColors
                                                                  .primary,
                                                              width: 1.5,
                                                            ),
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          onConfirm: () {
                                            if (confirmCtrl.text.trim() !=
                                                c.name) {
                                              Get.snackbar(
                                                "Nama Tidak Sesuai",
                                                "Nama rule yang diketik tidak sesuai.",
                                                snackPosition:
                                                    SnackPosition.TOP,
                                                backgroundColor:
                                                    Colors.redAccent,
                                                colorText: Colors.white,
                                              );
                                              return;
                                            }
                                            controller
                                                .deletePositionClassification(
                                                  idx,
                                                );
                                            toastification.show(
                                              context: context,
                                              title: const Text(
                                                'Rule berhasil dihapus',
                                              ),
                                              type: ToastificationType.success,
                                              alignment: Alignment.topCenter,
                                              autoCloseDuration: const Duration(
                                                seconds: 2,
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  // Tombol tambah di ujung
                  SizedBox(
                    width: cardWidth,
                    height: cardHeight,
                    child: DottedBorder(
                      options: RoundedRectDottedBorderOptions(
                        dashPattern: [10, 5],
                        strokeWidth: 2,
                        radius: Radius.circular(16),
                        color: Colors.grey,
                        padding: EdgeInsets.all(16),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => _showAddOrEditHeadPositionModal(context),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add, color: Colors.grey, size: 28),
                              SizedBox(width: 8),
                              Text(
                                'Tambah Klasifikasi',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
