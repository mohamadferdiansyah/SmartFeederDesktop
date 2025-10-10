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
  final WalkerDashboardController controller =
      Get.find<WalkerDashboardController>();

  late AnimationController _animController;
  late Animation<double> _angleAnim;

  // Add disposal flag
  bool _isDisposed = false;

  // Worker untuk GetX listener
  Worker? _statusWorker;

  // Add variables untuk tracking rotation direction
  double _currentDisplayAngle = 0.0;
  bool _lastRotationDirection = false; // false = CCW, true = CW

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 14), // durasi 1 putaran
    );
    _angleAnim =
        Tween<double>(begin: 0, end: 2 * 3.1415926).animate(_animController)
          ..addListener(() {
            if (mounted && !_isDisposed) {
              _updateDisplayAngle();
            }
          });

    // Setup animation callbacks untuk controller
    controller.setAnimationCallbacks(
      onStart: startWalkerAnimation,
      onStop: stopWalkerAnimation,
    );

    // Listen untuk perubahan arah rotasi
    ever(controller.rotation, (bool newDirection) {
      if (_lastRotationDirection != newDirection &&
          _animController.isAnimating) {
        _handleRotationDirectionChange(newDirection);
      }
      _lastRotationDirection = newDirection;
    });
  }

  void _updateDisplayAngle() {
    final currentDirection = controller.rotation.value;

    if (currentDirection) {
      // CW: positive angle
      _currentDisplayAngle = _angleAnim.value;
    } else {
      // CCW: negative angle
      _currentDisplayAngle = -_angleAnim.value;
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _handleRotationDirectionChange(bool newDirection) {
    if (!mounted || _isDisposed) return;

    // Smooth transition saat mengubah arah rotasi
    try {
      // Get current normalized angle (0 to 2π)
      double currentNormalizedAngle = _angleAnim.value % (2 * 3.14159);

      // Reset animation dari posisi saat ini
      _animController.stop();
      _animController.reset();

      // Create new animation dari current position
      _angleAnim =
          Tween<double>(
            begin: currentNormalizedAngle,
            end: currentNormalizedAngle + (2 * 3.14159),
          ).animate(_animController)..addListener(() {
            if (mounted && !_isDisposed) {
              _updateDisplayAngle();
            }
          });

      // Resume animation
      _animController.repeat();
    } catch (e) {
      print('Error handling rotation direction change: $e');
    }
  }

  void startWalkerAnimation({bool cw = true}) {
    if (!mounted || _isDisposed) return; // Safety check

    try {
      _animController.repeat();
    } catch (e) {
      print('Error starting animation: $e');
    }
  }

  void stopWalkerAnimation() {
    if (!mounted || _isDisposed) return; // Safety check

    try {
      if (_animController.isAnimating) {
        _animController.stop();
      }
    } catch (e) {
      print('Error stopping animation: $e');
      // Ignore error if already disposed
    }
  }

  @override
  void dispose() {
    // Set disposal flag first
    _isDisposed = true;

    // Dispose worker if exists
    _statusWorker?.dispose();
    _statusWorker = null;

    // Safe dispose animation controller
    try {
      _animController.dispose();
    } catch (e) {
      print('Error disposing animation controller: $e');
    }

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
                                  animation: _animController,
                                  builder: (context, child) {
                                    return CustomWalkerCircle(
                                      size: 600,
                                      lineAngle:
                                          _currentDisplayAngle, // Gunakan calculated angle
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

                                                      final currentDeviceId =
                                                          int.tryParse(
                                                            controller
                                                                .idDeviceCtrl
                                                                .text
                                                                .trim(),
                                                          ) ??
                                                          1;
                                                      final deviceFullId =
                                                          'SHWIPB$currentDeviceId';

                                                      final deviceStatus = controller
                                                          .walkerStatusList
                                                          .firstWhereOrNull(
                                                            (device) =>
                                                                device
                                                                    .deviceId ==
                                                                deviceFullId,
                                                          );

                                                      final walkerStatus =
                                                          deviceStatus?.status
                                                              .toUpperCase();
                                                      final isWalkerRunning =
                                                          walkerStatus ==
                                                          'START';

                                                      final shouldDisable =
                                                          controller
                                                              .isLoading
                                                              .value ||
                                                          !hasSelectedHorse ||
                                                          isWalkerRunning;

                                                      String buttonText;
                                                      if (!hasSelectedHorse) {
                                                        buttonText =
                                                            'Pilih Minimal 1 Kuda';
                                                      } else if (isWalkerRunning) {
                                                        buttonText =
                                                            'Walker Sedang Berjalan';
                                                      } else {
                                                        buttonText =
                                                            'Mulai Walker';
                                                      }

                                                      return ElevatedButton.icon(
                                                        onPressed: shouldDisable
                                                            ? null
                                                            : () async {
                                                                await controller
                                                                    .sendWalkerCommand();
                                                                // startWalkerAnimation();
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
                                                        label: Text(buttonText),
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              shouldDisable
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
                                                    child: Obx(() {
                                                      final currentDeviceId =
                                                          int.tryParse(
                                                            controller
                                                                .idDeviceCtrl
                                                                .text
                                                                .trim(),
                                                          ) ??
                                                          1;
                                                      final deviceFullId =
                                                          'SHWIPB$currentDeviceId';

                                                      final deviceStatus = controller
                                                          .walkerStatusList
                                                          .firstWhereOrNull(
                                                            (device) =>
                                                                device
                                                                    .deviceId ==
                                                                deviceFullId,
                                                          );

                                                      final isWalkerRunning =
                                                          deviceStatus?.status
                                                              .toUpperCase() ==
                                                          'START';

                                                      return ElevatedButton.icon(
                                                        onPressed:
                                                            isWalkerRunning
                                                            ? () {
                                                                controller
                                                                    .stopWalker();
                                                                // stopWalkerAnimation();
                                                              }
                                                            : null,
                                                        icon: const Icon(
                                                          Icons.stop,
                                                        ),
                                                        label: Text(
                                                          isWalkerRunning
                                                              ? 'Stop Walker'
                                                              : 'Walker Tidak Berjalan',
                                                        ),
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              isWalkerRunning
                                                              ? Colors.red
                                                              : Colors.grey,
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

                      _buildRecentHistoryCard(),
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

  // Update widget _buildRecentHistoryCard di walker_dashboard_page.dart
  Widget _buildRecentHistoryCard() {
    return Container(
      width: 600,
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Container(
            height: 50,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Riwayat Terbaru',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Navigate to full history page
                      // Get.toNamed('/horse-walker/history');
                    },
                    child: const Text(
                      'Lihat Semua',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            constraints: const BoxConstraints(minHeight: 100, maxHeight: 200),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Obx(() {
                final recentHistory = controller.historyController
                    .getRecentHistory(3);

                if (recentHistory.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                      child: Text(
                        'Belum ada riwayat walker',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: recentHistory.length,
                  itemBuilder: (context, index) {
                    final history = recentHistory[index];
                    final horseNames = controller.historyController
                        .getHorseNamesByIds(history.horseIds);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _getHistoryStatusColor(
                          history.status,
                        ).withOpacity(0.1),
                        border: Border.all(
                          color: _getHistoryStatusColor(history.status),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _getHistoryStatusIcon(history.status),
                                color: _getHistoryStatusColor(history.status),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${history.deviceId} - ${history.statusText}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _getHistoryStatusColor(
                                      history.status,
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                DateFormat(
                                  'HH:mm:ss',
                                ).format(history.timeStart),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          if (horseNames.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4, left: 28),
                              child: Text(
                                'Kuda: ${horseNames.join(', ')}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.only(top: 4, left: 28),
                            child: Text(
                              '${history.speed} RPM • ${history.modeText}: ${history.durationText}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          if (history.timeStop != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4, left: 28),
                              child: Text(
                                'Durasi aktual: ${history.actualDurationText}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // Update method _getHistoryStatusColor
  Color _getHistoryStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'START':
        return Colors.blue;
      case 'SELESAI':
        return Colors.green;
      case 'DIHENTIKAN':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Update method _getHistoryStatusIcon
  IconData _getHistoryStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'START':
        return Icons.play_arrow;
      case 'SELESAI':
        return Icons.check_circle;
      case 'DIHENTIKAN':
        return Icons.stop_circle;
      default:
        return Icons.history;
    }
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
