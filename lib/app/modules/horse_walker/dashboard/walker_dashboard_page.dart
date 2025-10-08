import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smart_feeder_desktop/app/constants/app_colors.dart';
import 'package:smart_feeder_desktop/app/modules/horse_walker/dashboard/walker_dashboard_controller.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_walker_circle.dart';

class WalkerDashboardPage extends StatefulWidget {
  const WalkerDashboardPage({super.key});

  @override
  State<WalkerDashboardPage> createState() => WalkerDashboardPageState();
}

class WalkerDashboardPageState extends State<WalkerDashboardPage>
    with SingleTickerProviderStateMixin {
  final WalkerDashboardController controller = Get.put(
    WalkerDashboardController(),
  );

  late AnimationController _animController;
  late Animation<double> _angleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 4), // durasi 1 putaran
    );
    _angleAnim = Tween<double>(
      begin: 0,
      end: 2 * 3.1415926,
    ).animate(_animController);
  }

  void startWalkerAnimation({bool cw = true}) {
    _animController.repeat();
  }

  void stopWalkerAnimation() {
    _animController.stop();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
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
                    'Horse Walker Control Dashboard',
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // Header Info Card
                      // Container(
                      //   width: double.infinity,
                      //   padding: const EdgeInsets.all(20),
                      //   decoration: BoxDecoration(
                      //     gradient: LinearGradient(
                      //       colors: [
                      //         AppColors.primary,
                      //         AppColors.primary.withOpacity(0.7),
                      //       ],
                      //       begin: Alignment.topLeft,
                      //       end: Alignment.bottomRight,
                      //     ),
                      //     borderRadius: BorderRadius.circular(12),
                      //   ),
                      //   child: Row(
                      //     children: [
                      //       const Icon(
                      //         Icons.directions_walk,
                      //         color: Colors.white,
                      //         size: 40,
                      //       ),
                      //       const SizedBox(width: 16),
                      //       Expanded(
                      //         child: Column(
                      //           crossAxisAlignment: CrossAxisAlignment.start,
                      //           children: [
                      //             const Text(
                      //               'Smart Horse Walker',
                      //               style: TextStyle(
                      //                 color: Colors.white,
                      //                 fontSize: 24,
                      //                 fontWeight: FontWeight.bold,
                      //               ),
                      //             ),
                      //             Text(
                      //               'Kontrol otomatis untuk latihan kuda',
                      //               style: TextStyle(
                      //                 color: Colors.white.withOpacity(0.9),
                      //                 fontSize: 16,
                      //               ),
                      //             ),
                      //           ],
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            Column(
                              children: [
                                AnimatedBuilder(
                                  animation: _angleAnim,
                                  builder: (context, child) {
                                    // Untuk CCW, ganti -_angleAnim.value
                                    double angle = controller.rotation.value
                                        ? _angleAnim.value
                                        : -_angleAnim.value;
                                    return CustomWalkerCircle(
                                      size: 600,
                                      lineAngle: angle, // dari animasi
                                      numMarkers: 12,
                                      arcColors: [
                                        Colors.red,
                                        Colors.green,
                                        Colors.blue,
                                        Colors.yellow,
                                      ],
                                    );
                                  },
                                ),
                                // Ganti bagian Container(child: Text('ini status card')), dengan kode ini:
                                SizedBox(height: 10),
                                // Status Walker Devices Card
                                Container(
                                  width: 600,
                                  margin: const EdgeInsets.only(top: 20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 50,
                                        width: double.infinity,
                                        decoration: const BoxDecoration(
                                          color: AppColors.primary,
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(12),
                                            topRight: Radius.circular(12),
                                          ),
                                        ),
                                        child: const Center(
                                          child: Text(
                                            'Status Walker Devices',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        // constraints: const BoxConstraints(
                                        //   minHeight: 150,
                                        //   maxHeight: 300,
                                        // ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Obx(
                                            () =>
                                                controller
                                                    .walkerStatusList
                                                    .isEmpty
                                                ? const Center(
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                            vertical: 20.0,
                                                          ),
                                                      child: Text(
                                                        'Belum ada device walker yang terdeteksi',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                : SingleChildScrollView(
                                                    child: Column(
                                                      children: controller
                                                          .walkerStatusList
                                                          .map(
                                                            (
                                                              status,
                                                            ) => Container(
                                                              margin:
                                                                  const EdgeInsets.only(
                                                                    bottom: 8,
                                                                  ),
                                                              padding:
                                                                  const EdgeInsets.all(
                                                                    12,
                                                                  ),
                                                              decoration: BoxDecoration(
                                                                color:
                                                                    _getStatusColor(
                                                                      status
                                                                          .status,
                                                                    ).withOpacity(
                                                                      0.1,
                                                                    ),
                                                                border: Border.all(
                                                                  color: _getStatusColor(
                                                                    status
                                                                        .status,
                                                                  ),
                                                                ),
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      8,
                                                                    ),
                                                              ),
                                                              child: Row(
                                                                children: [
                                                                  Icon(
                                                                    _getStatusIcon(
                                                                      status
                                                                          .status,
                                                                    ),
                                                                    color: _getStatusColor(
                                                                      status
                                                                          .status,
                                                                    ),
                                                                    size: 24,
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 12,
                                                                  ),
                                                                  Expanded(
                                                                    child: Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                          'Device ${status.deviceId}',
                                                                          style: const TextStyle(
                                                                            fontSize:
                                                                                16,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                        Text(
                                                                          'Status: ${_getStatusText(status.status)}',
                                                                          style: TextStyle(
                                                                            fontSize:
                                                                                14,
                                                                            color: _getStatusColor(
                                                                              status.status,
                                                                            ),
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    'Update: ${DateFormat('HH:mm:ss').format(status.lastUpdate)}',
                                                                    style: const TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      color: Colors
                                                                          .grey,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          )
                                                          .toList(),
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: 20),
                            Container(
                              width: 4,
                              height: MediaQuery.of(context).size.height * 0.6,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                children: [
                                  // Pilih Kuda
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Container(
                                          height: 50,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: Colors.green[600],
                                            borderRadius:
                                                const BorderRadius.only(
                                                  topLeft: Radius.circular(12),
                                                  topRight: Radius.circular(12),
                                                ),
                                          ),
                                          child: const Center(
                                            child: Text(
                                              'Pemilihan Kuda',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(20.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Baris 1: Posisi 1 dan 2
                                              Row(
                                                children: [
                                                  // Posisi 1 - Merah
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Container(
                                                              width: 16,
                                                              height: 16,
                                                              decoration:
                                                                  BoxDecoration(
                                                                    color: Colors
                                                                        .red,
                                                                    shape: BoxShape
                                                                        .circle,
                                                                  ),
                                                            ),
                                                            const SizedBox(
                                                              width: 8,
                                                            ),
                                                            const Text(
                                                              'Kuda 1',
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 8,
                                                        ),
                                                        Obx(() {
                                                          // Filter kuda yang sudah dipilih di dropdown lain
                                                          final availableHorses = controller.horseList.where((
                                                            horse,
                                                          ) {
                                                            return horse.horseId !=
                                                                    controller
                                                                        .selectedHorse2
                                                                        .value &&
                                                                horse.horseId !=
                                                                    controller
                                                                        .selectedHorse3
                                                                        .value &&
                                                                horse.horseId !=
                                                                    controller
                                                                        .selectedHorse4
                                                                        .value;
                                                          }).toList();

                                                          return DropdownButtonFormField<
                                                            String
                                                          >(
                                                            value:
                                                                controller
                                                                    .selectedHorse1
                                                                    .value
                                                                    .isEmpty
                                                                ? null
                                                                : controller
                                                                      .selectedHorse1
                                                                      .value,
                                                            isExpanded: true,
                                                            decoration: InputDecoration(
                                                              border: OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      8,
                                                                    ),
                                                              ),
                                                              contentPadding:
                                                                  const EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        12,
                                                                    vertical:
                                                                        12,
                                                                  ),
                                                              hintText:
                                                                  'Pilih Kuda',
                                                            ),
                                                            items: [
                                                              const DropdownMenuItem(
                                                                value: null,
                                                                child: Text(
                                                                  'Tidak Ada Kuda',
                                                                ),
                                                              ),
                                                              ...availableHorses.map(
                                                                (
                                                                  horse,
                                                                ) => DropdownMenuItem(
                                                                  value: horse
                                                                      .horseId,
                                                                  child: Text(
                                                                    '${horse.horseId} - ${horse.name}',
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                            onChanged:
                                                                (
                                                                  value,
                                                                ) => controller
                                                                    .setSelectedHorse1(
                                                                      value ??
                                                                          '',
                                                                    ),
                                                          );
                                                        }),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  // Posisi 2 - Hijau
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Container(
                                                              width: 16,
                                                              height: 16,
                                                              decoration:
                                                                  BoxDecoration(
                                                                    color: Colors
                                                                        .green,
                                                                    shape: BoxShape
                                                                        .circle,
                                                                  ),
                                                            ),
                                                            const SizedBox(
                                                              width: 8,
                                                            ),
                                                            const Text(
                                                              'Kuda 2',
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 8,
                                                        ),
                                                        Obx(() {
                                                          // Filter kuda yang sudah dipilih di dropdown lain
                                                          final availableHorses = controller.horseList.where((
                                                            horse,
                                                          ) {
                                                            return horse.horseId !=
                                                                    controller
                                                                        .selectedHorse1
                                                                        .value &&
                                                                horse.horseId !=
                                                                    controller
                                                                        .selectedHorse3
                                                                        .value &&
                                                                horse.horseId !=
                                                                    controller
                                                                        .selectedHorse4
                                                                        .value;
                                                          }).toList();

                                                          return DropdownButtonFormField<
                                                            String
                                                          >(
                                                            value:
                                                                controller
                                                                    .selectedHorse2
                                                                    .value
                                                                    .isEmpty
                                                                ? null
                                                                : controller
                                                                      .selectedHorse2
                                                                      .value,
                                                            isExpanded: true,
                                                            decoration: InputDecoration(
                                                              border: OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      8,
                                                                    ),
                                                              ),
                                                              contentPadding:
                                                                  const EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        12,
                                                                    vertical:
                                                                        12,
                                                                  ),
                                                              hintText:
                                                                  'Pilih Kuda',
                                                            ),
                                                            items: [
                                                              const DropdownMenuItem(
                                                                value: null,
                                                                child: Text(
                                                                  'Tidak Ada Kuda',
                                                                ),
                                                              ),
                                                              ...availableHorses.map(
                                                                (
                                                                  horse,
                                                                ) => DropdownMenuItem(
                                                                  value: horse
                                                                      .horseId,
                                                                  child: Text(
                                                                    '${horse.horseId} - ${horse.name}',
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                            onChanged:
                                                                (
                                                                  value,
                                                                ) => controller
                                                                    .setSelectedHorse2(
                                                                      value ??
                                                                          '',
                                                                    ),
                                                          );
                                                        }),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),

                                              const SizedBox(height: 16),

                                              // Baris 2: Posisi 3 dan 4
                                              Row(
                                                children: [
                                                  // Posisi 3 - Biru
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Container(
                                                              width: 16,
                                                              height: 16,
                                                              decoration:
                                                                  BoxDecoration(
                                                                    color: Colors
                                                                        .blue,
                                                                    shape: BoxShape
                                                                        .circle,
                                                                  ),
                                                            ),
                                                            const SizedBox(
                                                              width: 8,
                                                            ),
                                                            const Text(
                                                              'Kuda 3',
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 8,
                                                        ),
                                                        Obx(() {
                                                          // Filter kuda yang sudah dipilih di dropdown lain
                                                          final availableHorses = controller.horseList.where((
                                                            horse,
                                                          ) {
                                                            return horse.horseId !=
                                                                    controller
                                                                        .selectedHorse1
                                                                        .value &&
                                                                horse.horseId !=
                                                                    controller
                                                                        .selectedHorse2
                                                                        .value &&
                                                                horse.horseId !=
                                                                    controller
                                                                        .selectedHorse4
                                                                        .value;
                                                          }).toList();

                                                          return DropdownButtonFormField<
                                                            String
                                                          >(
                                                            value:
                                                                controller
                                                                    .selectedHorse3
                                                                    .value
                                                                    .isEmpty
                                                                ? null
                                                                : controller
                                                                      .selectedHorse3
                                                                      .value,
                                                            isExpanded: true,
                                                            decoration: InputDecoration(
                                                              border: OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      8,
                                                                    ),
                                                              ),
                                                              contentPadding:
                                                                  const EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        12,
                                                                    vertical:
                                                                        12,
                                                                  ),
                                                              hintText:
                                                                  'Pilih Kuda',
                                                            ),
                                                            items: [
                                                              const DropdownMenuItem(
                                                                value: null,
                                                                child: Text(
                                                                  'Tidak Ada Kuda',
                                                                ),
                                                              ),
                                                              ...availableHorses.map(
                                                                (
                                                                  horse,
                                                                ) => DropdownMenuItem(
                                                                  value: horse
                                                                      .horseId,
                                                                  child: Text(
                                                                    '${horse.horseId} - ${horse.name}',
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                            onChanged:
                                                                (
                                                                  value,
                                                                ) => controller
                                                                    .setSelectedHorse3(
                                                                      value ??
                                                                          '',
                                                                    ),
                                                          );
                                                        }),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  // Posisi 4 - Kuning
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Container(
                                                              width: 16,
                                                              height: 16,
                                                              decoration:
                                                                  BoxDecoration(
                                                                    color: Colors
                                                                        .yellow,
                                                                    shape: BoxShape
                                                                        .circle,
                                                                  ),
                                                            ),
                                                            const SizedBox(
                                                              width: 8,
                                                            ),
                                                            const Text(
                                                              'Kuda 4',
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 8,
                                                        ),
                                                        Obx(() {
                                                          // Filter kuda yang sudah dipilih di dropdown lain
                                                          final availableHorses = controller.horseList.where((
                                                            horse,
                                                          ) {
                                                            return horse.horseId !=
                                                                    controller
                                                                        .selectedHorse1
                                                                        .value &&
                                                                horse.horseId !=
                                                                    controller
                                                                        .selectedHorse2
                                                                        .value &&
                                                                horse.horseId !=
                                                                    controller
                                                                        .selectedHorse3
                                                                        .value;
                                                          }).toList();

                                                          return DropdownButtonFormField<
                                                            String
                                                          >(
                                                            value:
                                                                controller
                                                                    .selectedHorse4
                                                                    .value
                                                                    .isEmpty
                                                                ? null
                                                                : controller
                                                                      .selectedHorse4
                                                                      .value,
                                                            isExpanded: true,
                                                            decoration: InputDecoration(
                                                              border: OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      8,
                                                                    ),
                                                              ),
                                                              contentPadding:
                                                                  const EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        12,
                                                                    vertical:
                                                                        12,
                                                                  ),
                                                              hintText:
                                                                  'Pilih Kuda',
                                                            ),
                                                            items: [
                                                              const DropdownMenuItem(
                                                                value: null,
                                                                child: Text(
                                                                  'Tidak Ada Kuda',
                                                                ),
                                                              ),
                                                              ...availableHorses.map(
                                                                (
                                                                  horse,
                                                                ) => DropdownMenuItem(
                                                                  value: horse
                                                                      .horseId,
                                                                  child: Text(
                                                                    '${horse.horseId} - ${horse.name}',
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                            onChanged:
                                                                (
                                                                  value,
                                                                ) => controller
                                                                    .setSelectedHorse4(
                                                                      value ??
                                                                          '',
                                                                    ),
                                                          );
                                                        }),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),

                                              const SizedBox(height: 24),

                                              // Button Actions
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: ElevatedButton.icon(
                                                      onPressed: controller
                                                          .clearAllHorses,
                                                      icon: const Icon(
                                                        Icons.clear_all,
                                                      ),
                                                      label: const Text(
                                                        'Clear Kuda',
                                                      ),
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            Colors.orange,
                                                        foregroundColor:
                                                            Colors.white,
                                                        minimumSize: const Size(
                                                          double.infinity,
                                                          45,
                                                        ),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                8,
                                                              ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  SizedBox(height: 14),

                                  // Kontrol Walker
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Container(
                                          height: 50,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: AppColors.primary,
                                            borderRadius:
                                                const BorderRadius.only(
                                                  topLeft: Radius.circular(12),
                                                  topRight: Radius.circular(12),
                                                ),
                                          ),
                                          child: const Center(
                                            child: Text(
                                              'Kontrol Device Walker',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(20.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Speed and Mode Selection
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        const Text(
                                                          'Kecepatan (RPM) *',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 8,
                                                        ),
                                                        TextFormField(
                                                          controller: controller
                                                              .speedCtrl,
                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
                                                          inputFormatters: [
                                                            FilteringTextInputFormatter
                                                                .digitsOnly,
                                                            LengthLimitingTextInputFormatter(
                                                              4,
                                                            ),
                                                          ],
                                                          decoration: InputDecoration(
                                                            hintText:
                                                                'Masukkan kecepatan (1-2000)',
                                                            border: OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    8,
                                                                  ),
                                                            ),
                                                            contentPadding:
                                                                const EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      12,
                                                                  vertical: 12,
                                                                ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        const Text(
                                                          'Mode Operasi',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 12,
                                                        ),
                                                        Obx(
                                                          () => Row(
                                                            children: [
                                                              Expanded(
                                                                child: Container(
                                                                  decoration: BoxDecoration(
                                                                    color:
                                                                        controller.operationMode.value ==
                                                                            'duration'
                                                                        ? AppColors.primary.withOpacity(
                                                                            0.1,
                                                                          )
                                                                        : Colors
                                                                              .transparent,
                                                                    border: Border.all(
                                                                      color:
                                                                          controller.operationMode.value ==
                                                                              'duration'
                                                                          ? AppColors.primary
                                                                          : Colors.grey.shade300,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          8,
                                                                        ),
                                                                  ),
                                                                  child: RadioListTile<String>(
                                                                    title: const Text(
                                                                      'Durasi',
                                                                    ),
                                                                    value:
                                                                        'duration',
                                                                    groupValue:
                                                                        controller
                                                                            .operationMode
                                                                            .value,
                                                                    onChanged:
                                                                        (
                                                                          value,
                                                                        ) => controller.setOperationMode(
                                                                          value!,
                                                                        ),
                                                                    activeColor:
                                                                        AppColors
                                                                            .primary,
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                width: 8,
                                                              ),
                                                              Expanded(
                                                                child: Container(
                                                                  decoration: BoxDecoration(
                                                                    color:
                                                                        controller.operationMode.value ==
                                                                            'rotation'
                                                                        ? AppColors.primary.withOpacity(
                                                                            0.1,
                                                                          )
                                                                        : Colors
                                                                              .transparent,
                                                                    border: Border.all(
                                                                      color:
                                                                          controller.operationMode.value ==
                                                                              'rotation'
                                                                          ? AppColors.primary
                                                                          : Colors.grey.shade300,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          8,
                                                                        ),
                                                                  ),
                                                                  child: RadioListTile<String>(
                                                                    title: const Text(
                                                                      'Putaran',
                                                                    ),
                                                                    value:
                                                                        'rotation',
                                                                    groupValue:
                                                                        controller
                                                                            .operationMode
                                                                            .value,
                                                                    onChanged:
                                                                        (
                                                                          value,
                                                                        ) => controller.setOperationMode(
                                                                          value!,
                                                                        ),
                                                                    activeColor:
                                                                        AppColors
                                                                            .primary,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),

                                              const SizedBox(height: 20),

                                              // Duration/Rotation Input
                                              Obx(
                                                () => Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      controller
                                                                  .operationMode
                                                                  .value ==
                                                              'duration'
                                                          ? 'Durasi (menit) *'
                                                          : 'Jumlah Putaran *',
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    TextFormField(
                                                      controller: controller
                                                          .durationCtrl,
                                                      keyboardType:
                                                          TextInputType.number,
                                                      inputFormatters: [
                                                        FilteringTextInputFormatter
                                                            .digitsOnly,
                                                        LengthLimitingTextInputFormatter(
                                                          4,
                                                        ),
                                                      ],
                                                      decoration: InputDecoration(
                                                        hintText:
                                                            controller
                                                                    .operationMode
                                                                    .value ==
                                                                'duration'
                                                            ? 'Masukkan durasi (1-7200 menit)'
                                                            : 'Masukkan jumlah putaran (1-1000)',
                                                        border: OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                8,
                                                              ),
                                                        ),
                                                        contentPadding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 12,
                                                              vertical: 12,
                                                            ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              const SizedBox(height: 20),

                                              // Rotation Direction
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    'Arah Rotasi',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 12),
                                                  Obx(
                                                    () => Row(
                                                      children: [
                                                        Expanded(
                                                          child: Container(
                                                            decoration: BoxDecoration(
                                                              color:
                                                                  !controller
                                                                      .rotation
                                                                      .value
                                                                  ? AppColors
                                                                        .primary
                                                                        .withOpacity(
                                                                          0.1,
                                                                        )
                                                                  : Colors
                                                                        .transparent,
                                                              border: Border.all(
                                                                color:
                                                                    !controller
                                                                        .rotation
                                                                        .value
                                                                    ? AppColors
                                                                          .primary
                                                                    : Colors
                                                                          .grey
                                                                          .shade300,
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    8,
                                                                  ),
                                                            ),
                                                            child: RadioListTile<bool>(
                                                              title: Row(
                                                                children: [
                                                                  Icon(
                                                                    Icons
                                                                        .rotate_left,
                                                                    color:
                                                                        !controller
                                                                            .rotation
                                                                            .value
                                                                        ? AppColors
                                                                              .primary
                                                                        : Colors
                                                                              .grey,
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 8,
                                                                  ),
                                                                  const Text(
                                                                    'CCW (Berlawanan Jarum Jam)',
                                                                  ),
                                                                ],
                                                              ),
                                                              value: false,
                                                              groupValue:
                                                                  controller
                                                                      .rotation
                                                                      .value,
                                                              onChanged:
                                                                  (
                                                                    value,
                                                                  ) => controller
                                                                      .setRotation(
                                                                        value!,
                                                                      ),
                                                              activeColor:
                                                                  AppColors
                                                                      .primary,
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 16,
                                                        ),
                                                        Expanded(
                                                          child: Container(
                                                            decoration: BoxDecoration(
                                                              color:
                                                                  controller
                                                                      .rotation
                                                                      .value
                                                                  ? AppColors
                                                                        .primary
                                                                        .withOpacity(
                                                                          0.1,
                                                                        )
                                                                  : Colors
                                                                        .transparent,
                                                              border: Border.all(
                                                                color:
                                                                    controller
                                                                        .rotation
                                                                        .value
                                                                    ? AppColors
                                                                          .primary
                                                                    : Colors
                                                                          .grey
                                                                          .shade300,
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    8,
                                                                  ),
                                                            ),
                                                            child: RadioListTile<bool>(
                                                              title: Row(
                                                                children: [
                                                                  Icon(
                                                                    Icons
                                                                        .rotate_right,
                                                                    color:
                                                                        controller
                                                                            .rotation
                                                                            .value
                                                                        ? AppColors
                                                                              .primary
                                                                        : Colors
                                                                              .grey,
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 8,
                                                                  ),
                                                                  const Text(
                                                                    'CW (Searah Jarum Jam)',
                                                                  ),
                                                                ],
                                                              ),
                                                              value: true,
                                                              groupValue:
                                                                  controller
                                                                      .rotation
                                                                      .value,
                                                              onChanged:
                                                                  (
                                                                    value,
                                                                  ) => controller
                                                                      .setRotation(
                                                                        value!,
                                                                      ),
                                                              activeColor:
                                                                  AppColors
                                                                      .primary,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),

                                              const SizedBox(height: 32),

                                              // Action Buttons
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Obx(() {
                                                      // Cek apakah ada minimal 1 kuda yang dipilih
                                                      final hasSelectedHorse =
                                                          controller
                                                              .selectedHorse1
                                                              .value
                                                              .isNotEmpty ||
                                                          controller
                                                              .selectedHorse2
                                                              .value
                                                              .isNotEmpty ||
                                                          controller
                                                              .selectedHorse3
                                                              .value
                                                              .isNotEmpty ||
                                                          controller
                                                              .selectedHorse4
                                                              .value
                                                              .isNotEmpty;

                                                      return ElevatedButton.icon(
                                                        onPressed:
                                                            (controller
                                                                    .isLoading
                                                                    .value ||
                                                                !hasSelectedHorse)
                                                            ? null
                                                            : () async {
                                                                await controller
                                                                    .sendWalkerCommand();
                                                                startWalkerAnimation();
                                                              },
                                                        icon:
                                                            controller
                                                                .isLoading
                                                                .value
                                                            ? const SizedBox(
                                                                width: 20,
                                                                height: 20,
                                                                child: CircularProgressIndicator(
                                                                  strokeWidth:
                                                                      2,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                              )
                                                            : const Icon(
                                                                Icons
                                                                    .play_arrow,
                                                              ),
                                                        label: Text(
                                                          !hasSelectedHorse
                                                              ? 'Pilih Minimal 1 Kuda'
                                                              : 'Mulai Walker',
                                                        ),
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              (!hasSelectedHorse ||
                                                                  controller
                                                                      .isLoading
                                                                      .value)
                                                              ? Colors.grey
                                                              : Colors.green,
                                                          foregroundColor:
                                                              Colors.white,
                                                          minimumSize:
                                                              const Size(
                                                                double.infinity,
                                                                50,
                                                              ),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  8,
                                                                ),
                                                          ),
                                                        ),
                                                      );
                                                    }),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Expanded(
                                                    child: ElevatedButton.icon(
                                                      onPressed: () {
                                                        controller.stopWalker();
                                                        stopWalkerAnimation();
                                                      },
                                                      icon: const Icon(
                                                        Icons.stop,
                                                      ),
                                                      label: const Text(
                                                        'Stop Walker',
                                                      ),
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            Colors.red,
                                                        foregroundColor:
                                                            Colors.white,
                                                        minimumSize: const Size(
                                                          double.infinity,
                                                          50,
                                                        ),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                8,
                                                              ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Information Card
                      // Container(
                      //   width: double.infinity,
                      //   decoration: BoxDecoration(
                      //     color: Colors.white,
                      //     borderRadius: BorderRadius.circular(12),
                      //     border: Border.all(color: Colors.grey.shade300),
                      //   ),
                      //   child: Column(
                      //     children: [
                      //       // Info Header
                      //       Container(
                      //         height: 50,
                      //         width: double.infinity,
                      //         decoration: const BoxDecoration(
                      //           color: Colors.blue,
                      //           borderRadius: BorderRadius.only(
                      //             topLeft: Radius.circular(12),
                      //             topRight: Radius.circular(12),
                      //           ),
                      //         ),
                      //         child: const Center(
                      //           child: Text(
                      //             'Informasi Penggunaan',
                      //             style: TextStyle(
                      //               color: Colors.white,
                      //               fontSize: 18,
                      //               fontWeight: FontWeight.bold,
                      //             ),
                      //           ),
                      //         ),
                      //       ),
                      //       // Info Content
                      //       Padding(
                      //         padding: const EdgeInsets.all(20.0),
                      //         child: Column(
                      //           crossAxisAlignment: CrossAxisAlignment.start,
                      //           children: [
                      //             _buildInfoRow(
                      //               'Header',
                      //               'SHWIPB (Fixed)',
                      //               Icons.info,
                      //             ),
                      //             _buildInfoRow(
                      //               'ID Device',
                      //               '1-99 (Angka)',
                      //               Icons.devices,
                      //             ),
                      //             _buildInfoRow(
                      //               'Control Motor',
                      //               'ON/OFF (Boolean)',
                      //               Icons.power_settings_new,
                      //             ),
                      //             _buildInfoRow(
                      //               'Rotation',
                      //               'CW/CCW (Boolean)',
                      //               Icons.rotate_90_degrees_ccw,
                      //             ),
                      //             _buildInfoRow(
                      //               'Speed',
                      //               '1-2000 RPM (Number)',
                      //               Icons.speed,
                      //             ),
                      //             _buildInfoRow(
                      //               'Duration',
                      //               '1-7200 detik (Number)',
                      //               Icons.timer,
                      //             ),
                      //           ],
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
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

  Widget _buildInfoRow(String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Text('$title: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(description)),
        ],
      ),
    );
  }

  // Tambahkan di akhir class WalkerDashboardPageState, sebelum penutup }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ON':
        return Colors.green;
      case 'START':
        return Colors.blue;
      case 'STOP':
        return Colors.orange;
      case 'OFF':
      default:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'ON':
        return Icons.power_settings_new;
      case 'START':
        return Icons.play_circle;
      case 'STOP':
        return Icons.pause_circle;
      case 'OFF':
      default:
        return Icons.power_off;
    }
  }

  String _getStatusText(String status) {
    switch (status.toUpperCase()) {
      case 'ON':
        return 'Aktif';
      case 'START':
        return 'Berjalan';
      case 'STOP':
        return 'Berhenti';
      case 'OFF':
      default:
        return 'Mati';
    }
  }
}
