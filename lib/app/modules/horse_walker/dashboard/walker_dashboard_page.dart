import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/constants/app_colors.dart';
import 'package:smart_feeder_desktop/app/modules/horse_walker/dashboard/walker_dashboard_controller.dart';

class WalkerDashboardPage extends StatefulWidget {
  const WalkerDashboardPage({super.key});

  @override
  State<WalkerDashboardPage> createState() => WalkerDashboardPageState();
}

class WalkerDashboardPageState extends State<WalkerDashboardPage> {
  final WalkerDashboardController controller = Get.put(
    WalkerDashboardController(),
  );

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
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withOpacity(0.7),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.directions_walk,
                              color: Colors.white,
                              size: 40,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Smart Horse Walker',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Kontrol otomatis untuk latihan kuda',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Control Form Card
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          children: [
                            // Form Header
                            Container(
                              height: 50,
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
                                  'Pengaturan Kontrol Walker',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            // Form Content
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Device ID and Control Motor
                                  // Row(
                                  //   children: [
                                  //     Expanded(
                                  //       child: Column(
                                  //         crossAxisAlignment:
                                  //             CrossAxisAlignment.start,
                                  //         children: [
                                  //           const Text(
                                  //             'ID Device *',
                                  //             style: TextStyle(
                                  //               fontSize: 16,
                                  //               fontWeight: FontWeight.w600,
                                  //             ),
                                  //           ),
                                  //           const SizedBox(height: 8),
                                  //           TextFormField(
                                  //             controller:
                                  //                 controller.idDeviceCtrl,
                                  //             keyboardType:
                                  //                 TextInputType.number,
                                  //             inputFormatters: [
                                  //               FilteringTextInputFormatter
                                  //                   .digitsOnly,
                                  //               LengthLimitingTextInputFormatter(
                                  //                 2,
                                  //               ),
                                  //             ],
                                  //             decoration: InputDecoration(
                                  //               hintText:
                                  //                   'Masukkan ID Device (1-99)',
                                  //               border: OutlineInputBorder(
                                  //                 borderRadius:
                                  //                     BorderRadius.circular(8),
                                  //               ),
                                  //               contentPadding:
                                  //                   const EdgeInsets.symmetric(
                                  //                     horizontal: 12,
                                  //                     vertical: 12,
                                  //                   ),
                                  //             ),
                                  //           ),
                                  //         ],
                                  //       ),
                                  //     ),
                                  //     const SizedBox(width: 16),
                                  //     Expanded(
                                  //       child: Column(
                                  //         crossAxisAlignment:
                                  //             CrossAxisAlignment.start,
                                  //         children: [
                                  //           const Text(
                                  //             'Kontrol Motor',
                                  //             style: TextStyle(
                                  //               fontSize: 16,
                                  //               fontWeight: FontWeight.w600,
                                  //             ),
                                  //           ),
                                  //           const SizedBox(height: 8),
                                  //           Obx(
                                  //             () => Container(
                                  //               padding:
                                  //                   const EdgeInsets.symmetric(
                                  //                     horizontal: 16,
                                  //                     vertical: 12,
                                  //                   ),
                                  //               decoration: BoxDecoration(
                                  //                 border: Border.all(
                                  //                   color: Colors.grey.shade300,
                                  //                 ),
                                  //                 borderRadius:
                                  //                     BorderRadius.circular(8),
                                  //               ),
                                  //               child: Row(
                                  //                 children: [
                                  //                   Switch(
                                  //                     value: controller
                                  //                         .controlMotor
                                  //                         .value,
                                  //                     onChanged: controller
                                  //                         .setControlMotor,
                                  //                     activeColor:
                                  //                         AppColors.primary,
                                  //                   ),
                                  //                   const SizedBox(width: 8),
                                  //                   Text(
                                  //                     controller
                                  //                             .controlMotor
                                  //                             .value
                                  //                         ? 'ON'
                                  //                         : 'OFF',
                                  //                     style: TextStyle(
                                  //                       fontWeight:
                                  //                           FontWeight.bold,
                                  //                       color:
                                  //                           controller
                                  //                               .controlMotor
                                  //                               .value
                                  //                           ? Colors.green
                                  //                           : Colors.red,
                                  //                     ),
                                  //                   ),
                                  //                 ],
                                  //               ),
                                  //             ),
                                  //           ),
                                  //         ],
                                  //       ),
                                  //     ),
                                  //   ],
                                  // ),
                                  const SizedBox(height: 20),

                                  // Speed and Duration
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Kecepatan (RPM) *',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            TextFormField(
                                              controller: controller.speedCtrl,
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
                                                    'Masukkan kecepatan (1-2000)',
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
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
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Durasi (detik) *',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            TextFormField(
                                              controller:
                                                  controller.durationCtrl,
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
                                                    'Masukkan durasi (1-7200)',
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
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
                                    ],
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
                                          fontWeight: FontWeight.w600,
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
                                                      !controller.rotation.value
                                                      ? AppColors.primary
                                                            .withOpacity(0.1)
                                                      : Colors.transparent,
                                                  border: Border.all(
                                                    color:
                                                        !controller
                                                            .rotation
                                                            .value
                                                        ? AppColors.primary
                                                        : Colors.grey.shade300,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: RadioListTile<bool>(
                                                  title: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.rotate_left,
                                                        color:
                                                            !controller
                                                                .rotation
                                                                .value
                                                            ? AppColors.primary
                                                            : Colors.grey,
                                                      ),
                                                      const SizedBox(width: 8),
                                                      const Text(
                                                        'CCW (Berlawanan Jarum Jam)',
                                                      ),
                                                    ],
                                                  ),
                                                  value: false,
                                                  groupValue:
                                                      controller.rotation.value,
                                                  onChanged: (value) =>
                                                      controller.setRotation(
                                                        value!,
                                                      ),
                                                  activeColor:
                                                      AppColors.primary,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color:
                                                      controller.rotation.value
                                                      ? AppColors.primary
                                                            .withOpacity(0.1)
                                                      : Colors.transparent,
                                                  border: Border.all(
                                                    color:
                                                        controller
                                                            .rotation
                                                            .value
                                                        ? AppColors.primary
                                                        : Colors.grey.shade300,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: RadioListTile<bool>(
                                                  title: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.rotate_right,
                                                        color:
                                                            controller
                                                                .rotation
                                                                .value
                                                            ? AppColors.primary
                                                            : Colors.grey,
                                                      ),
                                                      const SizedBox(width: 8),
                                                      const Text(
                                                        'CW (Searah Jarum Jam)',
                                                      ),
                                                    ],
                                                  ),
                                                  value: true,
                                                  groupValue:
                                                      controller.rotation.value,
                                                  onChanged: (value) =>
                                                      controller.setRotation(
                                                        value!,
                                                      ),
                                                  activeColor:
                                                      AppColors.primary,
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
                                        child: Obx(
                                          () => ElevatedButton.icon(
                                            onPressed:
                                                controller.isLoading.value
                                                ? null
                                                : controller.sendWalkerCommand,
                                            icon: controller.isLoading.value
                                                ? const SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child:
                                                        CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          color: Colors.white,
                                                        ),
                                                  )
                                                : const Icon(Icons.play_arrow),
                                            label: const Text('Mulai Walker'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                              foregroundColor: Colors.white,
                                              minimumSize: const Size(
                                                double.infinity,
                                                50,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: controller.stopWalker,
                                          icon: const Icon(Icons.stop),
                                          label: const Text('Stop Walker'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white,
                                            minimumSize: const Size(
                                              double.infinity,
                                              50,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: controller.resetForm,
                                          icon: const Icon(Icons.refresh),
                                          label: const Text('Reset Form'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.orange,
                                            foregroundColor: Colors.white,
                                            minimumSize: const Size(
                                              double.infinity,
                                              50,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
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

                      const SizedBox(height: 24),

                      // Information Card
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          children: [
                            // Info Header
                            Container(
                              height: 50,
                              width: double.infinity,
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  'Informasi Penggunaan',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            // Info Content
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildInfoRow(
                                    'Header',
                                    'SHWIPB (Fixed)',
                                    Icons.info,
                                  ),
                                  _buildInfoRow(
                                    'ID Device',
                                    '1-99 (Angka)',
                                    Icons.devices,
                                  ),
                                  _buildInfoRow(
                                    'Control Motor',
                                    'ON/OFF (Boolean)',
                                    Icons.power_settings_new,
                                  ),
                                  _buildInfoRow(
                                    'Rotation',
                                    'CW/CCW (Boolean)',
                                    Icons.rotate_90_degrees_ccw,
                                  ),
                                  _buildInfoRow(
                                    'Speed',
                                    '1-2000 RPM (Number)',
                                    Icons.speed,
                                  ),
                                  _buildInfoRow(
                                    'Duration',
                                    '1-7200 detik (Number)',
                                    Icons.timer,
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
}
